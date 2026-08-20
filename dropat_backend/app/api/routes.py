from typing import List

from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.core.database import get_session
from app.models.route import Route
from app.schemas.schemas import RouteListResponse, RouteResponse

router = APIRouter()


@router.get("", response_model=RouteListResponse)
async def list_routes(
    session: AsyncSession = Depends(get_session),
    skip: int = 0,
    limit: int = 50,
):
    """
    Get all active shuttle routes with their waypoints.
    """
    query = (
        select(Route)
        .options(selectinload(Route.waypoints))
        .where(Route.is_active == True)
        .order_by(Route.created_at.desc())
        .offset(skip)
        .limit(limit)
    )
    
    result = await session.execute(query)
    routes = result.scalars().all()
    
    # In a real app we'd do a separate count query
    total = len(routes)
    
    # Sort waypoints by order for each route
    for route in routes:
        route.waypoints.sort(key=lambda w: w.order)
        
    return RouteListResponse(
        routes=routes,
        total=total,
    )
