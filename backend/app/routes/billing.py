"""Billing routes for subscription management and Stripe webhooks."""
import stripe
from fastapi import APIRouter, Depends, HTTPException, Request, Header
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession
from typing import Optional
from datetime import datetime, timezone

from app.config import get_settings
from app.database import get_db
from app.deps import get_current_user
from app.models import User
from app.services.billing import BillingService

router = APIRouter(prefix="/billing", tags=["billing"])
settings = get_settings()


# ==================== Request/Response Models ====================

class SubscriptionResponse(BaseModel):
    tier: str
    status: str
    tokens_used: int
    token_limit: int
    llm_calls: int
    period_start: Optional[datetime]
    period_end: Optional[datetime]
    cancel_at_period_end: bool


class CheckoutRequest(BaseModel):
    tier: str  # "pro" or "team"
    success_url: str
    cancel_url: str


class CheckoutResponse(BaseModel):
    checkout_url: str


class PortalRequest(BaseModel):
    return_url: str


class PortalResponse(BaseModel):
    portal_url: str


# ==================== Subscription Endpoints ====================

@router.get("/subscription", response_model=SubscriptionResponse)
async def get_subscription(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Get current user's subscription and usage."""
    billing = BillingService(db)

    subscription = await billing.get_subscription(current_user.id)
    if not subscription:
        # Create free subscription if none exists
        subscription = await billing.create_free_subscription(current_user)

    usage = await billing.ensure_usage_record(subscription)

    return SubscriptionResponse(
        tier=subscription.tier,
        status=subscription.status,
        tokens_used=usage.tokens_used,
        token_limit=usage.token_limit,
        llm_calls=usage.llm_calls,
        period_start=subscription.current_period_start,
        period_end=subscription.current_period_end,
        cancel_at_period_end=subscription.cancel_at_period_end,
    )


@router.post("/checkout", response_model=CheckoutResponse)
async def create_checkout(
    request: CheckoutRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Create Stripe Checkout session for subscription upgrade."""
    if request.tier not in ("pro", "team"):
        raise HTTPException(status_code=400, detail="Invalid tier. Must be 'pro' or 'team'.")

    billing = BillingService(db)

    try:
        checkout_url = await billing.create_checkout_session(
            user=current_user,
            tier=request.tier,
            success_url=request.success_url,
            cancel_url=request.cancel_url,
        )
        return CheckoutResponse(checkout_url=checkout_url)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except stripe.StripeError as e:
        raise HTTPException(status_code=502, detail=f"Stripe error: {str(e)}")


@router.post("/portal", response_model=PortalResponse)
async def create_portal(
    request: PortalRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Create Stripe Customer Portal session for subscription management."""
    billing = BillingService(db)

    try:
        portal_url = await billing.create_portal_session(
            user=current_user,
            return_url=request.return_url,
        )
        return PortalResponse(portal_url=portal_url)
    except stripe.StripeError as e:
        raise HTTPException(status_code=502, detail=f"Stripe error: {str(e)}")


# ==================== Stripe Webhook ====================

@router.post("/webhooks/stripe")
async def stripe_webhook(
    request: Request,
    stripe_signature: str = Header(None, alias="Stripe-Signature"),
    db: AsyncSession = Depends(get_db),
):
    """Handle Stripe webhook events."""
    if not stripe_signature:
        raise HTTPException(status_code=400, detail="Missing Stripe-Signature header")

    payload = await request.body()

    # Verify webhook signature
    try:
        event = stripe.Webhook.construct_event(
            payload,
            stripe_signature,
            settings.stripe_webhook_secret,
        )
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid payload")
    except stripe.SignatureVerificationError:
        raise HTTPException(status_code=400, detail="Invalid signature")

    billing = BillingService(db)

    # Check idempotency
    if await billing.is_event_processed(event.id):
        return {"status": "already_processed"}

    # Handle subscription events
    event_type = event.type
    data = event.data.object

    if event_type == "customer.subscription.created":
        await handle_subscription_update(billing, data)

    elif event_type == "customer.subscription.updated":
        await handle_subscription_update(billing, data)

    elif event_type == "customer.subscription.deleted":
        await handle_subscription_deleted(billing, data)

    elif event_type == "invoice.paid":
        # Subscription renewed - ensure usage record for new period
        customer_id = data.get("customer")
        if customer_id:
            subscription = await billing.get_subscription_by_customer(customer_id)
            if subscription:
                await billing.ensure_usage_record(subscription)

    # Mark event as processed
    await billing.mark_event_processed(event.id, event_type, dict(data))

    return {"status": "processed"}


async def handle_subscription_update(billing: BillingService, data: dict):
    """Handle subscription created/updated events."""
    await billing.update_subscription_from_stripe(
        stripe_subscription_id=data.get("id"),
        stripe_customer_id=data.get("customer"),
        status=data.get("status"),
        price_id=data.get("items", {}).get("data", [{}])[0].get("price", {}).get("id"),
        current_period_start=datetime.fromtimestamp(data.get("current_period_start", 0), tz=timezone.utc) if data.get("current_period_start") else None,
        current_period_end=datetime.fromtimestamp(data.get("current_period_end", 0), tz=timezone.utc) if data.get("current_period_end") else None,
        cancel_at_period_end=data.get("cancel_at_period_end", False),
    )


async def handle_subscription_deleted(billing: BillingService, data: dict):
    """Handle subscription canceled/deleted events."""
    customer_id = data.get("customer")
    subscription = await billing.get_subscription_by_customer(customer_id)
    if subscription:
        await billing.cancel_subscription(subscription)
