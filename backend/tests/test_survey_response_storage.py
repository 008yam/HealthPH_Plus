from __future__ import annotations

import importlib
import unittest
from unittest.mock import MagicMock, patch

from fastapi import HTTPException

from app.core.config import settings
from app.schemas.sentiment_survey import SentimentSurveyResponseCreate


class SurveyResponseStorageTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        # Module initialization must not create a real database connection.
        with patch.object(settings, "mongo_uri", "mongodb://localhost:27017"), patch(
            "pymongo.MongoClient"
        ):
            cls.module = importlib.import_module(
                "app.services.mongo_sentiment_survey"
            )

    def setUp(self):
        self.db = MagicMock()
        self.db.__getitem__.side_effect = lambda name: {
            settings.mongo_sentiment_surveys_collection: self.surveys,
            settings.mongo_sentiment_survey_responses_collection: self.responses,
        }[name]
        self.surveys = MagicMock()
        self.responses = MagicMock()
        with patch.object(settings, "mongo_uri", "mongodb://localhost:27017"), patch.object(
            self.module, "MongoClient"
        ) as client:
            client.return_value.__getitem__.return_value = self.db
            self.store = self.module.MongoSentimentSurveyStore()
        self.surveys.find_one.return_value = {
            "id": "SUR00012",
            "status": "Published",
            "publishToMobile": True,
            "questions": [{"id": "q1", "title": "First"}, {"id": "q2", "title": "Second"}],
        }

    def test_submission_creates_one_document_with_all_answers(self):
        for answers in (
            {"q1": "Yes"},
            {"q1": "Yes", "q2": "Health center", "q3": 5},
            {"q1": 0, "q2": False, "q3": ["A", "B"]},
        ):
            with self.subTest(answers=answers):
                self.responses.reset_mock()
                self.surveys.update_one.reset_mock()
                with patch.object(self.module, "next_readable_id") as sequence:
                    sequence.side_effect = lambda db, **kw: kw["prefix"] + "0001"
                    result = self.store.submit_response(
                        survey_id="SUR00012",
                        payload=SentimentSurveyResponseCreate(
                            answers=answers, userId="user-1", visitorId="visitor-1",
                            region="Region VI", metadata={"roleId": "user"},
                        ),
                    )
                sequence.assert_called_once_with(
                    self.db, key="survey_responses:SUR00012:submission",
                    prefix="SUR-000012-RES", width=4, separator="",
                )
                self.assertEqual(set(result), {"message", "responseId"})
                self.responses.insert_one.assert_called_once()
                document = self.responses.insert_one.call_args.args[0]
                for field in ("analyticsEntryId", "answer", "questionId", "questionNumber", "questionText"):
                    self.assertNotIn(field, document)
                self.assertEqual(document["answers"], answers)
                self.assertEqual(document["userId"], "user-1")
                self.assertEqual(document["visitorId"], "visitor-1")
                self.assertEqual(document["region"], "Region VI")
                self.assertEqual(document["metadata"], {"roleId": "user"})
                self.assertEqual(document["id"], "SUR-000012-RES0001")
                self.assertEqual(result["responseId"], document["id"])
                self.responses.update_many.assert_not_called()
                self.surveys.update_one.assert_called_once()
                self.assertEqual(
                    self.surveys.update_one.call_args.args[1]["$inc"],
                    {"responseCount": 1},
                )
                # No collection other than surveys/responses may be requested here.
                self.assertEqual(self.db.__getitem__.call_count, 2)

    def test_blank_answers_are_rejected_without_writes(self):
        with self.assertRaises(HTTPException) as error:
            self.store.submit_response(
                survey_id="SUR00012",
                payload=SentimentSurveyResponseCreate(answers={"q1": " "}),
            )
        self.assertEqual(error.exception.status_code, 400)
        self.responses.insert_one.assert_not_called()
        self.surveys.update_one.assert_not_called()

    def test_optional_blank_answers_are_omitted_from_single_document(self):
        with patch.object(self.module, "next_readable_id", return_value="SUR-000012-RES0002"):
            self.store.submit_response(
                survey_id="SUR00012",
                payload=SentimentSurveyResponseCreate(
                    answers={"q1": "Yes", "q2": " ", "q3": None, "q4": []},
                ),
            )
        self.responses.insert_one.assert_called_once()
        self.assertEqual(
            self.responses.insert_one.call_args.args[0]["answers"], {"q1": "Yes"}
        )
