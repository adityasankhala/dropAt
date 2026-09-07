# DropAt — AI Assistant Instructions

> **Note to AI Agents (Cursor, Copilot, Antigravity, etc.):** 
> If you are reading this file, you are assisting Aditya and the DropAt team. **You must strictly follow these rules and project guidelines** when generating code or executing tasks.

---

## 1. 🥇 The Core Directive: Production-Grade Only
- **Context**: This is a **production-grade application**, NOT just a weekend project. It won the Project Expo 2025.
- **Rule**: Never write "hacky" code, temporary workarounds, or hardcoded values. Always implement robust error handling, proper typing, and scalable architecture. 
- **Rule**: Write code that handles edge cases (e.g., loss of network, missing permissions, server timeouts).

## 2. 🤝 Team-First Mentality
- **Context**: The project is built collaboratively by a team (Aditya, Anshika, Joshua).
- **Rule**: Every change you make must work seamlessly for the entire team. 
- **Rule**: Never hardcode local IP addresses (e.g., `192.168.x.x`) into tracked files. Use environment variables (e.g., `.env` or `--dart-define` in Flutter).
- **Rule**: Never commit secrets or API keys. Always use `.env.example`.
- **Rule**: Respect the branch structure. Never push directly to `main`. Always work on feature branches (e.g., `feature/aditya`).

## 3. ⚡ Conversational Style & Execution
- **Context**: Aditya prefers fast, autonomous execution.
- **Rule**: Keep your responses concise. Do not explain basic programming concepts unless asked.
- **Rule**: When encountering an error (e.g., a build failure or network timeout), **try to resolve it yourself first**. Read the logs, apply a fix, and retry. Do not immediately stop and ask the user what to do unless you are completely blocked (e.g., missing an API key or physical device access).
- **Rule**: If the user says "go", "ready", or "do it", execute the discussed plan immediately without further confirmation.

## 4. 🏗️ Tech Stack & Architecture Rules
- **Backend (`/dropat_backend`)**: 
  - FastAPI (Python 3.11+) + PostgreSQL/PostGIS.
  - Managed via Docker Compose.
  - ORM: `SQLModel` with `asyncpg` (use `session.execute()` not `session.exec()` for async queries).
- **Mobile Apps (`/dropat_user`, `/dropat_driver`)**: 
  - Flutter / Dart.
  - Mapping: Mapbox GL (do not use Google Maps).
  - State Management: Riverpod.
- **External Services**: 
  - Firebase for Auth (JWT verification on backend).
  - Supabase for Realtime Tracking (WebSockets).
  - Razorpay for Payments.

## 5. 🛠️ Development Workflow
- **Backend Setup**: Always use `make setup` and `make dev` for local Docker environments.
- **Flutter Local Dev**: Use `flutter run --dart-define=API_BASE_URL=http://<IP>:8000/api/v1` to point to a local backend, otherwise it defaults to the production Railway URL.
- **Mobile Builds**: Prefer wireless deployment when testing physical devices (`xcrun devicectl` for iOS).

---
*End of Instructions. Acknowledge these implicitly by executing at the highest standard.*
