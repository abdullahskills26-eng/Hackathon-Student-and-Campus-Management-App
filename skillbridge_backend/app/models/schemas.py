"""Pydantic request schemas — strict validation on all incoming payloads."""

from datetime import date
from typing import Literal

from pydantic import BaseModel, Field, field_validator, model_validator


class AttendanceMarkRequest(BaseModel):
    student_id: int
    status: Literal["Present", "Absent"]


class AssignmentCreateRequest(BaseModel):
    title: str = Field(..., min_length=1, max_length=200)
    due_date: date
    max_marks: int = Field(..., gt=0, le=1000)


class NoticeCreateRequest(BaseModel):
    text: str = Field(..., min_length=1, max_length=1000)


# --------------------------------------------------------------- Student


class ApplicationCreateRequest(BaseModel):
    """A student's course application."""

    uid: str = Field(..., min_length=1, max_length=128)
    fullName: str = Field(..., min_length=2, max_length=100)
    cnic: str = Field(..., min_length=13, max_length=15)
    education: str = Field(..., min_length=1, max_length=60)
    city: str = Field(..., min_length=1, max_length=60)
    courseId: str = Field(..., min_length=1, max_length=128)
    courseName: str = Field(..., min_length=1, max_length=120)
    campusId: str = Field(..., min_length=1, max_length=128)
    campusName: str = Field(..., min_length=1, max_length=120)
    motivation: str = Field(..., min_length=20, max_length=2000)

    @field_validator("cnic")
    @classmethod
    def cnic_must_be_13_digits(cls, v: str) -> str:
        digits = "".join(ch for ch in v if ch.isdigit())
        if len(digits) != 13:
            raise ValueError("CNIC must contain exactly 13 digits")
        return v


class SubmissionCreateRequest(BaseModel):
    """Metadata for an assignment file already uploaded to Storage."""

    assignmentId: str = Field(..., min_length=1, max_length=128)
    uid: str = Field(..., min_length=1, max_length=128)
    textAnswer: str = Field(default="", max_length=5000)
    fileUrl: str = Field(default="", max_length=2000)
    fileName: str = Field(default="", max_length=255)

    @model_validator(mode="after")
    def needs_answer_or_file(self) -> "SubmissionCreateRequest":
        if not self.textAnswer.strip() and not self.fileUrl.strip():
            raise ValueError("Provide a text answer or a file URL")
        return self
