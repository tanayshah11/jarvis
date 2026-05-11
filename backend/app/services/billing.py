"""Billing service for Stripe integration and usage tracking."""
import uuid
from datetime import datetime, timezone
from typing import Optional

import stripe
from sqlalchemy import select, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import get_settings
from app.models import User, Subscription, UsageRecord, WebhookEvent

settings = get_settings()

# Initialize Stripe (may be None in development)
stripe.api_key = settings.stripe_secret_key

# Check if Stripe is configured
STRIPE_CONFIGURED = bool(settings.stripe_secret_key)


class BillingService:
    """Handles all billing operations with Stripe."""

    def __init__(self, db: AsyncSession):
        self.db = db

    # ==================== Customer Management ====================

    async def get_or_create_stripe_customer(self, user: User) -> str:
        """Get existing Stripe customer ID or create a new one."""
        if user.stripe_customer_id:
            return user.stripe_customer_id

        # In development mode without Stripe, use a mock customer ID
        if not STRIPE_CONFIGURED:
            mock_customer_id = f"dev_cus_{user.id}"
            user.stripe_customer_id = mock_customer_id
            await self.db.commit()
            return mock_customer_id

        # Create Stripe customer
        customer = stripe.Customer.create(
            email=user.email,
            metadata={"user_id": str(user.id)},
        )

        # Update user with Stripe customer ID
        user.stripe_customer_id = customer.id
        await self.db.commit()

        return customer.id

    # ==================== Subscription Management ====================

    async def get_subscription(self, user_id: uuid.UUID) -> Optional[Subscription]:
        """Get user's subscription."""
        result = await self.db.execute(
            select(Subscription).where(Subscription.user_id == user_id)
        )
        return result.scalar_one_or_none()

    async def get_subscription_by_customer(self, stripe_customer_id: str) -> Optional[Subscription]:
        """Get subscription by Stripe customer ID."""
        result = await self.db.execute(
            select(Subscription).where(Subscription.stripe_customer_id == stripe_customer_id)
        )
        return result.scalar_one_or_none()

    async def create_free_subscription(self, user: User) -> Subscription:
        """Create a free tier subscription for a new user."""
        stripe_customer_id = await self.get_or_create_stripe_customer(user)

        now = datetime.now(timezone.utc)
        period_end = now.replace(month=now.month + 1 if now.month < 12 else 1, year=now.year if now.month < 12 else now.year + 1)

        subscription = Subscription(
            user_id=user.id,
            stripe_customer_id=stripe_customer_id,
            tier="free",
            status="active",
            current_period_start=now,
            current_period_end=period_end,
        )
        self.db.add(subscription)
        await self.db.commit()
        await self.db.refresh(subscription)

        # Create initial usage record
        await self.ensure_usage_record(subscription)

        return subscription

    async def update_subscription_from_stripe(
        self,
        stripe_subscription_id: str,
        stripe_customer_id: str,
        status: str,
        price_id: Optional[str],
        current_period_start: Optional[datetime],
        current_period_end: Optional[datetime],
        cancel_at_period_end: bool = False,
    ) -> Optional[Subscription]:
        """Update local subscription from Stripe webhook data."""
        result = await self.db.execute(
            select(Subscription).where(Subscription.stripe_customer_id == stripe_customer_id)
        )
        subscription = result.scalar_one_or_none()

        if not subscription:
            return None

        # Map price ID to tier
        tier = self.get_tier_from_price_id(price_id) if price_id else subscription.tier

        subscription.stripe_subscription_id = stripe_subscription_id
        subscription.tier = tier
        subscription.status = status
        subscription.cancel_at_period_end = cancel_at_period_end
        if current_period_start:
            subscription.current_period_start = current_period_start
        if current_period_end:
            subscription.current_period_end = current_period_end

        await self.db.commit()
        await self.db.refresh(subscription)

        # Ensure usage record exists for new period
        await self.ensure_usage_record(subscription)

        return subscription

    async def cancel_subscription(self, subscription: Subscription) -> Subscription:
        """Mark subscription as canceled and downgrade to free."""
        subscription.status = "canceled"
        subscription.tier = "free"
        subscription.canceled_at = datetime.now(timezone.utc)
        subscription.stripe_subscription_id = None

        await self.db.commit()
        await self.db.refresh(subscription)

        return subscription

    # ==================== Usage Tracking ====================

    async def ensure_usage_record(self, subscription: Subscription) -> UsageRecord:
        """Ensure a usage record exists for the current billing period."""
        now = datetime.now(timezone.utc)
        period_start = subscription.current_period_start or now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)

        result = await self.db.execute(
            select(UsageRecord).where(
                UsageRecord.subscription_id == subscription.id,
                UsageRecord.period_start == period_start,
            )
        )
        usage = result.scalar_one_or_none()

        if usage:
            return usage

        # Create new usage record
        token_limit = self.get_token_limit_for_tier(subscription.tier)
        period_end = subscription.current_period_end or period_start.replace(
            month=period_start.month + 1 if period_start.month < 12 else 1,
            year=period_start.year if period_start.month < 12 else period_start.year + 1
        )

        usage = UsageRecord(
            subscription_id=subscription.id,
            period_start=period_start,
            period_end=period_end,
            tokens_used=0,
            token_limit=token_limit,
            llm_calls=0,
        )
        self.db.add(usage)
        await self.db.commit()
        await self.db.refresh(usage)

        return usage

    async def get_current_usage(self, user_id: uuid.UUID) -> Optional[UsageRecord]:
        """Get current billing period usage for a user."""
        subscription = await self.get_subscription(user_id)
        if not subscription:
            return None

        return await self.ensure_usage_record(subscription)

    async def increment_usage(self, user_id: uuid.UUID, tokens: int) -> Optional[UsageRecord]:
        """Increment token usage for the current period."""
        usage = await self.get_current_usage(user_id)
        if not usage:
            return None

        # Atomic increment
        await self.db.execute(
            update(UsageRecord)
            .where(UsageRecord.id == usage.id)
            .values(
                tokens_used=UsageRecord.tokens_used + tokens,
                llm_calls=UsageRecord.llm_calls + 1,
                updated_at=datetime.now(timezone.utc),
            )
        )
        await self.db.commit()
        await self.db.refresh(usage)

        return usage

    async def check_quota(self, user_id: uuid.UUID) -> tuple[bool, Optional[UsageRecord]]:
        """Check if user has remaining quota. Returns (has_quota, usage_record)."""
        usage = await self.get_current_usage(user_id)
        if not usage:
            return False, None

        has_quota = usage.tokens_used < usage.token_limit
        return has_quota, usage

    # ==================== Webhook Handling ====================

    async def is_event_processed(self, event_id: str) -> bool:
        """Check if webhook event was already processed (idempotency)."""
        result = await self.db.execute(
            select(WebhookEvent).where(WebhookEvent.stripe_event_id == event_id)
        )
        return result.scalar_one_or_none() is not None

    async def mark_event_processed(self, event_id: str, event_type: str, payload: dict) -> WebhookEvent:
        """Record processed webhook event."""
        webhook_event = WebhookEvent(
            stripe_event_id=event_id,
            event_type=event_type,
            payload=payload,
        )
        self.db.add(webhook_event)
        await self.db.commit()
        return webhook_event

    # ==================== Checkout & Portal ====================

    async def create_checkout_session(
        self,
        user: User,
        tier: str,
        success_url: str,
        cancel_url: str,
    ) -> str:
        """Create Stripe Checkout session for subscription upgrade."""
        if not STRIPE_CONFIGURED:
            raise ValueError("Stripe is not configured. Cannot create checkout session.")

        stripe_customer_id = await self.get_or_create_stripe_customer(user)

        price_id = self.get_price_id_for_tier(tier)
        if not price_id:
            raise ValueError(f"Invalid tier: {tier}")

        session = stripe.checkout.Session.create(
            customer=stripe_customer_id,
            mode="subscription",
            line_items=[{"price": price_id, "quantity": 1}],
            success_url=success_url,
            cancel_url=cancel_url,
            client_reference_id=str(user.id),
            metadata={"user_id": str(user.id), "tier": tier},
        )

        return session.url

    async def create_portal_session(self, user: User, return_url: str) -> str:
        """Create Stripe Customer Portal session."""
        if not STRIPE_CONFIGURED:
            raise ValueError("Stripe is not configured. Cannot create portal session.")

        stripe_customer_id = await self.get_or_create_stripe_customer(user)

        session = stripe.billing_portal.Session.create(
            customer=stripe_customer_id,
            return_url=return_url,
        )

        return session.url

    # ==================== Helper Methods ====================

    @staticmethod
    def get_tier_from_price_id(price_id: Optional[str]) -> str:
        """Map Stripe price ID to tier name."""
        if not price_id:
            return "free"
        if price_id == settings.stripe_price_pro:
            return "pro"
        if price_id == settings.stripe_price_team:
            return "team"
        return "free"

    @staticmethod
    def get_price_id_for_tier(tier: str) -> Optional[str]:
        """Map tier name to Stripe price ID."""
        if tier == "pro":
            return settings.stripe_price_pro
        if tier == "team":
            return settings.stripe_price_team
        return None

    @staticmethod
    def get_token_limit_for_tier(tier: str) -> int:
        """Get token limit for a subscription tier."""
        if tier == "pro":
            return settings.token_limit_pro
        if tier == "team":
            return settings.token_limit_team
        return settings.token_limit_free
