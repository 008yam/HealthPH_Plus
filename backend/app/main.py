from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api import health, health_literacy, mobile_users, self_reports
from app.core.config import settings


def create_app() -> FastAPI:
    app = FastAPI(
        title=settings.app_name,
        version="0.1.0",
        description="Backend API scaffold for HealthPH+ web and mobile integration.",
    )

    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.cors_origins,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    app.include_router(health.router, prefix=settings.api_prefix)
    app.include_router(health_literacy.router, prefix=settings.api_prefix)
    app.include_router(mobile_users.router, prefix=settings.api_prefix)
    app.include_router(self_reports.router, prefix=settings.api_prefix)

    return app


app = create_app()
