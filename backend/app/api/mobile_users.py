from __future__ import annotations

from fastapi import APIRouter

from app.schemas.mobile_user import (
    MobileUserCreate,
    MobileUserLanguageUpdate,
    MobileUserLogin,
    MobileUserPinUpdate,
    MobileUserRecord,
)
from app.services.mongo_mobile_user import store


router = APIRouter(prefix="/mobile/users", tags=["mobile_users"])


@router.post("", response_model=MobileUserRecord, status_code=201)
def create_mobile_user(payload: MobileUserCreate) -> MobileUserRecord:
    return store.create_mobile_users(payload)


@router.post("/login", response_model=MobileUserRecord)
def login_mobile_user(payload: MobileUserLogin) -> MobileUserRecord:
    return store.login_mobile_user(payload)

@router.patch("/{user_id}/language", response_model=MobileUserRecord)
def update_mobile_user_language(
    user_id: str,
    payload: MobileUserLanguageUpdate,
) -> MobileUserRecord:
    return store.update_mobile_user_language(user_id, payload.language)

@router.patch("/{user_id}/pin", response_model=dict[str, bool])
def updated_mobile_user_pin(
    user_id: str,
    payload: MobileUserPinUpdate,
) -> dict[str, bool]:
    store.update_mobile_user_pin(
        user_id=user_id,
        pin=payload.pin,
        current_password=payload.currentPassword,
    )

    return {"pinConfigured": True}