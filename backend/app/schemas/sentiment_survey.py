from __future__ import annotations

from typing import Any

from pydantic import BaseModel, Field


class SentimentSurveyResponseCreate(BaseModel):
    answers: dict[str, Any] = Field(default_factory=dict)
    platform: str = "mobile"
    visitorId: str | None = None
    region: str | None = None
    metadata: dict[str, Any] = Field(default_factory=dict)