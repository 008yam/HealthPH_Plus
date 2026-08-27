from __future__ import annotations

from datetime import datetime, timezone
from typing import Any

from bson import ObjectId
from pymongo import MongoClient, DESCENDING

from app.core.config import settings
from app.schemas.health_literacy import (
    HealthLiteracyAnalyticsEvent,
    HealthLiteracyContent,
)


class MongoHealthLiteracyStore:
    def __init__(self) -> None:
        if not settings.mongo_uri:
            raise RuntimeError("MONGO_URI is not configured.")

        self.client = MongoClient(
            settings.mongo_uri,
            serverSelectionTimeoutMS=5000,
        )
        self.db = self.client[settings.mongo_db_name]
        self.content_collection = self.db[
            settings.mongo_health_literacy_content_collection
        ]
        self.analytics_collection = self.db[
            settings.mongo_health_literacy_analytics_collection
        ]

    def list_health_literacy(
        self,
        *,
        content_type: str | None = None,
        language: str | None = None,
        q: str | None = None,
        tag: str | None = None,
    ) -> list[HealthLiteracyContent]:
        filters: list[dict[str, Any]] = [
            {"isArchived": {"$ne": True}},
            {
                "$or": [
                    {"publishToMobile": True},
                    {"publishToWebsite": True},
                    {"publishToMobile": {"$exists": False}},
                ],
            },
        ]

        if content_type:
            aliases = self._content_type_aliases(content_type)
            filters.append(
                {
                    "$or": [
                        {"contentType": {"$in": aliases}},
                        {"type": {"$in": aliases}},
                        {"resourceType": {"$in": aliases}},
                    ],
                }
            )

        if language:
            filters.append({"language": self._normalize_language(language)})

        if tag:
            filters.append({"tags": {"$in": [tag]}})

        if q:
            filters.append(
                {
                    "$or": [
                        {"title": {"$regex": q, "$options": "i"}},
                        {"description": {"$regex": q, "$options": "i"}},
                        {"tags": {"$regex": q, "$options": "i"}},
                        {"topics": {"$regex": q, "$options": "i"}},
                        {"diseases": {"$regex": q, "$options": "i"}},
                    ],
                }
            )

        query = {"$and": filters}
        rows = self.content_collection.find(query).sort(
            [
                ("isPinned", DESCENDING),
                ("pinnedAt", DESCENDING),
                ("createdAt", DESCENDING),
                ("updatedAt", DESCENDING),
            ]
        )
        return [self._doc_to_content(row) for row in rows]

    def record_health_literacy_event(
        self,
        event: HealthLiteracyAnalyticsEvent,
    ) -> None:
        document = event.model_dump(mode="python")
        document["createdAt"] = datetime.now(timezone.utc)
        self.analytics_collection.insert_one(document)

    def _doc_to_content(self, document: dict) -> HealthLiteracyContent:
        document = dict(document)
        mongo_id = document.pop("_id", None)

        content_type = self._normalize_content_type(
            document.get("contentType")
            or document.get("type")
            or document.get("resourceType")
            or "articles"
        )
        media = self._json_safe(document.get("media"))
        media_url = self._first_text(
            document.get("mediaUrl"),
            media.get("url") if isinstance(media, dict) else None,
            media.get("dataUrl") if isinstance(media, dict) else None,
        )

        document["id"] = str(document.get("id") or document.get("contentId") or mongo_id)
        document["contentType"] = content_type
        document["title"] = str(document.get("title") or document.get("headline") or "Untitled")
        document["description"] = str(
            document.get("description") or document.get("summary") or ""
        )
        document["source"] = self._clean_optional_text(document.get("source"))
        document["author"] = self._clean_optional_text(document.get("author"))
        document["externalUrl"] = self._first_text(
            document.get("externalUrl"),
            document.get("publicUrl"),
            document.get("shareUrl"),
            document.get("url"),
            document.get("link"),
        )
        document["publicUrl"] = self._clean_optional_text(document.get("publicUrl"))
        document["shareUrl"] = self._clean_optional_text(document.get("shareUrl"))
        document["imageUrl"] = self._first_text(document.get("imageUrl"), media_url)
        document["mediaUrl"] = media_url
        document["media"] = media if isinstance(media, dict) else None
        document["duration"] = self._clean_optional_text(document.get("duration"))
        document["language"] = self._normalize_language(document.get("language"))
        document["tags"] = self._string_list(document.get("tags"))
        document["topics"] = self._string_list(document.get("topics"))
        document["diseases"] = self._string_list(document.get("diseases"))
        document["viewCount"] = self._int_value(
            document.get("viewCount"),
            document.get("views"),
            document.get("viewsCount"),
        )
        document["downloadCount"] = self._int_value(
            document.get("downloadCount"),
            document.get("downloads"),
            document.get("downloadsCount"),
        )
        document["shareCount"] = self._int_value(document.get("shareCount"))

        return HealthLiteracyContent(**document)

    def _content_type_aliases(self, value: str) -> list[str]:
        normalized = self._normalize_content_type(value)
        if normalized == "articles":
            return ["article", "articles", "Article", "Articles"]
        if normalized == "videos":
            return ["video", "videos", "Video", "Videos"]
        if normalized == "infographics":
            return ["infographic", "infographics", "Infographic", "Infographics"]
        return [normalized]

    def _normalize_content_type(self, value: Any) -> str:
        text = str(value or "").strip().lower()
        aliases = {
            "article": "articles",
            "articles": "articles",
            "video": "videos",
            "videos": "videos",
            "infographic": "infographics",
            "infographics": "infographics",
            "fact_check": "fact_check",
            "fact-check": "fact_check",
        }
        return aliases.get(text, "articles")

    def _normalize_language(self, value: Any) -> str:
        text = str(value or "en").strip().lower()
        aliases = {
            "english": "en",
            "filipino": "fil",
            "tagalog": "fil",
            "cebuano": "ceb",
            "ilocano": "ilo",
            "hiligaynon": "hil",
        }
        normalized = aliases.get(text, text)
        return normalized if normalized in {"en", "fil", "ceb", "ilo", "hil"} else "en"

    def _clean_optional_text(self, value: Any) -> str | None:
        if value is None:
            return None
        text = str(value).strip()
        if not text or text.lower() == "null":
            return None
        return text

    def _first_text(self, *values: Any) -> str | None:
        for value in values:
            text = self._clean_optional_text(value)
            if text:
                return text
        return None

    def _string_list(self, value: Any) -> list[str]:
        if not isinstance(value, list):
            return []
        return [str(item).strip() for item in value if str(item).strip()]

    def _int_value(self, *values: Any) -> int:
        for value in values:
            try:
                if value is not None:
                    return int(value)
            except (TypeError, ValueError):
                continue
        return 0

    def _json_safe(self, value: Any) -> Any:
        if isinstance(value, ObjectId):
            return str(value)
        if isinstance(value, list):
            return [self._json_safe(item) for item in value]
        if isinstance(value, dict):
            return {key: self._json_safe(item) for key, item in value.items()}
        return value


store = MongoHealthLiteracyStore()
