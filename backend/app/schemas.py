"""
Pydantic schemas for the Jarvis backend.

Privacy-First Architecture:
- Only auth and billing schemas needed in backend
- All conversation/memory/preference schemas are handled on-device
"""

from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, EmailStr, Field


# ==================== Auth Schemas ====================

class UserCreate(BaseModel):
    """Request to create a new user account."""
    email: EmailStr
    password: str = Field(..., min_length=8)


class UserLogin(BaseModel):
    """Request to log in."""
    email: EmailStr
    password: str


class Token(BaseModel):
    """JWT token response."""
    access_token: str
    token_type: str = "bearer"


class UserResponse(BaseModel):
    """User information response."""
    id: UUID
    email: str
    created_at: datetime

    class Config:
        from_attributes = True


# ==================== Billing Schemas ====================
# (Used by billing.py route)

class SubscriptionResponse(BaseModel):
    """Subscription status response."""
    tier: str  # free, pro, team
    status: str  # active, past_due, canceled
    current_period_end: datetime | None
    cancel_at_period_end: bool

    class Config:
        from_attributes = True


class CheckoutRequest(BaseModel):
    """Request to create a checkout session."""
    tier: str = Field(..., pattern="^(pro|team)$")  # Only paid tiers


class CheckoutResponse(BaseModel):
    """Checkout session URL response."""
    checkout_url: str
