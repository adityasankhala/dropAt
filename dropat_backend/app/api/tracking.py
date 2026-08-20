import uuid

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_session
from app.core.security import get_current_user
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
    from app.models.user import User
    from app.models.driver import Driver
    from sqlalchemy import select
    
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
    session: AsyncSession = Depends(get_session),
):
    """Get latest location for a trip's driver."""
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
