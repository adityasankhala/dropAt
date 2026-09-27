from types import SimpleNamespace
from unittest.mock import AsyncMock, Mock
import uuid

import pytest

from app.models.booking import BookingStatus
from app.models.payment import PaymentMethod
from app.services.payment_service import PaymentService


@pytest.mark.asyncio
async def test_payment_order_uses_the_server_booking_total(monkeypatch):
    """A client cannot choose the amount charged for a booking."""
    booking = SimpleNamespace(
        id=uuid.uuid4(),
        user_id=uuid.uuid4(),
        status=BookingStatus.PENDING,
        total_paid=73.45,
    )
    order = Mock()
    order.create.return_value = {"id": "order_123"}
    client = SimpleNamespace(order=order)
    session = SimpleNamespace(
        get=AsyncMock(return_value=booking),
        execute=AsyncMock(
            return_value=SimpleNamespace(scalar_one_or_none=lambda: None)
        ),
        add=Mock(),
        flush=AsyncMock(),
    )

    monkeypatch.setattr("app.services.payment_service.settings.PAYMENTS_ENABLED", True)
    monkeypatch.setattr(
        "app.services.payment_service.settings.RAZORPAY_KEY_ID", "rzp_test_key"
    )
    monkeypatch.setattr(
        "app.services.payment_service.settings.RAZORPAY_KEY_SECRET", "test_secret"
    )
    monkeypatch.setattr(PaymentService, "_get_razorpay_client", lambda: client)

    response = await PaymentService.create_order(
        session=session,
        booking_id=booking.id,
        user_id=booking.user_id,
        method=PaymentMethod.UPI.value,
    )

    assert response["amount"] == 7345
    assert order.create.call_args.args[0]["amount"] == 7345
