# pyrefly: ignore [missing-import]
from indic_transliteration import sanscript
# pyrefly: ignore [missing-import]
from indic_transliteration.sanscript import transliterate

COMMON_MAP = {
    # General
    "കേരളം": "Kerala",
    "കേരള": "Kerala",
    "കേരളം.": "Kerala",
    "മലയാളം": "Malayalam",

    # Major cities / districts
    "തിരുവനന്തപുരം": "Thiruvananthapuram",
    "കൊച്ചി": "Kochi",
    "കോഴിക്കോട്": "Kozhikode",
    "കണ്ണൂർ": "Kannur",
    "കണ്ണൂര്": "Kannur",
    "കോട്ടയം": "Kottayam",
    "കൊല്ലം": "Kollam",
    "ആലപ്പുഴ": "Alappuzha",
    "പാലക്കാട്": "Palakkad",
    "മലപ്പുറം": "Malappuram",
    "വയനാട്": "Wayanad",
    "ഇടുക്കി": "Idukki",
    "പത്തനംതിട്ട": "Pathanamthitta",
    "കാസർഗോഡ്": "Kasaragod",
    "കാസർകോട്": "Kasaragod",
    "എറണാകുളം": "Ernakulam",
    "തൃശൂർ": "Thrissur",
    "തൃശ്ശൂർ": "Thrissur",
    "തൃശൂര്": "Thrissur",

    # Towns / places
    "ആലുവ": "Aluva",
    "തൊടുപുഴ": "Thodupuzha",
    "ഉടുമ്പന്നൂർ": "Udumbannoor",
    "ഉടുമ്പന്നൂര": "Udumbannoor",

    # Pilgrim / famous places
    "ഗുരുവായൂർ": "Guruvayur",
    "ഗുരുവായൂര്": "Guruvayur",
    "ശബരിമല": "Sabarimala",

    # Common OCR variants
    "കൊച്ചി.": "Kochi",
    "കണ്ണൂര്.": "Kannur",
    "തൃശൂര്": "Thrissur",
}

def normalize_text(text: str) -> str:
    return (
        text.replace("\u200d", "")  # ZWJ
            .replace("\u200c", "")  # ZWNJ
            .strip()
    )

def malayalam_to_english(text: str) -> str:
    stripped = normalize_text(text)

    if stripped in COMMON_MAP:
        return COMMON_MAP[stripped]

    # try fuzzy city match
    for key, value in COMMON_MAP.items():
        if key in stripped:
            return value

    return transliterate(
        stripped,
        sanscript.MALAYALAM,
        sanscript.ITRANS
    )