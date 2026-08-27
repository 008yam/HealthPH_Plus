from __future__ import annotations

from fastapi import APIRouter

from app.schemas.mobile_user import MobileUserCreate, MobileUserRecord
from app.services.mongo_mobile_user import store


router = APIRouter(prefix="/mobile/users", tags=["mobile_users"])

@router.post("", response_model=MobileUserRecord, status_code=201)
def create_mobile_user(payload: MobileUserCreate) -> MobileUserRecord:
    return store.create_mobile_users(payload)