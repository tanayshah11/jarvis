"""Quota checking dependency for LLM routes."""
import uuid
from fastapi import Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.models import User
from app.deps import get_current_user
from app.services.billing import BillingService


async def check_quota(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> User:
    """
    Dependency that checks if user has remaining token quota.

    Creates free subscription if none exists.
    Raises 429 if quota exceeded.
    """
    billing = BillingService(db)

    # Ensure user has a subscription
    subscription = await billing.get_subscription(current_user.id)
    if not subscription:
        subscription = await billing.create_free_subscription(current_user)

    # Check quota
    has_quota, usage = await billing.check_quota(current_user.id)

    if not has_quota:
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail={
                "error": "quota_exceeded",
                "message": "Monthly token quota exceeded. Please upgrade your plan.",
                "tokens_used": usage.tokens_used if usage else 0,
                "token_limit": usage.token_limit if usage else 0,
                "tier": subscription.tier,
            },
        )

    return current_user


async def increment_token_usage(
    user_id: uuid.UUID,
    tokens: int,
    db: AsyncSession,
) -> None:
    """Helper function to increment token usage after LLM call."""
    billing = BillingService(db)
    await billing.increment_usage(user_id, tokens)
