import uuid
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.core.database import get_session
from app.core.security import get_current_user
from app.models.booking import Booking, BookingStatus, BookingType
from app.schemas.schemas import (
    ShuttleBookingRequest,
    RideBookingRequest,
    BookingResponse,
    BookingListResponse,
    CancelBookingRequest,
)
from app.services.booking_service import BookingService

router = APIRouter()


def _format_booking_response(booking: Booking) -> BookingResponse:
    return BookingResponse(
        id=booking.id,
        booking_type=booking.booking_type,
        status=booking.status,
        trip_id=booking.trip_id,
        boarding_stop_name=booking.boarding_stop_name,
        alighting_stop_name=booking.alighting_stop_name,
        fare=booking.fare,
        discount_amount=booking.discount_amount,
        total_paid=booking.total_paid,
        payment_method=booking.payment_method,
        schedule_time=booking.schedule_time,
        vehicle_type=booking.vehicle_type,
        cancellation_reason=booking.cancellation_reason,
        created_at=booking.created_at,
        updated_at=booking.updated_at,
        # Driver details are deliberately omitted until they are loaded from
        # persisted relations. Returning invented data here is misleading.
        route_name=booking.trip.route.name if booking.trip and booking.trip.route else None,
        driver_name=None,
        vehicle_number=None,
    )


@router.post("/shuttle", response_model=BookingResponse)
async def book_shuttle(
    request: ShuttleBookingRequest,
    current_user: dict = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
):
    """Book a seat on a shuttle trip."""
    try:
        from app.models.user import User
        from sqlalchemy import select
        result = await session.execute(select(User).where(User.firebase_uid == current_user["uid"]))
        user = result.scalar_one_or_none()
        if not user:
            raise HTTPException(status_code=401, detail="User not found in database")
            
        booking = await BookingService.create_shuttle_booking(
            session=session,
            user_id=user.id,
            trip_id=request.trip_id,
            boarding_stop_name=request.boarding_stop_name,
            alighting_stop_name=request.alighting_stop_name,
            boarding_stop_lat=request.boarding_stop_lat,
            boarding_stop_lng=request.boarding_stop_lng,
            alighting_stop_lat=request.alighting_stop_lat,
            alighting_stop_lng=request.alighting_stop_lng,
            schedule_time=request.schedule_time,
            payment_method=request.payment_method,
            voucher_code=request.voucher_code,
        )
        return _format_booking_response(booking)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.get("/me", response_model=BookingListResponse)
async def get_my_bookings(
    booking_type: Optional[str] = None,
    status: Optional[str] = None,
    limit: int = 50,
    offset: int = 0,
    current_user: dict = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
):
    """Get the current user's bookings."""
    from app.models.user import User
    from sqlalchemy import select
    result = await session.execute(select(User).where(User.firebase_uid == current_user["uid"]))
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=401, detail="User not found in database")

    bookings, total = await BookingService.get_user_bookings(
        session=session,
        user_id=user.id,
        booking_type=booking_type,
        status=status,
        limit=limit,
        offset=offset,
    )
    
    # Needs joined loads for _format_booking_response to work nicely
    # This is simplified for the boilerplate
    return BookingListResponse(
        bookings=[_format_booking_response(b) for b in bookings],
        total=total,
    )


@router.delete("/{booking_id}", response_model=BookingResponse)
async def cancel_booking(
    booking_id: uuid.UUID,
    request: CancelBookingRequest,
    current_user: dict = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
):
    """Cancel a booking."""
    from app.models.user import User
    from sqlalchemy import select
    result = await session.execute(select(User).where(User.firebase_uid == current_user["uid"]))
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=401, detail="User not found in database")

    try:
        booking = await BookingService.cancel_booking(
            session=session,
            booking_id=booking_id,
            user_id=user.id,
            reason=request.reason,
        )
        return _format_booking_response(booking)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
