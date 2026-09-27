from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_session
from app.models.voucher import Voucher
from app.schemas.schemas import (
    VoucherListResponse,
    VoucherResponse,
    VoucherValidateRequest,
    VoucherValidateResponse,
)

router = APIRouter()

def _format_voucher(voucher: Voucher) -> VoucherResponse:
    return VoucherResponse(
        id=voucher.id,
        code=voucher.code,
        description=voucher.description,
        discount_amount=voucher.discount_amount,
        is_percentage=voucher.is_percentage,
        min_order_amount=voucher.min_order_amount,
        max_discount=voucher.max_discount,
        valid_until=voucher.valid_until,
        is_valid=voucher.is_valid,
    )

@router.get("", response_model=VoucherListResponse)
async def list_vouchers(
    session: AsyncSession = Depends(get_session),
):
    """List all available (valid) vouchers."""
    from datetime import datetime
    
    query = select(Voucher).where(
        Voucher.is_active == True,
        Voucher.valid_until >= datetime.utcnow(),
    )
    result = await session.execute(query)
    vouchers = result.scalars().all()
    
    # Filter valid
    valid_vouchers = [v for v in vouchers if v.is_valid]
    
    return VoucherListResponse(
        vouchers=[_format_voucher(v) for v in valid_vouchers]
    )

@router.post("/validate", response_model=VoucherValidateResponse)
async def validate_voucher(
    request: VoucherValidateRequest,
    session: AsyncSession = Depends(get_session),
):
    """Validate a voucher code and calculate discount."""
    query = select(Voucher).where(
        Voucher.code == request.code.upper().strip(),
        Voucher.is_active == True,
    )
    result = await session.execute(query)
    voucher = result.scalar_one_or_none()
    
    if not voucher:
        return VoucherValidateResponse(
            valid=False,
            message="Invalid promo code",
        )
        
    if not voucher.is_valid:
        return VoucherValidateResponse(
            valid=False,
            message="Promo code has expired or reached usage limit",
        )
        
    if request.order_amount > 0 and request.order_amount < voucher.min_order_amount:
        return VoucherValidateResponse(
            valid=False,
            message=f"Minimum order amount of ₹{voucher.min_order_amount} required",
            voucher=_format_voucher(voucher),
        )
        
    discount = voucher.calculate_discount(request.order_amount) if request.order_amount > 0 else 0
    
    return VoucherValidateResponse(
        valid=True,
        voucher=_format_voucher(voucher),
        calculated_discount=discount,
        message="Promo code applied successfully",
    )
