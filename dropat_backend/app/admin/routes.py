"""
DropAt Admin Panel — API Routes
────────────────────────────────
Admin-only routes for managing routes, trips, drivers, vouchers, and bookings.
Served via Jinja2 templates at /admin.
"""

import uuid
from datetime import datetime, date, time

from fastapi import APIRouter, Depends, HTTPException, Request, Form
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.templating import Jinja2Templates
from sqlalchemy import select, func, desc
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.core.database import get_session
from app.core.security import require_admin
from app.models.user import User
from app.models.driver import Driver
from app.models.route import Route
from app.models.waypoint import Waypoint
from app.models.trip import Trip, TripStatus, TripMode
from app.models.booking import Booking, BookingStatus
from app.models.voucher import Voucher
from app.models.payment import Payment

templates = Jinja2Templates(directory="app/admin/templates")

router = APIRouter(dependencies=[Depends(require_admin)])


# ─── Dashboard ───────────────────────────────────────────

@router.get("", response_class=HTMLResponse)
async def admin_dashboard(request: Request, session: AsyncSession = Depends(get_session)):
    """Admin dashboard with key metrics."""
    # Counts
    user_count = (await session.execute(select(func.count(User.id)))).scalar() or 0
    driver_count = (await session.execute(select(func.count(Driver.id)))).scalar() or 0
    route_count = (await session.execute(select(func.count(Route.id)))).scalar() or 0
    trip_count = (await session.execute(select(func.count(Trip.id)))).scalar() or 0
    booking_count = (await session.execute(select(func.count(Booking.id)))).scalar() or 0
    voucher_count = (await session.execute(select(func.count(Voucher.id)))).scalar() or 0

    # Recent bookings
    recent_bookings_q = (
        select(Booking)
        .options(selectinload(Booking.user))
        .order_by(desc(Booking.created_at))
        .limit(5)
    )
    recent_bookings = (await session.execute(recent_bookings_q)).scalars().all()

    return templates.TemplateResponse("dashboard.html", {
        "request": request,
        "page": "dashboard",
        "user_count": user_count,
        "driver_count": driver_count,
        "route_count": route_count,
        "trip_count": trip_count,
        "booking_count": booking_count,
        "voucher_count": voucher_count,
        "recent_bookings": recent_bookings,
    })


# ─── Routes Management ──────────────────────────────────

@router.get("/routes", response_class=HTMLResponse)
async def admin_routes(request: Request, session: AsyncSession = Depends(get_session)):
    """List all shuttle routes."""
    result = await session.execute(
        select(Route).options(selectinload(Route.waypoints)).order_by(desc(Route.created_at))
    )
    routes = result.scalars().all()
    for r in routes:
        r.waypoints.sort(key=lambda w: w.order)
    return templates.TemplateResponse("routes.html", {
        "request": request,
        "page": "routes",
        "routes": routes,
    })


@router.post("/routes/create")
async def admin_create_route(
    request: Request,
    name: str = Form(...),
    description: str = Form(""),
    price: float = Form(0),
    total_seats: int = Form(25),
    estimated_duration_min: int = Form(15),
    session: AsyncSession = Depends(get_session),
):
    """Create a new shuttle route."""
    route = Route(
        name=name,
        description=description,
        price=price,
        total_seats=total_seats,
        estimated_duration_min=estimated_duration_min,
    )
    session.add(route)
    await session.commit()
    return RedirectResponse(url="/admin/routes", status_code=303)


@router.post("/routes/{route_id}/toggle")
async def admin_toggle_route(
    route_id: uuid.UUID,
    session: AsyncSession = Depends(get_session),
):
    """Toggle route active/inactive."""
    result = await session.execute(select(Route).where(Route.id == route_id))
    route = result.scalar_one_or_none()
    if route:
        route.is_active = not route.is_active
        session.add(route)
        await session.commit()
    return RedirectResponse(url="/admin/routes", status_code=303)


@router.post("/routes/{route_id}/delete")
async def admin_delete_route(
    route_id: uuid.UUID,
    session: AsyncSession = Depends(get_session),
):
    """Delete a route."""
    result = await session.execute(select(Route).where(Route.id == route_id))
    route = result.scalar_one_or_none()
    if route:
        await session.delete(route)
        await session.commit()
    return RedirectResponse(url="/admin/routes", status_code=303)


# ─── Trips Management ───────────────────────────────────

@router.get("/trips", response_class=HTMLResponse)
async def admin_trips(request: Request, session: AsyncSession = Depends(get_session)):
    """List all trips."""
    result = await session.execute(
        select(Trip)
        .options(selectinload(Trip.route))
        .order_by(desc(Trip.trip_date), desc(Trip.departure_time))
        .limit(100)
    )
    trips = result.scalars().all()

    # Get routes for the create form
    routes_result = await session.execute(select(Route).where(Route.is_active == True))
    routes = routes_result.scalars().all()

    return templates.TemplateResponse("trips.html", {
        "request": request,
        "page": "trips",
        "trips": trips,
        "routes": routes,
        "trip_statuses": [s.value for s in TripStatus],
    })


