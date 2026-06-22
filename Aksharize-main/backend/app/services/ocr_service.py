"""
OCR Service
-----------
Accepts a raw NumPy image (BGR, as decoded by OpenCV),
preprocesses it, runs Tesseract OCR, and returns the
extracted text string.
"""

# pyrefly: ignore [missing-import]
import cv2
# pyrefly: ignore [missing-import]
import numpy as np
# pyrefly: ignore [missing-import]
import pytesseract

pytesseract.pytesseract.tesseract_cmd = "/opt/homebrew/bin/tesseract"


def preprocess(image: np.ndarray) -> np.ndarray:
    """
    Preprocess a BGR image for Malayalam OCR.

    Current pipeline:
        1. Grayscale conversion

    NOTE:
    Additional preprocessing such as thresholding,
    resizing, and blurring reduced OCR accuracy
    during testing and is intentionally disabled.
    """

    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

    return gray


def extract_text(image: np.ndarray) -> str:
    """
    Run the full OCR pipeline on a BGR NumPy image.

    Supports:
        - Malayalam (mal)

    Returns:
        Extracted Malayalam text.
    """

    preprocessed = preprocess(image)

    cv2.imwrite("debug_original.png", image)
    cv2.imwrite("debug_processed.png", preprocessed)

    # Tesseract configuration:
    # OEM 3 -> Default OCR Engine
    # PSM 8 -> Single Word
    config = "--oem 3 --psm 8"

    text: str = pytesseract.image_to_string(
        preprocessed,
        lang="mal",
        config=config
    )

    print("OCR OUTPUT:", repr(text))

    return text.strip()