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

## 🚀 Getting Started

### Prerequisites
- [Docker & Docker Compose](https://www.docker.com/)
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (for mobile apps)
- Python 3.11+ (optional, for local backend development)

### Running the Backend

The backend is fully dockerized for easy setup.

1. Navigate to the backend directory:
   ```bash
   cd dropat_backend
   ```
2. Make sure you have created your `.env` file from `.env.example`.
3. Start the services:
   ```bash
   docker compose up --build -d
   ```
4. Access the API documentation at `http://localhost:8000/docs`.
5. Access the Admin Dashboard at `http://localhost:8000/admin`.

### Running the Mobile Apps

1. Navigate to the respective app directory (`dropat_user` or `dropat_driver`).
2. Fetch dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app on a connected device or emulator:
   ```bash
   flutter run
   ```

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
