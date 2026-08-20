from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_session
from app.core.security import get_current_user
from app.schemas.schemas import (
    CreatePaymentOrderRequest,
    CreatePaymentOrderResponse,
    VerifyPaymentRequest,
    PaymentResponse,
)
from app.services.payment_service import PaymentService

router = APIRouter()


@router.post("/create-order", response_model=CreatePaymentOrderResponse)
async def create_order(
    request: CreatePaymentOrderRequest,
    current_user: dict = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
):
    """Create a Razorpay payment order for a booking."""
    from app.models.user import User
    from sqlalchemy import select
    result = await session.execute(select(User).where(User.firebase_uid == current_user["uid"]))
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=401, detail="User not found in database")

    try:
        order_details = await PaymentService.create_order(
            session=session,
            booking_id=request.booking_id,
            user_id=user.id,
            amount=request.amount,
            method=request.method,
        )
        return CreatePaymentOrderResponse(**order_details)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post("/verify", response_model=PaymentResponse)
async def verify_payment(
    request: VerifyPaymentRequest,
    current_user: dict = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
):
    """Verify Razorpay payment signature."""
    try:
        payment = await PaymentService.verify_payment(
            session=session,
            razorpay_order_id=request.razorpay_order_id,
            razorpay_payment_id=request.razorpay_payment_id,
            razorpay_signature=request.razorpay_signature,
        )
        return PaymentResponse(
            id=payment.id,
            booking_id=payment.booking_id,
            amount=payment.amount,
            method=payment.method,
            status=payment.status,
            razorpay_order_id=payment.razorpay_order_id,
            created_at=payment.created_at,
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
