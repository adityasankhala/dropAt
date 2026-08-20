"""
Route Model
────────────
A named shuttle route (e.g., "Hostel → College").
Routes are templates — actual departures are Trip instances.
"""

import uuid
from datetime import datetime
from typing import Optional, List

from sqlmodel import SQLModel, Field, Relationship, Column, JSON


class Route(SQLModel, table=True):
    """
    A shuttle route definition with schedule metadata.
    Waypoints (stops) are stored in the Waypoint table.
    """

    __tablename__ = "routes"

    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    name: str = Field(max_length=200, index=True)  # e.g. "Hostel → College"
    description: Optional[str] = Field(default=None, max_length=500)
    price: float = Field(default=0.0)  # Base price in INR
    total_seats: int = Field(default=25)
    is_active: bool = Field(default=True)
    # Schedule stored as JSON: [{"departure_time": "08:00", "days": ["Mon","Tue",...]}]
    schedule: Optional[list] = Field(default=None, sa_column=Column(JSON))
    estimated_duration_min: Optional[int] = Field(default=None)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    # Relationships
    waypoints: List["Waypoint"] = Relationship(back_populates="route")  # noqa: F821
    trips: List["Trip"] = Relationship(back_populates="route")  # noqa: F821
