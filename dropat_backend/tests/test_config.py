import pytest
from pydantic import ValidationError

from app.core.config import Settings


def production_settings(**overrides):
    values = {
        "APP_ENV": "production",
        "APP_DEBUG": False,
        "AUTO_CREATE_SCHEMA": False,
        "DATABASE_URL": "postgresql+asyncpg://dropat:strong-password@db:5432/dropat",
        "CORS_ORIGINS": ["https://app.dropat.example"],
        "TRUSTED_HOSTS": ["api.dropat.example"],
        "FIREBASE_PROJECT_ID": "dropat-production",
        "ADMIN_USERNAME": "admin",
        "ADMIN_PASSWORD": "a-long-unique-production-password",
        "ALLOW_DEV_PAYMENT_FALLBACK": False,
        "PAYMENTS_ENABLED": False,
    }
    values.update(overrides)
    return Settings(**values)


def test_safe_production_configuration_is_accepted():
    settings = production_settings()
    assert settings.is_production


@pytest.mark.parametrize(
    "overrides",
    [
        {"APP_DEBUG": True},
        {"AUTO_CREATE_SCHEMA": True},
        {"CORS_ORIGINS": ["*"]},
        {"TRUSTED_HOSTS": ["*"]},
        {"ALLOW_DEV_PAYMENT_FALLBACK": True},
        {"ADMIN_PASSWORD": ""},
    ],
)
def test_unsafe_production_configuration_is_rejected(overrides):
    with pytest.raises(ValidationError):
        production_settings(**overrides)
