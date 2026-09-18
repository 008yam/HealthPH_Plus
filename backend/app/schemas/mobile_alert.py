from __future__ import annotations

from pydantic import BaseModel


class MobileAlertSymptom(BaseModel):
    symptomKey: str
    label: str
    reportCount: int


class MobileAlertRecord(BaseModel):
    schemaVersion: int = 1
    id: str
    type: str = "regional_symptom_alert"
    source: str = "automated"
    region: str
    regionName: str
    title: str
    message: str
    reportCount: int
    threshold: int
    comparison: str | None = None
    windowMinutes: int
    windowStart: str | None = None
    windowEnd: str | None = None
    symptoms: list[MobileAlertSymptom]
    publishedAt: str | None = None
    readAt: str | None = None


class MobileAlertsPage(BaseModel):
    items: list[MobileAlertRecord]
    nextCursor: str | None = None
    unreadCount: int


class MobileAlertDetail(BaseModel):
    item: MobileAlertRecord


class MobileAlertReadResult(BaseModel):
    item: MobileAlertRecord
    unreadCount: int
