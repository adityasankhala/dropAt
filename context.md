# DropAt — Project Context & Architecture

This document defines the high-level architecture, technology stack, and structure of the DropAt project. Use this to quickly understand how the system is built.

---

## 🏗️ Architectural Overview
The DropAt platform consists of three main components: a centralized backend and two mobile applications.

- **Backend (`/dropat_backend`)**: 
  - Framework: FastAPI (Python)
  - Database: PostgreSQL with PostGIS extension for spatial queries.
  - ORM: SQLModel & GeoAlchemy2.
  - Admin Panel: Server-side rendered Jinja2 templates served directly from FastAPI at `/admin`.
  - Infrastructure: Containerized using Docker & Docker Compose (`api` and `db` services).

- **User App (`/dropat_user`)**: 
  - Framework: Flutter (Dart) for iOS & Android.
  - Features: Booking shuttles, real-time tracking, wallet management, and viewing ride history.

- **Driver App (`/dropat_driver`)**: 
  - Framework: Flutter (Dart) for iOS & Android.
  - Features: Managing assigned trips, navigation, passenger check-ins, and earnings dashboard.

---

## 🔗 Integrations & External Services
- **Authentication**: Firebase Auth (Mobile apps generate JWT tokens, Backend verifies them via Firebase Admin SDK).
- **Payments**: Razorpay Gateway (Planned for wallet top-ups and ride payments).
- **Maps & Routing**: Google Maps SDK / API (For drawing routes and tracking).
- **Real-Time Data**: Supabase / WebSockets (Planned for live vehicle tracking).

---

## 📂 Repository Structure
- `dropat_backend/`: FastAPI source code, Docker configuration, Admin HTML templates.
- `dropat_user/`: Flutter source code for the student application.
- `dropat_driver/`: Flutter source code for the driver application.
