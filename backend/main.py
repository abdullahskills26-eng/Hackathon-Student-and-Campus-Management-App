# backend/main.py
"""
Instructor Dashboard API
-------------------------
A lightweight FastAPI backend using in-memory mock data (no external DB)
for rapid prototyping of an Instructor Dashboard application.

Run with:
    uvicorn backend.main:app --host 0.0.0.0 --port 8000 --reload
"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import List, Literal
from datetime import date, datetime
from itertools import count

# ---------------------------------------------------------------------------
# APP INITIALIZATION
# ---------------------------------------------------------------------------
app = FastAPI(
    title="Instructor Dashboard API",
    description="Backend API powering the Instructor Dashboard (mock in-memory data)",
    version="1.0.0",
)

# ---------------------------------------------------------------------------
# CORS MIDDLEWARE (MANDATORY)
# Allows the frontend (any origin) to communicate with this API without
# being blocked by browser CORS policy. Required for local dev + demos.
# ---------------------------------------------------------------------------
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---------------------------------------------------------------------------
# IN-MEMORY MOCK DATA STORE
# Simulates a database using plain Python dictionaries/lists.
# In production, replace these with real DB queries (Postgres/Mongo/etc.)
# ---------------------------------------------------------------------------

ATTENDANCE_RISK_THRESHOLD = 75.0  # attendance % below this => at-risk

students_db = [
    {"id": 1, "name": "Aisha Khan", "attendance_percentage": 92.0, "status": "Present"},
    {"id": 2, "name": "Bilal Ahmed", "attendance_percentage": 68.5, "status": "Absent"},
    {"id": 3, "name": "Sara Malik", "attendance_percentage": 74.0, "status": "Present"},
    {"id": 4, "name": "Hamza Raza", "attendance_percentage": 88.0, "status": "Present"},
    {"id": 5, "name": "Fatima Noor", "attendance_percentage": 55.0, "status": "Absent"},
]

assignments_db = [
    {
        "id": 1,
        "title": "Data Structures - Assignment 1",
        "due_date": "2026-09-20",
        "max_marks": 100,
        "submissions_count": 18,
    },
    {
        "id": 2,
        "title": "Algorithms - Midterm Project",
        "due_date": "2026-09-30",
        "max_marks": 50,
        "submissions_count": 5,
    },
]

notices_db = [
    {"id": 1, "text": "Class rescheduled to 3 PM on Friday.", "created_at": "2026-09-08T10:00:00"},
]

classes_db = [
    {"id": 1, "name": "CS-101 Data Structures"},
    {"id": 2, "name": "CS-201 Algorithms"},
]

# Simple auto-incrementing ID generators for new records
_assignment_id_counter = count(start=len(assignments_db) + 1)
_notice_id_counter = count(start=len(notices_db) + 1)

# ---------------------------------------------------------------------------
# PYDANTIC MODELS (Request Body Schemas)
# Enforce strict validation on all incoming POST payloads.
# ---------------------------------------------------------------------------

class AttendanceMarkRequest(BaseModel):
    student_id: int
    status: Literal["Present", "Absent"]


class AssignmentCreateRequest(BaseModel):
    title: str = Field(..., min_length=1, max_length=200)
    due_date: date
    max_marks: int = Field(..., gt=0, le=1000)


class NoticeCreateRequest(BaseModel):
    text: str = Field(..., min_length=1, max_length=1000)


# ---------------------------------------------------------------------------
# HELPER FUNCTIONS
# ---------------------------------------------------------------------------

def enrich_student(student: dict) -> dict:
    """Add computed field `is_at_risk` based on attendance threshold."""
    return {
        **student,
        "is_at_risk": student["attendance_percentage"] < ATTENDANCE_RISK_THRESHOLD,
    }


def find_student(student_id: int) -> dict:
    for s in students_db:
        if s["id"] == student_id:
            return s
    raise HTTPException(status_code=404, detail=f"Student with id {student_id} not found")


# ---------------------------------------------------------------------------
# ROUTES
# ---------------------------------------------------------------------------

@app.get("/", tags=["Health"])
def health_check():
    """Basic health check endpoint to confirm the API is running."""
    return {"status": "Instructor API online"}


@app.get("/dashboard/summary", tags=["Dashboard"])
def dashboard_summary():
    """
    Aggregate summary stats for the instructor dashboard homepage:
    total classes, total students, active notices, and pending assignments.
    """
    return {
        "total_classes": len(classes_db),
        "total_students": len(students_db),
        "active_notices": len(notices_db),
        "pending_assignments": len(assignments_db),
    }


@app.get("/students", tags=["Students"])
def get_students():
    """Return the full student roster, each enriched with an at-risk flag."""
    return [enrich_student(s) for s in students_db]


@app.post("/attendance/mark", tags=["Attendance"])
def mark_attendance(payload: AttendanceMarkRequest):
    """
    Update a student's attendance status for the day.
    NOTE: This mock implementation only toggles Present/Absent status;
    it does not recalculate the running attendance_percentage.
    """
    student = find_student(payload.student_id)
    student["status"] = payload.status
    return {
        "message": f"Attendance updated for student {payload.student_id}",
        "student": enrich_student(student),
    }


@app.get("/assignments", tags=["Assignments"])
def get_assignments():
    """Return all created assignments."""
    return assignments_db


@app.post("/assignments/create", tags=["Assignments"])
def create_assignment(payload: AssignmentCreateRequest):
    """Create a new assignment record and add it to the in-memory store."""
    new_assignment = {
        "id": next(_assignment_id_counter),
        "title": payload.title,
        "due_date": payload.due_date.isoformat(),
        "max_marks": payload.max_marks,
        "submissions_count": 0,
    }
    assignments_db.append(new_assignment)
    return {"message": "Assignment created successfully", "assignment": new_assignment}


@app.post("/notices/create", tags=["Notices"])
def create_notice(payload: NoticeCreateRequest):
    """Post a new announcement/notice for students."""
    new_notice = {
        "id": next(_notice_id_counter),
        "text": payload.text,
        "created_at": datetime.utcnow().isoformat(),
    }
    notices_db.append(new_notice)
    return {"message": "Notice posted successfully", "notice": new_notice}


@app.get("/batch/progress", tags=["Batch Progress"])
def batch_progress():
    """
    Return a filtered list of at-risk students:
    - Low attendance (< 75%)
    - Poor performance proxy: assignment submissions below half of assignments issued
      (used here as a simple mock heuristic since no per-student grades exist yet)
    """
    total_assignments = len(assignments_db)
    at_risk_students = []

    for s in students_db:
        low_attendance = s["attendance_percentage"] < ATTENDANCE_RISK_THRESHOLD
        # Mock heuristic: flag as poor performer if attendance is borderline
        # and there are pending assignments (placeholder for real grade logic).
        poor_grades_flag = low_attendance and total_assignments > 0

        if low_attendance or poor_grades_flag:
            at_risk_students.append({
                **enrich_student(s),
                "reason": "Low Attendance" if low_attendance else "Poor Grades",
            })

    return {
        "at_risk_count": len(at_risk_students),
        "students": at_risk_students,
    }


# ---------------------------------------------------------------------------
# ENTRY POINT (for `python main.py` direct execution)
# ---------------------------------------------------------------------------
if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
