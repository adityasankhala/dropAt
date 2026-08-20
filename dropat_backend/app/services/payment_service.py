"""
DropAt — Payment Service
──────────────────────────
Razorpay integration for UPI/card payments.
"""

import hashlib
import hmac
import uuid
from datetime import datetime
from typing import Optional

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.models.payment import Payment, PaymentStatus, PaymentMethod
from app.models.booking import Booking, BookingStatus


class PaymentService:
    """Razorpay payment integration."""

    @staticmethod
    def _get_razorpay_client():
        """Lazy import razorpay client to avoid import errors when keys aren't set."""
        try:
            import razorpay
            return razorpay.Client(
                auth=(settings.RAZORPAY_KEY_ID, settings.RAZORPAY_KEY_SECRET)
            )
        except Exception:
            return None

    @staticmethod
    async def create_order(
        session: AsyncSession,
        booking_id: uuid.UUID,
        user_id: uuid.UUID,
        amount: float,
        method: str = "upi",
    ) -> dict:
        """
        Create a Razorpay order for a booking.
        Returns order details for the Flutter client.
        """
        # Verify the booking exists and belongs to the user
        booking = await session.get(Booking, booking_id)
        if booking is None:
            raise ValueError("Booking not found")
        if booking.user_id != user_id:
            raise ValueError("Booking does not belong to this user")

        # Amount in paise (Razorpay uses smallest currency unit)
        amount_paise = int(amount * 100)

        # Create Razorpay order
        client = PaymentService._get_razorpay_client()
        if client:
            order_data = client.order.create({
                "amount": amount_paise,
                "currency": "INR",
                "receipt": str(booking_id),
                "notes": {
                    "booking_id": str(booking_id),
                    "user_id": str(user_id),
                },
            })
            razorpay_order_id = order_data["id"]
        else:
            # Development fallback — mock order
            razorpay_order_id = f"order_dev_{uuid.uuid4().hex[:16]}"

        # Create payment record
        payment = Payment(
            booking_id=booking_id,
            user_id=user_id,
            amount=amount,
            method=PaymentMethod(method) if method in PaymentMethod.__members__.values() else PaymentMethod.UPI,
            status=PaymentStatus.CREATED,
            razorpay_order_id=razorpay_order_id,
        )
        session.add(payment)
        await session.flush()

        return {
            "order_id": razorpay_order_id,
            "amount": amount_paise,
            "currency": "INR",
            "key_id": settings.RAZORPAY_KEY_ID,
            "payment_id": str(payment.id),
        }

    @staticmethod
    async def verify_payment(
        session: AsyncSession,
        razorpay_order_id: str,
        razorpay_payment_id: str,
        razorpay_signature: str,
    ) -> Payment:
        """
        Verify Razorpay payment signature and update booking status.
        """
        # Find the payment record
        result = await session.execute(
            select(Payment).where(Payment.razorpay_order_id == razorpay_order_id)
        )
        payment = result.scalar_one_or_none()
        if payment is None:
            raise ValueError("Payment not found")

        # Verify signature
        if settings.RAZORPAY_KEY_SECRET:
            expected_signature = hmac.new(
                settings.RAZORPAY_KEY_SECRET.encode(),
                f"{razorpay_order_id}|{razorpay_payment_id}".encode(),
                hashlib.sha256,
            ).hexdigest()

            if not hmac.compare_digest(expected_signature, razorpay_signature):
                payment.status = PaymentStatus.FAILED
                session.add(payment)
                await session.flush()
                raise ValueError("Invalid payment signature")

        # Update payment record
        payment.razorpay_payment_id = razorpay_payment_id
        payment.razorpay_signature = razorpay_signature
        payment.status = PaymentStatus.CAPTURED
        payment.updated_at = datetime.utcnow()
        session.add(payment)

        # Update booking status to confirmed
        booking = await session.get(Booking, payment.booking_id)
        if booking:
            booking.status = BookingStatus.CONFIRMED
            booking.updated_at = datetime.utcnow()
            session.add(booking)

        await session.flush()
        return payment

    @staticmethod
    async def process_refund(
        session: AsyncSession,
        payment_id: uuid.UUID,
        amount: Optional[float] = None,
        reason: str = "Booking cancelled",
    ) -> Payment:
        """Process a refund for a payment."""
        payment = await session.get(Payment, payment_id)
        if payment is None:
            raise ValueError("Payment not found")
        if payment.status != PaymentStatus.CAPTURED:
            raise ValueError("Can only refund captured payments")

        refund_amount = amount or payment.amount

        # Refund via Razorpay
        client = PaymentService._get_razorpay_client()
        if client and payment.razorpay_payment_id:
            try:
                client.payment.refund(
                    payment.razorpay_payment_id,
                    {
                        "amount": int(refund_amount * 100),
                        "notes": {"reason": reason},
                    },
                )
            except Exception:
                pass  # Log but don't block — manual reconciliation

        payment.status = (
            PaymentStatus.REFUNDED
            if refund_amount >= payment.amount
            else PaymentStatus.PARTIAL_REFUND
        )
        payment.refund_amount = refund_amount
        payment.refund_reason = reason
        payment.updated_at = datetime.utcnow()
        session.add(payment)
        await session.flush()
        return payment
