# FastAPI Starter Template — Production Dockerfile
# Build: docker compose build   |   Run: docker compose up
# Follows uv Docker best practices: https://docs.astral.sh/uv/guides/integration/docker/

FROM python:3.14-slim

# Copy uv binary from Astral's official distroless image (zero-overhead vs curl/pip).
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# All app code lives under /app; uv creates .venv here during sync
WORKDIR /app

# Copy the whole project, then install everything in one pass.
# Simpler than a split deps-then-project build; trades a larger layer for clarity.
COPY . /app
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-editable

# PORT is sourced from .env via docker-compose build args (see docker-compose.yml).
# Falls back to 8000 when building without compose/args (e.g. plain `docker build`).
ARG PORT=8000
ENV PORT=$PORT

# Expose the port the server listens on
EXPOSE $PORT

# Run the server in production mode via `uv run` so the venv is handled
# automatically (PORT read from .env via scripts/serve.py)
CMD ["uv", "run", "python", "scripts/serve.py"]
