"""
Trip Model
A specific instance of a route being driven.
"""

import uuid
from datetime import datetime, date, time
from enum import Enum
from typing import Optional, List

from sqlmodel import SQLModel, Field, Relationship

class TripMode(str, Enum):
    """fixed_route or on_demand."""
    FIXED_ROUTE = "fixed_route"  #     ON_DEMAND = "on_demand"  # 

class TripStatus(str, Enum):
    """Trip lifecycle status."""
    SCHEDULED = "scheduled"
    BOARDING = "boarding"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    CANCELLED = "cancelled"

class Trip(SQLModel, table=True):
    """
    A specific trip instance.
    For     For     """

    __tablename__ = "trips"

    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    route_id: Optional[uuid.UUID] = Field(
        default=None, foreign_key="routes.id", index=True
    )
    driver_id: Optional[uuid.UUID] = Field(
        default=None, foreign_key="drivers.id", index=True
    )
    vehicle_id: Optional[uuid.UUID] = Field(
        default=None, foreign_key="vehicles.id", index=True
    )
    mode: TripMode = Field(default=TripMode.FIXED_ROUTE, index=True)
    status: TripStatus = Field(default=TripStatus.SCHEDULED, index=True)
    trip_date: date = Field(index=True)
    departure_time: time
    total_seats: int = Field(default=25)
    booked_seats: int = Field(default=0)

    # On-demand fields (Phase 2)
    origin_lat: Optional[float] = Field(default=None)
    origin_lng: Optional[float] = Field(default=None)
    origin_address: Optional[str] = Field(default=None, max_length=500)
    destination_lat: Optional[float] = Field(default=None)
    destination_lng: Optional[float] = Field(default=None)
    destination_address: Optional[str] = Field(default=None, max_length=500)
    distance_meters: Optional[int] = Field(default=None)
    duration_seconds: Optional[int] = Field(default=None)
    encoded_polyline: Optional[str] = Field(default=None)

    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    # Relationships
    route: Optional["Route"] = Relationship(back_populates="trips")  # noqa: F821
    bookings: List["Booking"] = Relationship(back_populates="trip")  # noqa: F821

    @property
    def available_seats(self) -> int:
        return max(0, self.total_seats - self.booked_seats)

    @property
    def is_full(self) -> bool:
        return self.available_seats <= 0
