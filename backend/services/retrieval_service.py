import math
from typing import List, Dict, Any
from services.embedding_service import EmbeddingService

class RetrievalService:
    # In-memory document vector index store
    _index_store: Dict[str, Dict[str, Any]] = {}

    @classmethod
    def index_document(cls, document_id: str, filename: str, chunks: List[Dict[str, Any]]):
        """
        Indexes a document by generating embeddings for all text chunks.
        """
        texts = [c["text"] for c in chunks]
        vectors = EmbeddingService.compute_tfidf_vectors(texts)

        indexed_chunks = []
        for idx, chunk in enumerate(chunks):
            indexed_chunks.append({
                "chunkId": chunk["chunkId"],
                "page": chunk["page"],
                "text": chunk["text"],
                "vector": vectors[idx]
            })

        cls._index_store[document_id] = {
            "documentId": document_id,
            "filename": filename,
            "chunks": indexed_chunks
        }

    @classmethod
    def _cosine_similarity(cls, vec1: Dict[str, float], vec2: Dict[str, float]) -> float:
        dot = sum(val * vec2.get(key, 0.0) for key, val in vec1.items())
        norm1 = math.sqrt(sum(val * val for val in vec1.values()))
        norm2 = math.sqrt(sum(val * val for val in vec2.values()))
        if norm1 == 0.0 or norm2 == 0.0:
            return 0.0
        return dot / (norm1 * norm2)

    @classmethod
    def retrieve_relevant_chunks(
        cls,
        document_id: str,
        query: str,
        top_k: int = 4
    ) -> List[Dict[str, Any]]:
        """
        Retrieves top K relevant chunks using Cosine Similarity ranking.
        """
        doc = cls._index_store.get(document_id)
        if not doc or not doc.get("chunks"):
            return []

        chunks = doc["chunks"]
        vocabulary = list({w for c in chunks for w in c["vector"].keys()})
        query_vec = EmbeddingService.compute_query_vector(query, vocabulary)

        scored_chunks = []
        for c in chunks:
            sim = cls._cosine_similarity(query_vec, c["vector"])
            scored_chunks.append({
                "chunkId": c["chunkId"],
                "page": c["page"],
                "text": c["text"],
                "score": round(sim, 4)
            })

        # Sort descending by similarity score
        scored_chunks.sort(key=lambda x: x["score"], reverse=True)
        return scored_chunks[:top_k]

    @classmethod
    def get_document(cls, document_id: str) -> Dict[str, Any]:
        return cls._index_store.get(document_id, {})
