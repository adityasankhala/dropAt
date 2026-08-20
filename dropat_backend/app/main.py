"""
DropAt Backend — FastAPI Application
────────────────────────────────────
Main entry point for the REST API.
"""

from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.router import api_router
from app.admin.routes import router as admin_router
from app.core.config import settings
from app.core.database import init_db, close_db


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

# Include all API routes
app.include_router(api_router, prefix=settings.API_V1_PREFIX)

# Include Admin Panel
app.include_router(admin_router, prefix="/admin", tags=["admin"])


@app.get("/health", tags=["health"])
async def health_check():
    """Health check endpoint."""
    return {
        "status": "ok",
        "version": "1.0.0",
        "environment": settings.APP_ENV,
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8000,
        reload=settings.APP_DEBUG,
    )
