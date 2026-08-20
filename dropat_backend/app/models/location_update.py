"""
Location Update Model
──────────────────────
GPS pings from drivers.
Written to the database; Supabase Realtime broadcasts changes
to subscribed passenger apps.
"""

import uuid
from datetime import datetime
from typing import Optional

from sqlmodel import SQLModel, Field


class LocationUpdate(SQLModel, table=True):
    """
    GPS location ping from a driver.
    
    The driver app batch-pushes GPS coordinates every 3-5 seconds.
    The backend writes to this table, and Supabase Realtime
    automatically broadcasts the INSERT/UPDATE to subscribed clients.

    We use a single row per driver (upsert pattern) rather than
    appending rows to avoid table bloat. Historical tracking data
    is stored in `location_history` for analytics (Phase 2).
    """

    __tablename__ = "location_updates"

    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    driver_id: uuid.UUID = Field(foreign_key="drivers.id", unique=True, index=True)
    trip_id: Optional[uuid.UUID] = Field(
        default=None, foreign_key="trips.id", index=True
    )
    lat: float
    lng: float
    heading: Optional[float] = Field(default=None)  # Compass bearing 0-360
    speed: Optional[float] = Field(default=None)  # km/h
    accuracy: Optional[float] = Field(default=None)  # GPS accuracy in meters
    battery_level: Optional[int] = Field(default=None)  # 0-100
    is_moving: bool = Field(default=True)
    timestamp: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)
