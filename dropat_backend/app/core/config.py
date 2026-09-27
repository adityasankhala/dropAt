"""
DropAt Backend — Core Configuration
────────────────────────────────────
Centralized settings loaded from environment variables.
Uses pydantic-settings for automatic validation and type coercion.
"""

from typing import List
from pydantic import field_validator, model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Application settings loaded from .env file."""

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore",
    )

    # ── App ──────────────────────────────────────
    APP_ENV: str = "development"
    APP_DEBUG: bool = True
    API_V1_PREFIX: str = "/api/v1"
    CORS_ORIGINS: List[str] = [
        "http://localhost:3000",
        "http://localhost:5173",
        "http://localhost:8000",
    ]
    TRUSTED_HOSTS: List[str] = []
    AUTO_CREATE_SCHEMA: bool = True

    # ── Database ─────────────────────────────────
    DATABASE_URL: str = "postgresql+asyncpg://postgres:postgres@localhost:5432/dropat"

    @field_validator("DATABASE_URL", mode="after")
    @classmethod
    def fix_database_url(cls, v: str) -> str:
        if v.startswith("postgres://"):
            return v.replace("postgres://", "postgresql+asyncpg://", 1)
        if v.startswith("postgresql://"):
            return v.replace("postgresql://", "postgresql+asyncpg://", 1)
        return v

    # ── Supabase ─────────────────────────────────
    SUPABASE_URL: str = ""
    SUPABASE_ANON_KEY: str = ""
    SUPABASE_SERVICE_KEY: str = ""

    # ── Firebase Auth ────────────────────────────
    FIREBASE_PROJECT_ID: str = "dropat-80f0b"

    # ── Google Maps ──────────────────────────────
    GOOGLE_MAPS_API_KEY: str = ""

    # ── Razorpay ─────────────────────────────────
    RAZORPAY_KEY_ID: str = ""
    RAZORPAY_KEY_SECRET: str = ""
    PAYMENTS_ENABLED: bool = False
    ALLOW_DEV_PAYMENT_FALLBACK: bool = True

    # ── Admin panel ──────────────────────────────
    ADMIN_USERNAME: str = ""
    ADMIN_PASSWORD: str = ""

    @model_validator(mode="after")
    def validate_production_settings(self) -> "Settings":
        """Reject unsafe configuration before a production server starts."""
        if not self.is_production:
            return self

        failures = []
        if self.APP_DEBUG:
            failures.append("APP_DEBUG must be false")
        if self.AUTO_CREATE_SCHEMA:
            failures.append("AUTO_CREATE_SCHEMA must be false; run Alembic migrations")
        if not self.DATABASE_URL or "postgres:postgres@" in self.DATABASE_URL:
            failures.append("DATABASE_URL must use production credentials")
        if not self.CORS_ORIGINS or "*" in self.CORS_ORIGINS:
            failures.append("CORS_ORIGINS must contain explicit allowed origins")
        if not self.TRUSTED_HOSTS or "*" in self.TRUSTED_HOSTS:
            failures.append("TRUSTED_HOSTS must contain explicit allowed hosts")
        if not self.FIREBASE_PROJECT_ID:
            failures.append("FIREBASE_PROJECT_ID is required")
        if not self.ADMIN_USERNAME or not self.ADMIN_PASSWORD:
            failures.append("ADMIN_USERNAME and ADMIN_PASSWORD are required")
        if self.ALLOW_DEV_PAYMENT_FALLBACK:
            failures.append("ALLOW_DEV_PAYMENT_FALLBACK must be false")
        if self.PAYMENTS_ENABLED and (
            not self.RAZORPAY_KEY_ID or not self.RAZORPAY_KEY_SECRET
        ):
            failures.append("Razorpay credentials are required when payments are enabled")

        if failures:
            raise ValueError("Invalid production configuration: " + "; ".join(failures))
        return self

    @property
    def is_production(self) -> bool:
        return self.APP_ENV.lower() == "production"

    @property
    def is_development(self) -> bool:
        return self.APP_ENV.lower() == "development"


# Singleton instance
settings = Settings()
