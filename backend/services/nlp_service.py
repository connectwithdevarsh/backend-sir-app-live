import re
import time

# Robust import for serverless deployment (Vercel)
try:
    import nltk
    try:
        nltk.download('vader_lexicon', quiet=True)
    except Exception:
        pass
    from nltk.sentiment.vader import SentimentIntensityAnalyzer
except Exception:
    SentimentIntensityAnalyzer = None

class NLPService:
    _vader_analyzer = None
    _classifier = None
    _supported_classes = [
        "Technology & AI",
        "Education & Academics",
        "Business & Finance",
        "Healthcare & Medicine",
        "Customer Support & Services"
    ]

    @classmethod
    def _extract_features(cls, text: str) -> dict:
        words = re.findall(r'\b[a-zA-Z]{2,}\b', text.lower())
        return {word: True for word in words}

    @classmethod
    def _get_vader(cls):
        if cls._vader_analyzer is None and SentimentIntensityAnalyzer is not None:
            try:
                cls._vader_analyzer = SentimentIntensityAnalyzer()
            except Exception:
                cls._vader_analyzer = None
        return cls._vader_analyzer

    @classmethod
    def analyze_text(cls, text: str, task: str = "sentiment") -> dict:
        start_time = time.time()
        vader = cls._get_vader()
        
        pos, neg, neu, compound = 0.0, 0.0, 1.0, 0.0
        label = "NEUTRAL"

        if vader is not None:
            try:
                scores = vader.polarity_scores(text)
                compound = scores['compound']
                pos = scores['pos']
                neg = scores['neg']
                neu = scores['neu']
                if compound >= 0.05:
                    label = "POSITIVE"
                elif compound <= -0.05:
                    label = "NEGATIVE"
                else:
                    label = "NEUTRAL"
            except Exception:
                vader = None

        if vader is None:
            # Fallback dictionary-based sentiment scoring for serverless environments
            pos_words = {'good', 'great', 'excellent', 'fantastic', 'amazing', 'happy', 'love', 'best', 'positive', 'wonderful', 'nice', 'awesome', 'smart'}
            neg_words = {'bad', 'terrible', 'horrible', 'poor', 'worst', 'hate', 'negative', 'wrong', 'fail', 'error', 'broken', 'slow', 'bugs'}
            words = set(re.findall(r'\b[a-zA-Z]{2,}\b', text.lower()))
            pos_count = len(words & pos_words)
            neg_count = len(words & neg_words)
            if pos_count > neg_count:
                label = "POSITIVE"
                compound = 0.65
                pos, neg, neu = 0.6, 0.1, 0.3
            elif neg_count > pos_count:
                label = "NEGATIVE"
                compound = -0.65
                pos, neg, neu = 0.1, 0.6, 0.3
            else:
                label = "NEUTRAL"
                compound = 0.0
                pos, neg, neu = 0.1, 0.1, 0.8

        if label == "POSITIVE":
            raw_conf = 0.55 + (compound * 0.40) + (pos * 0.05)
        elif label == "NEGATIVE":
            raw_conf = 0.55 + (abs(compound) * 0.40) + (neg * 0.05)
        else:
            raw_conf = 0.52 + (neu * 0.38)

        confidence = round(min(max(raw_conf, 0.52), 0.99), 2)
        elapsed_ms = max(int((time.time() - start_time) * 1000), 2)

        return {
            "success": True,
            "task": "sentiment",
            "label": label,
            "confidence": confidence,
            "executionTimeMs": elapsed_ms,
            "details": {
                "positive": round(pos, 3),
                "neutral": round(neu, 3),
                "negative": round(neg, 3),
                "compound": round(compound, 4)
            }
        }

    @classmethod
    def classify_text(cls, text: str) -> dict:
        start_time = time.time()
        
        # Rule-based zero-dependency text classification for serverless
        lower_text = text.lower()
        scores = {c: 0.1 for c in cls._supported_classes}
        
        keywords = {
            "Technology & AI": ["ai", "python", "code", "model", "algorithm", "data", "software", "hardware", "app", "flutter", "fastapi", "computer", "network", "system", "llm"],
            "Education & Academics": ["student", "college", "university", "study", "exam", "syllabus", "practical", "lecture", "degree", "homework", "engineering", "academic"],
            "Business & Finance": ["money", "profit", "market", "stock", "company", "bank", "revenue", "sales", "business", "price", "invest", "finance"],
            "Healthcare & Medicine": ["doctor", "health", "hospital", "patient", "medicine", "disease", "treatment", "clinic", "care", "medical"],
            "Customer Support & Services": ["support", "service", "help", "order", "refund", "ticket", "issue", "customer", "contact", "agent"]
        }

        for cat, kw_list in keywords.items():
            for kw in kw_list:
                if kw in lower_text:
                    scores[cat] += 0.25

        predicted_class = max(scores, key=scores.get)
        max_score = scores[predicted_class]
        total_score = sum(scores.values())
        confidence = round(min(max_score / total_score, 0.99), 2)
        elapsed_ms = max(int((time.time() - start_time) * 1000), 2)

        return {
            "success": True,
            "task": "classification",
            "predictedCategory": predicted_class,
            "confidence": confidence,
            "executionTimeMs": elapsed_ms,
            "allCategories": {cat: round(score / total_score, 2) for cat, score in scores.items()}
        }
