from __future__ import annotations

from datetime import datetime, timezone
from typing import Any
from uuid import uuid4

from fastapi import HTTPException
from pymongo import DESCENDING, MongoClient

from app.core.config import settings
from app.schemas.sentiment_survey import SentimentSurveyResponseCreate


class MongoSentimentSurveyStore:
    def __init__(self) -> None:
        if not settings.mongo_uri:
            raise RuntimeError("MONGO_URI is not configured.")

        self.client = MongoClient(settings.mongo_uri)
        self.db = self.client[settings.mongo_db_name]
        self.surveys = self.db[settings.mongo_sentiment_surveys_collection]
        self.responses = self.db[
            settings.mongo_sentiment_survey_responses_collection
        ]

    def list_public_surveys(self, platform: str = "mobile") -> list[dict]:
        normalized_platform = platform.strip().lower()

        if normalized_platform not in {"mobile", "website"}:
            raise HTTPException(
                status_code=400,
                detail="platform must be mobile or website",
            )

        publish_field = (
            "publishToMobile"
            if normalized_platform == "mobile"
            else "publishToWebsite"
        )

        now = datetime.now(timezone.utc)

        query = {
            publish_field: True,
            "scheduledAt": {"$ne": ""},
        }

        rows = self.surveys.find(query).sort(
            [
                ("scheduledAt", DESCENDING),
                ("createdAt", DESCENDING),
            ]
        )

        surveys: list[dict] = []

        for row in rows:
            survey = self._serialize_survey(row, now=now)

            if survey["status"] == "Published":
                surveys.append(survey)

        return surveys

    def submit_response(
        self,
        *,
        survey_id: str,
        payload: SentimentSurveyResponseCreate,
    ) -> None:
        normalized_platform = payload.platform.strip().lower()

        if normalized_platform not in {"mobile", "website"}:
            raise HTTPException(
                status_code=400,
                detail="platform must be mobile or website",
            )

        if not payload.answers:
            raise HTTPException(
                status_code=400,
                detail="answers must not be empty",
            )

        publish_field = (
            "publishToMobile"
            if normalized_platform == "mobile"
            else "publishToWebsite"
        )

        survey = self.surveys.find_one({
            "id": survey_id,
            publish_field: True,
        })

        if not survey:
            raise HTTPException(
                status_code=404,
                detail="Published Sentiment Pulse survey not found",
            )

        serialized = self._serialize_survey(
            survey,
            now=datetime.now(timezone.utc),
        )

        if serialized["status"] != "Published":
            raise HTTPException(
                status_code=404,
                detail="Published Sentiment Pulse survey not found",
            )

        now = datetime.now(timezone.utc)
        response_id = str(uuid4())

        self.responses.insert_one({
            "id": response_id,
            "surveyId": survey_id,
            "answers": payload.answers,
            "platform": normalized_platform,
            "visitorId": payload.visitorId,
            "region": payload.region or "",
            "metadata": payload.metadata or {},
            "createdAt": now,
        })

        self.surveys.update_one(
            {"id": survey_id},
            {
                "$inc": {"responseCount": 1},
                "$set": {"updatedAt": now},
            },
        )

    def _serialize_survey(self, row: dict, *, now: datetime) -> dict:
        survey = dict(row)
        survey.pop("_id", None)
        survey.pop("createdBy", None)
        survey.pop("updatedBy", None)

        survey["id"] = str(survey.get("id") or "")
        survey["title"] = str(survey.get("title") or "Untitled Survey")
        survey["subtitle"] = str(survey.get("subtitle") or "")
        survey["target"] = self._int_value(survey.get("target"), default=0)
        survey["questions"] = survey.get("questions") or []
        survey["surveyJson"] = survey.get("surveyJson") or {}
        survey["publishToMobile"] = survey.get("publishToMobile") is True
        survey["publishToWebsite"] = survey.get("publishToWebsite") is True
        survey["responses"] = self._int_value(
            survey.get("responses"),
            survey.get("responseCount"),
            default=0,
        )
        survey["sentimentBreakdown"] = survey.get("sentimentBreakdown") or {
            "concerned": 0,
            "proactive": 0,
            "misinformed": 0,
            "neutral": 0,
        }
        survey["dominantSentiment"] = str(
            survey.get("dominantSentiment") or "Neutral"
        )

        scheduled_at = survey.get("scheduledAt")
        scheduled_dt = self._parse_datetime(scheduled_at)

        if scheduled_dt is not None and scheduled_dt <= now:
            survey["status"] = "Published"
            survey["publishedAt"] = scheduled_at
        elif scheduled_dt is not None:
            survey["status"] = "Scheduled"
            survey["publishedAt"] = ""
        else:
            survey["status"] = "Draft"
            survey["publishedAt"] = ""

        survey["scheduledAt"] = self._string_date(scheduled_at)
        survey["createdAt"] = self._string_date(survey.get("createdAt"))
        survey["updatedAt"] = self._string_date(survey.get("updatedAt"))

        return survey

    def _parse_datetime(self, value: Any) -> datetime | None:
        if isinstance(value, datetime):
            if value.tzinfo is None:
                return value.replace(tzinfo=timezone.utc)
            return value

        if not value:
            return None

        text = str(value).strip()

        if not text:
            return None

        try:
            parsed = datetime.fromisoformat(text.replace("Z", "+00:00"))
        except ValueError:
            return None

        if parsed.tzinfo is None:
            return parsed.replace(tzinfo=timezone.utc)

        return parsed

    def _string_date(self, value: Any) -> str:
        if isinstance(value, datetime):
            return value.isoformat()

        return str(value or "")

    def _int_value(self, *values: Any, default: int = 0) -> int:
        for value in values:
            if isinstance(value, int):
                return value

            if isinstance(value, float):
                return int(value)

            if isinstance(value, str) and value.strip().isdigit():
                return int(value.strip())

        return default


store = MongoSentimentSurveyStore()