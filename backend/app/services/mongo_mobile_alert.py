from __future__ import annotations

import base64
import json
from datetime import datetime, timedelta, timezone

from bson import ObjectId
from fastapi import HTTPException
from pymongo import MongoClient

from app.core.config import settings
from app.schemas.mobile_alert import (
    MobileAlertDetail,
    MobileAlertReadResult,
    MobileAlertRecord,
    MobileAlertsPage,
)


AUTOMATED_SOURCE = "automated_regional_summary"
PREPARED_DELIVERY_STATUS = "Prepared"
VISIBLE_ALERT_STATUSES = ("Published", "Prepared")
PH_TIMEZONE = timezone(timedelta(hours=8))

REGION_NAMES = {
    "NCR": "National Capital Region",
    "I": "Ilocos Region",
    "II": "Cagayan Valley",
    "III": "Central Luzon",
    "IVA": "CALABARZON",
    "IVB": "MIMAROPA",
    "V": "Bicol Region",
    "CAR": "Cordillera Administrative Region",
    "VI": "Western Visayas",
    "VII": "Central Visayas",
    "VIII": "Eastern Visayas",
    "IX": "Zamboanga Peninsula",
    "X": "Northern Mindanao",
    "XI": "Davao Region",
    "XII": "SOCCSKSARGEN",
    "XIII": "Caraga",
    "BARMM": "Bangsamoro Autonomous Region in Muslim Mindanao",
}


