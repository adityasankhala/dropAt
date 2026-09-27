# DropAt — Campus Shuttle Platform

**Connecting smaller cities through organised shuttle networks.**

DropAt is a ride-sharing platform built for Tier 2 and Tier 3 Indian cities where public transport is unreliable and expensive. We start with fixed-route campus shuttles (hostels → colleges → markets → railway stations) and expand into on-demand rides as the network grows.

## Why Smaller Cities First?

Big cities already have Ola, Uber, Rapido. But students in Jaipur, Kota, Indore, and Lucknow still depend on overcrowded autos and shared rickshaws with zero tracking, no fixed pricing, and unsafe late-night commutes. DropAt solves this by:

- **Fixed routes** with known stops, schedules, and fares — no surge pricing
- **Live GPS tracking** so passengers know exactly where the shuttle is
- **Seat reservations** to guarantee a spot during peak hours
- **UPI payments** built in — no cash hassles
- Starting with college campuses where demand is predictable and dense

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| **User App** | Flutter (Dart) — iOS & Android |
| **Driver App** | Flutter (Dart) — iOS & Android |
| **Backend API** | FastAPI (Python) |
| **Database** | PostgreSQL + PostGIS |
| **Auth** | Firebase Auth (Phone OTP + Google Sign-In) |
| **Realtime** | Supabase Realtime (live GPS broadcast) |
| **Payments** | Razorpay (UPI, cards, wallets) |
| **Maps** | Google Maps SDK + Places API |
| **Hosting** | Railway / Docker |

---

## Project Structure

```
lifeproject/
├── dropat_user/          # Passenger Flutter app
│   ├── lib/
│   │   ├── screens/      # All UI screens
│   │   ├── services/     # API client, auth, shuttle, payments
│   │   ├── models/       # Data models (ride, shuttle, user, etc.)
│   │   ├── widgets/      # Reusable UI components
│   │   ├── providers/    # State management
│   │   ├── config/       # Environment config
│   │   └── theme/        # Colors, typography, spacing
│   └── pubspec.yaml
│
├── dropat_driver/        # Driver Flutter app
│   ├── lib/
│   │   ├── screens/      # Driver home, ride, earnings, profile
│   │   ├── services/     # API client, location tracking, auth
│   │   ├── config/       # Environment config
│   │   └── theme/        # Driver app theme
│   └── pubspec.yaml
│
├── dropat_backend/       # FastAPI server
│   ├── app/
│   │   ├── api/          # REST endpoints (routes, bookings, payments, etc.)
│   │   ├── models/       # SQLModel ORM models
│   │   ├── schemas/      # Pydantic request/response schemas
│   │   ├── services/     # Business logic (booking, payment, tracking)
│   │   ├── core/         # Config, DB, Firebase auth middleware
│   │   └── admin/        # Admin dashboard (server-rendered HTML)
│   ├── migrations/       # Alembic DB migrations
│   ├── seed.py           # Demo data seeder
│   ├── Dockerfile
│   └── requirements.txt
│
└── dropat_admin/         # Admin panel templates
```

---

## Getting Started

### Prerequisites

