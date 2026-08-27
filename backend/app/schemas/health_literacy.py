from __future__ import annotations

from datetime import datetime
from typing import Any, Literal

from pydantic import BaseModel, Field


ContentType = Literal[
    "article",
    "articles",
    "video",
    "videos",
    "infographic",
    "infographics",
    "fact_check",
]

LanguageCode = Literal["en", "fil", "ceb", "ilo", "hil"]
Verdict = Literal["True", "Mostly True", "Needs Context", "False"]


class HealthLiteracyContent(BaseModel):
    id: str = Field(..., examples=["content_001"])
    contentType: ContentType
    title: str
    description: str
    source: str | None = None
    author: str | None = None
    publishedDate: datetime | None = None
    externalUrl: str | None = None
    publicUrl: str | None = None
    shareUrl: str | None = None
    imageUrl: str | None = None
    mediaUrl: str | None = None
    media: dict[str, Any] | None = None
    duration: str | None = None
    downloadCount: int = 0
    publishToWebsite: bool = False
    isArchived: bool = False
    claim: str | None = None
    verdict: Verdict | None = None
    explanation: str | None = None
    tags: list[str] = Field(default_factory=list)
    topics: list[str] = Field(default_factory=list)
    diseases: list[str] = Field(default_factory=list)
    language: LanguageCode = "en"
    isPublished: bool = True
    publishToMobile: bool = True
    viewCount: int = 0
    shareCount: int = 0
    createdAt: datetime | None = None
    updatedAt: datetime | None = None


class HealthLiteracyAnalyticsEvent(BaseModel):
    eventType: Literal["content_opened", "content_shared", "content_downloaded", "search"]
    contentId: str | None = None
    contentTitle: str | None = None
    contentType: ContentType | None = None
    region: str | None = None
    topic: str | None = None
    vote: str | None = None
    reportFormat: str | None = None
    clientPlatform: Literal["mobile", "website"] = "mobile"
    visitorId: str | None = None
    metadata: dict[str, Any] = Field(default_factory=dict)


class AnalyticsEventResponse(BaseModel):
    message: str
