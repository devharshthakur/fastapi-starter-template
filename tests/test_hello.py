def test_status_returns_running(client):
    response = client.get("/api/")

    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "ok"
    assert data["message"] == "API server is running"
    assert data["request_id"]
    assert response.headers["X-Request-ID"]
