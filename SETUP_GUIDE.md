# 🚀 DropAt — Teammate Setup Guide

> **Hey! Welcome to the DropAt project.** Follow this guide step-by-step and you'll have the entire system running on your machine in under 10 minutes.

---

## 📋 Prerequisites (Install These First)

| Tool | Why You Need It | Install Link |
|------|----------------|-------------|
| **Git** | Version control | [git-scm.com](https://git-scm.com/) |
| **Docker Desktop** | Runs the backend + database | [docker.com/get-started](https://www.docker.com/products/docker-desktop/) |
| **Flutter SDK** | Builds the mobile apps | [docs.flutter.dev/get-started/install](https://docs.flutter.dev/get-started/install) |
| **Xcode** (macOS only) | Needed for iOS builds | App Store → Xcode |
| **Android Studio** | Needed for Android builds | [developer.android.com/studio](https://developer.android.com/studio) |
| **VS Code** (recommended) | Code editor | [code.visualstudio.com](https://code.visualstudio.com/) |

### Quick Check — Make sure everything is installed:
```bash
git --version          # Should print something like: git version 2.x.x
docker --version       # Should print: Docker version 2x.x.x
flutter --version      # Should print Flutter SDK version
```

---

## 🏁 Step 1: Clone the Repository

```bash
git clone https://github.com/adityasankhala/lifeproject.git
cd lifeproject
```

---

## 🐳 Step 2: Start the Backend (Docker)

The entire backend (FastAPI server + PostgreSQL database) runs inside Docker containers. You don't need to install Python or Postgres yourself.

```bash
# Go to the backend folder
cd dropat_backend

# Create your local environment file from the template
cp .env.example .env

# One command to build + start + seed everything
make setup
```

**What `make setup` does automatically:**
1. ✅ Builds the Docker containers
2. ✅ Starts PostgreSQL database
3. ✅ Starts the FastAPI server
4. ✅ Seeds the database with sample routes & vouchers

### Verify It's Working:
```bash
# Check if the API is alive
curl http://localhost:8000/health
```
You should see:
```json
{"status": "ok", "version": "1.0.0", "environment": "development"}
```

### Useful Links (after backend is running):
| URL | What |
|-----|------|
| http://localhost:8000/docs | 📚 API Documentation (Swagger UI) |
| http://localhost:8000/admin | 🛡️ Admin Dashboard |
| http://localhost:8000/health | 💚 Health Check |

---

## 📱 Step 3: Run the User App (Flutter)

```bash
# Go back to the project root, then into the user app
cd ../dropat_user

# Install Flutter dependencies
flutter pub get

# Run on a connected device or emulator
flutter run
```

> **By default, the app talks to the production Railway server** (deployed online). This means you can test the app even without running the backend locally!

### 🔌 Want the app to talk to YOUR LOCAL backend instead?

You'll need your computer's local IP address:
```bash
# macOS:
ipconfig getifaddr en0

# Linux:
hostname -I | awk '{print $1}'

# Windows:
ipconfig    # Look for IPv4 Address under Wi-Fi
```

Then run Flutter with the override:
```bash
flutter run --dart-define=API_BASE_URL=http://<YOUR-IP>:8000/api/v1

# Example: if your IP is 192.168.1.42
flutter run --dart-define=API_BASE_URL=http://192.168.1.42:8000/api/v1
```

> **Important:** If testing on a **physical phone**, your phone and computer must be on the **same Wi-Fi network**.

### Special Cases:
| Testing On | Use This URL |
|-----------|-------------|
| iOS Simulator | `http://localhost:8000/api/v1` |
| Android Emulator | `http://10.0.2.2:8000/api/v1` |
| Physical Phone | `http://<YOUR-COMPUTER-IP>:8000/api/v1` |

---

## 🚗 Step 4: Run the Driver App (Flutter)

```bash
cd ../dropat_driver
flutter pub get
flutter run
```

Same `--dart-define` override applies if you want to point to your local backend.

---

## 🔥 Step 5: Firebase Setup

Firebase config files are **not included in the repo** (for security). You need to get them from the Firebase Console or from Aditya.

### Files You Need:

| File | Where to Put It |
|------|----------------|
| `GoogleService-Info.plist` | `dropat_user/ios/Runner/GoogleService-Info.plist` |
| `GoogleService-Info.plist` | `dropat_driver/ios/Runner/GoogleService-Info.plist` |
| `google-services.json` | `dropat_user/android/app/google-services.json` |
| `google-services.json` | `dropat_driver/android/app/google-services.json` |
| `firebase_options.dart` | `dropat_user/lib/firebase_options.dart` |
| `firebase_options.dart` | `dropat_driver/lib/firebase_options.dart` |

**How to get them:**
1. Go to [Firebase Console](https://console.firebase.google.com/) → Project: `dropat-80f0b`
2. Download the config files for iOS and Android
3. Or just ask Aditya to share them with you directly

---

## 🔧 Everyday Commands (Backend)

Run these from the `dropat_backend/` folder:

```bash
make dev       # Start containers
make stop      # Stop containers
make logs      # See API logs (live)
make health    # Quick health check
make seed      # Re-seed sample data
make rebuild   # Rebuild after changing requirements.txt
make clean     # ⚠️ Delete everything (including DB data)
```

---

## 🌿 Git Workflow (How We Work Together)

### ⚠️ NEVER push directly to `main`!

```bash
# 1. Always start by pulling the latest main
git checkout main
git pull origin main

# 2. Create your own branch
git checkout -b feature/your-feature-name
# Examples:
#   git checkout -b feature/payment-integration
#   git checkout -b fix/login-crash
#   git checkout -b ui/booking-screen

# 3. Make your changes, then commit
git add .
git commit -m "feat: add payment integration"

# 4. Push your branch
git push origin feature/your-feature-name

# 5. Go to GitHub → Create a Pull Request → Get it reviewed → Merge!
```

---

## 🐛 Troubleshooting

### "Docker Desktop is not running"
→ Open Docker Desktop app and wait for it to start, then retry `make dev`.

### "Port 8000 already in use"
```bash
# Find what's using the port
lsof -i :8000
# Kill it
kill -9 $(lsof -t -i :8000)
# Retry
make dev
```

### "Port 5432 already in use"
Same thing, but for the database port:
```bash
kill -9 $(lsof -t -i :5432)
make dev
```

### "Network Error" in the Flutter app
- **Are you using the local backend?** Make sure Docker is running (`make health`)
- **Physical device?** Phone must be on the same Wi-Fi as your computer
- **Using the right IP?** Run `ipconfig getifaddr en0` to double-check

### "No Firebase config" / app crashes at startup
→ You need the Firebase config files (see Step 5 above). Ask Aditya.

### Flutter build fails
```bash
# Clean everything and rebuild
flutter clean
flutter pub get
flutter run
```

### "CocoaPods error" (iOS)
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter run
```

---

## 📂 Project Structure (Quick Reference)

```
lifeproject/
├── dropat_backend/        ← FastAPI + PostgreSQL (Python)
│   ├── app/
│   │   ├── api/           ← API route handlers
│   │   ├── core/          ← Config, database, auth
│   │   ├── models/        ← SQLModel database models
│   │   └── admin/         ← Admin panel (Jinja2 templates)
│   ├── migrations/        ← Alembic database migrations
│   ├── docker-compose.yml ← Docker setup
│   ├── Makefile           ← Helper commands
│   ├── .env.example       ← Environment template
│   └── requirements.txt   ← Python dependencies
│
├── dropat_user/           ← User Flutter App
│   └── lib/
│       ├── config/        ← API URL configuration
│       ├── models/        ← Data models
│       ├── screens/       ← UI screens
│       └── services/      ← API client & business logic
│
├── dropat_driver/         ← Driver Flutter App
│   └── lib/               ← Same structure as user app
│
└── dropat_admin/          ← Admin Web Dashboard
```

---

## 💬 Need Help?

If you're stuck, reach out to **Aditya** — he built most of this and can walk you through anything.

Good luck and happy coding! 🚀
