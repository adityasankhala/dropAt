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

## 🎯 Future Goals (Current Phase 1 Focus)
1. **Real-time Tracking Architecture**: 
   - Integrate `flutter_background_geolocation` in `dropat_driver` to batch-push GPS coordinates to FastAPI (SQLite queueing).
   - Configure FastAPI to write batch points to PostgreSQL.
   - Setup Supabase Realtime to broadcast DB `UPDATE` events to `dropat_user`.
2. **Map UI Migration**: Transition from Google Maps to Mapbox GL in both Flutter apps for smoother asset rendering.
3. **State Management Migration**: Refactor Flutter apps to use Riverpod for efficient async data stream handling.
4. **Payment Gateway**: Integrate Razorpay / Cashfree test SDK in the User app for seat booking via UPI.

## 🚀 Phase 2 (Future Expansion)
- Point-to-Point routing (Uber/Rapido style).
- Geospatial driver matching (Redis + Uber H3 hex clustering).
- Dynamic pricing algorithm.
