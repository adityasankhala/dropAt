"""
Vehicle Model
Generic vehicle entity with type enum.
"""

import uuid
from datetime import datetime
from enum import Enum
from typing import Optional

from sqlmodel import SQLModel, Field

class VehicleType(str, Enum):
    """shuttle, auto, bike, mini, sedan, suv."""
    SHUTTLE = "shuttle"
    AUTO = "auto"
    BIKE = "bike"
    MINI = "mini"
    SEDAN = "sedan"
    SUV = "suv"

class Vehicle(SQLModel, table=True):
    """
    Represents a physical vehicle.
    Decoupled from the driver so a driver can switch vehicles
    and a shuttle can be shared among drivers.
    """

    __tablename__ = "vehicles"

    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    type: VehicleType = Field(index=True)
    name: str = Field(max_length=200)  # e.g. "Maruti Suzuki Eeco"
    number_plate: str = Field(max_length=20, unique=True)  # e.g. "RJ 14 AB 1234"
    capacity: int = Field(default=4)  # Total passenger seats
    color: Optional[str] = Field(default=None, max_length=50)
    model_year: Optional[int] = Field(default=None)
    is_active: bool = Field(default=True)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)
