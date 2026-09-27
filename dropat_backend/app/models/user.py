"""
User Model
Represents both passengers and drivers (unified identity).
Firebase Auth is the source of truth for authentication;
this table stores profile data and app-specific fields.
"""

import uuid
from datetime import datetime
from typing import Optional, List

from sqlmodel import SQLModel, Field, Relationship, Column, JSON

class SavedPlace(SQLModel, table=True):
    """User's saved/favourite locations (Home, Work, etc.)."""

    __tablename__ = "saved_places"

    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    user_id: uuid.UUID = Field(foreign_key="users.id", index=True)
    name: str = Field(max_length=100)  # e.g. "Home", "College"
    address: str = Field(max_length=500)
    lat: float
    lng: float
    created_at: datetime = Field(default_factory=datetime.utcnow)

    # Relationships
    user: Optional["User"] = Relationship(back_populates="saved_places")

class User(SQLModel, table=True):
    """
    Core user profile.
    `firebase_uid` links to Firebase Auth.
    A user can be both a passenger and a driver (via Driver table).
    """

    __tablename__ = "users"

    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    firebase_uid: str = Field(unique=True, index=True, max_length=128)
    name: str = Field(max_length=200, default="User")
    phone: str = Field(max_length=20, default="")
    email: Optional[str] = Field(default=None, max_length=255)
    photo_url: Optional[str] = Field(default=None, max_length=500)
    rating: float = Field(default=5.0)
    wallet_balance: float = Field(default=0.0)
    is_active: bool = Field(default=True)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    # Relationships
    saved_places: List[SavedPlace] = Relationship(back_populates="user")
    driver: Optional["Driver"] = Relationship(  # noqa: F821
        back_populates="user",
        sa_relationship_kwargs={"uselist": False},
    )
    bookings: List["Booking"] = Relationship(back_populates="user")  # noqa: F821
    reviews: List["Review"] = Relationship(back_populates="user")  # noqa: F821
