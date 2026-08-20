"""
DropAt Models Package
─────────────────────
All SQLModel database models for the DropAt platform.
Import all models here so SQLModel.metadata.create_all() picks them up.
"""

from app.models.user import User, SavedPlace
from app.models.vehicle import Vehicle, VehicleType
from app.models.driver import Driver
from app.models.route import Route
from app.models.waypoint import Waypoint
from app.models.trip import Trip, TripMode
from app.models.booking import Booking, BookingType, BookingStatus
from app.models.payment import Payment, PaymentStatus, PaymentMethod
from app.models.location_update import LocationUpdate
from app.models.voucher import Voucher
from app.models.review import Review

__all__ = [
    "User",
    "SavedPlace",
    "Vehicle",
    "VehicleType",
    "Driver",
    "Route",
    "Waypoint",
    "Trip",
    "TripMode",
    "Booking",
    "BookingType",
    "BookingStatus",
    "Payment",
    "PaymentStatus",
    "PaymentMethod",
    "LocationUpdate",
    "Voucher",
    "Review",
]
