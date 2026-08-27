from __future__ import annotations

from datetime import datetime, timezone

from bson import ObjectId
from pymongo import MongoClient

from app.core.config import settings
from app.schemas.mobile_user import MobileUserCreate, MobileUserRecord

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

        data = payload.model_dump()
        data["roleId"] = "user"
        data['roleLabel'] = "User"

        existing = self.collection.find_one({"email": payload.email.lower()})
        if existing:
            existing["_id"] = str(existing["_id"])
            existing["id"] = existing.pop("_id")
            return MobileUserRecord(**existing)

        record = MobileUserRecord(
            **data,
            id=str(object_id),
            createdAt=now,
            updatedAt=now,
        )

        document = record.model_dump(mode="python")
        document["_id"] = object_id
        document["email"] = document["email"].lower()

        self.collection.insert_one(document)
        return record

store = MongoMobileUserStore()
