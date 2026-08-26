from __future__ import annotations


from fastapi import APIRouter, Response

from app.schemas.self_report import SelfReportCreate, SelfReportMapPin, SelfReportRecord
from app.services.mongo_self_report import store


router = APIRouter(prefix="/mobile/self-reports", tags=["self-reports"])


@router.post("", response_model=SelfReportRecord, status_code=201)
def create_self_report(payload: SelfReportCreate) -> SelfReportRecord:
    return store.create_self_report(payload)


@router.get("/mine", response_model=list[SelfReportRecord])
def list_my_self_reports(
    user_id: str | None = None,
    email: str | None = None,
) -> list[SelfReportRecord]:
    return store.list_self_reports(user_id=user_id, email=email)


@router.get("/map-pins", response_model=list[SelfReportMapPin])
def list_self_report_map_pins() -> list[SelfReportMapPin]:
    return store.self_report_map_pins()


@router.get("/export")
def export_self_reports_csv() -> Response:
    csv_body = store.self_reports_csv()
    return Response(
        content=csv_body,
        media_type="text/csv",
        headers={
            "Content-Disposition": 'attachment; filename="healthph_self_reports.csv"',
        },
    )
