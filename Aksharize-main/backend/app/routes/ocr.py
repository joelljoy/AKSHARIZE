"""
OCR Route
---------
POST /ocr   – accepts a multipart image upload, runs OCR, returns JSON.
"""

import io

# pyrefly: ignore [missing-import]
import cv2
# pyrefly: ignore [missing-import]
import numpy as np
# pyrefly: ignore [missing-import]
from fastapi import APIRouter, File, HTTPException, UploadFile
# pyrefly: ignore [missing-import]
from fastapi.responses import JSONResponse

from app.services.ocr_service import extract_text
from app.services.transliteration_service import malayalam_to_english

router = APIRouter()

@router.post("/ocr")
async def ocr_endpoint(image: UploadFile = File(...)):
    # ── 1. Validate MIME type (loose check) ──────────────────────────────────
    if image.content_type not in (
        "image/jpeg",
        "image/png",
        "image/webp",
        "image/bmp",
        "image/tiff",
        "image/jpg",
        "application/octet-stream",  # some clients omit explicit MIME
    ):
        raise HTTPException(
            status_code=400,
            detail={"error": "Invalid image file. Upload a JPEG, PNG, or similar image."},
        )

    # ── 2. Read raw bytes ─────────────────────────────────────────────────────
    try:
        raw_bytes = await image.read()
        if not raw_bytes:
            raise ValueError("Empty file")
    except Exception:
        raise HTTPException(
            status_code=400, detail={"error": "Invalid image file"}
        )

    # ── 3. Decode with OpenCV ─────────────────────────────────────────────────
    np_arr = np.frombuffer(raw_bytes, dtype=np.uint8)
    
    img = cv2.imdecode(np_arr, cv2.IMREAD_COLOR)

    if img is None:

        raise HTTPException(

            status_code=400,

        detail={"error": "Invalid image file - could not decode."}

    )

    cv2.imwrite("received_image.png", img)



    # ── 4. Run OCR ────────────────────────────────────────────────────────────
    try:
        text = extract_text(img)

        transliterated_text = malayalam_to_english(text)

        print("OCR:", text)
        print("TRANSLITERATION:", transliterated_text)

    except Exception as exc:
        raise HTTPException(
            status_code=500,
            detail={"error": f"OCR processing failed: {str(exc)}"}
        )

    return JSONResponse(
        content={
            "text": text,
            "transliteration": transliterated_text
        }
    )