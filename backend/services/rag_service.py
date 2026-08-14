import time
from typing import Dict, Any, List
from services.retrieval_service import RetrievalService
from services.ai_service import AIService

class RAGService:
    @classmethod
    def answer_question(cls, document_id: str, question: str, top_k: int = 4) -> Dict[str, Any]:
        """
        Orchestrates full RAG workflow: Retrieval -> Context Assembly -> Grounded LLM Prompt -> Answer & Citations.
        """
        start_time = time.time()
        doc_info = RetrievalService.get_document(document_id)
        filename = doc_info.get("filename", "Uploaded Document")

        # 1. Retrieve top K relevant chunks
        chunks = RetrievalService.retrieve_relevant_chunks(document_id, question, top_k=top_k)

        if not chunks:
            return {
                "success": False,
                "question": question,
                "answer": "The document has not been uploaded or initialized.",
                "sources": [],
                "retrievedChunks": [],
                "prompt": "",
                "model": "none",
                "executionTimeMs": int((time.time() - start_time) * 1000),
                "error": "Document not found"
            }

        # 2. Build retrieved context block
        context_parts = []
        sources = []
        for idx, c in enumerate(chunks):
            context_parts.append(f"--- SOURCE CHUNK #{idx + 1} (Page {c['page']}) ---\n{c['text']}")
            sources.append({
                "documentId": document_id,
                "filename": filename,
                "page": c["page"],
                "chunkId": c["chunkId"],
                "score": c["score"]
            })

        context_str = "\n\n".join(context_parts)

        # 3. Construct RAG prompt with strict grounding instructions
        rag_prompt = f"""You are an AI assistant answering questions using ONLY the provided document context.

Instructions:
1. Answer the question using ONLY the supplied document context.
2. If the answer cannot be found in the context, state clearly: "The answer could not be found in the provided document."
3. Do not invent facts or use general knowledge outside the provided text.

DOCUMENT CONTEXT:
{context_str}

USER QUESTION:
{question}"""

        # 4. Call real LLM service
        ai_res = AIService.generate_ai_response(rag_prompt)
        elapsed_ms = int((time.time() - start_time) * 1000)

        output_answer = ai_res.get("output", "") or ai_res.get("response", "")

        return {
            "success": ai_res.get("success", True),
            "question": question,
            "answer": output_answer,
            "sources": sources,
            "retrievedChunks": [
                {
                    "chunkId": c["chunkId"],
                    "page": c["page"],
                    "text": c["text"],
                    "score": c["score"]
                } for c in chunks
            ],
            "prompt": rag_prompt,
            "model": ai_res.get("model", "unknown"),
            "executionTimeMs": elapsed_ms,
            "error": ai_res.get("error")
        }
