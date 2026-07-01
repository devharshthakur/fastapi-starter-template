# app/app.py — app factory (wires routes, middlewares). Called by root main.py.
from fastapi import APIRouter, FastAPI

from app.config import get_settings
from app.middlewares.setup import setup_middlewares
from app.routes.hello import router as hello_router


def create_app() -> FastAPI:
    settings = get_settings()

    app = FastAPI()
    app.state.settings = settings

    setup_middlewares(app)

    api_router = APIRouter()
    api_router.include_router(hello_router)
    # add more routers here
    app.include_router(api_router, prefix=settings.api_prefix)

    return app
