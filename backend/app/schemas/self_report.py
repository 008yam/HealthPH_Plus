from __future__ import annotations

from datetime import datetime
from typing import Any, Literal

from pydantic import BaseModel, Field


ReporterType = Literal["guest", "registered"]
UserRoleId = Literal["guest", "user"]
PinAccuracy = Literal["geocoded", "region_estimate"]
ReportStatus = Literal["submitted", "for_review", "verified", "rejected"]


class Reporter(BaseModel):
    userId: str | None = None
    reporterType: ReporterType
    roleId: UserRoleId
    roleLabel: str
    fullName: str | None = None
    email: str | None = None


class ReportLocation(BaseModel):
    regionCode: str
    regionName: str
    provinceCode: str | None = None
    provinceName: str
    cityCode: str | None = None
    cityName: str
    barangayCode: str | None = None
    barangayName: str
    latitude: float | None = None
    longitude: float | None = None
    geocodedAddress: str | None = None
    pinAccuracy: PinAccuracy = "region_estimate"


class SelfReportCreate(BaseModel):
    reporter: Reporter
    location: ReportLocation
    symptomIds: list[str] = Field(min_length=1)
    symptomLabels: list[str] = Field(default_factory=list)
    possibleConditionId: str
    possibleConditionLabel: str
    notes: str = ""
    source: Literal["mobile_self_report"] = "mobile_self_report"
    createdAt: datetime | None = None


class SelfReportRecord(SelfReportCreate):
    id: str
    analyticsEntryId: str | None = None
    status: ReportStatus = "submitted"
    updatedAt: datetime
    syncedAt: datetime | None = None


class MobileSelfReportResponse(BaseModel):
    message: str
    item: SelfReportRecord
    mobileUser: dict[str, Any] | None = None
    analyticsEntryId: str | None = None


class SelfReportMapPin(BaseModel):
    id: str
    name: str
    diseaseId: str
    disease: str
    category: Literal["Self-reported respiratory symptoms"] = (
        "Self-reported respiratory symptoms"
    )
    reports: int = 1
    updated: str
    lat: float
    lng: float
    tagIds: list[str]
    tags: list[str]
    source: Literal["selfReport"] = "selfReport"
    pinAccuracy: PinAccuracy
    geocodedAddress: str | None = None
