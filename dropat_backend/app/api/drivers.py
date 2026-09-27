import uuid
from typing import List

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.core.database import get_session
from app.core.security import get_current_user
from app.models.driver import Driver
from app.models.trip import Trip
from app.models.booking import Booking, BookingStatus, BookingType
from app.schemas.schemas import (
    DriverToggleRequest,
    DriverStatusResponse,
    TripManifestResponse,
    ManifestPassenger,
)
from app.services.tracking_service import TrackingService

router = APIRouter()

async def get_current_driver(
    current_user: dict = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
) -> Driver:
    from app.models.user import User
    result = await session.execute(
        select(Driver).join(User).where(User.firebase_uid == current_user["uid"])
    )
    driver = result.scalar_one_or_none()
    if not driver:
        raise HTTPException(status_code=403, detail="Driver profile not found")
    return driver

@router.post("/toggle-online", response_model=DriverStatusResponse)
async def toggle_online(
    request: DriverToggleRequest,
    driver: Driver = Depends(get_current_driver),
    session: AsyncSession = Depends(get_session),
):
    """Toggle driver online/offline status."""
    driver.is_online = request.is_online
    
    if request.is_online and request.lat and request.lng:
        driver.current_lat = request.lat
        driver.current_lng = request.lng
        # Also create initial location update
        await TrackingService.update_location(
            session=session,
            driver_id=driver.id,
            lat=request.lat,
            lng=request.lng,
        )
    elif not request.is_online:
        # Clear location when going offline
        await TrackingService.clear_driver_location(session, driver.id)
        
    session.add(driver)
    await session.flush()
    
    # We should join user to get rating, but returning dummy rating for now
    return DriverStatusResponse(
        is_online=driver.is_online,
        total_trips=driver.total_trips,
        total_earnings=driver.total_earnings,
        rating=4.9, 
    )

@router.get("/manifest/{trip_id}", response_model=TripManifestResponse)
async def get_trip_manifest(
    trip_id: uuid.UUID,
    driver: Driver = Depends(get_current_driver),
    session: AsyncSession = Depends(get_session),
):
    """Get the passenger manifest for a specific shuttle trip."""
    # Ensure driver is assigned to this trip (or just allow if admin, here simplified)
    trip_result = await session.execute(
        select(Trip)
        .options(selectinload(Trip.route))
        .where(Trip.id == trip_id)
    )
    trip = trip_result.scalar_one_or_none()
    if not trip:
        raise HTTPException(status_code=404, detail="Trip not found")
    if trip.driver_id != driver.id:
        raise HTTPException(status_code=403, detail="You are not assigned to this trip")
        
    # Get all confirmed bookings for this trip
    booking_result = await session.execute(
        select(Booking)
        .options(selectinload(Booking.user))
        .where(
            Booking.trip_id == trip_id,
            Booking.booking_type == BookingType.SHUTTLE,
            Booking.status.in_([BookingStatus.CONFIRMED, BookingStatus.STARTED, BookingStatus.COMPLETED]),
        )
    )
    bookings = booking_result.scalars().all()
    
    passengers = []
    for b in bookings:
        passengers.append(
            ManifestPassenger(
                name=b.user.name if b.user else "Unknown",
                phone=b.user.phone if b.user else "",
                boarding_stop=b.boarding_stop_name or "",
                alighting_stop=b.alighting_stop_name or "",
                status=b.status.value,
            )
        )
        
    return TripManifestResponse(
        trip_id=trip.id,
        route_name=trip.route.name if trip.route else "",
        departure_time=trip.departure_time.strftime("%I:%M %p"),
        passengers=passengers,
        total_booked=len(passengers),
    )
