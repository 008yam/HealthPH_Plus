from __future__ import annotations
from typing import Any
from fastapi import APIRouter


from app.schemas.sentiment_survey import SentimentSurveyResponseCreate
from app.services.mongo_sentiment_survey import store

router = APIRouter(prefix="/sentiment-pulse", tags=["sentiment-pulse"])


@router.get("/public-surveys")
def list_public_surveys(platform: str = "mobile") -> list[dict]:
    return store.list_public_surveys(platform=platform)


@router.post("/public-surveys/{survey_id}/responses", status_code=201)
def submit_public_survey_response(
    survey_id: str,
    payload: SentimentSurveyResponseCreate,
) -> dict[str, Any]:
    return store.submit_response(survey_id=survey_id, payload=payload)