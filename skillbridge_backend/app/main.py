"""SkillBridge API — FastAPI application entrypoint.

Run from the skillbridge_backend/ directory with:
    uvicorn app.main:app --host 127.0.0.1 --port 8000 --reload

Interactive docs: http://127.0.0.1:8000/docs
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.v1 import (
    assignments,
    attendance,
    batch,
    dashboard,
    instructor,
    notices,
    student,
    students,
)
from app.core.config import API_V1_PREFIX, CORS_ORIGINS, PROJECT_NAME, VERSION

app = FastAPI(
    title=PROJECT_NAME,
    description="Backend API powering SkillBridge (mock in-memory data)",
    version=VERSION,
)

# Allows the Flutter web frontend to call this API from a different origin.
app.add_middleware(
    CORSMiddleware,
    allow_origins=CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

for router in (
    dashboard.router,
    students.router,
    attendance.router,
    assignments.router,
    notices.router,
    batch.router,
    student.router,
    instructor.router,
):
    app.include_router(router, prefix=API_V1_PREFIX)


@app.get("/", tags=["Health"])
def health_check():
    """Basic health check endpoint to confirm the API is running."""
    return {"status": "SkillBridge API online"}
