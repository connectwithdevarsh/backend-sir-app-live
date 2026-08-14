import io
from typing import List, Dict

class DocumentService:
    @staticmethod
    def extract_txt_text(file_bytes: bytes) -> List[Dict[str, any]]:
        """
        Extracts structured text from raw TXT bytes.
        """
        try:
            text = file_bytes.decode('utf-8')
        except UnicodeDecodeError:
            text = file_bytes.decode('latin-1', errors='ignore')

        clean_text = text.strip()
        if not clean_text:
            return []

        # Return single page representation for plain text
        return [
            {
                "page": 1,
                "text": clean_text
            }
        ]

    @staticmethod
    def extract_pdf_text(file_bytes: bytes) -> List[Dict[str, any]]:
        """
        Extracts structured text per page from PDF bytes.
        """
        pages = []
        try:
            import pypdf
            reader = pypdf.PdfReader(io.BytesIO(file_bytes))
            for idx, page in enumerate(reader.pages):
                extracted = page.extract_text() or ""
                if extracted.strip():
                    pages.append({
                        "page": idx + 1,
                        "text": extracted.strip()
                    })
        except Exception:
            # Fallback to plain string extraction if PyPDF is unavailable
            raw = file_bytes.decode('utf-8', errors='ignore')
            if raw.strip():
                pages.append({
                    "page": 1,
                    "text": raw.strip()
                })

        return pages
