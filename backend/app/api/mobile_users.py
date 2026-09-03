from __future__ import annotations

from fastapi import APIRouter

from app.schemas.mobile_user import MobileUserCreate, MobileUserLogin, MobileUserRecord
from app.services.mongo_mobile_user import store


router = APIRouter(prefix="/mobile/users", tags=["mobile_users"])


@router.post("", response_model=MobileUserRecord, status_code=201)
def create_mobile_user(payload: MobileUserCreate) -> MobileUserRecord:
    return store.create_mobile_users(payload)


@router.post("/login", response_model=MobileUserRecord)
def login_mobile_user(payload: MobileUserLogin) -> MobileUserRecord:
    return store.login_mobile_user(payload)