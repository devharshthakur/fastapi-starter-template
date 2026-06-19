import pytest
from fastapi.testclient import TestClient

from app.app import create_app
from app.config import get_settings


@pytest.fixture
def app():
    get_settings.cache_clear()
    application = create_app()
    yield application
    application.dependency_overrides.clear()


@pytest.fixture
def client(app):
    with TestClient(app) as test_client:
        yield test_client
