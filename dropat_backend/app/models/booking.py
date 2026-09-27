"""
Booking Model
A user's reservation on a trip.
"""

import uuid
from datetime import datetime
from enum import Enum
from typing import Optional

from sqlmodel import SQLModel, Field, Relationship

class BookingType(str, Enum):
    """Booking type — shuttle seat vs individual ride."""
    SHUTTLE = "shuttle"
    RIDE = "ride"  # Phase 2

class BookingStatus(str, Enum):
    """Booking lifecycle status."""
    PENDING = "pending"  # Payment not yet completed
    CONFIRMED = "confirmed"  # Payment received, seat reserved
    REQUESTED = "requested"  #     SEARCHING = "searching"  #     ACCEPTED = "accepted"  # Driver accepted
    DRIVER_EN_ROUTE = "driver_en_route"  # Driver on way to pickup
    ARRIVED = "arrived"  # Driver at pickup
    STARTED = "started"  # Ride in progress
    COMPLETED = "completed"  # Ride finished
    CANCELLED = "cancelled"  # Cancelled by user or driver
    REFUNDED = "refunded"  # Payment refunded

class Booking(SQLModel, table=True):
    """
    Unified booking entity for both shuttle seats and individual rides.
    """

    __tablename__ = "bookings"

    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    user_id: uuid.UUID = Field(foreign_key="users.id", index=True)
    trip_id: uuid.UUID = Field(foreign_key="trips.id", index=True)
    booking_type: BookingType = Field(default=BookingType.SHUTTLE, index=True)
    status: BookingStatus = Field(default=BookingStatus.PENDING, index=True)

    # Shuttle-specific: boarding and alighting stops
    boarding_stop_name: Optional[str] = Field(default=None, max_length=200)
    boarding_stop_lat: Optional[float] = Field(default=None)
    boarding_stop_lng: Optional[float] = Field(default=None)
    alighting_stop_name: Optional[str] = Field(default=None, max_length=200)
    alighting_stop_lat: Optional[float] = Field(default=None)
    alighting_stop_lng: Optional[float] = Field(default=None)

    # Pricing
    fare: float = Field(default=0.0)
    discount_amount: float = Field(default=0.0)
    total_paid: float = Field(default=0.0)
    payment_method: str = Field(default="CASH", max_length=20)
    voucher_id: Optional[uuid.UUID] = Field(default=None, foreign_key="vouchers.id")

    # Cancellation
    cancellation_reason: Optional[str] = Field(default=None, max_length=500)
    cancelled_by: Optional[str] = Field(
        default=None, max_length=10
    )  # "user" or "driver"

    # Schedule reference
    schedule_time: Optional[str] = Field(
        default=None, max_length=20
    )  # e.g. "08:00 AM"

    #     vehicle_type: Optional[str] = Field(default=None, max_length=20)
    driver_id: Optional[uuid.UUID] = Field(
        default=None, foreign_key="drivers.id", index=True
    )

    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    # Relationships
    user: Optional["User"] = Relationship(back_populates="bookings")  # noqa: F821
    trip: Optional["Trip"] = Relationship(back_populates="bookings")  # noqa: F821
