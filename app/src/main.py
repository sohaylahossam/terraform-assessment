from fastapi import FastAPI
from datetime import datetime
import os

app = FastAPI()

@app.get("/")
def root():
    """Root endpoint - Hello World with timestamp"""
    return {
        "message": "Hello World from Python FastAPI!",
        "timestamp": datetime.utcnow().isoformat(),
        "environment": os.getenv("ENVIRONMENT", "development")
    }

@app.get("/health")
def health():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "timestamp": datetime.utcnow().isoformat()
    }

if __name__ == "__main__":
    import uvicorn
    port = int(os.getenv("PORT", 8080))
    uvicorn.run(app, host="0.0.0.0", port=port)
