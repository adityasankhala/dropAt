"""
DropAt Backend — Core Configuration
────────────────────────────────────
Centralized settings loaded from environment variables.
Uses pydantic-settings for automatic validation and type coercion.
"""

from typing import List
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
    CORS_ORIGINS: List[str] = ["*"]

    # ── Database ─────────────────────────────────
    DATABASE_URL: str = "postgresql+asyncpg://postgres:postgres@localhost:5432/dropat"

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

    @property
    def is_production(self) -> bool:
        return self.APP_ENV == "production"

    @property
    def is_development(self) -> bool:
        return self.APP_ENV == "development"


# Singleton instance
settings = Settings()
