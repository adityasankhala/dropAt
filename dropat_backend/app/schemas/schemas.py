"""
DropAt API — Pydantic Request/Response Schemas
────────────────────────────────────────────────
Type-safe API contracts for all endpoints.
"""

import uuid
from datetime import datetime, date, time
from typing import Optional, List

from pydantic import BaseModel, Field, ConfigDict


# ═══════════════════════════════════════════════
# Auth Schemas
# ═══════════════════════════════════════════════

class AuthVerifyRequest(BaseModel):
    """Sent after Firebase login to sync user profile."""
    name: Optional[str] = None
    phone: Optional[str] = None
    email: Optional[str] = None
    photo_url: Optional[str] = None


class AuthVerifyResponse(BaseModel):
    """Returned after successful auth verification."""
    user_id: uuid.UUID
    firebase_uid: str
    name: str
    is_new_user: bool


# ═══════════════════════════════════════════════
# User Schemas
# ═══════════════════════════════════════════════

class SavedPlaceSchema(BaseModel):
    id: Optional[uuid.UUID] = None
    name: str
    address: str
    lat: float
    lng: float


class UserProfileResponse(BaseModel):
    id: uuid.UUID
    firebase_uid: str
    name: str
    phone: str
    email: Optional[str]
    photo_url: Optional[str]
    rating: float
    wallet_balance: float
    saved_places: List[SavedPlaceSchema] = []
    created_at: datetime


class UserProfileUpdate(BaseModel):
    name: Optional[str] = None
    phone: Optional[str] = None
    email: Optional[str] = None
    photo_url: Optional[str] = None


# ═══════════════════════════════════════════════
# Route & Waypoint Schemas
# ═══════════════════════════════════════════════

