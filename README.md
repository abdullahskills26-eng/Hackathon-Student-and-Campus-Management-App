# SkillBridge — Student & Campus Management App

A Flutter + Firebase campus management app for students, instructors, and coordinators to manage courses, applications, attendance, assignments, progress, and career readiness.

Students apply for free IT courses, attend classes, submit work, track progress, and see whether they are job-ready.

Roles: **Student**, **Instructor**, **Campus Coordinator**.
Stack: **Flutter + Dart** frontend, **FastAPI + Firebase Admin** backend, **Firebase** (Auth, Cloud Firestore, Storage).

## Structure

```
skillbridge/
├── skillbridge_app/                 # Flutter Frontend
│   ├── assets/
│   │   ├── images/
│   │   └── icons/
│   └── lib/
│       ├── main.dart
│       ├── app.dart
│       ├── core/
│       │   ├── constants/           # app_colors, firestore_collections, demo_credentials
│       │   ├── theme/               # app_theme
│       │   ├── utils/               # state_renderers (Loading/Empty/Error)
│       │   └── widgets/             # custom_button, custom_textfield
│       ├── models/                  # 10 Firestore data models
│       ├── services/                # auth, firestore, storage, seed
│       └── features/                # Feature-first modules (13 screens)
│           ├── auth/                # Screen 1: Login / Demo Roles
│           ├── student/             # Screens 2-9
│           ├── instructor/          # Screens 10-11
│           ├── coordinator/         # Screens 12-13
│           └── shared/              # notifications, profile
└── skillbridge_backend/             # FastAPI + Firebase Admin
    ├── app/
    │   ├── main.py
    │   ├── core/                    # config, firebase_admin
    │   ├── api/v1/                  # auth, reports, seed
    │   ├── models/
    │   └── services/
    ├── scripts/seed_demo_data.py
    ├── requirements.txt
    ├── .env.example
    └── Dockerfile
```

## Firestore collections

`users` · `courses` · `campuses` · `batches` · `applications` · `attendance` · `assignments` · `submissions` · `notices` · `notifications`

## Firebase Storage paths

- `profiles/{uid}.jpg`
- `submissions/{assignmentId}/{uid}`

## Demo accounts

| Role | Email | Description |
| --- | --- | --- |
| Student | student@skillbridge.org | Abdullah — Flutter student |
| Instructor | instructor@skillbridge.org | Sir Hamza — Flutter instructor |
| Coordinator | admin@skillbridge.org | Campus Coordinator — Lahore |

## Status

Scaffold only — all source files are intentionally empty placeholders.
