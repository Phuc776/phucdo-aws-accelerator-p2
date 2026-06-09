from fastapi import FastAPI, Response
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
import random
import time

app = FastAPI(title="W9 Observability Demo")

REQUEST_COUNT = Counter(
    "http_requests_total",
    "Total number of HTTP requests",
    ["method", "endpoint", "status"]
)

REQUEST_LATENCY = Histogram(
    "http_request_duration_seconds",
    "HTTP request latency in seconds",
    ["endpoint"]
)


def record_request(endpoint: str, status: str, duration: float):
    REQUEST_COUNT.labels(
        method="GET",
        endpoint=endpoint,
        status=status
    ).inc()

    REQUEST_LATENCY.labels(
        endpoint=endpoint
    ).observe(duration)


@app.get("/")
def root():
    start = time.time()

    time.sleep(random.uniform(0.05, 0.2))

    duration = time.time() - start
    record_request("/", "200", duration)

    return {
        "message": "W9 Observability Demo App",
        "status": "ok"
    }


@app.get("/slow")
def slow():
    start = time.time()

    time.sleep(random.uniform(0.5, 1.5))

    duration = time.time() - start
    record_request("/slow", "200", duration)

    return {
        "message": "This endpoint is intentionally slow",
        "status": "ok"
    }


@app.get("/error")
def error():
    start = time.time()

    duration = time.time() - start
    record_request("/error", "500", duration)

    return Response(
        content="Simulated internal server error",
        status_code=500
    )


@app.get("/health")
def health():
    return {
        "status": "healthy"
    }


@app.get("/metrics")
def metrics():
    return Response(
        generate_latest(),
        media_type=CONTENT_TYPE_LATEST
    )