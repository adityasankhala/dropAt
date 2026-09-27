# DropAt production release checklist

## Required infrastructure

- Create a managed PostgreSQL/PostGIS database and give the API a distinct,
  strong database user. Do not expose its port publicly.
- Configure Firebase for both mobile apps and provide the native configuration
  files outside source control.
- Create a live Razorpay account and configure its live credentials only in the
  deployment environment.
- Create a Supabase project, apply row-level security, and use a server-only
  service key for server operations. The mobile apps may use only the anonymous
  key.
- Point a custom HTTPS domain at the API and set the exact app origins and API
  hostnames in `CORS_ORIGINS` and `TRUSTED_HOSTS`.

## Deploy the API

1. Copy `dropat_backend/production.env.example` to `.env.production` and replace
   every example value. Keep that copied file out of source control.
2. Run `docker compose -f docker-compose.production.yml up --build -d` from
   `dropat_backend`, or configure the same variables in Railway. The image runs
   `alembic upgrade head` before it starts accepting traffic.
3. Verify `GET /health` returns `200`; it checks both the API and database.
   `GET /health/live` is available for a process-only liveness probe.
4. Sign in to `/admin` with the configured HTTP Basic credentials. Never deploy
   the panel without HTTPS.

## Release gates

- Run backend tests and both Flutter analyzers.
- Complete a live Razorpay payment and refund in test mode before enabling live
  payments.
- Verify a passenger cannot fetch another trip's live location and a driver
  cannot view another driver’s manifest.
- Test a booking race with the final seat; only one booking may succeed.
- Back up the production database and prove a restore in a non-production
  environment.
- Configure error monitoring, uptime alerts, and database backups before public
  launch.
