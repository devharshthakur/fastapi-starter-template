from fastapi import APIRouter, Request

from app.services.hello import HelloService

router = APIRouter(tags=["status"])


@router.get("/")
async def status(request: Request):
    service = HelloService()
    data = service.status()
    request_id: str | None = getattr(request.state, "request_id", None)
    return {**data, "request_id": request_id}
