# DropAt — Daily Progress & Developer Diary

This document tracks past achievements, daily progress, and future goals to prevent context loss across sessions.

---

## 🏆 Past Achievements & What's Built
- **Backend Core**: Built the FastAPI core, SQLModel database schemas (User, Driver, Route, Trip, Booking, etc.), and full CRUD API endpoints.
- **Admin Panel**: Developed a complete, professional, minimalist UI for managing the system (`/admin`). Pages include Dashboard, Routes, Trips, Users, Drivers, Bookings, and Vouchers.
- **Mobile UI**: Implemented the UI screens for both the User and Driver Flutter apps (Auth, Maps, Ride History, Profile).
- **Git Strategy**: Set up a professional GitHub repository with a clean `.gitignore`, an outstanding `README.md`, and established a feature-branch workflow.

---

## 📅 Daily Log

### Aug 21, 2026
- **Achievements**: 
  - Overhauled the Admin Panel UI to a modern, minimalist dashboard style (light theme, clean SVG icons, distinct status badges).
  - Fixed Git divergence issues, merged conflicts, and successfully pushed the Admin Panel to GitHub `main`.
  - Created a professional GitHub Profile `README.md` for Aditya.
  - Initialized a new feature branch `feature/aditya`.
- **Current State**: The backend and admin panel are 100% running. The Flutter apps exist but lack backend integration and data.
- **Next Immediate Goal**: Seed the backend database with test data and connect the Flutter apps (User/Driver) to the FastAPI backend API.

### Aug 24, 2026
- **Achievements**:
  - Implemented **Real-time Tracking Architecture** (Phase 1 core feature):
    - Driver App: Integrated `flutter_background_geolocation` for battery-efficient GPS batch-pushing to FastAPI.
    - User App: Built `LiveTrackingScreen` with Mapbox GL map + Riverpod `StreamProvider` listening to Supabase Realtime.
    - Created Riverpod `tracking_providers.dart` with `tripLocationProvider`, `driverLocationProvider`, and `bookingStatusProvider`.
  - Migrated both apps from Google Maps to **Mapbox GL** (`mapbox_maps_flutter`).
  - Added **Riverpod** state management to both apps (`flutter_riverpod`).
  - Rewrote `SupabaseService` to use SDK-agnostic `DriverLocation` model instead of `LatLng`.
  - Wrapped User app root in `ProviderScope`.
  - Updated `context.md` and `progress.md` to reflect new architecture.
- **Current State**: Backend tracking API (`POST /tracking/update`, `GET /tracking/trip/{trip_id}`) is complete. Driver app has native background geolocation configured. User app has live tracking screen ready. Supabase Realtime needs cloud project setup.
- **Next Immediate Goal**: Set up Supabase cloud project, configure API keys, and test end-to-end tracking flow.
---

## 🎯 Phase 1 Status

| Feature | Status |
|---|---|
| Backend Core (FastAPI + SQLModel) | ✅ Done |
| Admin Panel (Jinja2 minimalist UI) | ✅ Done |
| Mobile UI (User + Driver Flutter) | ✅ Done |
| Payment Gateway (Razorpay backend + Flutter) | ✅ Done |
| Real-time Tracking (Background GPS → FastAPI → Supabase) | ✅ Code done, needs Supabase cloud setup |
| Mapbox GL (LiveTrackingScreen) | ✅ Done (new screens only) |
| Riverpod State Management | ✅ Done (tracking providers) |
| Google Maps → Mapbox Migration (all screens) | 🔄 Incremental (8 legacy screens remain) |

## ⚠️ Pending Actions
- [ ] **Merge `feature/aditya` → `main`**: All new code is on the feature branch. Create a PR or merge when ready.
- [ ] **Supabase Cloud Setup**: Create project at supabase.com, get URL + anon key, update `.env`.
- [ ] **Mapbox Token**: Sign up at mapbox.com, add public token to Flutter apps.
- [ ] **Razorpay Test Keys**: Get test keys from razorpay.com dashboard, update `.env`.
- [ ] **Firebase Config Files**: Place `google-services.json` and `GoogleService-Info.plist`.
- [ ] **Full Mapbox Migration**: Migrate remaining 8 screens from Google Maps to Mapbox GL.

## 🚀 Phase 2 (Future Expansion)
- Point-to-Point routing (Uber/Rapido style).
- Geospatial driver matching (Redis + Uber H3 hex clustering).
- Dynamic pricing algorithm.
