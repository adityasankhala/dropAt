"""Razorpay integration for UPI/card payments."""

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

        if booking.status != BookingStatus.PENDING:
            raise ValueError("This booking is not awaiting online payment")
        if booking.total_paid <= 0:
            raise ValueError("This booking does not require an online payment")

        try:
            payment_method = PaymentMethod(method.lower())
        except ValueError as exc:
            raise ValueError("Unsupported payment method") from exc
        if payment_method == PaymentMethod.CASH:
            raise ValueError("Cash bookings do not use an online payment order")

        # The server, never the client, is the source of truth for payment value.
        amount_paise = round(booking.total_paid * 100)

        # Returning an existing unexpired order makes a retried mobile request
        # idempotent and avoids charging a rider twice.
        existing_result = await session.execute(
            select(Payment).where(
                Payment.booking_id == booking_id,
                Payment.user_id == user_id,
                Payment.status == PaymentStatus.CREATED,
            )
        )
        existing_payment = existing_result.scalar_one_or_none()
        if existing_payment and existing_payment.razorpay_order_id:
            return {
                "order_id": existing_payment.razorpay_order_id,
                "amount": round(existing_payment.amount * 100),
                "currency": existing_payment.currency,
                "key_id": settings.RAZORPAY_KEY_ID,
                "payment_id": str(existing_payment.id),
            }

        if not settings.PAYMENTS_ENABLED:
            raise ValueError("Online payments are currently unavailable")

        # Create Razorpay order
        client = PaymentService._get_razorpay_client()
        if client and settings.RAZORPAY_KEY_ID and settings.RAZORPAY_KEY_SECRET:
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
        elif settings.ALLOW_DEV_PAYMENT_FALLBACK:
            # Development fallback — mock order
            razorpay_order_id = f"order_dev_{uuid.uuid4().hex[:16]}"
        else:
            raise ValueError("Online payments are not configured")

        # Create payment record
        payment = Payment(
            booking_id=booking_id,
            user_id=user_id,
            amount=booking.total_paid,
            method=payment_method,
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
        user_id: uuid.UUID,
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
        if payment.user_id != user_id:
            raise ValueError("Payment does not belong to this user")
        if payment.status == PaymentStatus.CAPTURED:
            if payment.razorpay_payment_id == razorpay_payment_id:
                return payment
            raise ValueError("Payment has already been captured")
        if payment.status != PaymentStatus.CREATED:
            raise ValueError("Payment cannot be verified in its current state")

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
        elif not settings.ALLOW_DEV_PAYMENT_FALLBACK:
            raise ValueError("Payment verification is not configured")

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
        if not settings.PAYMENTS_ENABLED:
            raise ValueError("Online payments are currently unavailable")
        if not client or not payment.razorpay_payment_id:
            raise ValueError("Refund provider is not configured")

        try:
            client.payment.refund(
                payment.razorpay_payment_id,
                {
                    "amount": round(refund_amount * 100),
                    "notes": {"reason": reason},
                },
            )
        except Exception as exc:
            raise ValueError("Refund could not be processed") from exc

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