@router.post("/trips/create")
async def admin_create_trip(
    request: Request,
    route_id: str = Form(...),
    trip_date: str = Form(...),
    departure_time: str = Form(...),
    total_seats: int = Form(25),
    session: AsyncSession = Depends(get_session),
):
    """Create a new trip for a route."""
    route = (await session.execute(select(Route).where(Route.id == uuid.UUID(route_id)))).scalar_one_or_none()
    if not route:
        raise HTTPException(status_code=404, detail="Route not found")

    parsed_date = date.fromisoformat(trip_date)
    h, m = departure_time.split(":")
    parsed_time = time(int(h), int(m))

    trip = Trip(
        route_id=route.id,
        mode=TripMode.FIXED_ROUTE,
        status=TripStatus.SCHEDULED,
        trip_date=parsed_date,
        departure_time=parsed_time,
        total_seats=total_seats,
        booked_seats=0,
    )
    session.add(trip)
    await session.commit()
    return RedirectResponse(url="/admin/trips", status_code=303)


# ─── Users Management ───────────────────────────────────

@router.get("/users", response_class=HTMLResponse)
async def admin_users(request: Request, session: AsyncSession = Depends(get_session)):
    """List all users."""
    result = await session.execute(
        select(User).order_by(desc(User.created_at)).limit(100)
    )
    users = result.scalars().all()
    return templates.TemplateResponse("users.html", {
        "request": request,
        "page": "users",
        "users": users,
    })


# ─── Drivers Management ─────────────────────────────────

@router.get("/drivers", response_class=HTMLResponse)
async def admin_drivers(request: Request, session: AsyncSession = Depends(get_session)):
    """List all drivers."""
    result = await session.execute(
        select(Driver)
        .options(selectinload(Driver.user), selectinload(Driver.vehicle))
        .order_by(desc(Driver.created_at))
        .limit(100)
    )
    drivers = result.scalars().all()
    return templates.TemplateResponse("drivers.html", {
        "request": request,
        "page": "drivers",
        "drivers": drivers,
    })


# ─── Bookings Management ────────────────────────────────

@router.get("/bookings", response_class=HTMLResponse)
async def admin_bookings(request: Request, session: AsyncSession = Depends(get_session)):
    """List all bookings."""
    result = await session.execute(
        select(Booking)
        .options(selectinload(Booking.user), selectinload(Booking.trip).selectinload(Trip.route))
        .order_by(desc(Booking.created_at))
        .limit(100)
    )
    bookings = result.scalars().all()
    return templates.TemplateResponse("bookings.html", {
        "request": request,
        "page": "bookings",
        "bookings": bookings,
    })


# ─── Vouchers Management ────────────────────────────────

@router.get("/vouchers", response_class=HTMLResponse)
async def admin_vouchers(request: Request, session: AsyncSession = Depends(get_session)):
    """List all vouchers."""
    result = await session.execute(
        select(Voucher).order_by(desc(Voucher.created_at))
    )
    vouchers = result.scalars().all()
    return templates.TemplateResponse("vouchers.html", {
        "request": request,
        "page": "vouchers",
        "vouchers": vouchers,
    })


@router.post("/vouchers/create")
async def admin_create_voucher(
    request: Request,
    code: str = Form(...),
    description: str = Form(""),
    discount_amount: float = Form(0),
    is_percentage: bool = Form(False),
    min_order_amount: float = Form(0),
    max_discount: float = Form(None),
    usage_limit: int = Form(100),
    valid_until: str = Form(None),
    session: AsyncSession = Depends(get_session),
):
    """Create a new voucher."""
    parsed_until = datetime.fromisoformat(valid_until) if valid_until else datetime(2030, 12, 31)

    voucher = Voucher(
        code=code.upper().strip(),
        description=description,
        discount_amount=discount_amount,
        is_percentage=is_percentage,
        min_order_amount=min_order_amount,
        max_discount=max_discount if max_discount and max_discount > 0 else None,
        usage_limit=usage_limit,
        valid_until=parsed_until,
    )
    session.add(voucher)
    await session.commit()
    return RedirectResponse(url="/admin/vouchers", status_code=303)


@router.post("/vouchers/{voucher_id}/toggle")
async def admin_toggle_voucher(
    voucher_id: uuid.UUID,
    session: AsyncSession = Depends(get_session),
):
    """Toggle voucher active/inactive."""
    result = await session.execute(select(Voucher).where(Voucher.id == voucher_id))
    voucher = result.scalar_one_or_none()
    if voucher:
        voucher.is_active = not voucher.is_active
        session.add(voucher)
        await session.commit()
    return RedirectResponse(url="/admin/vouchers", status_code=303)
