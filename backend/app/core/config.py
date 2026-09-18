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

    mongo_analytics_entries_collection: str = "analytics_entries"

    mongo_sentiment_surveys_collection: str = "surveys"

    mongo_sentiment_survey_responses_collection: str = "survey_responses"

    mongo_mobile_users_collection: str = "mobile_users"

    mongo_id_counters_collection: str = "id_counters"

    mongo_regional_alerts_collection: str = "regional_alerts"

    mongo_mobile_notification_deliveries_collection: str = (
        "mobile_notification_deliveries"
    )

    mobile_jwt_secret: str = os.getenv(
        "SECRET_KEY",
        "development-only-change-this-mobile-jwt-secret",
    )

    mobile_jwt_algorithm: str = os.getenv("ALGORITHM", "HS256")

    mobile_access_token_expire_minutes: int = int(
        os.getenv("MOBILE_ACCESS_TOKEN_EXPIRE_MINUTES", "60")
    )

    mobile_bcrypt_rounds: int = max(
        int(os.getenv("MOBILE_BCRYPT_ROUNDS", "12")),
        12,
    )

    mobile_migrate_pbkdf2_to_bcrypt: bool = os.getenv(
        "MOBILE_MIGRATE_PBKDF2_TO_BCRYPT",
        "false",
    ).strip().lower() in {"1", "true", "yes", "on"}

settings = Settings()
