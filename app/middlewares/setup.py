from fastapi import FastAPI

from app.middlewares.request_id import RequestIDMiddleware


def setup_middlewares(app: FastAPI) -> None:
    app.add_middleware(RequestIDMiddleware)
    # Example: enable CORS when wiring a frontend.
    # from fastapi.middleware.cors import CORSMiddleware
    # app.add_middleware(
    #     CORSMiddleware,
    #     allow_origins=["*"],
    #     allow_methods=["*"],
    #     allow_headers=["*"],
    # )
