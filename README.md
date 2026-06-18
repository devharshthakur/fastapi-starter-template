# FastAPI Starter Template

[![GitHub](https://img.shields.io/badge/github-devharshthakur/fastapi--starter--template-blue?logo=github)](https://github.com/devharshthakur/fastapi-starter-template)

Starter Template for a FastAPI project

## Quick Start

```bash
git clone https://github.com/devharshthakur/fastapi-starter-template.git my-app
cd my-app
bash setup.sh
```

`setup.sh` removes the template's `.git` history, initialises a fresh repo, installs dependencies, and starts the dev server.

Open [http://localhost:8000/api/](http://localhost:8000/api/) → `{"status":"ok","message":"API server is running"}`

## Docker

One-command production deployment. No Python or Node.js required on the host.

```bash
cp .env.example .env
docker compose up -d
```

Open [http://localhost:8000/api/](http://localhost:8000/api/).

| Command             | Description                |
| ------------------- | -------------------------- |
| `pnpm docker:up`    | Start in background        |
| `pnpm docker:down`  | Stop and remove containers |
| `pnpm docker:build` | Rebuild the image          |
| `pnpm docker:logs`  | Tail logs                  |

Or use `docker compose` commands directly. The `PORT` and `API_PREFIX` values in your `.env` file are picked up automatically. The image uses [uv](https://docs.astral.sh/uv/) for fast, reproducible dependency installation.

## Scripts

| Command             | Description              |
| ------------------- | ------------------------ |
| `pnpm dev`          | Dev server + hot reload  |
| `pnpm start`        | Production server        |
| `pnpm lint`         | Ruff + prettier checks   |
| `pnpm format`       | Auto-format all code     |
| `pnpm typecheck`    | Type checker (`ty`)      |
| `pnpm test`         | Pytest                   |
| `pnpm check`        | Lint + typecheck + tests |
| `pnpm docker:build` | Build Docker image       |
| `pnpm docker:up`    | Start Docker container   |
| `pnpm docker:down`  | Stop Docker container    |
| `pnpm docker:logs`  | Tail Docker logs         |

Pre-commit auto-formats staged files via husky + lint-staged.

## Project Structure

```
app/
├── main.py                  # App factory + router wiring
├── config.py                # Settings (PORT, API_PREFIX)
├── middlewares/
│   ├── request_id.py        # X-Request-ID middleware
│   └── setup.py             # Middleware registration
├── routes/
│   └── hello.py             # GET /api/
└── services/
    └── hello.py             # HelloService
tests/
├── conftest.py
└── test_hello.py
```

## How to Add Things

### Add a route

Create a route file, then include it in `app/main.py`:

```python
# app/routes/items.py
from fastapi import APIRouter

router = APIRouter(prefix="/items", tags=["items"])

@router.get("")
async def list_items():
    return [{"id": 1, "name": "Widget"}]
```

```python
# app/main.py
from app.routes.items import router as items_router

api_router.include_router(items_router)
```

### Add a middleware

Create middleware in `app/middlewares/`, register it in `setup.py`.

### Add a service

Create service in `app/services/`, instantiate it in your route:

```python
@router.get("/stuff")
async def stuff():
    service = MyService()
    return service.do_thing()
```

For dependencies (DB, HTTP client, etc.), pass them into the constructor or use `Depends()`.

## Configuration

Set via environment variables — no prefix. Copy `.env.example` to `.env` if needed.

| Variable     | Default | Description |
| ------------ | ------- | ----------- |
| `PORT`       | `8000`  | Server port |
| `API_PREFIX` | `/api`  | API prefix  |

Extend `Settings` in `app/config.py`:

```python
class Settings(BaseSettings):
    port: int = 8000
    api_prefix: str = "/api"
    database_url: str = "..."  # your field
```

## Linting & Formatting

- **Python**: [ruff](https://docs.astral.sh/ruff/) — rules E, F, I, double quotes, 88 char lines
- **Other**: [prettier](https://prettier.io/)
- **Pre-commit**: [lint-staged](https://github.com/lint-staged/lint-staged) via [husky](https://typicode.github.io/husky/)

## Architecture

See [architecture.md](./architecture.md) for request flow and extension rules.
