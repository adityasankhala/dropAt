# DropAt 🚐

> A multi-service campus mobility app built for students — designed to simplify getting around campus.

DropAt is a modern, reliable campus shuttle and ride-hailing platform designed for universities and tight-knit communities. The system comprises a high-performance backend, an intuitive user application, and a dedicated driver application. Developed as a **Project Based Learning (PBL)** initiative at Manipal University Jaipur.

🏆 **Winner – Project Expo 2025** | Selected from the top 10–15 projects out of 100+ submissions.

## 🌟 Key Features

- **Campus Shuttle System**: Fixed-route shuttle tracking and booking.
- **On-Demand Rides**: (Phase 2) Ride-hailing for personalized routes.
- **Real-Time Tracking**: Live vehicle tracking using PostGIS and websockets.
- **Admin Dashboard**: Comprehensive web-based admin panel to manage routes, trips, users, and drivers.
- **Voucher System**: Built-in promotional and discount system.
- **Authentication**: Secure sign-up and login for students.

## 🏗️ Architecture / Tech Stack

The project is structured into three main repositories/folders:

### 1. Backend (`/dropat_backend`)
- **Framework**: Python with [FastAPI](https://fastapi.tiangolo.com/)
- **Database**: PostgreSQL with PostGIS extension (via `SQLModel` and `GeoAlchemy2`)
- **Admin Panel**: Jinja2 HTML templates served directly from FastAPI
- **Containerization**: Docker & Docker Compose

### 2. User App (`/dropat_user`)
- **Framework**: [Flutter](https://flutter.dev/) (iOS & Android)
- **Features**: Route browsing, shuttle booking, wallet management, real-time tracking, intuitive UI/UX designed in Figma.

### 3. Driver App (`/dropat_driver`)
- **Framework**: [Flutter](https://flutter.dev/) (iOS & Android)
- **Features**: Trip management, route navigation, passenger check-ins, earnings dashboard.

---

## 🚀 Getting Started (First-Time Setup)

### Prerequisites
- [Docker & Docker Compose](https://www.docker.com/)
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (for mobile apps)
- Python 3.11+ (optional, for local backend development without Docker)

### 1. Clone & Setup the Backend

```bash
# Clone the repo
git clone https://github.com/your-org/lifeproject.git
cd lifeproject

# Navigate to backend
cd dropat_backend

# Create your environment file from the template
cp .env.example .env

# Start everything with one command
make setup
```

This will:
- Build the Docker containers (FastAPI API + PostgreSQL)
- Wait for the database to be healthy
- Seed the database with sample routes and vouchers

**Verify it's running:**
```bash
curl http://localhost:8000/health
# → {"status":"ok","version":"1.0.0","environment":"development"}
```

- **API Docs**: http://localhost:8000/docs
- **Admin Panel**: http://localhost:8000/admin

### 2. Run the Flutter User App

```bash
cd ../dropat_user
flutter pub get
flutter run
```

By default, the app connects to the **production Railway backend**. To connect to your **local Docker backend** instead:

```bash
# Find your computer's local IP address
# macOS:
ipconfig getifaddr en0
# Linux:
hostname -I | awk '{print $1}'

# Run Flutter with local backend
flutter run --dart-define=API_BASE_URL=http://<YOUR-IP>:8000/api/v1

# Example:
flutter run --dart-define=API_BASE_URL=http://192.168.0.100:8000/api/v1
```

> **Note for iOS Simulator**: Use `http://localhost:8000/api/v1`  
> **Note for Android Emulator**: Use `http://10.0.2.2:8000/api/v1`

### 3. Run the Flutter Driver App

```bash
cd ../dropat_driver
flutter pub get
flutter run
```

Same `--dart-define` override applies for local development.

---

## 🔧 Useful Commands (Backend)

All commands should be run from the `dropat_backend/` directory:

| Command | Description |
|---------|-------------|
| `make setup` | First-time setup (build + seed) |
| `make dev` | Start Docker containers |
| `make stop` | Stop all containers |
| `make logs` | Tail API container logs |
| `make seed` | Seed database with sample data |
| `make health` | Check API health |
| `make rebuild` | Rebuild API after changing `requirements.txt` |
| `make clean` | Stop containers + delete DB data ⚠️ |

---

## 🛠️ Troubleshooting

### "Network Error" when booking / loading routes
**Cause**: The app can't reach the backend.  
**Fix**: 
1. Check the backend is running: `curl http://localhost:8000/health`
2. If using a physical device, make sure your phone and computer are on the **same Wi-Fi network**
3. Use `--dart-define` to point to your local IP (not `localhost`)

### Docker containers won't start
```bash
# Check if port 5432 or 8000 is already in use
lsof -i :5432
lsof -i :8000

# Kill any existing process, then retry
make dev
```

### "address already in use" error
Another process is using port 8000 or 5432. Kill it:
```bash
# Find and kill the process on port 8000
kill -9 $(lsof -t -i :8000)
make dev
```

### Flutter app shows demo/fake data
The app falls back to demo data when it can't reach the backend. This is expected when:
- The backend is not running
- Your phone can't resolve the Railway domain (ISP blocking)

Fix: Start the local backend and use `--dart-define` to point to it.

### Firebase / Google Services errors
Firebase config files are gitignored for security. You need to:
1. Get `GoogleService-Info.plist` (iOS) from the Firebase Console
2. Get `google-services.json` (Android) from the Firebase Console
3. Place them in the correct directories:
   - iOS: `dropat_user/ios/Runner/GoogleService-Info.plist`
   - Android: `dropat_user/android/app/google-services.json`

---

## 🤝 Contributing & Branching Strategy

To keep the development process smooth and conflict-free, especially when working in a team, we follow a feature-branching workflow.

### The Golden Rules of Branching
1. **Never commit directly to `main`**. The `main` branch should always contain stable, working code.
2. **Create a new branch for every feature or fix**. 
3. **Use descriptive branch names** (e.g., `feature/user-login`, `fix/map-crash`, `ui/admin-dashboard`).

### Workflow Example

1. **Pull the latest changes** from the main branch to ensure you are up to date:
   ```bash
   git checkout main
   git pull origin main
   ```

2. **Create a new branch** for your work:
   ```bash
   git checkout -b feature/my-awesome-feature
   ```

3. **Make your changes** and commit them:
   ```bash
   git add .
   git commit -m "Add my awesome feature"
   ```

4. **Push your branch** to GitHub:
   ```bash
   git push origin feature/my-awesome-feature
   ```

5. **Create a Pull Request (PR)** on GitHub to merge your branch into `main`. Once your teammate reviews and approves it, it can be merged!

## 👥 Team

Developed by **Aditya Saini**, **Arnav Mehrotra** and **Joshua Sherwin Fernandes** 

---
*Built with ❤️ for better campus mobility.*
