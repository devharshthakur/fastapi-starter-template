from app.config import Settings


class HelloService:
    def __init__(self, settings: Settings) -> None:
        self.settings = settings

    def status(self) -> dict[str, str | int]:
        return {
            "status": "ok",
            "message": "API server is running",
            "port": self.settings.port,
            "api_prefix": self.settings.api_prefix,
        }
