"""
DropAt — Tracking Service
──────────────────────────
Processes GPS updates from drivers and writes to the database.
Supabase Realtime automatically broadcasts the changes to subscribed clients.
"""

import uuid
from datetime import datetime
from typing import Optional, List

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.location_update import LocationUpdate
from app.models.driver import Driver


class TrackingService:
    """
    GPS tracking service.
    
    Architecture:
    1. Driver app pushes GPS batch to POST /tracking/update
    2. This service validates and upserts into location_updates table
    3. Supabase Realtime detects the INSERT/UPDATE and broadcasts
       to all Flutter clients subscribed to the relevant trip_id channel
    4. Flutter user app receives the event and updates the map marker
    """

    @staticmethod
    async def update_location(
        session: AsyncSession,
        driver_id: uuid.UUID,
        lat: float,
        lng: float,
        heading: Optional[float] = None,
        speed: Optional[float] = None,
        accuracy: Optional[float] = None,
        battery_level: Optional[int] = None,
        is_moving: bool = True,
        trip_id: Optional[uuid.UUID] = None,
    ) -> LocationUpdate:
        """
        Upsert a driver's current location.
        Uses upsert pattern (one row per driver) to avoid table bloat.
        """
        # Check for existing location record for this driver
        result = await session.execute(
            select(LocationUpdate).where(LocationUpdate.driver_id == driver_id)
        )
        location = result.scalar_one_or_none()

        now = datetime.utcnow()

        if location:
            # Update existing record
            location.lat = lat
            location.lng = lng
            location.heading = heading
            location.speed = speed
            location.accuracy = accuracy
            location.battery_level = battery_level
            location.is_moving = is_moving
            location.trip_id = trip_id
            location.timestamp = now
            location.updated_at = now
        else:
            # Create new record
            location = LocationUpdate(
                driver_id=driver_id,
                trip_id=trip_id,
                lat=lat,
                lng=lng,
                heading=heading,
                speed=speed,
                accuracy=accuracy,
                battery_level=battery_level,
                is_moving=is_moving,
                timestamp=now,
                updated_at=now,
            )

        session.add(location)

        # Also update driver's current position
        driver = await session.get(Driver, driver_id)
        if driver:
            driver.current_lat = lat
            driver.current_lng = lng
            driver.heading = heading
            driver.speed = speed
            driver.updated_at = now
            session.add(driver)

        await session.flush()
        return location

    @staticmethod
    async def batch_update(
        session: AsyncSession,
        driver_id: uuid.UUID,
        updates: List[dict],
    ) -> LocationUpdate:
        """
        Process a batch of GPS updates.
        We only keep the latest position (upsert pattern).
        In production, you'd also write to a time-series table for analytics.
        """
        if not updates:
            raise ValueError("No updates provided")

        # Use the last (most recent) update in the batch
        latest = updates[-1]
        return await TrackingService.update_location(
            session=session,
            driver_id=driver_id,
            lat=latest["lat"],
            lng=latest["lng"],
            heading=latest.get("heading"),
            speed=latest.get("speed"),
            accuracy=latest.get("accuracy"),
            battery_level=latest.get("battery_level"),
            is_moving=latest.get("is_moving", True),
            trip_id=latest.get("trip_id"),
        )

    @staticmethod
    async def get_trip_location(
        session: AsyncSession,
        trip_id: uuid.UUID,
    ) -> Optional[LocationUpdate]:
        """Get the latest location for a specific trip's driver."""
        result = await session.execute(
            select(LocationUpdate).where(LocationUpdate.trip_id == trip_id)
        )
        return result.scalar_one_or_none()

    @staticmethod
    async def get_driver_location(
        session: AsyncSession,
        driver_id: uuid.UUID,
    ) -> Optional[LocationUpdate]:
        """Get the latest location for a specific driver."""
        result = await session.execute(
            select(LocationUpdate).where(LocationUpdate.driver_id == driver_id)
        )
        return result.scalar_one_or_none()

    @staticmethod
    async def clear_driver_location(
        session: AsyncSession,
        driver_id: uuid.UUID,
    ) -> None:
        """Remove a driver's location when they go offline."""
        result = await session.execute(
            select(LocationUpdate).where(LocationUpdate.driver_id == driver_id)
        )
        location = result.scalar_one_or_none()
        if location:
            await session.delete(location)
            await session.flush()
