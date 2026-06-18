# Architecture

## Design Principles

1. **Explicit beats magic.** Routers are included in one place. No import-time auto-discovery.
2. **One file, one concern.** Routes, services, and middlewares stay separate.
3. **App factory first.** `create_app()` owns wiring, lifespan, middleware, and router registration.
4. **Keep template small.** Fewer folders, fewer indirections, easier onboarding.

## Directory Map

```
app/
├── main.py                   # App factory + router wiring + lifespan
├── config.py                 # Settings (PORT, API_PREFIX)
├── middlewares/
│   ├── request_id.py         # Request ID middleware
│   └── setup.py              # Middleware registration
├── routes/
│   └── hello.py              # GET /api/
└── services/
    └── hello.py              # HelloService
tests/
├── conftest.py
└── test_hello.py
```

## Router Composition

`app/main.py` builds an aggregator router and includes route modules:

```python
api_router = APIRouter()
api_router.include_router(hello_router)
```

## Middleware Registration

`app/middlewares/setup.py` owns registration. Add new middlewares here:

```python
def setup_middlewares(app):
    app.add_middleware(RequestIDMiddleware)
```

## Service Pattern

Simple stateless service, instantiated in the route:

```python
# app/services/hello.py
class HelloService:
    def status(self) -> dict[str, str]:
        return {"status": "ok", "message": "API server is running"}
```

```python
# app/routes/hello.py
@router.get("/")
async def status(request: Request):
    service = HelloService()
    return service.status()
```

When you need dependencies (DB, HTTP client, etc.), pass them into the service constructor or inject via `Depends()`.

## Configuration Flow

```
Environment (.env / shell)
        │
        ▼
┌───────────────────┐
│  Settings          │  pydantic-settings.BaseSettings
│  - PORT            │  Defaults: port=8000, api_prefix="/api"
│  - API_PREFIX      │
└────────┬──────────┘
         │
         ▼
┌───────────────────┐
│  get_settings()    │  Cached via @lru_cache
└────────┬──────────┘
         │
         ▼
┌───────────────────┐
│  main.py           │  Uses api_prefix for router, stores in app.state
└───────────────────┘
```

## Dependency Graph

```
config.py          ← depends on nothing in app/
      ↑
main.py            ← depends on config.py + routes + middlewares
routes/*.py        ← depends on services/*.py
services/*.py      ← depends on nothing in app/
middlewares/*.py   ← self-contained
```

No circular dependencies. `config.py` is foundation. `main.py` is wiring layer.

## Decision Log

| Decision                          | Rationale                                                                     |
| --------------------------------- | ----------------------------------------------------------------------------- |
| Explicit router registration      | Easier to trace, version, and debug than import-time discovery.               |
| Centralized middleware setup      | Middleware order matters. One function keeps order auditable.                 |
| `pydantic-settings` for config    | De facto FastAPI standard. Type-safe, env-aware, validated at startup.        |
| `@lru_cache` on `get_settings()`  | Prevents re-reading env vars on every request. Settings immutable at runtime. |
| Service created inside route      | One less abstraction layer for starters. Easier to follow.                    |
| Lifespan hook in app factory      | Clear place for startup/shutdown resources.                                   |
| Minimal config (2 fields)         | Users extend Settings with their own fields. No bloat.                        |
| Single middleware, route, service | Minimal starter — copy the pattern, add more as needed.                       |
