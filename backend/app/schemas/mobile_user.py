from __future__ import annotations

from datetime import datetime
from typing import Literal

from pydantic import BaseModel, Field

class MobileUserCreate(BaseModel):
    fullName: str
    email: str
    password: str
    roleId: Literal["user"] = "user"
    roleLabel: str = "User"
    language: str = "English"
    regionCode: str
    regionLabel: str
    province: str
    city: str
    barangay: str
    source: Literal["mobile_registration"] = "mobile_registration"

class MobileUserLanguageUpdate(BaseModel):
    language: str

class MobileUserPinUpdate(BaseModel):
    currentPassword: str = Field(min_length=1)
    pin: str = Field(min_length=6, max_length=6, pattern=r"^\d{6}$")

class MobileUserLogin(BaseModel):
    email: str
    password: str

class MobileUserRecord(BaseModel):
    id: str
    fullName: str
    email: str
    roleId: Literal["user"] = "user"
    roleLabel: str
    regionCode: str
    regionLabel: str
    language: str = "English"
    province: str
    city: str
    barangay: str
    source: Literal["mobile_registration"] = "mobile_registration"
    createdAt: datetime
    updatedAt: datetime
