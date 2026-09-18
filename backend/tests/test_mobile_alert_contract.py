from __future__ import annotations

import os
import unittest
from datetime import datetime, timezone
from unittest.mock import MagicMock

from bson import ObjectId


os.environ["MONGO_URI"] = "mongodb://127.0.0.1:27017"
os.environ.setdefault("SECRET_KEY", "mobile-alert-contract-test-secret")
os.environ.setdefault("ALGORITHM", "HS256")

from app.core.mobile_auth import (  # noqa: E402
    create_mobile_access_token,
    decode_mobile_token,
)
from app.services.mongo_mobile_alert import MongoMobileAlertStore  # noqa: E402


class MobileAlertContractTests(unittest.TestCase):
    def setUp(self) -> None:
        self.store = MongoMobileAlertStore.__new__(MongoMobileAlertStore)
        self.store.mobile_users = MagicMock()
        self.store.alerts = MagicMock()
        self.store.deliveries = MagicMock()

        self.user_id = "MUSER-000001"
        self.alert_id = ObjectId()
        self.store.mobile_users.find_one.return_value = {
            "id": self.user_id,
            "source": "mobile_registration",
            "roleId": "user",
        }
        self.store.deliveries.find.return_value = [
            {
                "_id": ObjectId(),
                "alertId": self.alert_id,
                "mobileUserId": self.user_id,
                "status": "Prepared",
                "publishedAt": datetime(2026, 9, 17, tzinfo=timezone.utc),
            }
        ]
        self.store.alerts.find_one.return_value = {
            "_id": self.alert_id,
            "source": "automated_regional_summary",
            "status": "Published",
            "region": "NCR",
            "title": "Regional self-report alert: NCR",
            "message": "Six reports were recorded.",
            "trigger": {
                "reportCount": 6,
                "threshold": 5,
                "comparison": ">",
                "intervalMinutes": 30,
                "includedSymptomKeys": ["literal:Fever"],
                "summarySnapshot": {
                    "symptomKeyLabels": {"literal:Fever": "Fever"},
                    "symptomKeyCounts": {"literal:Fever": 6},
                },
            },
        }

    def test_mobile_jwt_round_trip_preserves_user_id(self) -> None:
        token = create_mobile_access_token(self.user_id)
        claims = decode_mobile_token(token)

        self.assertEqual(claims["sub"], self.user_id)
        self.assertEqual(claims["aud"], "mobile")
        self.assertEqual(claims["typ"], "mobile_access")

    def test_list_returns_only_the_users_prepared_assignment(self) -> None:
        page = self.store.list_alerts(
            mobile_user_id=self.user_id,
            cursor=None,
            limit=20,
        )

        self.assertEqual(page.unreadCount, 1)
        self.assertEqual(len(page.items), 1)
        self.assertEqual(page.items[0].id, str(self.alert_id))
        self.assertEqual(page.items[0].regionName, "National Capital Region")
        self.assertEqual(page.items[0].reportCount, 6)
        self.assertEqual(page.items[0].symptoms[0].label, "Fever")
        self.store.deliveries.find.assert_called_once_with(
            {
                "mobileUserId": self.user_id,
                "status": "Prepared",
            }
        )


if __name__ == "__main__":
    unittest.main()
