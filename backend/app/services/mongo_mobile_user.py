from __future__ import annotations

import hashlib
import hmac
import secrets
from fastapi import HTTPException

from datetime import datetime, timezone

from bson import ObjectId
from pymongo import MongoClient, ReturnDocument

from app.core.config import settings
from app.schemas.mobile_user import MobileUserCreate, MobileUserLogin, MobileUserRecord
from app.services.id_sequence import next_readable_id


class MongoMobileUserStore:
    def __init__(self) -> None:
        if not settings.mongo_uri:
            raise RuntimeError("MONGO_URI is not configured.")

        self.client = MongoClient(settings.mongo_uri)
        self.db = self.client[settings.mongo_db_name]
        self.collection = self.db[settings.mongo_mobile_users_collection]

    def create_mobile_users(self, payload: MobileUserCreate) -> MobileUserRecord:
        now = datetime.now(timezone.utc)
        object_id = ObjectId()
        email = payload.email.strip().lower()

        data = payload.model_dump(exclude={"password"})
        data["roleId"] = "user"
        data["roleLabel"] = "User"
        data["email"] = email

        existing = self.collection.find_one({"email": email})
        if existing:
            update_data = {
                **data,
                "updatedAt": now,
            }

            if not existing.get("passwordHash"):
                update_data["passwordHash"] = self._hash_password(payload.password)
            elif not self._verify_password(payload.password, existing["passwordHash"]):
                raise HTTPException(
                    status_code=409,
                    detail="Email already exists. Please login using the original password.",
                )

            self.collection.update_one(
                {"_id": existing["_id"]},
                {"$set": update_data},
            )

            updated = self.collection.find_one({"_id": existing["_id"]})
            return self._record_from_document(updated)

        user_id = next_readable_id(
            self.db,
            key="mobile_users",
            prefix="MUSER",
        )

        record = MobileUserRecord(
            **data,
            id=user_id,
            createdAt=now,
            updatedAt=now,
        )

        document = record.model_dump(mode="python")
        document["_id"] = object_id
        document["passwordHash"] = self._hash_password(payload.password)

        self.collection.insert_one(document)
        return record

    def login_mobile_user(self, payload: MobileUserLogin) -> MobileUserRecord:
        user = self.collection.find_one({"email": payload.email.strip().lower()})

        if not user or not self._verify_password(
            payload.password,
            user.get("passwordHash", ""),
        ):
            raise HTTPException(status_code=401, detail="Invalid email or password")

        return self._record_from_document(user)

    def update_mobile_user_language(self, user_id: str, language: str) -> MobileUserRecord:
        clean_language = language.strip() or "English"
        now = datetime.now(timezone.utc)

        updated = self.collection.find_one_and_update(
            {"id": user_id},
            {"$set": {"language": clean_language, "updatedAt": now}},
            return_document=ReturnDocument.AFTER,
        )

        if not updated:
            raise HTTPException(status_code=404, detail="Mobile user not found")

        return self._record_from_document(updated)

    def update_mobile_user_pin(
            self,
            user_id: str,
            pin: str,
            current_password: str,
    ) -> None:
        document = self.collection.find_one({"id": user_id})

        if document is None:
            raise HTTPException(status_code=404, detail="Mobile user not found.")

        password_hash = document.get("passwordHash", "")

        if not self._verify_password(current_password, password_hash):
            raise HTTPException(
                status_code=401,
                detail="Current password is incorrect.",
            )

        result = self.collection.update_one(
            {"id": user_id},
            {
                "$set": {
                    "pins": self._hash_password(pin),
                    "updatedAt": datetime.now(timezone.utc),
                }
            },
        )

        if result.matched_count == 0:
            raise HTTPException(status_code=404, detail="Mobile user not found.")

    def _record_from_document(self, document: dict | None) -> MobileUserRecord:
        if document is None:
            raise HTTPException(status_code=404, detail="Mobile user not found")

        data = dict(document)
        mongo_id = data.pop("_id", None)
        data["id"] = str(data.get("id") or mongo_id or "")
        data.pop("passwordHash", None)
        data.pop("pins", None)
        data["language"] = str(data.get("language") or "English")

        return MobileUserRecord(**data)

    def _hash_password(self, password: str) -> str:
        salt = secrets.token_hex(16)
        password_hash = hashlib.pbkdf2_hmac(
            "sha256",
            password.encode("utf-8"),
            salt.encode("utf-8"),
            100000,
        ).hex()
        return f"{salt}:{password_hash}"

    def _verify_password(self, password: str, stored_password: str) -> bool:
        try:
            salt, saved_hash = stored_password.split(":", 1)
        except ValueError:
            return False

        password_hash = hashlib.pbkdf2_hmac(
            "sha256",
            password.encode("utf-8"),
            salt.encode("utf-8"),
            100000,
        ).hex()

        return hmac.compare_digest(password_hash, saved_hash)


store = MongoMobileUserStore()
