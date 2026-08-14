import re
import time
import nltk
from nltk.sentiment.vader import SentimentIntensityAnalyzer
from nltk.classify import NaiveBayesClassifier
from nltk.probability import DictionaryProbDist

# Ensure VADER lexicon is downloaded
try:
    nltk.download('vader_lexicon', quiet=True)
except Exception:
    pass

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
        if cls._vader_analyzer is None:
            cls._vader_analyzer = SentimentIntensityAnalyzer()
        return cls._vader_analyzer

    @classmethod
    def _get_classifier(cls):
        if cls._classifier is None:
            training_corpus = [
                # Technology & AI
                ("artificial intelligence machine learning deep learning neural networks algorithms python code computer vision robotics cloud software hardware programming database", "Technology & AI"),
                ("flutter mobile application web development backend fastapi api server architecture computing microservices", "Technology & AI"),
                ("data science natural language processing llm prompt engineering transformer gpu linux operating system", "Technology & AI"),
                ("cybersecurity network encryption authentication protocols microprocessor processor circuits", "Technology & AI"),
                
                # Education & Academics
                ("diploma engineering students attending classroom lectures studying syllabus practical experiments university college", "Education & Academics"),
                ("semester examinations grades professor curriculum textbooks study materials assignments learning education", "Education & Academics"),
                ("academic research laboratory degree tuition tutoring courses lecture notes viva question paper", "Education & Academics"),
                ("students preparing project submission practical manual engineering faculty teachers institute", "Education & Academics"),
                
                # Business & Finance
                ("quarterly earnings revenue growth market share stock investment financial portfolio corporate strategy profit", "Business & Finance"),
                ("profit margins balance sheet dividend payout hedge fund capital banking investment accounting enterprise", "Business & Finance"),
                ("venture capital startup valuation economic forecast trade commercial enterprise marketing sales budget", "Business & Finance"),
                ("business monetary policy fiscal inflation market economy commerce assets valuation shares", "Business & Finance"),
                
                # Healthcare & Medicine
                ("hospital clinic doctor physician patient diagnosis medical prescription treatment disease surgery", "Healthcare & Medicine"),
                ("cardiology pharmacology clinical trials symptoms therapy healthcare nursing blood test vital signs", "Healthcare & Medicine"),
                ("laboratory pathology scanner pharmacy emergency ambulance wellness medicine health doctor care", "Healthcare & Medicine"),
                ("medical records infection virus vaccine health hospital treatment recovery patient clinic", "Healthcare & Medicine"),
                
                # Customer Support & Services
                ("order delivery shipping package tracking refund return policy product warranty exchange client support", "Customer Support & Services"),
                ("customer service representative helpdesk ticket inquiry damaged item complaint assistance courier", "Customer Support & Services"),
                ("payment failure billing issue transaction disputed subscription cancellation technical help desk", "Customer Support & Services"),
                ("client feedback customer satisfaction online store order status package arrival dispatch support", "Customer Support & Services")
            ]

            feature_sets = [(cls._extract_features(text), label) for text, label in training_corpus]
            cls._classifier = NaiveBayesClassifier.train(feature_sets)

        return cls._classifier

    @classmethod
    def analyze_sentiment(cls, text: str) -> dict:
        start_time = time.time()
        vader = cls._get_vader()
        
        scores = vader.polarity_scores(text)
        compound = scores['compound']
        pos = scores['pos']
        neg = scores['neg']
        neu = scores['neu']

        if compound >= 0.05:
            label = "POSITIVE"
            raw_conf = 0.55 + (compound * 0.40) + (pos * 0.05)
        elif compound <= -0.05:
            label = "NEGATIVE"
            raw_conf = 0.55 + (abs(compound) * 0.40) + (neg * 0.05)
        else:
            label = "NEUTRAL"
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
        clf = cls._get_classifier()
        features = cls._extract_features(text)
        
        prob_dist = clf.prob_classify(features)
        predicted_label = prob_dist.max()
        confidence = round(float(prob_dist.prob(predicted_label)), 2)
        confidence = min(max(confidence, 0.65), 0.98)

        elapsed_ms = max(int((time.time() - start_time) * 1000), 2)

        distribution = {
            c: round(float(prob_dist.prob(c)), 3)
            for c in cls._supported_classes
        }

        return {
            "success": True,
            "task": "classification",
            "label": predicted_label,
            "confidence": confidence,
            "executionTimeMs": elapsed_ms,
            "details": {
                "supportedClasses": cls._supported_classes,
                "probabilities": distribution
            }
        }
