from fastapi import FastAPI

from app.middlewares.request_id import RequestIDMiddleware


def setup_middlewares(app: FastAPI) -> None:
    app.add_middleware(RequestIDMiddleware)
