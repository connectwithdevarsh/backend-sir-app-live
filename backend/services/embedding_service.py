import re
import math
from typing import List, Dict

class EmbeddingService:
    @staticmethod
    def _tokenize(text: str) -> List[str]:
        clean = re.sub(r'[^a-zA-Z0-9\s]', ' ', text.lower())
        return [w for w in clean.split() if len(w) > 1]

    @classmethod
    def compute_tfidf_vectors(cls, texts: List[str]) -> List[Dict[str, float]]:
        """
        Computes term-frequency inverse document frequency (TF-IDF) vector representations.
        """
        tokenized_docs = [cls._tokenize(t) for t in texts]
        num_docs = len(texts)

        # Compute document frequency
        df = {}
        for doc in tokenized_docs:
            unique_words = set(doc)
            for word in unique_words:
                df[word] = df.get(word, 0) + 1

        # Compute TF-IDF
        vectors = []
        for doc in tokenized_docs:
            tf = {}
            for word in doc:
                tf[word] = tf.get(word, 0) + 1

            vec = {}
            doc_len = len(doc) or 1
            for word, freq in tf.items():
                idf = math.log((num_docs + 1.0) / (df.get(word, 0) + 1.0)) + 1.0
                vec[word] = (freq / doc_len) * idf
            vectors.append(vec)

        return vectors

    @classmethod
    def compute_query_vector(cls, query: str, vocabulary: List[str]) -> Dict[str, float]:
        tokens = cls._tokenize(query)
        tf = {}
        for t in tokens:
            tf[t] = tf.get(t, 0) + 1

        doc_len = len(tokens) or 1
        return {w: count / doc_len for w, count in tf.items()}
