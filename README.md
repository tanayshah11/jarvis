# Jarvis

A privacy-first, on-device AI assistant. Your data never leaves your phone.

Every consumer AI assistant in 2025 ships your data to a cloud, indefinitely. Jarvis is designed from the opposite default: assume the cloud is hostile, then see how much you can do with a backend that genuinely doesn't see your data.

**Case study:** [tanayshah.dev/projects/jarvis](https://tanayshah.dev/projects/jarvis)

## Architecture

Fat client + thin stateless backend.

- **Frontend (Flutter)** — all user data stays on-device:
  - **Drift / SQLite** for structured data (conversations, memories, preferences)
  - **ObjectBox** for vector embeddings
  - **TensorFlow Lite** for on-device embedding inference
  - **Apache AGE-shaped memory graph** (people, places, events, references) — manual edge tables in Drift on-device; same shape syncable to a real AGE backend if the user opts into cloud sync
  - **Riverpod** for state, **go_router** for navigation, **Dio** for HTTP

- **Backend (FastAPI)** — four routes, never sees real user data:
  - `auth` — bcrypt + JWT
  - `llm-proxy` — provider-agnostic chat (Anthropic / OpenAI / Gemini / Groq via factory pattern; Groq + Llama 3.3 70B is the free default tier)
  - `billing` — token-quota tracking server-side; contents stay on-device
  - `relationship-inference` — operates on anonymized tokens (`PERSON_1`, `EMAIL_1`, `ADDR_1`) only; the de-anonymization map never leaves the device

Postgres with `pgvector` and `Apache AGE` extensions for the (opt-in) cloud-sync path. Alembic for migrations.

## Project structure

```
jarvis/
├── backend/                FastAPI service
│   ├── app/                routes, services, models
│   ├── alembic/            migrations
│   ├── scripts/            local dev helpers
│   ├── tests/
│   └── requirements.txt
├── frontend/               Flutter app
│   ├── lib/                Dart source
│   ├── ios/  android/      platform shells
│   ├── assets/
│   └── pubspec.yaml
└── docker-compose.yml      local Postgres + backend
```

## Running locally

### Backend

```bash
cd backend
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env       # then fill in API keys for the LLM providers you want
alembic upgrade head
uvicorn app.main:app --reload
```

### Frontend

```bash
cd frontend
flutter pub get
flutter run
```

### Postgres + everything via Docker

```bash
docker compose up -d
```

## Status

Prototype. Built in 2025 to test how much utility a fat-client / thin-backend assistant can deliver under the strict assumption that the backend never sees real user data. See the [case study](https://tanayshah.dev/projects/jarvis) for the design decisions and tradeoffs.

## License

All rights reserved. Open-sourced for portfolio review and reading; not a product, not a contribution-accepting project.
