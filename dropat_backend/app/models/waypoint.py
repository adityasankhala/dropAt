"""
Waypoint Model
A stop/node along a route.
"""

import uuid
from datetime import datetime
from typing import Optional

from sqlmodel import SQLModel, Field, Relationship

class Waypoint(SQLModel, table=True):
    """
    An ordered stop on a route.
    Supports both static bus stops and dynamic user pins (Phase 2).
    """

    __tablename__ = "waypoints"

    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    route_id: uuid.UUID = Field(foreign_key="routes.id", index=True)
    name: str = Field(max_length=200)  # e.g. "Boys Hostel"
    lat: float
    lng: float
    order: int = Field(default=0)  # Sequence position on the route
    is_fixed: bool = Field(default=True)  # True = bus stop, False = user pin (Phase 2)
    estimated_arrival_offset_min: Optional[int] = Field(
        default=None
    )  # Minutes from route start
    created_at: datetime = Field(default_factory=datetime.utcnow)

    # Relationships
    route: Optional["Route"] = Relationship(back_populates="waypoints")  # noqa: F821
