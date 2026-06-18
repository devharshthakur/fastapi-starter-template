from contextlib import asynccontextmanager

from fastapi import APIRouter, FastAPI

from app.config import get_settings
from app.middlewares.setup import setup_middlewares
from app.routes.hello import router as hello_router

api_router = APIRouter()
api_router.include_router(hello_router)


@asynccontextmanager
async def lifespan(app: FastAPI):
    settings = get_settings()
    app.state.settings = settings
    yield


def create_app() -> FastAPI:
    settings = get_settings()

    app = FastAPI(lifespan=lifespan)

    setup_middlewares(app)
    app.include_router(api_router, prefix=settings.api_prefix)

    return app
