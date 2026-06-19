from fastapi import APIRouter, Depends, Request

from app.config import Settings, get_settings
from app.services.hello import HelloService

router = APIRouter(tags=["status"])


def get_hello_service(settings: Settings = Depends(get_settings)) -> HelloService:
    return HelloService(settings)


@router.get("/")
async def status(
    request: Request,
    service: HelloService = Depends(get_hello_service),
):
    data = service.status()
    request_id: str | None = getattr(request.state, "request_id", None)
    return {**data, "request_id": request_id}
