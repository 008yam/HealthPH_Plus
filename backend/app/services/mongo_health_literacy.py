from __future__ import annotations

from datetime import datetime, timezone

from pymongo import MongoClient, DESCENDING

from app.core.config import settings
from app.schemas.health_literacy import (
    HealthLiteracyAnalyticsEvent,
    HealthLiteracyContent,
)


class MongoHealthLiteracyStore:
    def __init__(self) -> None:
        if not settings.mongo_uri:
            raise RuntimeError("MONGO_URI is not configured.")

        self.client = MongoClient(
            settings.mongo_uri,
            serverSelectionTimeoutMS=5000,
        )
        self.db = self.client[settings.mongo_db_name]
        self.content_collection = self.db[
            settings.mongo_health_literacy_content_collection
        ]
        self.analytics_collection = self.db[
            settings.mongo_health_literacy_analytics_collection
        ]

    def list_health_literacy(
        self,
        *,
        content_type: str | None = None,
        language: str | None = None,
        q: str | None = None,
        tag: str | None = None,
    ) -> list[HealthLiteracyContent]:
        query = {
            "isArchived": {"$ne": True},
            "$or": [
                {"publishToMobile": True},
                {"publishToWebsite": True},
                {"publishToMobile": {"$exists": False}},
            ],
        }

        if content_type:
            query["contentType"] = content_type

        if language:
            query["language"] = language

        if tag:
            query["tags"] = {"$in": [tag]}

        if q:
            query["$or"] = [
                {"title": {"$regex": q, "$options": "i"}},
                {"description": {"$regex": q, "$options": "i"}},
                {"tags": {"$regex": q, "$options": "i"}},
                {"topics": {"$regex": q, "$options": "i"}},
                {"diseases": {"$regex": q, "$options": "i"}},
            ]

        rows = self.content_collection.find(query).sort("updatedAt", DESCENDING)
        return [self._doc_to_content(row) for row in rows]

    def record_health_literacy_event(
        self,
        event: HealthLiteracyAnalyticsEvent,
    ) -> None:
        document = event.model_dump(mode="python")
        document["createdAt"] = datetime.now(timezone.utc)
        self.analytics_collection.insert_one(document)

    def _doc_to_content(self, document: dict) -> HealthLiteracyContent:
        document = dict(document)
        mongo_id = document.pop("_id", None)

        document["id"] = str(document.get("id") or mongo_id)
        document["contentType"] = document.get("contentType") or "article"
        document["title"] = document.get("title") or "Untitled"
        document["description"] = document.get("description") or ""

        return HealthLiteracyContent(**document)


store = MongoHealthLiteracyStore()