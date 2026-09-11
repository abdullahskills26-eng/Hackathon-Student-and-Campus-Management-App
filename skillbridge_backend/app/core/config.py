"""Application settings."""

from typing import List

# API
API_V1_PREFIX: str = "/api/v1"
PROJECT_NAME: str = "SkillBridge API"
VERSION: str = "1.0.0"

# CORS — "*" is fine for local dev and demos. Narrow this to the deployed
# frontend origin before exposing the API publicly.
CORS_ORIGINS: List[str] = ["*"]

# Attendance percentage below this marks a student as at-risk.
ATTENDANCE_RISK_THRESHOLD: float = 75.0
