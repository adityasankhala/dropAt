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


async def _get_db_user_id(session: AsyncSession, firebase_uid: str):
    """Resolve the authenticated Firebase identity to the local user record."""
    from app.models.user import User
    from sqlalchemy import select

    result = await session.execute(
        select(User).where(User.firebase_uid == firebase_uid)
    )
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=401, detail="User not found in database")
    return user.id


@router.post("/create-order", response_model=CreatePaymentOrderResponse)
async def create_order(
    request: CreatePaymentOrderRequest,
    current_user: dict = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
):
    """Create a Razorpay payment order for a booking."""
    try:
        user_id = await _get_db_user_id(session, current_user["uid"])
        order_details = await PaymentService.create_order(
            session=session,
            booking_id=request.booking_id,
            user_id=user_id,
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
        user_id = await _get_db_user_id(session, current_user["uid"])
        payment = await PaymentService.verify_payment(
            session=session,
            user_id=user_id,
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
