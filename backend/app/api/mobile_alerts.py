from __future__ import annotations

from typing import Annotated

from fastapi import APIRouter, Depends, Query

from app.core.mobile_auth import require_mobile_auth
from app.schemas.mobile_alert import (
    MobileAlertDetail,
    MobileAlertReadResult,
    MobileAlertsPage,
)
from app.services.mongo_mobile_alert import store


router = APIRouter(prefix="/mobile/alerts", tags=["mobile_alerts"])


@router.get("", response_model=MobileAlertsPage)
def list_mobile_alerts(
    claims: Annotated[dict, Depends(require_mobile_auth)],
    cursor: str | None = None,
    limit: int = Query(default=20, ge=1, le=100),
) -> MobileAlertsPage:
    return store.list_alerts(
        mobile_user_id=claims["sub"],
        cursor=cursor,
        limit=limit,
    )


@router.get("/{alert_id}", response_model=MobileAlertDetail)
def get_mobile_alert(
    alert_id: str,
    claims: Annotated[dict, Depends(require_mobile_auth)],
) -> MobileAlertDetail:
    return store.get_alert(mobile_user_id=claims["sub"], alert_id=alert_id)


@router.patch("/{alert_id}/read", response_model=MobileAlertReadResult)
def mark_mobile_alert_read(
    alert_id: str,
    claims: Annotated[dict, Depends(require_mobile_auth)],
) -> MobileAlertReadResult:
    return store.mark_read(mobile_user_id=claims["sub"], alert_id=alert_id)
