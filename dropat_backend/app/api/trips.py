import uuid
from datetime import date
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.core.database import get_session
from app.models.trip import Trip, TripStatus, TripMode
from app.models.route import Route
from app.schemas.schemas import TripListResponse, TripResponse

router = APIRouter()

@router.get("", response_model=TripListResponse)
async def list_trips(
    route_id: Optional[uuid.UUID] = None,
    trip_date: Optional[date] = None,
    session: AsyncSession = Depends(get_session),
):
    """
    Get available shuttle trips for a specific route and date.
    """
    if trip_date is None:
        trip_date = date.today()
        
    query = (
        select(Trip)
        .options(selectinload(Trip.route).selectinload(Route.waypoints))
        .where(
            Trip.mode == TripMode.FIXED_ROUTE,
            Trip.trip_date == trip_date,
            Trip.status.in_([TripStatus.SCHEDULED, TripStatus.BOARDING]),
        )
    )
    
    if route_id:
        query = query.where(Trip.route_id == route_id)
        
    query = query.order_by(Trip.departure_time)
    
    result = await session.execute(query)
    trips = result.scalars().all()
    
    response_trips = []
    for trip in trips:
        route_name = trip.route.name if trip.route else None
        waypoints = trip.route.waypoints if trip.route else []
        waypoints.sort(key=lambda w: w.order)
        
        response_trips.append(
            TripResponse(
                id=trip.id,
                route_id=trip.route_id,
                route_name=route_name,
                mode=trip.mode,
                status=trip.status,
                trip_date=trip.trip_date,
                departure_time=trip.departure_time,
                total_seats=trip.total_seats,
                booked_seats=trip.booked_seats,
                available_seats=trip.available_seats,
                stops=waypoints,
            )
        )
        
    return TripListResponse(trips=response_trips, total=len(response_trips))

@router.get("/{trip_id}", response_model=TripResponse)
async def get_trip(
    trip_id: uuid.UUID,
    session: AsyncSession = Depends(get_session),
):
    """Get details of a specific trip."""
    query = (
        select(Trip)
        .options(selectinload(Trip.route).selectinload(Route.waypoints))
        .where(Trip.id == trip_id)
    )
    result = await session.execute(query)
    trip = result.scalar_one_or_none()
    
    if not trip:
        raise HTTPException(status_code=404, detail="Trip not found")
        
    route_name = trip.route.name if trip.route else None
    waypoints = trip.route.waypoints if trip.route else []
    waypoints.sort(key=lambda w: w.order)
    
    return TripResponse(
        id=trip.id,
        route_id=trip.route_id,
        route_name=route_name,
        mode=trip.mode,
        status=trip.status,
        trip_date=trip.trip_date,
        departure_time=trip.departure_time,
        total_seats=trip.total_seats,
        booked_seats=trip.booked_seats,
        available_seats=trip.available_seats,
        stops=waypoints,
    )
