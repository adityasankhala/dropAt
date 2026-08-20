from typing import List

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.core.database import get_session
from app.core.security import get_current_user
from app.models.user import User, SavedPlace
from app.schemas.schemas import UserProfileResponse, UserProfileUpdate, SavedPlaceSchema

router = APIRouter()


async def get_db_user(
    current_user: dict = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
) -> User:
    """Dependency to get the full DB user model from the token."""
    firebase_uid = current_user["uid"]
    result = await session.execute(
        select(User)
        .options(selectinload(User.saved_places))
        .where(User.firebase_uid == firebase_uid)
    )
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=404, detail="User profile not found")
    return user


@router.get("/me", response_model=UserProfileResponse)
async def get_profile(user: User = Depends(get_db_user)):
    """Get the current user's profile and saved places."""
    return user


@router.put("/me", response_model=UserProfileResponse)
async def update_profile(
    update_data: UserProfileUpdate,
    user: User = Depends(get_db_user),
    session: AsyncSession = Depends(get_session),
):
    """Update user profile details."""
    update_dict = update_data.model_dump(exclude_unset=True)
    for key, value in update_dict.items():
        setattr(user, key, value)
        
    session.add(user)
    await session.flush()
    return user


@router.post("/me/saved-places", response_model=SavedPlaceSchema)
async def add_saved_place(
    place: SavedPlaceSchema,
    user: User = Depends(get_db_user),
    session: AsyncSession = Depends(get_session),
):
    """Add a saved place for the user."""
    new_place = SavedPlace(
        user_id=user.id,
        name=place.name,
        address=place.address,
        lat=place.lat,
        lng=place.lng,
    )
    session.add(new_place)
    await session.flush()
    return new_place
