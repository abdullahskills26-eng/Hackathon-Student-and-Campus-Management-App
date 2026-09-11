"""Pydantic request schemas — strict validation on all incoming payloads."""

from datetime import date
from typing import Literal

from pydantic import BaseModel, Field


class AttendanceMarkRequest(BaseModel):
    student_id: int
    status: Literal["Present", "Absent"]


class AssignmentCreateRequest(BaseModel):
    title: str = Field(..., min_length=1, max_length=200)
    due_date: date
    max_marks: int = Field(..., gt=0, le=1000)


class NoticeCreateRequest(BaseModel):
    text: str = Field(..., min_length=1, max_length=1000)
