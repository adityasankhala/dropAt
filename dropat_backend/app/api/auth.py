import uuid
from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_session
from app.core.security import get_current_user
from app.models.user import User
from app.schemas.schemas import AuthVerifyRequest, AuthVerifyResponse

router = APIRouter()

@router.post("/verify", response_model=AuthVerifyResponse)
async def verify_auth(
    request: AuthVerifyRequest,
    current_user: dict = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
):
    """
    Called by mobile app after successful Firebase login.
    Verifies the token (via middleware), and creates or updates
    the user profile in our PostgreSQL database.
    """
    firebase_uid = current_user["uid"]
    
    # Check if user exists
    result = await session.execute(
        select(User).where(User.firebase_uid == firebase_uid)
    )
    user = result.scalar_one_or_none()
    
    is_new_user = False
    
    if user is None:
        # Create new user
        is_new_user = True
        user = User(
            firebase_uid=firebase_uid,
            name=request.name or current_user.get("name") or "User",
            phone=request.phone or current_user.get("phone_number") or "",
            email=request.email or current_user.get("email"),
            photo_url=request.photo_url or current_user.get("picture"),
        )
        session.add(user)
    else:
        # Update existing user if new info provided
        updated = False
        if request.name and user.name == "User":
            user.name = request.name
            updated = True
        if request.phone and not user.phone:
            user.phone = request.phone
            updated = True
        if request.email and not user.email:
            user.email = request.email
            updated = True
        if request.photo_url and not user.photo_url:
            user.photo_url = request.photo_url
            updated = True
            
        if updated:
            user.updated_at = datetime.utcnow()
            session.add(user)

    await session.flush()
    
    return AuthVerifyResponse(
        user_id=user.id,
        firebase_uid=user.firebase_uid,
        name=user.name,
        is_new_user=is_new_user,
    )
