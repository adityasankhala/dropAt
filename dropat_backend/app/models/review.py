"""
Review Model
Ratings and feedback for completed trips.
"""

import uuid
from datetime import datetime
from typing import Optional

from sqlmodel import SQLModel, Field, Relationship

class Review(SQLModel, table=True):
    """
    Post-trip review from a user.
    """

    __tablename__ = "reviews"

    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    booking_id: uuid.UUID = Field(foreign_key="bookings.id", unique=True, index=True)
    user_id: uuid.UUID = Field(foreign_key="users.id", index=True)
    driver_id: Optional[uuid.UUID] = Field(
        default=None, foreign_key="drivers.id", index=True
    )
    rating: float = Field(ge=1.0, le=5.0)
    feedback: Optional[str] = Field(default=None, max_length=1000)
    tip_amount: Optional[float] = Field(default=None)
    created_at: datetime = Field(default_factory=datetime.utcnow)

    # Relationships
    user: Optional["User"] = Relationship(back_populates="reviews")  # noqa: F821
