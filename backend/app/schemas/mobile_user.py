from __future__ import annotations

from datetime import datetime
from typing import Literal

from pydantic import BaseModel


class MobileUserCreate(BaseModel):
    fullName: str
    email: str
    roleId: Literal["user"] = "user"
    roleLabel: str = "User"
    regionCode: str
    regionLabel: str
    province: str
    city: str
    barangay: str
    source: Literal["mobile_registration"] = "mobile_registration"


class MobileUserRecord(MobileUserCreate):
    id: str
    createdAt: datetime
    updatedAt: datetime