"""
Jarvis Backend API - Privacy-First Architecture

This backend is a thin, stateless service that provides:
- Authentication (register, login)
- LLM proxy (forwards requests to AI providers)
- Billing (Stripe subscription management)

ALL user data stays on-device:
- Conversations
- Memory graph
- User preferences
- OAuth connections

The backend never sees real user data - only anonymized tokens (PERSON_1, etc.)
"""

from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.routes import auth, billing, llm, sync


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Startup: warm up database connection."""
    # Warm up database connection
    try:
        from app.database import async_session_maker
        from sqlalchemy import text
        async with async_session_maker() as db:
            await db.execute(text("SELECT 1"))
    except Exception:
        pass

    yield


app = FastAPI(
    title="Jarvis API",
    description="Privacy-First Backend - LLM Proxy & Billing (all user data stays on-device)",
    version="1.0.0",
    lifespan=lifespan,
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure appropriately for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers (minimal - privacy-first)
app.include_router(auth.router)      # POST /auth/register, /auth/login, GET /auth/me
app.include_router(llm.router)       # POST /llm/chat (streaming), GET /llm/providers
app.include_router(billing.router)   # GET /billing/subscription, POST /billing/checkout, webhooks
app.include_router(sync.router)      # POST /sync/infer-relationships (deep network sync)


@app.get("/health")
async def health_check() -> dict:
    """Health check endpoint."""
    return {"status": "healthy", "architecture": "privacy-first"}
