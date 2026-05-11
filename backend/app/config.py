from pydantic_settings import BaseSettings
from functools import lru_cache


class Settings(BaseSettings):
    # Database
    database_url: str = "postgresql+asyncpg://postgres:postgres@localhost:5432/jarvis"

    # JWT
    secret_key: str = "your-secret-key-change-in-production"
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 60 * 24 * 7  # 7 days

    # Encryption key for OAuth tokens
    encryption_key: str = "your-32-byte-encryption-key-here"

    # Environment
    environment: str = "development"

    # AI Provider API Keys
    anthropic_api_key: str = ""
    openai_api_key: str = ""

    # Default AI settings
    default_ai_provider: str = "anthropic"
    anthropic_model: str = "claude-sonnet-4-20250514"
    openai_model: str = "gpt-4o"
    openai_embedding_model: str = "text-embedding-3-small"

    # Llama API (Meta)
    llama_api_key: str = ""
    llama_model: str = "Llama-4-Maverick-17B-128E-Instruct-FP8"

    # Groq API (Free tier - fast Llama inference)
    groq_api_key: str = ""
    groq_model: str = "llama-3.3-70b-versatile"

    # Google Gemini API (Free tier available)
    gemini_api_key: str = ""
    gemini_model: str = "gemini-2.0-flash"

    # Google OAuth (Calendar, Gmail, Contacts)
    google_client_id: str = ""
    google_client_secret: str = ""

    # Stripe Billing
    stripe_secret_key: str = ""
    stripe_publishable_key: str = ""
    stripe_webhook_secret: str = ""
    stripe_price_pro: str = "price_pro_monthly"
    stripe_price_team: str = "price_team_monthly"

    # Token Limits per Tier (monthly)
    token_limit_free: int = 50_000
    token_limit_pro: int = 500_000
    token_limit_team: int = 2_000_000

    class Config:
        env_file = ".env"
        extra = "ignore"


@lru_cache
def get_settings() -> Settings:
    return Settings()