- **Flutter SDK** 3.x+ — [install guide](https://docs.flutter.dev/get-started/install)
- **Python 3.11+** — for the backend
- **PostgreSQL 15+** — local or Docker
- **Firebase project** — for authentication
- **Google Maps API key** — for maps and places

### 1. Clone the repo

```bash
git clone https://github.com/adityasankhala/dropAt.git
cd dropAt
```

### 2. Backend Setup

```bash
cd dropat_backend

# Create virtual environment
python3 -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Copy env template and fill in your values
cp .env.example .env
# Edit .env with your database URL, Firebase project ID, etc.

# Run database migrations
alembic upgrade head

# Seed demo data (3 shuttle routes in Jaipur)
python seed.py

# Start the server
uvicorn app.main:app --reload --port 8000
```

The API will be live at `http://localhost:8000`. Check `http://localhost:8000/docs` for the interactive Swagger UI.

### 3. User App Setup

```bash
cd dropat_user

# Install Flutter dependencies
flutter pub get
```

#### Running on Mobile (iOS / Android)

Set up your Google Maps API key securely in the local configuration files:
- **Android:** Add `GOOGLE_MAPS_API_KEY=your-key` to `android/local.properties`
- **iOS:** Add `GOOGLE_MAPS_API_KEY=your-key` to `ios/Flutter/Secrets.xcconfig`

Run the app on a connected mobile device or emulator:
```bash
flutter run
```
*(The UI automatically adapts to a classic mobile layout with a bottom navigation bar.)*

#### Running on Web / Desktop Browsers

To run the app as a fully responsive Web Application, inject the API key directly into the run command since the web builder does not read from mobile config files:

```bash
flutter run -d web-server --web-port 5000 --dart-define=GOOGLE_MAPS_API_KEY=your-key-here
```
*(Note: If you encounter a Google Sign-In `origin_mismatch` error, ensure your Google Cloud OAuth Client ID allows the `http://localhost:5000` Authorized JavaScript Origin.)*

**Responsive UI Logic:**
The User App uses a `LayoutBuilder` to adapt across devices:
- **Mobile (`width <= 800`):** Uses a bottom navigation bar and anchored bottom-sheet overlays.
- **Desktop/Web (`width > 800`):** Transforms into a Desktop Website layout, utilizing a side Navigation Rail, full-screen map background, and floating left-aligned dashboard widgets mimicking modern web apps.

### 4. Driver App Setup

```bash
cd dropat_driver

flutter pub get

# Same key setup as user app (local.properties + Secrets.xcconfig)

flutter run --dart-define=GOOGLE_MAPS_API_KEY=your-key-here
```

### 5. Firebase Setup

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable **Phone Authentication** and **Google Sign-In**
3. Download `google-services.json` → place in `android/app/`
4. Download `GoogleService-Info.plist` → place in `ios/Runner/`
5. Set `FIREBASE_PROJECT_ID` in your backend `.env`

---

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/v1/auth/verify` | Verify Firebase token, create user |
| `GET` | `/api/v1/routes` | List all shuttle routes |
| `GET` | `/api/v1/trips?route_id=&date=` | Available trips for a route |
| `POST` | `/api/v1/bookings` | Book a seat on a shuttle |
| `GET` | `/api/v1/bookings/me` | My booking history |
| `DELETE` | `/api/v1/bookings/{id}` | Cancel a booking |
| `POST` | `/api/v1/payments/create-order` | Create Razorpay payment |
| `POST` | `/api/v1/payments/verify` | Verify payment callback |
| `POST` | `/api/v1/tracking/update` | Driver pushes GPS location |
| `GET` | `/api/v1/tracking/trip/{id}` | Get live shuttle position |
| `POST` | `/api/v1/drivers/toggle-online` | Driver goes online/offline |
| `GET` | `/api/v1/vouchers` | Available promo codes |

Full interactive docs at `/docs` (Swagger UI) when running locally.

---

## Architecture

```
┌─────────────┐     ┌─────────────┐
│  User App   │     │ Driver App  │
│  (Flutter)  │     │  (Flutter)  │
└──────┬──────┘     └──────┬──────┘
       │  HTTP + JWT       │  HTTP + JWT
       └────────┬──────────┘
                │
         ┌──────▼──────┐
         │   FastAPI    │
         │   Backend    │
         └──────┬──────┘
                │
    ┌───────────┼───────────┐
    │           │           │
┌───▼───┐ ┌────▼────┐ ┌────▼────┐
│ Postgres│ │Supabase │ │Razorpay │
│+PostGIS│ │Realtime │ │Payments │
└────────┘ └─────────┘ └─────────┘
```

**Auth flow**: Firebase Auth (phone OTP / Google) → JWT token → sent in every API request → backend verifies with Google's public keys.

**Live tracking**: Driver app sends GPS coordinates → backend writes to PostgreSQL → Supabase Realtime broadcasts to all subscribers → user app updates map in real-time.

**Payments**: User selects seat → backend creates Razorpay order → Flutter opens Razorpay checkout → payment verified server-side → booking confirmed.

---

## Database Schema

The schema is designed for shuttle operations now, but the models support on-demand rides when we're ready:

- **users** — profiles synced from Firebase Auth
- **vehicles** — shuttles (and eventually autos, bikes, cars)
- **drivers** — linked to users and vehicles
- **routes** — fixed shuttle routes with names and metadata
- **waypoints** — stops along a route (with lat/lng coordinates)
- **trips** — specific departures (e.g., Route A at 8:00 AM today)
- **bookings** — seat reservations with status tracking
- **payments** — transaction records with Razorpay integration
- **location_updates** — GPS pings from drivers (powers live tracking)
- **vouchers** — promo codes and discounts
- **reviews** — ratings and feedback

---

## Docker

```bash
cd dropat_backend

# Run everything (API + PostgreSQL + PostGIS)
docker-compose up -d

# Or just build the API image
docker build -t dropat-api .
```

---

## Roadmap

### Phase 1 (Current) — Campus Shuttles
- [x] Fixed shuttle routes with schedules
- [x] Seat booking and cancellation
- [x] Live GPS tracking
- [x] UPI payments via Razorpay
- [x] Driver and passenger apps
- [x] Admin dashboard

### Phase 2 (Next) — On-Demand Rides
- [ ] Auto-rickshaw and bike taxi booking
- [ ] Dynamic pricing and driver matching
- [ ] Wallet system with top-up
- [ ] Ride sharing / carpooling
- [ ] Multi-city expansion

---

## Environment Variables

See [`dropat_backend/.env.example`](dropat_backend/.env.example) for the full list. Key ones:

| Variable | Required | Description |
|----------|----------|-------------|
| `DATABASE_URL` | Yes | PostgreSQL connection string |
| `FIREBASE_PROJECT_ID` | Yes | For JWT verification |
| `GOOGLE_MAPS_API_KEY` | Yes | Maps and Places API |
| `RAZORPAY_KEY_ID` | No* | Payment gateway |
| `RAZORPAY_KEY_SECRET` | No* | Payment gateway |
| `SUPABASE_URL` | No* | For realtime tracking |

*Required for those features to work. The app runs without them in dev mode.

---

## Contributing

This is a private project built for the DropAt team. If you're a contributor:

1. Create a feature branch from `main`
2. Make your changes
3. Test locally (`flutter analyze` + `pytest`)
4. Open a PR

---

## License

Proprietary. All rights reserved.

---

Built with ☕ by the DropAt team from Jaipur, India.