class MongoMobileAlertStore:
    def __init__(self) -> None:
        if not settings.mongo_uri:
            raise RuntimeError("MONGO_URI is not configured.")

        self.client = MongoClient(settings.mongo_uri)
        self.db = self.client[settings.mongo_db_name]
        self.alerts = self.db[settings.mongo_regional_alerts_collection]
        self.deliveries = self.db[
            settings.mongo_mobile_notification_deliveries_collection
        ]
        self.mobile_users = self.db[settings.mongo_mobile_users_collection]

    def list_alerts(
        self,
        *,
        mobile_user_id: str,
        cursor: str | None,
        limit: int,
    ) -> MobileAlertsPage:
        self._require_mobile_user(mobile_user_id)
        assignments = self._visible_assignments(mobile_user_id)
        items = [
            (self._serialize_alert(alert, delivery), delivery)
            for alert, delivery in assignments
        ]
        items.sort(
            key=lambda item: (item[0].publishedAt or "", item[0].id),
            reverse=True,
        )

        if cursor:
            cursor_key = self._decode_cursor(cursor)
            items = [
                item
                for item in items
                if (item[0].publishedAt or "", item[0].id) < cursor_key
            ]

        page = items[:limit]
        next_cursor = None
        if len(items) > limit and page:
            last = page[-1][0]
            next_cursor = self._encode_cursor(last.publishedAt or "", last.id)

        unread_count = sum(
            1 for _alert, delivery in assignments if not delivery.get("readAt")
        )
        return MobileAlertsPage(
            items=[item for item, _delivery in page],
            nextCursor=next_cursor,
            unreadCount=unread_count,
        )

    def get_alert(self, *, mobile_user_id: str, alert_id: str) -> MobileAlertDetail:
        self._require_mobile_user(mobile_user_id)
        alert, delivery = self._find_assignment(mobile_user_id, alert_id)
        return MobileAlertDetail(item=self._serialize_alert(alert, delivery))

    def mark_read(
        self,
        *,
        mobile_user_id: str,
        alert_id: str,
    ) -> MobileAlertReadResult:
        self._require_mobile_user(mobile_user_id)
        alert, delivery = self._find_assignment(mobile_user_id, alert_id)

        if not delivery.get("readAt"):
            self.deliveries.update_one(
                {
                    "_id": delivery["_id"],
                    "$or": [
                        {"readAt": None},
                        {"readAt": {"$exists": False}},
                    ],
                },
                {"$set": {"readAt": datetime.now(timezone.utc)}},
            )
            delivery = self.deliveries.find_one({"_id": delivery["_id"]})

        assignments = self._visible_assignments(mobile_user_id)
        unread_count = sum(
            1 for _alert, candidate in assignments if not candidate.get("readAt")
        )
        return MobileAlertReadResult(
            item=self._serialize_alert(alert, delivery),
            unreadCount=unread_count,
        )

    def _require_mobile_user(self, mobile_user_id: str) -> None:
        user = self.mobile_users.find_one(
            {
                "id": mobile_user_id,
                "source": "mobile_registration",
                "roleId": "user",
            }
        )
        if not user:
            raise HTTPException(status_code=401, detail="Mobile user not found")

    def _visible_assignments(self, mobile_user_id: str) -> list[tuple[dict, dict]]:
        assignments: list[tuple[dict, dict]] = []
        deliveries = self.deliveries.find(
            {
                "mobileUserId": mobile_user_id,
                "status": PREPARED_DELIVERY_STATUS,
            }
        )

        for delivery in deliveries:
            alert_id = delivery.get("alertId")
            alert = self.alerts.find_one(
                {
                    "_id": alert_id,
                    "source": AUTOMATED_SOURCE,
                    "status": {"$in": VISIBLE_ALERT_STATUSES},
                }
            )
            if alert:
                assignments.append((alert, delivery))

        return assignments

    def _find_assignment(
        self,
        mobile_user_id: str,
        alert_id: str,
    ) -> tuple[dict, dict]:
        if not ObjectId.is_valid(alert_id):
            raise HTTPException(status_code=404, detail="Alert not found")

        object_id = ObjectId(alert_id)
        alert = self.alerts.find_one(
            {
                "_id": object_id,
                "source": AUTOMATED_SOURCE,
                "status": {"$in": VISIBLE_ALERT_STATUSES},
            }
        )
        delivery = self.deliveries.find_one(
            {
                "alertId": object_id,
                "mobileUserId": mobile_user_id,
                "status": PREPARED_DELIVERY_STATUS,
            }
        )

        if not alert or not delivery:
            raise HTTPException(status_code=404, detail="Alert not found")

        return alert, delivery

    def _serialize_alert(self, alert: dict, delivery: dict) -> MobileAlertRecord:
        trigger = alert.get("trigger") or {}
        snapshot = trigger.get("summarySnapshot") or {}
        symptom_keys = trigger.get("includedSymptomKeys") or []
        symptom_labels = snapshot.get("symptomKeyLabels") or {}
        symptom_counts = snapshot.get("symptomKeyCounts") or {}
        legacy_labels = trigger.get("includedSymptomLabels") or []
        region = str(alert.get("region") or "")

        symptoms = []
        for index, key in enumerate(symptom_keys):
            fallback_label = legacy_labels[index] if index < len(legacy_labels) else key
            symptoms.append(
                {
                    "symptomKey": str(key),
                    "label": str(symptom_labels.get(key) or fallback_label),
                    "reportCount": self._integer(symptom_counts.get(key)),
                }
            )

        comparison = trigger.get("comparison")
        return MobileAlertRecord(
            id=str(alert.get("_id")),
            region=region,
            regionName=str(
                alert.get("regionName") or REGION_NAMES.get(region, region)
            ),
            title=str(alert.get("title") or "Regional self-report alert"),
            message=str(alert.get("message") or ""),
            reportCount=self._integer(trigger.get("reportCount")),
            threshold=self._integer(trigger.get("threshold")),
            comparison="gt" if comparison == ">" else comparison,
            windowMinutes=self._integer(trigger.get("intervalMinutes")),
            windowStart=self._date_iso(trigger.get("windowStart")),
            windowEnd=self._date_iso(trigger.get("windowEnd")),
            symptoms=symptoms,
            publishedAt=self._published_at(alert, delivery),
            readAt=self._date_iso(delivery.get("readAt")),
        )

    def _published_at(self, alert: dict, delivery: dict) -> str | None:
        return self._date_iso(
            delivery.get("publishedAt")
            or alert.get("preparedAt")
            or alert.get("createdAt")
            or delivery.get("createdAt")
        )

    def _date_iso(self, value: object) -> str | None:
        if isinstance(value, str):
            try:
                value = datetime.fromisoformat(value.strip().replace("Z", "+00:00"))
            except ValueError:
                return None

        if not isinstance(value, datetime):
            return None

        aware = value.replace(tzinfo=PH_TIMEZONE) if value.tzinfo is None else value
        return aware.astimezone(timezone.utc).isoformat().replace("+00:00", "Z")

    def _integer(self, value: object, default: int = 0) -> int:
        try:
            return int(value)
        except (TypeError, ValueError):
            return default

    def _encode_cursor(self, published_at: str, alert_id: str) -> str:
        payload = json.dumps(
            {"publishedAt": published_at, "id": alert_id},
            separators=(",", ":"),
        ).encode("utf-8")
        return base64.urlsafe_b64encode(payload).decode("ascii").rstrip("=")

    def _decode_cursor(self, cursor: str) -> tuple[str, str]:
        try:
            padding = "=" * (-len(cursor) % 4)
            value = json.loads(
                base64.urlsafe_b64decode((cursor + padding).encode("ascii"))
            )
            published_at = value["publishedAt"]
            alert_id = value["id"]
            if not isinstance(published_at, str) or not isinstance(alert_id, str):
                raise ValueError
            if published_at and not self._date_iso(published_at):
                raise ValueError
            return published_at, alert_id
        except (
            KeyError,
            TypeError,
            ValueError,
            UnicodeDecodeError,
            json.JSONDecodeError,
        ) as error:
            raise HTTPException(status_code=400, detail="Invalid alert cursor") from error


store = MongoMobileAlertStore()
