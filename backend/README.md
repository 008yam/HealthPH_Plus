# HealthPH+ Backend

FastAPI backend scaffold for HealthPH+ mobile and web integration.

## Current Scope

This backend exposes working API endpoints for:

- Health Literacy mobile content
- Health Literacy analytics events
- Mobile self-report submissions
- Mobile self-report map pins
- Mobile self-report CSV export

The current implementation uses an in-memory service layer so the API can run immediately. Replace `app/services/data_store.py` with MongoDB-backed repositories when the shared database is ready.

## Local Setup

```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Open:

```text
http://127.0.0.1:8000/docs
```

Health check:

```text
GET http://127.0.0.1:8000/api/health
```

## API Endpoints

```text
GET  /api/health
GET  /api/health-literacy/mobile
GET  /api/health-literacy/mobile/{content_type}
POST /api/health-literacy/analytics/events
POST /api/mobile/self-reports
GET  /api/mobile/self-reports/mine
GET  /api/mobile/self-reports/map-pins
GET  /api/mobile/self-reports/export
```

## Deployment

The backend includes a Dockerfile for container hosting.

Build locally:

```bash
docker build -t healthph-backend .
docker run -p 8000:8000 healthph-backend
```

For Render/Railway/Fly.io style deployment, use:

```text
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

Set environment variables from `.env.example`.
