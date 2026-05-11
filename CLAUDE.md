# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Jarvis is a privacy-first, on-device AI assistant ("Life Operating System"). User data (conversations, memory graph, preferences) stays on-device; the backend is a thin stateless service for auth, LLM proxying, and billing only. The backend never sees real user data—only anonymized tokens (PERSON_1, EMAIL_1, etc.).

## Development Commands

### Backend (Python/FastAPI)
```bash
cd backend
source .venv/bin/activate
pip install -r requirements.txt

# Database
docker-compose up -d                    # Start PostgreSQL (pgvector + Apache AGE)
alembic upgrade head                    # Run migrations
alembic revision --autogenerate -m "description"  # Create migration

# Run server (restart after file changes)
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### Frontend (Flutter/Dart)
```bash
cd frontend
flutter pub get
dart run build_runner build --delete-conflicting-outputs  # Generate Drift, ObjectBox, Riverpod code
flutter run -d <device_id>
flutter test integration_test/calendar_integration_test.dart -d <device_id>
```

## Architecture

### Backend (`/backend/app/`)
- **main.py** - FastAPI app with CORS, includes 4 routers
- **routes/** - `auth.py` (register/login/me), `llm.py` (chat streaming), `billing.py` (Stripe), `sync.py` (relationship inference)
- **ai/providers/** - Factory pattern for AI providers: Anthropic (Claude), OpenAI, Gemini, Groq (Llama)
- **models.py** - User, Subscription, UsageRecord, WebhookEvent (SQLAlchemy async)
- **dependencies/quota.py** - Token usage tracking per subscription tier

**API Endpoints:**
| Route | Purpose |
|-------|---------|
| `POST /auth/register`, `/login`, `GET /me` | JWT auth |
| `POST /llm/chat` | LLM inference (streaming via SSE) |
| `GET /llm/providers` | List available AI providers |
| `GET/POST /billing/*` | Subscription & Stripe webhooks |
| `POST /sync/infer-relationships` | Deep network sync |

**Default Provider:** Groq (Llama 3.3 70B) - free tier; Premium: Claude, Gemini, GPT-4o

### Frontend (`/frontend/lib/`)
- **core/** - Theme, widgets, services (OAuth, native bridges), network (Dio), storage
- **data/** - Drift (SQLite), ObjectBox (vectors), TensorFlow Lite embeddings, repositories
- **features/** - agent, chat, memory, auth, settings, integrations, onboarding

**Agent Pipeline:**
```
User Message → IntentClassifier → FunctionRouter
  ├─ LOCAL (calendar, memory, contacts) → Execute locally
  └─ NEEDS_LLM → EntityAnonymizer → Backend → De-anonymizer → MemoryExtractor → GraphUpdate
```

**State Management:** Riverpod throughout
**Navigation:** GoRouter
**Native Bridges:** iOS method channels for Calendar (EventKit) & Contacts

### Database
- **PostgreSQL 16** with pgvector (384-dim embeddings) + Apache AGE (graph)
- **Drift (SQLite)** on device: conversations, messages, memory_nodes, memory_edges
- **ObjectBox** on device: vector embeddings for semantic search

## Key Patterns

1. **Factory Pattern** - AI provider selection in `ai/factory.py`
2. **Privacy-First** - PII anonymized before transmission (PERSON_1, PHONE_1, EMAIL_1)
3. **Streaming** - SSE via sse-starlette for real-time LLM responses
4. **Quota Tiers** - Free (50K tokens/mo), Pro (500K), Team (2M)

## Environment Variables

Backend requires `.env` with:
- `DATABASE_URL` - PostgreSQL connection string
- `SECRET_KEY` - JWT signing (change in production)
- `ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, `GEMINI_API_KEY`, `GROQ_API_KEY`
- `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET`

## Important Notes

- **Restart server after file changes** to avoid stale shell output consuming context
- Use `datetime.now(datetime.timezone.utc)` instead of deprecated `datetime.utcnow()`
- Frontend code generation required after modifying Drift schemas or Riverpod providers
- iOS deployment target: 14.0+
