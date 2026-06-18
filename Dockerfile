# FastAPI Starter Template — Production Dockerfile
# Build: docker compose build   |   Run: docker compose up
# Follows uv Docker best practices: https://docs.astral.sh/uv/guides/integration/docker/

FROM python:3.14-slim

# Copy uv binary from Astral's official distroless image (zero-overhead vs curl/pip).
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# All app code lives under /app; uv creates .venv here during sync
WORKDIR /app

# Layer 1 — Install third-party dependencies (cached until uv.lock or pyproject.toml change)
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --frozen --no-install-project --no-editable

# Copy application source (main.py, app/, uv.lock, etc.)
COPY . /app

# Layer 2 — Install the project into the already-built .venv from Layer 1
# Only processes the project's own entry points; all third-party deps already resolved
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-editable

# Activate venv: fastapi / python resolve directly without `uv run` prefix
ENV PATH="/app/.venv/bin:$PATH"

# Expose ports
EXPOSE 8000

# Run the server in production mode
CMD ["fastapi", "run", "main.py", "--port", "8000"]
