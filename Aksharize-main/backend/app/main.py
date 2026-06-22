"""
Aksharize OCR Backend
---------------------
FastAPI application entry point.
"""

# pyrefly: ignore [missing-import]
from fastapi import FastAPI 
# pyrefly: ignore [missing-import]
from fastapi.middleware.cors import CORSMiddleware
from app.routes.ocr import router as ocr_router

app = FastAPI(
    title="Aksharize OCR API",
    description="Street-sign OCR service – MVP",
    version="0.1.0",
)

# ── CORS ──────────────────────────────────────────────────────────────────────
# Open for MVP; tighten in production.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ── Routes ────────────────────────────────────────────────────────────────────
app.include_router(ocr_router, tags=["OCR"])


@app.get("/", tags=["Health"])
def health_check():
    return {"status": "ok", "service": "Aksharize OCR API"}