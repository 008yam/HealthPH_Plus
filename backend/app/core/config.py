import os
from pathlib import Path


def _load_local_env() -> None:
    env_path = Path(__file__).resolve().parents[2] / ".env"

    if not env_path.exists():
        return

    for raw_line in env_path.read_text().splitlines():
        line = raw_line.strip()

        if not line or line.startswith("#") or "=" not in line:
            continue

        key, value = line.split("=", 1)
        key = key.strip()
        value = value.strip().strip('"').strip("'")

        os.environ.setdefault(key, value)


_load_local_env()


class Settings:
    app_name: str = os.getenv("APP_NAME", "HealthPH+ Backend API")
    api_prefix: str = os.getenv("API_PREFIX", "/api")
    environment: str = os.getenv("ENVIRONMENT", "development")
    cors_origins_raw: str = os.getenv(
        "CORS_ORIGINS",
        "http://localhost:5173,http://127.0.0.1:5173",
    )

    @property
    def cors_origins(self) -> list[str]:
        return [
            origin.strip()
            for origin in self.cors_origins_raw.split(",")
            if origin.strip()
        ]

    mongo_uri: str = os.getenv("MONGO_URI", "")

    mongo_db_name: str = "healthph-plus"

    mongo_self_reports_collection: str = "self_reports"

    mongo_health_literacy_content_collection: str = "content"

    mongo_health_literacy_analytics_collection: str = "analytics_events"

    mongo_sentiment_surveys_collection: str = "surveys"

    mongo_sentiment_survey_responses_collection: str = "survey_responses"

    mongo_mobile_users_collection: str = "mobile_users"


settings = Settings()
