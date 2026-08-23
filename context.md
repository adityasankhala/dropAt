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
  - State Management: Riverpod (for async data streams without UI bottlenecks).
  - Map UI: Mapbox GL (for smooth asset movement).
  - Features: Booking shuttles, live tracking, wallet management.

- **Driver App (`/dropat_driver`)**: 
  - Framework: Flutter (Dart) for iOS & Android.
  - State Management: Riverpod.
  - Features: Background geolocation (batch pushing to FastAPI), managing trips, passenger manifests.

---

## 🔗 Integrations & External Services
- **Authentication**: Firebase Auth (Phone/OTP verification).
- **Payments**: Razorpay / Cashfree SDKs integrated natively into Flutter.
- **Maps & Routing**: Mapbox GL.
- **Real-Time Data**: Supabase Realtime (FastAPI writes batch GPS points to DB, Supabase automatically broadcasts `UPDATE` events to passengers).

---

## 📂 Repository Structure
- `dropat_backend/`: FastAPI source code, Docker configuration, Admin HTML templates.
- `dropat_user/`: Flutter source code for the student application.
- `dropat_driver/`: Flutter source code for the driver application.

---

## 🗺️ Real-World Route Context
- **Campus Location**: Bagru, Rajasthan (~25km west of Jaipur city center).
- **Route A (City Express)**: Bagru → Airport → Malviya Nagar → WTP → C-Scheme (south-east corridor, ~55 min).
- **Route B (Station Express)**: Bagru → Chandpole → Sindhi Camp → Railway Station (north corridor, ~45 min).
- **Logic**: 2 shuttles depart simultaneously. Route A covers the south destinations, Route B covers the old city transport hubs. No overlap, maximum coverage.

## ⚙️ UI Rules
- **DO NOT change** existing UI colors, themes, or design combinations.
- All new screens must use the existing `DropAtColors`, `DropAtTextStyles`, and `DropAtRadius` tokens from `app_theme.dart`.

