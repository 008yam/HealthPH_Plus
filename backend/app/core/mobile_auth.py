from __future__ import annotations

from datetime import datetime, timedelta, timezone
from typing import Annotated

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jose import JWTError, jwt

from app.core.config import settings


mobile_bearer = HTTPBearer(auto_error=False)


def create_mobile_access_token(mobile_user_id: str) -> str:
    expires_at = datetime.now(timezone.utc) + timedelta(
        minutes=settings.mobile_access_token_expire_minutes
    )
    return jwt.encode(
        {
            "sub": mobile_user_id,
            "aud": "mobile",
            "typ": "mobile_access",
            "roleId": "user",
            "roleLabel": "User",
            "exp": expires_at,
        },
        settings.mobile_jwt_secret,
        algorithm=settings.mobile_jwt_algorithm,
    )


def _credentials_exception() -> HTTPException:
    return HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate mobile credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )


def decode_mobile_token(token: str) -> dict:
    try:
        payload = jwt.decode(
            token,
            settings.mobile_jwt_secret,
            algorithms=[settings.mobile_jwt_algorithm],
            audience="mobile",
        )
    except JWTError as error:
        raise _credentials_exception() from error

    if (
        payload.get("typ") != "mobile_access"
        or not isinstance(payload.get("sub"), str)
        or not payload["sub"]
    ):
        raise _credentials_exception()

    return payload


def require_mobile_auth(
    credentials: Annotated[
        HTTPAuthorizationCredentials | None,
        Depends(mobile_bearer),
    ],
) -> dict:
    if credentials is None:
        raise _credentials_exception()
    return decode_mobile_token(credentials.credentials)


def require_matching_mobile_user(user_id: str, claims: dict) -> None:
    if claims.get("sub") != user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Mobile user mismatch",
        )
