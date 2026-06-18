class HelloService:
    def status(self) -> dict[str, str]:
        return {"status": "ok", "message": "API server is running"}
