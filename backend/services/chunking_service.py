import os
from typing import List, Dict

class ChunkingService:
    @staticmethod
    def create_chunks(
        pages: List[Dict[str, any]],
        chunk_size: int = 800,
        chunk_overlap: int = 100
    ) -> List[Dict[str, any]]:
        """
        Splits document pages into text chunks with configurable size and overlap.
        """
        chunks = []
        global_chunk_idx = 1

        for p in pages:
            page_num = p.get("page", 1)
            text = p.get("text", "")
            if not text.strip():
                continue

            # Split text into overlapping windows
            start = 0
            text_len = len(text)

            while start < text_len:
                end = min(start + chunk_size, text_len)
                chunk_text = text[start:end].strip()

                if chunk_text:
                    chunks.append({
                        "chunkId": f"chunk_{global_chunk_idx:02d}",
                        "page": page_num,
                        "text": chunk_text,
                        "charCount": len(chunk_text)
                    })
                    global_chunk_idx += 1

                if end >= text_len:
                    break

                start += (chunk_size - chunk_overlap)

        return chunks
