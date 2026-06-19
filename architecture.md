# Architecture

## Project Structure

```
app/
├── app.py               # App factory — wires routes, middlewares
├── config.py            # pydantic-settings — loads env vars
├── middlewares/
│   ├── request_id.py    # X-Request-ID middleware
│   └── setup.py         # Central middleware registration
├── routes/
│   └── hello.py         # GET /api/ endpoint
└── services/
    └── hello.py         # HelloService — business logic
scripts/
└── serve.py             # Launcher — runs `fastapi dev|run` with PORT from .env
tests/
├── conftest.py          # TestClient fixture
└── test_hello.py        # Status endpoint test
```

## Scripts

All commands are run via `pnpm`. They're defined in `package.json` and just wrap Python/Node tooling — no magic.

### Development

| Command      | What it does                                                        |
| ------------ | ------------------------------------------------------------------- |
| `pnpm dev`   | `uv run python scripts/serve.py --dev` — dev server with hot reload |
| `pnpm start` | `uv run python scripts/serve.py` — production server                |

Both honour `PORT` from `.env` (read through `Settings` in `scripts/serve.py`), so dev, prod, and Docker share one source of truth.

### Quality

| Command          | What it does                                                     |
| ---------------- | ---------------------------------------------------------------- |
| `pnpm lint`      | `ruff check .` (Python) + `prettier --check .` (everything else) |
| `pnpm format`    | `ruff format .` + `prettier --write .` — auto-fix in place       |
| `pnpm typecheck` | `ty check` — static type checking                                |
| `pnpm test`      | `pytest`                                                         |
| `pnpm check`     | Runs lint → typecheck → test in sequence                         |

## How Routes, Services, and Middlewares Work

### Routes live in `app/routes/`

Each route file creates an `APIRouter` and registers handlers on it. The router is then imported and attached to the app in `app/app.py`.

```python
# app/routes/hello.py
from fastapi import APIRouter, Depends, Request

from app.config import Settings, get_settings
from app.services.hello import HelloService

router = APIRouter(tags=["status"])


def get_hello_service(settings: Settings = Depends(get_settings)) -> HelloService:
    return HelloService(settings)


@router.get("/")
async def status(request: Request, service: HelloService = Depends(get_hello_service)):
    data = service.status()
    request_id: str | None = getattr(request.state, "request_id", None)
    return {**data, "request_id": request_id}
```

Registration happens explicitly inside `create_app()` in `app/app.py` — no auto-discovery:

```python
# app/app.py
from app.routes.hello import router as hello_router

def create_app() -> FastAPI:
    ...
    api_router = APIRouter()
    api_router.include_router(hello_router)
    # add more routers here
    app.include_router(api_router, prefix=settings.api_prefix)
    return app
```

### Services live in `app/services/`

Services contain business logic. They receive their dependencies (config, DB clients, HTTP clients) through the constructor and are built per-request via a FastAPI dependency.

```python
# app/services/hello.py
from app.config import Settings


class HelloService:
    def __init__(self, settings: Settings) -> None:
        self.settings = settings

    def status(self) -> dict[str, str | int]:
        return {
            "status": "ok",
            "message": "API server is running",
            "port": self.settings.port,
            "api_prefix": self.settings.api_prefix,
        }
```

The matching dependency (`get_hello_service` in the route file) is what you override in tests via `app.dependency_overrides`.

### Middlewares live in `app/middlewares/`

Middlewares intercept every request/response. Create your middleware class, then register it in `setup.py`:

```python
# app/middlewares/setup.py
from fastapi import FastAPI
from app.middlewares.request_id import RequestIDMiddleware

def setup_middlewares(app: FastAPI) -> None:
    app.add_middleware(RequestIDMiddleware)
    # add more middlewares here — order matters
```

Middleware classes extend `starlette.middleware.base.BaseHTTPMiddleware`:

```python
import uuid

from fastapi import Request, Response
from starlette.middleware.base import BaseHTTPMiddleware, RequestResponseEndpoint


class RequestIDMiddleware(BaseHTTPMiddleware):
    """Attach an X-Request-ID to every request and echo it on the response."""

    async def dispatch(self, request: Request, call_next: RequestResponseEndpoint) -> Response:
        request_id = request.headers.get("X-Request-ID", str(uuid.uuid4()))
        request.state.request_id = request_id
        response = await call_next(request)
        response.headers["X-Request-ID"] = request_id
        return response
```

## Dependency Flow

```
config.py       — depends on nothing
services/*.py   — depends on nothing (or external libs)
routes/*.py     — depends on services/*
middlewares/*.py — self-contained
app/app.py       — depends on config + routes + middlewares (the wiring layer)
main.py          — root entry point; imports create_app from app/app.py
```

`config.py` is the foundation. `app/app.py` is the wiring layer that ties everything together; root `main.py` just exposes `app = create_app()` for the `fastapi` CLI.

## App Lifecycle

No `lifespan` is registered by default. Add one to `create_app()` only when you have real startup/teardown work (DB pools, cache warmup, background tasks) — an empty lifespan just adds ceremony.

## Pre-commit Quality Checks

[husky](https://typicode.github.io/husky/) and [lint-staged](https://github.com/lint-staged/lint-staged) run automatically before every commit. They stage-only lint and format changed files so you never push messy code.

To run these checks **manually** instead of waiting for a commit:

```bash
# Full quality gate (same as what CI would run)
pnpm check

# Or individual checks
pnpm lint        # ruff + prettier (check only)
pnpm format      # ruff + prettier (auto-fix)
pnpm typecheck   # static types
pnpm test        # unit tests
```
