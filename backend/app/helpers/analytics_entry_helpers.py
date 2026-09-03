from __future__ import annotations

from datetime import datetime, timedelta, timezone
from math import isnan
from typing import Any


DEFAULT_ANALYSIS_TASKS = [
    "sentiment",
    "disease_classification",
    "misinformation",
    "ner",
]


def get_ph_datetime() -> datetime:
    return datetime.now(timezone(timedelta(hours=8)))


def _is_missing_value(value: Any) -> bool:
    return isinstance(value, float) and isnan(value)


def _clean_text_value(value: Any) -> str:
    if value is None or _is_missing_value(value):
        return ""

    if isinstance(value, list):
        return ", ".join(
            cleaned
            for item in value
            if (cleaned := _clean_text_value(item))
        )

    if isinstance(value, dict):
        return " ".join(
            cleaned
            for item in value.values()
            if (cleaned := _clean_text_value(item))
        )

    return str(value).strip()


def _is_analyzable_text(value: Any) -> bool:
    text = _clean_text_value(value)

    if not text:
        return False

    if text.isnumeric():
        return False

    return len(text) >= 3


def build_self_report_analytics_entry(report_document: dict[str, Any]) -> dict[str, Any] | None:
    report_id = str(report_document.get("_id") or report_document.get("id") or "")
    notes = _clean_text_value(report_document.get("notes"))
    symptom_labels = report_document.get("symptomLabels") or []
    possible_condition = _clean_text_value(
        report_document.get("possibleConditionLabel")
    )

    fallback_text = " ".join(
        value
        for value in [
            _clean_text_value(symptom_labels),
            possible_condition,
        ]
        if value
    )

    text = notes or fallback_text

    if not _is_analyzable_text(text):
        return None

    location = report_document.get("location") or {}
    created_at = report_document.get("createdAt") or get_ph_datetime()
    collected_at = report_document.get("syncedAt") or created_at
    raw_location = _clean_text_value(location.get("geocodedAddress"))

    if not raw_location:
        raw_location = ", ".join(
            value
            for value in [
                _clean_text_value(location.get("barangayName")),
                _clean_text_value(location.get("cityName")),
                _clean_text_value(location.get("provinceName")),
                _clean_text_value(location.get("regionName")),
            ]
            if value
        )

    return {
        "source_type": "self_report",
        "source_id": report_id,
        "report_id": report_id,
        "text": text,
        "language": "",
        "source_platform": _clean_text_value(report_document.get("source")),
        "location": {
            "raw": raw_location,
            "region": _clean_text_value(location.get("regionCode"))
            or _clean_text_value(location.get("regionName")),
            "province": _clean_text_value(location.get("provinceName")),
            "city": _clean_text_value(location.get("cityName")),
            "barangay": _clean_text_value(location.get("barangayName")),
            "latitude": location.get("latitude"),
            "longitude": location.get("longitude"),
        },
        "event_time": str(created_at),
        "collected_at": str(collected_at),
        "analysis_status": "pending",
        "analysis_tasks": ["sentiment", "disease_classification", "ner"],
        "analysis": {
            "sentiment": None,
            "sentiment_score": None,
            "disease_labels": [],
            "disease_probabilities": {},
            "symptoms": [],
            "misinformation": None,
            "misinformation_score": None,
            "entities": [],
            "model_version": "",
        },
        "metadata": {
            "symptom_ids": report_document.get("symptomIds") or [],
            "symptom_labels": symptom_labels,
            "possible_condition_id": report_document.get("possibleConditionId") or "",
            "possible_condition_label": possible_condition,
            "status": report_document.get("status") or "",
        },
        "created_at": created_at,
        "updated_at": None,
        "analyzed_at": None,
    }

def build_survey_response_analytics_entry(
    *,
    survey_document: dict[str, Any],
    response_document: dict[str, Any],
) -> dict[str, Any] | None:
    response_id = _clean_text_value(response_document.get("id"))
    survey_id = _clean_text_value(response_document.get("surveyId"))
    answers = response_document.get("answers") or {}
    metadata = response_document.get("metadata") or {}
    created_at = response_document.get("createdAt") or get_ph_datetime()

    question_lookup = {
        _clean_text_value(question.get("id")): question
        for question in survey_document.get("questions", [])
        if isinstance(question, dict)
    }

    answer_lines = []

    for question_id, answer in answers.items():
        question = question_lookup.get(question_id, {})
        question_title = _clean_text_value(question.get("title") or question_id)
        answer_text = _clean_text_value(answer)

        if answer_text:
            answer_lines.append(f"{question_title}: {answer_text}")

    text = " ".join(answer_lines)

    if not _is_analyzable_text(text):
        return None

    return {
        "source_type": "sentiment_survey_response",
        "source_id": response_id,
        "survey_id": survey_id,
        "response_id": response_id,
        "text": text,
        "language": "",
        "source_platform": _clean_text_value(response_document.get("platform")),
        "location": {
            "raw": _clean_text_value(response_document.get("region")),
            "region": _clean_text_value(response_document.get("region")),
            "province": _clean_text_value(metadata.get("province")),
            "city": _clean_text_value(metadata.get("city")),
            "barangay": _clean_text_value(metadata.get("barangay")),
            "latitude": None,
            "longitude": None,
        },
        "event_time": str(created_at),
        "collected_at": str(created_at),
        "analysis_status": "pending",
        "analysis_tasks": ["sentiment", "misinformation", "ner"],
        "analysis": {
            "sentiment": None,
            "sentiment_score": None,
            "disease_labels": [],
            "disease_probabilities": {},
            "symptoms": [],
            "misinformation": None,
            "misinformation_score": None,
            "entities": [],
            "model_version": "",
        },
        "metadata": {
            "survey_title": _clean_text_value(survey_document.get("title")),
            "visitor_id": response_document.get("visitorId"),
            "role_id": metadata.get("roleId", ""),
            "answers": answers,
        },
        "created_at": created_at,
        "updated_at": None,
        "analyzed_at": None,
    }