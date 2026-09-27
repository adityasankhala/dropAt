"""Main entry point for the REST API."""

from contextlib import asynccontextmanager

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.gzip import GZipMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from sqlalchemy import text

from app.api.router import api_router
from app.admin.routes import router as admin_router
from app.core.config import settings
from app.core.database import async_session_factory, init_db, close_db

@asynccontextmanager
async def lifespan(app: FastAPI):
    """Lifecycle events for the FastAPI application."""
    # Startup
    await init_db()  # In production, use Alembic instead
    yield
    # Shutdown
    await close_db()

app = FastAPI(
    title="DropAt API",
    description="Backend API for DropAt Phase 1 (Campus Shuttle) and Phase 2 (On-Demand)",
    version="1.0.0",
    lifespan=lifespan,
    docs_url="/docs" if settings.APP_DEBUG else None,
    redoc_url="/redoc" if settings.APP_DEBUG else None,
)

# CORS Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.add_middleware(GZipMiddleware, minimum_size=1000)

if settings.TRUSTED_HOSTS:
    app.add_middleware(TrustedHostMiddleware, allowed_hosts=settings.TRUSTED_HOSTS)

# Include all API routes
app.include_router(api_router, prefix=settings.API_V1_PREFIX)

# Include Admin Panel
app.include_router(admin_router, prefix="/admin", tags=["admin"])

@app.get("/health", tags=["health"])
async def health_check():
    """Readiness check used by deployment health probes."""
    try:
        async with async_session_factory() as session:
            await session.execute(text("SELECT 1"))
    except Exception as exc:
        raise HTTPException(status_code=503, detail="Database unavailable") from exc

    return {
        "status": "ok",
        "version": "1.0.0",
        "environment": settings.APP_ENV,
    }

@app.get("/health/live", tags=["health"])
async def liveness_check():
    """Process liveness check that does not depend on external services."""
    return {"status": "ok"}

@app.post("/seed", tags=["admin"])
async def seed_database():
    """One-time seed endpoint for production database."""
    if not settings.is_development:
        raise HTTPException(status_code=404, detail="Not found")
    from app.core.database import async_session_factory
    from app.models.route import Route
    from app.models.waypoint import Waypoint
    from app.models.voucher import Voucher

    async with async_session_factory() as session:
        # Check if already seeded
        from sqlmodel import select
        existing = (await session.execute(select(Route))).all()
        if existing:
            return {"status": "already_seeded", "routes": len(existing)}

        route_a = Route(
            name="City Express",
            description="Bagru → Airport → Malviya Nagar → WTP → C-Scheme",
            price=60.0, total_seats=30,
            schedule=[
                {"departure_time": "07:00 AM", "days": ["Mon","Tue","Wed","Thu","Fri","Sat"]},
                {"departure_time": "05:00 PM", "days": ["Mon","Tue","Wed","Thu","Fri","Sat"]},
            ],
            estimated_duration_min=55,
        )
        route_b = Route(
            name="Station Express",
            description="Bagru → Chandpole → Sindhi Camp → Railway Station",
            price=50.0, total_seats=30,
            schedule=[
                {"departure_time": "07:00 AM", "days": ["Mon","Tue","Wed","Thu","Fri","Sat"]},
                {"departure_time": "05:30 PM", "days": ["Mon","Tue","Wed","Thu","Fri","Sat"]},
            ],
            estimated_duration_min=45,
        )
        session.add(route_a)
        session.add(route_b)
        await session.flush()

        # Route A stops
        session.add_all([
            Waypoint(route_id=route_a.id, name="College Campus (Bagru)", lat=26.8156, lng=75.5422, order=1, is_fixed=True),
            Waypoint(route_id=route_a.id, name="Jaipur Airport", lat=26.8242, lng=75.8122, order=2, is_fixed=True),
            Waypoint(route_id=route_a.id, name="Malviya Nagar", lat=26.8530, lng=75.8025, order=3, is_fixed=True),
            Waypoint(route_id=route_a.id, name="WTP (World Trade Park)", lat=26.8927, lng=75.8050, order=4, is_fixed=True),
            Waypoint(route_id=route_a.id, name="C-Scheme", lat=26.9040, lng=75.7930, order=5, is_fixed=True),
        ])
        # Route B stops
        session.add_all([
            Waypoint(route_id=route_b.id, name="College Campus (Bagru)", lat=26.8156, lng=75.5422, order=1, is_fixed=True),
            Waypoint(route_id=route_b.id, name="Chandpole", lat=26.9218, lng=75.7770, order=2, is_fixed=True),
            Waypoint(route_id=route_b.id, name="Sindhi Camp Bus Stand", lat=26.9270, lng=75.7870, order=3, is_fixed=True),
            Waypoint(route_id=route_b.id, name="Jaipur Railway Station", lat=26.9196, lng=75.7878, order=4, is_fixed=True),
        ])
        # Vouchers
        session.add_all([
            Voucher(code="WELCOME50", description="50% off your first ride", discount_amount=50.0,
                    is_percentage=True, max_discount=100.0, usage_limit=1000),
            Voucher(code="FLAT20", description="Flat ₹20 off", discount_amount=20.0,
                    is_percentage=False, min_order_amount=50.0, usage_limit=500),
        ])
        await session.commit()

    return {"status": "seeded", "routes": 2, "vouchers": 2}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8000,
        reload=settings.APP_DEBUG,
    )
