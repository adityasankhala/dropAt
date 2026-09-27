"""
Payment Model
Payment records with Razorpay integration support.
"""

import uuid
from datetime import datetime
from enum import Enum
from typing import Optional

from sqlmodel import SQLModel, Field

class PaymentStatus(str, Enum):
    """Payment lifecycle."""
    CREATED = "created"  # Razorpay order created
    AUTHORIZED = "authorized"  # Payment authorized
    CAPTURED = "captured"  # Payment captured (success)
    FAILED = "failed"  # Payment failed
    REFUNDED = "refunded"  # Fully refunded
    PARTIAL_REFUND = "partial_refund"  # Partially refunded

class PaymentMethod(str, Enum):
    """Supported payment methods."""
    CASH = "cash"
    UPI = "upi"
    CARD = "card"
    WALLET = "wallet"
    NETBANKING = "netbanking"

class Payment(SQLModel, table=True):
    """
    Payment record linked to a booking.
    Integrates with Razorpay for UPI/card payments.
    """

    __tablename__ = "payments"

    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    booking_id: uuid.UUID = Field(foreign_key="bookings.id", index=True)
    user_id: uuid.UUID = Field(foreign_key="users.id", index=True)
    amount: float = Field(default=0.0)
    currency: str = Field(default="INR", max_length=3)
    method: PaymentMethod = Field(default=PaymentMethod.CASH)
    status: PaymentStatus = Field(default=PaymentStatus.CREATED, index=True)

    # Razorpay integration fields
    razorpay_order_id: Optional[str] = Field(default=None, max_length=100, index=True)
    razorpay_payment_id: Optional[str] = Field(default=None, max_length=100)
    razorpay_signature: Optional[str] = Field(default=None, max_length=500)

    # Refund tracking
    refund_amount: Optional[float] = Field(default=None)
    refund_reason: Optional[str] = Field(default=None, max_length=500)

    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)
