"""
DropAt Backend — Firebase Auth JWT Verification
─────────────────────────────────────────────────
Verifies Firebase ID tokens sent from Flutter apps.
Caches Google's public signing keys to avoid network calls on every request.
"""

import time
from typing import Optional

import httpx
from cachetools import TTLCache
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from jose import jwt, JWTError, jwk
from jose.utils import base64url_decode

from app.core.config import settings

# ── Constants ────────────────────────────────────────────
GOOGLE_CERTS_URL = "https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com"
GOOGLE_JWKS_URL = "https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com"
FIREBASE_ISSUER = f"https://securetoken.google.com/{settings.FIREBASE_PROJECT_ID}"
FIREBASE_AUDIENCE = settings.FIREBASE_PROJECT_ID

# Cache public keys for 1 hour (3600 seconds)
_keys_cache: TTLCache = TTLCache(maxsize=1, ttl=3600)

# Bearer token extractor
_bearer_scheme = HTTPBearer(auto_error=False)


async def _fetch_google_public_keys() -> dict:
    """Fetch and cache Google's public JWK keys for Firebase token verification."""
    if "keys" in _keys_cache:
        return _keys_cache["keys"]

    async with httpx.AsyncClient() as client:
        response = await client.get(GOOGLE_JWKS_URL)
        response.raise_for_status()
        keys_data = response.json()

    # Build a kid -> key mapping
    keys = {}
    for key_dict in keys_data.get("keys", []):
        kid = key_dict.get("kid")
        if kid:
            keys[kid] = key_dict

    _keys_cache["keys"] = keys
    return keys


async def verify_firebase_token(token: str) -> dict:
    """
    Verify a Firebase ID token and return the decoded claims.

    Returns dict with at minimum:
        - uid: str (Firebase user ID)
        - email: Optional[str]
        - phone_number: Optional[str]
        - name: Optional[str]
        - picture: Optional[str]
    """
    try:
        # Get the signing keys
        keys = await _fetch_google_public_keys()

        # Decode the header to find which key was used
        header = jwt.get_unverified_header(token)
        kid = header.get("kid")

        if not kid or kid not in keys:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token: unknown signing key",
            )

        # Verify and decode the token
        payload = jwt.decode(
            token,
            keys[kid],
            algorithms=["RS256"],
            audience=FIREBASE_AUDIENCE,
            issuer=FIREBASE_ISSUER,
        )

        # Additional validation
        if payload.get("sub") is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token: missing subject",
            )

        # Check expiration (jose does this, but let's be explicit)
        if payload.get("exp", 0) < time.time():
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Token has expired",
            )

        return {
            "uid": payload["sub"],
            "email": payload.get("email"),
            "phone_number": payload.get("phone_number"),
            "name": payload.get("name"),
            "picture": payload.get("picture"),
            "email_verified": payload.get("email_verified", False),
            "firebase": payload.get("firebase", {}),
        }

    except JWTError as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Invalid authentication token: {str(e)}",
        )
    except httpx.HTTPError:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to verify token: authentication service unavailable",
        )


async def get_current_user(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(_bearer_scheme),
) -> dict:
    """
    FastAPI dependency — extracts and verifies the Firebase JWT from the
    Authorization header. Returns the decoded user claims.

    Usage:
        @router.get("/me")
        async def get_profile(user: dict = Depends(get_current_user)):
            uid = user["uid"]
    """
    if credentials is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication required",
            headers={"WWW-Authenticate": "Bearer"},
        )

    return await verify_firebase_token(credentials.credentials)


async def get_optional_user(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(_bearer_scheme),
) -> Optional[dict]:
    """
    FastAPI dependency — same as get_current_user but returns None
    instead of raising an error for unauthenticated requests.
    """
    if credentials is None:
        return None

    try:
        return await verify_firebase_token(credentials.credentials)
    except HTTPException:
        return None