class WaypointSchema(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: uuid.UUID
    name: str
    lat: float
    lng: float
    order: int
    is_fixed: bool = True
    estimated_arrival_offset_min: Optional[int] = None


class ScheduleSchema(BaseModel):
    departure_time: str  # e.g. "08:00 AM"
    days: List[str]  # e.g. ["Mon", "Tue", ...]


class RouteResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: uuid.UUID
    name: str
    description: Optional[str]
    price: float
    total_seats: int
    schedule: Optional[List[ScheduleSchema]] = None
    estimated_duration_min: Optional[int]
    waypoints: List[WaypointSchema] = []
    is_active: bool


class RouteListResponse(BaseModel):
    routes: List[RouteResponse]
    total: int


# ═══════════════════════════════════════════════
# Trip Schemas
# ═══════════════════════════════════════════════

class TripResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: uuid.UUID
    route_id: Optional[uuid.UUID]
    route_name: Optional[str] = None
    mode: str
    status: str
    trip_date: date
    departure_time: time
    total_seats: int
    booked_seats: int
    available_seats: int
    stops: List[WaypointSchema] = []


class TripListResponse(BaseModel):
    trips: List[TripResponse]
    total: int


# ═══════════════════════════════════════════════
# Booking Schemas
# ═══════════════════════════════════════════════

class ShuttleBookingRequest(BaseModel):
    """Request to book a shuttle seat."""
    trip_id: uuid.UUID
    boarding_stop_name: str
    alighting_stop_name: str
    boarding_stop_lat: Optional[float] = None
    boarding_stop_lng: Optional[float] = None
    alighting_stop_lat: Optional[float] = None
    alighting_stop_lng: Optional[float] = None
    schedule_time: str  # e.g. "08:00 AM"
    payment_method: str = "CASH"
    voucher_code: Optional[str] = None


class RideBookingRequest(BaseModel):
    """Request to book an on-demand ride (Phase 2)."""
    pickup_lat: float
    pickup_lng: float
    drop_lat: float
    drop_lng: float
    pickup_address: str
    drop_address: str
    vehicle_type: str  # "BIKE", "AUTO", "MINI", etc.
    payment_method: str = "CASH"
    voucher_code: Optional[str] = None


class BookingResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: uuid.UUID
    booking_type: str
    status: str
    trip_id: uuid.UUID
    boarding_stop_name: Optional[str]
    alighting_stop_name: Optional[str]
    fare: float
    discount_amount: float
    total_paid: float
    payment_method: str
    schedule_time: Optional[str]
    vehicle_type: Optional[str]
    cancellation_reason: Optional[str]
    created_at: datetime
    updated_at: datetime

    # Joined data
    route_name: Optional[str] = None
    driver_name: Optional[str] = None
    driver_phone: Optional[str] = None
    driver_rating: Optional[float] = None
    vehicle_number: Optional[str] = None


class BookingListResponse(BaseModel):
    bookings: List[BookingResponse]
    total: int


class CancelBookingRequest(BaseModel):
    reason: str = Field(max_length=500)


# ═══════════════════════════════════════════════
# Payment Schemas
# ═══════════════════════════════════════════════

class CreatePaymentOrderRequest(BaseModel):
    booking_id: uuid.UUID
    amount: float
    method: str = "upi"  # upi, card, wallet


class CreatePaymentOrderResponse(BaseModel):
    order_id: str  # Razorpay order ID
    amount: int  # Amount in paise
    currency: str
    key_id: str  # Razorpay key for client


class VerifyPaymentRequest(BaseModel):
    razorpay_order_id: str
    razorpay_payment_id: str
    razorpay_signature: str


class PaymentResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: uuid.UUID
    booking_id: uuid.UUID
    amount: float
    method: str
    status: str
    razorpay_order_id: Optional[str]
    created_at: datetime


# ═══════════════════════════════════════════════
# Tracking Schemas
# ═══════════════════════════════════════════════

class LocationUpdateRequest(BaseModel):
    """Batch GPS update from driver."""
    lat: float
    lng: float
    heading: Optional[float] = None
    speed: Optional[float] = None
    accuracy: Optional[float] = None
    battery_level: Optional[int] = None
    is_moving: bool = True
    trip_id: Optional[uuid.UUID] = None


class LocationBatchRequest(BaseModel):
    """Batch of GPS updates."""
    updates: List[LocationUpdateRequest]


class LocationResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    driver_id: uuid.UUID
    lat: float
    lng: float
    heading: Optional[float]
    speed: Optional[float]
    is_moving: bool
    timestamp: datetime


# ═══════════════════════════════════════════════
# Driver Schemas
# ═══════════════════════════════════════════════

class DriverToggleRequest(BaseModel):
    is_online: bool
    lat: Optional[float] = None
    lng: Optional[float] = None


class DriverStatusResponse(BaseModel):
    is_online: bool
    total_trips: int
    total_earnings: float
    rating: float


class ManifestPassenger(BaseModel):
    name: str
    phone: str
    boarding_stop: str
    alighting_stop: str
    status: str


class TripManifestResponse(BaseModel):
    trip_id: uuid.UUID
    route_name: str
    departure_time: str
    passengers: List[ManifestPassenger]
    total_booked: int


class RideStatusUpdateRequest(BaseModel):
    status: str  # "DRIVER_EN_ROUTE", "ARRIVED", "STARTED", "COMPLETED"


# ═══════════════════════════════════════════════
# Voucher Schemas
# ═══════════════════════════════════════════════

class VoucherResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: uuid.UUID
    code: str
    description: str
    discount_amount: float
    is_percentage: bool
    min_order_amount: float
    max_discount: Optional[float]
    valid_until: datetime
    is_valid: bool


class VoucherListResponse(BaseModel):
    vouchers: List[VoucherResponse]


class VoucherValidateRequest(BaseModel):
    code: str
    order_amount: float = 0


class VoucherValidateResponse(BaseModel):
    valid: bool
    voucher: Optional[VoucherResponse] = None
    calculated_discount: float = 0
    message: str = ""


# ═══════════════════════════════════════════════
# Review Schemas
# ═══════════════════════════════════════════════

class ReviewRequest(BaseModel):
    booking_id: uuid.UUID
    rating: float = Field(ge=1.0, le=5.0)
    feedback: Optional[str] = None
    tip_amount: Optional[float] = None


class ReviewResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: uuid.UUID
    rating: float
    feedback: Optional[str]
    tip_amount: Optional[float]
    created_at: datetime


# ═══════════════════════════════════════════════
# Generic Schemas
# ═══════════════════════════════════════════════

class HealthResponse(BaseModel):
    status: str
    version: str
    environment: str


class ErrorResponse(BaseModel):
    detail: str
    code: Optional[str] = None
