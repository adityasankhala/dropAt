"""
DropAt — Booking Service
─────────────────────────
Core business logic for shuttle and ride bookings.
Handles seat availability, atomic reservations, and cancellations.
"""

import uuid
from datetime import datetime
from typing import Optional

from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.models.booking import Booking, BookingStatus, BookingType
from app.models.trip import Trip, TripStatus
from app.models.route import Route
from app.models.waypoint import Waypoint
from app.models.voucher import Voucher
from app.models.user import User
from app.models.driver import Driver


class BookingService:
    """Business logic for booking operations."""

    @staticmethod
    async def create_shuttle_booking(
        session: AsyncSession,
        user_id: uuid.UUID,
        trip_id: uuid.UUID,
        boarding_stop_name: str,
        alighting_stop_name: str,
        boarding_stop_lat: Optional[float],
        boarding_stop_lng: Optional[float],
        alighting_stop_lat: Optional[float],
        alighting_stop_lng: Optional[float],
        schedule_time: str,
        payment_method: str = "CASH",
        voucher_code: Optional[str] = None,
    ) -> Booking:
        """
        Create a shuttle seat booking with atomic seat decrement.
        Raises ValueError if no seats available or trip not found.
        """
        # 1. Fetch the trip and check availability
        trip_result = await session.execute(
            select(Trip).where(Trip.id == trip_id).with_for_update()
        )
        trip = trip_result.scalar_one_or_none()
        if trip is None:
            raise ValueError("Trip not found")
        if trip.status == TripStatus.CANCELLED:
            raise ValueError("This trip has been cancelled")
        if trip.is_full:
            raise ValueError("No seats available on this trip")

        # 2. Fetch the route for pricing
        route = await session.get(Route, trip.route_id)
        if route is None:
            raise ValueError("Route not found for this trip")

        # Only persisted route stops can be selected, and riders must travel
        # forward along the route.  This prevents arbitrary pickup/drop values
        # from becoming booking records.
        waypoint_result = await session.execute(
            select(Waypoint)
            .where(Waypoint.route_id == route.id)
            .order_by(Waypoint.order)
        )
        waypoints = waypoint_result.scalars().all()
        stops = {waypoint.name: waypoint.order for waypoint in waypoints}
        if boarding_stop_name not in stops or alighting_stop_name not in stops:
            raise ValueError("Boarding and alighting stops must belong to the route")
        if stops[boarding_stop_name] >= stops[alighting_stop_name]:
            raise ValueError("Alighting stop must be after boarding stop")

        # 3. Check for duplicate booking
        existing = await session.execute(
            select(Booking).where(
                Booking.user_id == user_id,
                Booking.trip_id == trip_id,
                Booking.status.notin_([BookingStatus.CANCELLED, BookingStatus.REFUNDED]),
            )
        )
        if existing.scalar_one_or_none():
            raise ValueError("You already have a booking on this trip")

        # 4. Calculate fare with optional voucher
        fare = route.price
        discount = 0.0
        voucher_id = None

        if voucher_code:
            voucher_result = await session.execute(
                select(Voucher).where(
                    Voucher.code == voucher_code.upper().strip(),
                    Voucher.is_active == True,
                ).with_for_update()
            )
            voucher = voucher_result.scalar_one_or_none()
            if voucher and voucher.is_valid:
                discount = voucher.calculate_discount(fare)
                voucher_id = voucher.id
                # Increment usage
                voucher.used_count += 1
                session.add(voucher)

        total_paid = max(0, fare - discount)

        # 5. Create the booking
        booking = Booking(
            user_id=user_id,
            trip_id=trip_id,
            booking_type=BookingType.SHUTTLE,
            status=(
                BookingStatus.CONFIRMED
                if payment_method.upper() == "CASH" or total_paid == 0
                else BookingStatus.PENDING
            ),
            boarding_stop_name=boarding_stop_name,
            alighting_stop_name=alighting_stop_name,
            boarding_stop_lat=boarding_stop_lat,
            boarding_stop_lng=boarding_stop_lng,
            alighting_stop_lat=alighting_stop_lat,
            alighting_stop_lng=alighting_stop_lng,
            fare=fare,
            discount_amount=discount,
            total_paid=total_paid,
            payment_method=payment_method,
            voucher_id=voucher_id,
            schedule_time=trip.departure_time.strftime("%I:%M %p"),
        )
        session.add(booking)

        # 6. Atomically increment booked seats
        trip.booked_seats += 1
        trip.updated_at = datetime.utcnow()
        session.add(trip)

        await session.flush()
        return booking

    @staticmethod
    async def create_ride_booking(
        session: AsyncSession,
        user_id: uuid.UUID,
        trip_id: uuid.UUID,
        vehicle_type: str,
        fare: float,
        discount: float,
        total_paid: float,
        payment_method: str,
        voucher_id: Optional[uuid.UUID] = None,
    ) -> Booking:
        """Create an on-demand ride booking (Phase 2)."""
        booking = Booking(
            user_id=user_id,
            trip_id=trip_id,
            booking_type=BookingType.RIDE,
            status=BookingStatus.REQUESTED,
            vehicle_type=vehicle_type,
            fare=fare,
            discount_amount=discount,
            total_paid=total_paid,
            payment_method=payment_method,
            voucher_id=voucher_id,
        )
        session.add(booking)
        await session.flush()
        return booking

    @staticmethod
    async def cancel_booking(
        session: AsyncSession,
        booking_id: uuid.UUID,
        user_id: uuid.UUID,
        reason: str,
    ) -> Booking:
        """Cancel a booking and free up the seat."""
        booking = await session.get(Booking, booking_id)
        if booking is None:
            raise ValueError("Booking not found")
        if booking.user_id != user_id:
            raise ValueError("You can only cancel your own bookings")
        if booking.status in (BookingStatus.COMPLETED, BookingStatus.CANCELLED):
            raise ValueError(f"Cannot cancel a {booking.status.value} booking")

        booking.status = BookingStatus.CANCELLED
        booking.cancellation_reason = reason
        booking.cancelled_by = "user"
        booking.updated_at = datetime.utcnow()
        session.add(booking)

        # Free up the seat on the trip
        if booking.booking_type == BookingType.SHUTTLE:
            trip = await session.get(Trip, booking.trip_id)
            if trip:
                trip.booked_seats = max(0, trip.booked_seats - 1)
                trip.updated_at = datetime.utcnow()
                session.add(trip)

        await session.flush()
        return booking

    @staticmethod
    async def get_user_bookings(
        session: AsyncSession,
        user_id: uuid.UUID,
        booking_type: Optional[str] = None,
        status: Optional[str] = None,
        limit: int = 50,
        offset: int = 0,
    ) -> tuple[list[Booking], int]:
        """Get paginated bookings for a user."""
        query = (
            select(Booking)
            .options(selectinload(Booking.trip).selectinload(Trip.route))
            .where(Booking.user_id == user_id)
        )

        if booking_type:
            query = query.where(Booking.booking_type == booking_type)
        if status:
            if status == "active":
                query = query.where(
                    Booking.status.in_([
                        BookingStatus.PENDING,
                        BookingStatus.CONFIRMED,
                        BookingStatus.REQUESTED,
                        BookingStatus.SEARCHING,
                        BookingStatus.ACCEPTED,
                        BookingStatus.DRIVER_EN_ROUTE,
                        BookingStatus.ARRIVED,
                        BookingStatus.STARTED,
                    ])
                )
            else:
                query = query.where(Booking.status == status)

        # Count total
        count_query = select(func.count()).select_from(query.subquery())
        total = (await session.execute(count_query)).scalar() or 0

        # Fetch with pagination
        query = query.order_by(Booking.created_at.desc()).offset(offset).limit(limit)
        result = await session.execute(query)
        bookings = list(result.scalars().all())

        return bookings, total

    @staticmethod
    async def get_booking_by_id(
        session: AsyncSession,
        booking_id: uuid.UUID,
    ) -> Optional[Booking]:
        """Get a single booking by ID."""
        return await session.get(Booking, booking_id)

    @staticmethod
    async def update_booking_status(
        session: AsyncSession,
        booking_id: uuid.UUID,
        new_status: BookingStatus,
        driver_id: Optional[uuid.UUID] = None,
    ) -> Booking:
        """Update booking status (used by drivers and system)."""
        booking = await session.get(Booking, booking_id)
        if booking is None:
            raise ValueError("Booking not found")

        booking.status = new_status
        booking.updated_at = datetime.utcnow()
        if driver_id:
            booking.driver_id = driver_id
        session.add(booking)
        await session.flush()
        return booking
