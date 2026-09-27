"""
Driver Model
Links a User to their driver profile and assigned vehicle.
"""

import uuid
from datetime import datetime
from typing import Optional, List

from sqlmodel import SQLModel, Field, Relationship

class Driver(SQLModel, table=True):
    """
    Driver profile linked to a User.
    A driver has an assigned vehicle and online/offline status.
    """

    __tablename__ = "drivers"

    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    user_id: uuid.UUID = Field(foreign_key="users.id", unique=True, index=True)
    vehicle_id: Optional[uuid.UUID] = Field(
        default=None, foreign_key="vehicles.id", index=True
    )
    license_number: str = Field(max_length=50, default="")
    is_verified: bool = Field(default=False)
    is_online: bool = Field(default=False)
    current_lat: Optional[float] = Field(default=None)
    current_lng: Optional[float] = Field(default=None)
    heading: Optional[float] = Field(default=None)  # Compass bearing 0-360
    speed: Optional[float] = Field(default=None)  # km/h
    total_trips: int = Field(default=0)
    total_earnings: float = Field(default=0.0)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    # Relationships
    user: Optional["User"] = Relationship(back_populates="driver")  # noqa: F821
    vehicle: Optional["Vehicle"] = Relationship(  # noqa: F821
        sa_relationship_kwargs={"foreign_keys": "[Driver.vehicle_id]"}
    )
