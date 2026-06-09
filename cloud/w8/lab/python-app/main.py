from fastapi import FastAPI
import socket

app = FastAPI()

@app.get("/")
def root():
    return {
        "message": "Hello from Kubernetes",
        "hostname": socket.gethostname()
    }
@app.get("/{name}")
def greet(name: str):
    return {
        "message": f"Hello, Mr. {name}, from Kubernetes!",
        "hostname": socket.gethostname()
    }
@app.get("/status/health")
def health():
    return {
        "status": "ok"
    }
