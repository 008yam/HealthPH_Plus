from __future__ import annotations

import csv
from datetime import datetime, timezone
from io import StringIO

from bson import ObjectId
from pymongo import MongoClient, DESCENDING

from app.core.config import settings
from app.schemas.self_report import SelfReportCreate,SelfReportMapPin, SelfReportRecord

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


    def self_report_map_pins(self) -> list[SelfReportMapPin]:
        rows = self.collection.find({}).sort("createdAt", DESCENDING)
        pins: list[SelfReportMapPin] = []

        for row in rows:
            report = self._doc_to_record(row)

            lat = report.location.latitude or 12.8797
            lng = report.location.longitude or 121.7740
            created = report.createdAt

            updated = (
                f"Self-reported on {created.month}/{created.day}/{created.year} "
                f"at {created.hour:02d}:{created.minute:02d}"
            )

            pins.append(
                SelfReportMapPin(
                    id=report.id,
                    name=(
                        f"{report.location.barangayName}, "
                        f"{report.location.cityName}, "
                        f"{report.location.provinceName}"
                    ),
                    diseaseId=report.possibleConditionId,
                    disease=report.possibleConditionLabel,
                    reports=1,
                    updated=updated,
                    lat=lat,
                    lng=lng,
                    tagIds=report.symptomIds,
                    tags=report.symptomLabels,
                    pinAccuracy=report.location.pinAccuracy,
                    geocodedAddress=report.location.geocodedAddress,
                )
            )

        return pins

    def self_reports_csv(self) -> str:
        output = StringIO()
        writer = csv.writer(output)

        writer.writerow([
            "id",
            "created_at",
            "reporter_type",
            "role_id",
            "role_label",
            "email",
            "region_code",
            "region_name",
            "province_name",
            "city_name",
            "barangay_name",
            "symptom_ids",
            "symptom_labels",
            "possible_condition_id",
            "possible_condition_label",
            "notes",
            "latitude",
            "longitude",
            "geocoded_address",
            "pin_accuracy",
            "status",
        ])

        rows = self.collection.find({}).sort("createdAt", DESCENDING)

        for row in rows:
            report = self._doc_to_record(row)

            writer.writerow([
                report.id,
                report.createdAt.isoformat(),
                report.reporter.reporterType,
                report.reporter.roleId,
                report.reporter.roleLabel,
                report.reporter.email,
                report.location.regionCode,
                report.location.regionName,
                report.location.provinceName,
                report.location.cityName,
                report.location.barangayName,
                "|".join(report.symptomIds),
                "|".join(report.symptomLabels),
                report.possibleConditionId,
                report.possibleConditionLabel,
                report.notes,
                report.location.latitude,
                report.location.longitude,
                report.location.geocodedAddress,
                report.location.pinAccuracy,
                report.status,
            ])

        return output.getvalue()

store = MongoSelfReportStore()