from fastapi import APIRouter

from app.api import (
    auth,
    users,
    routes,
    trips,
    bookings,
    payments,
    tracking,
    drivers,
    vouchers,
)

api_router = APIRouter()

api_router.include_router(auth.router, prefix="/auth", tags=["auth"])
api_router.include_router(users.router, prefix="/users", tags=["users"])
api_router.include_router(routes.router, prefix="/routes", tags=["routes"])
api_router.include_router(trips.router, prefix="/trips", tags=["trips"])
api_router.include_router(bookings.router, prefix="/bookings", tags=["bookings"])
api_router.include_router(payments.router, prefix="/payments", tags=["payments"])
api_router.include_router(tracking.router, prefix="/tracking", tags=["tracking"])
api_router.include_router(drivers.router, prefix="/drivers", tags=["drivers"])
api_router.include_router(vouchers.router, prefix="/vouchers", tags=["vouchers"])
