import os


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

    mongo_db_name: str = os.getenv("MONGO_DB_NAME", "healthph-plus")

    mongo_self_reports_collection: str = os.getenv(
        "MONGO_SELF_REPORTS_COLLECTION",
        "self_reports",
    )

    mongo_health_literacy_content_collection: str = os.getenv(
        "MONGO_HEALTH_LITERACY_CONTENT_COLLECTION",
        "content",
    )

    mongo_health_literacy_analytics_collection: str = os.getenv(
        "MONGO_HEALTH_LITERACY_ANALYTICS_COLLECTION",
        "analytics_events",
    )

    mongo_mobile_users_collection: str = os.getenv(
        "MONGO_MOBILE_USERS_COLLECTION",
        "mobile_users",
    )


settings = Settings()
