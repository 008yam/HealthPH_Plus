from __future__ import annotations

import csv
from datetime import datetime, timezone
from io import StringIO
from uuid import uuid4

from app.schemas.health_literacy import (
    HealthLiteracyAnalyticsEvent,
    HealthLiteracyContent,
)
from app.schemas.self_report import SelfReportCreate, SelfReportMapPin, SelfReportRecord


class InMemoryDataStore:
    """Temporary repository.

    Replace this class with MongoDB-backed repositories when the shared schema is
    finalized. Keeping the API surface here makes that swap straightforward.
    """

    def __init__(self) -> None:
        now = datetime.now(timezone.utc)
        self.health_literacy_contents: list[HealthLiteracyContent] = [
            HealthLiteracyContent(
                id="article_lung_health_latest_data",
                contentType="article",
                title="Lung Health in the Philippines - Latest Data",
                description=(
                    "Respiratory diseases remain a major public health concern "
                    "in the Philippines."
                ),
                source="RMCI Medical Staff - August 5, 2025",
                author="RMCI Medical Staff",
                externalUrl=(
                    "https://www.rmci.com.ph/lung-health-in-the-philippines-latest-data/"
                ),
                imageUrl="assets/images/lunghealtharticle.png",
                tags=["community", "pneumonia", "tuberculosis"],
                topics=["lung health", "public health"],
                diseases=["pneumonia", "tuberculosis"],
                createdAt=now,
                updatedAt=now,
            ),
            HealthLiteracyContent(
                id="article_protect_your_lungs",
                contentType="article",
                title="Protect Your Lungs from Common Respiratory Issues",
                description=(
                    "Learn how to prevent common respiratory issues and protect your lungs."
                ),
                source="Doctor Anywhere Team - Community Health",
                author="Doctor Anywhere Team",
                externalUrl=(
                    "https://www.doctoranywhere.ph/post/prevent-common-respiratory-issues"
                ),
                imageUrl="assets/images/protectyourlungs.png",
                tags=["lungs", "prevention", "wellness"],
                topics=["prevention", "lung health"],
                diseases=["respiratory"],
                createdAt=now,
                updatedAt=now,
            ),
            HealthLiteracyContent(
                id="fact_steam_inhalation",
                contentType="fact_check",
                title="Steam inhalation cures respiratory infections.",
                description=(
                    "Steam may relieve congestion, but it does not cure infections."
                ),
                source="HealthPH+ Fact Checker",
                author="HealthPH+ Team",
                claim="Steam inhalation cures respiratory infections.",
                verdict="Needs Context",
                explanation=(
                    "Steam may relieve congestion, but it does not cure infections."
                ),
                tags=["respiratory", "fact-check", "infection"],
                topics=["misinformation", "respiratory health"],
                diseases=["respiratory"],
                createdAt=now,
                updatedAt=now,
            ),
        ]
        self.analytics_events: list[HealthLiteracyAnalyticsEvent] = []
        self.self_reports: list[SelfReportRecord] = []

    def list_health_literacy(
        self,
        *,
        content_type: str | None = None,
        language: str | None = None,
        q: str | None = None,
        tag: str | None = None,
    ) -> list[HealthLiteracyContent]:
        items = [
            item
            for item in self.health_literacy_contents
            if item.isPublished and item.publishToMobile
        ]

        if content_type:
            items = [item for item in items if item.contentType == content_type]

        if language:
            items = [item for item in items if item.language == language]

        if tag:
            tag_lower = tag.lower()
            items = [
                item
                for item in items
                if any(item_tag.lower() == tag_lower for item_tag in item.tags)
            ]

        if q:
            query = q.lower()
            items = [
                item
                for item in items
                if query in item.title.lower()
                or query in item.description.lower()
                or any(query in item_tag.lower() for item_tag in item.tags)
            ]

        return items

    def record_health_literacy_event(
        self,
        event: HealthLiteracyAnalyticsEvent,
    ) -> None:
        self.analytics_events.append(event)

    def create_self_report(self, payload: SelfReportCreate) -> SelfReportRecord:
        now = datetime.now(timezone.utc)
        created_at = payload.createdAt or now
        data = payload.model_dump()
        data["createdAt"] = created_at

        record = SelfReportRecord(
            **data,
            id=str(uuid4()),
            status="submitted",
            updatedAt=now,
            syncedAt=now,
        )
        self.self_reports.insert(0, record)
        return record

    def list_self_reports(
        self,
        *,
        user_id: str | None = None,
        email: str | None = None,
    ) -> list[SelfReportRecord]:
        reports = self.self_reports

        if user_id:
            reports = [
                report for report in reports if report.reporter.userId == user_id
            ]

        if email:
            email_lower = email.lower()
            reports = [
                report
                for report in reports
                if (report.reporter.email or "").lower() == email_lower
            ]

        return reports

    def self_report_map_pins(self) -> list[SelfReportMapPin]:
        pins: list[SelfReportMapPin] = []

        for report in self.self_reports:
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
        writer.writerow(
            [
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
            ]
        )

        for report in self.self_reports:
            writer.writerow(
                [
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
                ]
            )

        return output.getvalue()


store = InMemoryDataStore()
