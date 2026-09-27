"""
Voucher Model
Promo codes and discount vouchers.
"""

import uuid
from datetime import datetime
from typing import Optional

from sqlmodel import SQLModel, Field

class Voucher(SQLModel, table=True):
    """
    Promo codes for discounts on rides/shuttles.
    """

    __tablename__ = "vouchers"

    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    code: str = Field(max_length=20, unique=True, index=True)
    description: str = Field(max_length=500, default="")
    discount_amount: float = Field(default=0.0)
    is_percentage: bool = Field(default=False)
    min_order_amount: float = Field(default=0.0)
    max_discount: Optional[float] = Field(default=None)  # Cap for percentage discounts
    usage_limit: int = Field(default=1)
    used_count: int = Field(default=0)
    valid_from: datetime = Field(default_factory=datetime.utcnow)
    valid_until: datetime = Field(
        default_factory=lambda: datetime(2030, 12, 31)
    )
    is_active: bool = Field(default=True)
    created_at: datetime = Field(default_factory=datetime.utcnow)

    @property
    def is_valid(self) -> bool:
        now = datetime.utcnow()
        return (
            self.is_active
            and self.valid_from <= now <= self.valid_until
            and self.used_count < self.usage_limit
        )

    def calculate_discount(self, order_amount: float) -> float:
        if order_amount < self.min_order_amount:
            return 0.0
        if self.is_percentage:
            discount = order_amount * self.discount_amount / 100
            if self.max_discount is not None:
                discount = min(discount, self.max_discount)
            return round(discount, 2)
        return self.discount_amount
