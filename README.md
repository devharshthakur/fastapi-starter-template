# FastAPI Starter Template

A clean, opinionated FastAPI starter that gets out of your way. Comes with uv for fast dependency management, Docker for production deployment, and pre-commit quality checks.

## Quick Start

```bash
git clone https://github.com/devharshthakur/fastapi-starter-template.git my-app
cd my-app
pnpm install
```

This strips the template's git history, initialises a fresh repository, installs Python dependencies, generates `.env`, and starts the dev server — all in one command.

## Run project via Docker

Run the app in production via docker as well

```bash
cp .env.example .env
pnpm docker:start
```

| Command               | What it does                              |
| --------------------- | ----------------------------------------- |
| `pnpm docker:build`   | Build the image (uses cache)              |
| `pnpm docker:rebuild` | Rebuild the image from scratch (no cache) |
| `pnpm docker:start`   | Start containers in background            |
| `pnpm docker:stop`    | Stop running containers (keep them)       |
| `pnpm docker:clean`   | Stop and remove containers + network      |

## Configuring environment vriables

This template uses pydantic settings to parse env contents before starting the server. So env files is the single source of truth

| Variable     | Default | What it controls                                         |
| ------------ | ------- | -------------------------------------------------------- |
| `PORT`       | `8000`  | Which port the server listens on (dev, prod, and Docker) |
| `API_PREFIX` | `/api`  | URL prefix for all API routes                            |

Copy `.env.example` to `.env` and you're set. To add your own settings, extend the `Settings` class in `app/config.py`:

> [!NOTE]
> Every new field is automatically loaded from the matching environment variable, type-checked, and validated at startup.

## Project Structure & Architecture

See [ARCHITECTURE.md](./ARCHITECTURE.md) for the directory layout, request lifecycle, and how to add routes, middlewares, or services and more.

## License

This project is made under [MIT](./LICENSE) license.
