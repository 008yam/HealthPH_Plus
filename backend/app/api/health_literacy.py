from __future__ import annotations

from fastapi import APIRouter, Query

from app.schemas.health_literacy import (
    AnalyticsEventResponse,
    HealthLiteracyAnalyticsEvent,
    HealthLiteracyContent,
)
from app.services.mongo_health_literacy import store


router = APIRouter(prefix="/health-literacy", tags=["health-literacy"])


@router.get("/mobile", response_model=list[HealthLiteracyContent])
def list_mobile_health_literacy(
    content_type: str | None = Query(None, alias="contentType"),
    language: str | None = None,
    q: str | None = None,
    tag: str | None = None,
) -> list[HealthLiteracyContent]:
    return store.list_health_literacy(
        content_type=content_type,
        language=language,
        q=q,
        tag=tag,
    )


@router.get("/mobile/{content_type}", response_model=list[HealthLiteracyContent])
def list_mobile_health_literacy_by_type(
    content_type: str,
    language: str | None = None,
) -> list[HealthLiteracyContent]:
    return store.list_health_literacy(
        content_type=content_type,
        language=language,
    )


@router.post("/analytics/events", response_model=AnalyticsEventResponse, status_code=201)
def record_health_literacy_event(
    event: HealthLiteracyAnalyticsEvent,
) -> AnalyticsEventResponse:
    store.record_health_literacy_event(event)
    return AnalyticsEventResponse(
        message="Health Literacy Hub analytics event recorded",
    )
