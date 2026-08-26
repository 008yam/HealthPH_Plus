from __future__ import annotations

from datetime import datetime, timezone
from bson import ObjectId
from pymongo import MongoClient, DESCENDING

from app.core.config import settings
from app.schemas.self_report import SelfReportCreate, SelfReportRecord


class MongoSelfReportStore:
    def __init__(self) -> None:
        if not settings.mongo_uri:
            raise RuntimeError("MONGO_URI is not configured.")

        self.client = MongoClient(settings.mongo_uri)
        self.db = self.client[settings.mongo_db_name]
        self.collection = self.db[settings.mongo_self_reports_collection]

    def create_self_report(self, payload: SelfReportCreate) -> SelfReportRecord:
        now = datetime.now(timezone.utc)
        object_id = ObjectId()

        record_data = payload.model_dump(exclude={"createdAt"})

        record = SelfReportRecord(
            **record_data,
            id=str(object_id),
            status="submitted",
            createdAt=payload.createdAt or now,
            updatedAt=now,
            syncedAt=now,
        )

        document = record.model_dump(mode="python")
        document["_id"] = object_id

        self.collection.insert_one(document)
        return record

    def list_self_reports(
            self,
            *,
            user_id: str | None = None,
            email: str | None = None,
    ) -> list[SelfReportRecord]:
        query = {}

        if user_id:
            query["reporter.userId"] = user_id

        if email:
            query["reporter.email"] = email

        rows = self.collection.find(query).sort("createdAt", DESCENDING)
        return [self._doc_to_record(row) for row in rows]

    def _doc_to_record(self, document: dict) -> SelfReportRecord:
        document = dict(document)
        document.pop("_id", None)
        return SelfReportRecord(**document)


store = MongoSelfReportStore()
