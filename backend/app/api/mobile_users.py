from __future__ import annotations

from typing import Annotated

from fastapi import APIRouter, Depends

from app.core.mobile_auth import (
    create_mobile_access_token,
    require_matching_mobile_user,
    require_mobile_auth,
)

from app.schemas.mobile_user import (
    MobileUserCreate,
    MobileUserLanguageUpdate,
    MobileUserLogin,
    MobileUserLoginResponse,
    MobileUserPinUpdate,
    MobileUserPinVerify,
    MobileUserRecord,
)
from app.services.mongo_mobile_user import store


router = APIRouter(prefix="/mobile/users", tags=["mobile_users"])


@router.post("", response_model=MobileUserRecord, status_code=201)
def create_mobile_user(payload: MobileUserCreate) -> MobileUserRecord:
    return store.create_mobile_users(payload)


@router.post("/login", response_model=MobileUserLoginResponse)
def login_mobile_user(payload: MobileUserLogin) -> MobileUserLoginResponse:
    user = store.login_mobile_user(payload)
    return MobileUserLoginResponse(
        access_token=create_mobile_access_token(user.id),
        user=user,
    )


@router.get("/count", response_model=dict[str, int])
def count_mobile_users() -> dict[str, int]:
    return {"count": store.count_mobile_users()}


@router.patch("/{user_id}/language", response_model=MobileUserRecord)
def update_mobile_user_language(
    user_id: str,
    payload: MobileUserLanguageUpdate,
    claims: Annotated[dict, Depends(require_mobile_auth)],
) -> MobileUserRecord:
    require_matching_mobile_user(user_id, claims)
    return store.update_mobile_user_language(user_id, payload.language)


@router.patch("/{user_id}/pin", response_model=dict[str, bool])
def updated_mobile_user_pin(
    user_id: str,
    payload: MobileUserPinUpdate,
    claims: Annotated[dict, Depends(require_mobile_auth)],
) -> dict[str, bool]:
    require_matching_mobile_user(user_id, claims)
    store.update_mobile_user_pin(
        user_id=user_id,
        pin=payload.pin,
        current_password=payload.currentPassword,
    )

    return {"pinConfigured": True}


@router.post("/{user_id}/pin/verify", response_model=MobileUserRecord)
def verify_mobile_user_pin(
    user_id: str,
    payload: MobileUserPinVerify,
    claims: Annotated[dict, Depends(require_mobile_auth)],
) -> MobileUserRecord:
    require_matching_mobile_user(user_id, claims)
    return store.verify_mobile_user_pin(user_id=user_id, pin=payload.pin)
