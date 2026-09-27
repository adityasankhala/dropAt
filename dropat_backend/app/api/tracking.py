import uuid

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_session
from app.core.security import get_current_user
from app.models.booking import Booking, BookingStatus
from app.models.driver import Driver
from app.models.trip import Trip
from app.models.user import User
from sqlalchemy import select
from app.schemas.schemas import (
    LocationBatchRequest,
    LocationResponse,
)
from app.services.tracking_service import TrackingService

router = APIRouter()


@router.post("/update", response_model=LocationResponse)
async def update_location(
    request: LocationBatchRequest,
    current_user: dict = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
):
    """
    Called by Driver app to push batch GPS updates.
    """
    result = await session.execute(
        select(Driver).join(User).where(User.firebase_uid == current_user["uid"])
    )
    driver = result.scalar_one_or_none()
    if not driver:
        raise HTTPException(status_code=403, detail="Driver profile not found")

    try:
        updates = [u.model_dump() for u in request.updates]
        location = await TrackingService.batch_update(
            session=session,
            driver_id=driver.id,
            updates=updates,
        )
        return LocationResponse(
            driver_id=location.driver_id,
            lat=location.lat,
            lng=location.lng,
            heading=location.heading,
            speed=location.speed,
            is_moving=location.is_moving,
            timestamp=location.timestamp,
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.get("/trip/{trip_id}", response_model=LocationResponse)
async def get_trip_location(
    trip_id: uuid.UUID,
    current_user: dict = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
):
    """Get a trip's latest location when the caller is a passenger or driver."""
    user_result = await session.execute(
        select(User).where(User.firebase_uid == current_user["uid"])
    )
    user = user_result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=401, detail="User not found in database")

    trip_result = await session.execute(select(Trip).where(Trip.id == trip_id))
    trip = trip_result.scalar_one_or_none()
    if not trip:
        raise HTTPException(status_code=404, detail="Trip not found")

    is_assigned_driver = False
    if trip.driver_id:
        driver_result = await session.execute(
            select(Driver).where(Driver.id == trip.driver_id, Driver.user_id == user.id)
        )
        is_assigned_driver = driver_result.scalar_one_or_none() is not None

    booking_result = await session.execute(
        select(Booking).where(
            Booking.trip_id == trip_id,
            Booking.user_id == user.id,
            Booking.status.notin_([BookingStatus.CANCELLED, BookingStatus.REFUNDED]),
        )
    )
    if not is_assigned_driver and booking_result.scalar_one_or_none() is None:
        raise HTTPException(status_code=403, detail="You do not have access to this trip")

    location = await TrackingService.get_trip_location(session, trip_id)
    if not location:
        raise HTTPException(status_code=404, detail="Location not found")
        
    return LocationResponse(
        driver_id=location.driver_id,
        lat=location.lat,
        lng=location.lng,
        heading=location.heading,
        speed=location.speed,
        is_moving=location.is_moving,
        timestamp=location.timestamp,
    )
