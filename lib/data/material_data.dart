import 'package:flutter/material.dart';
import '../models/material_model.dart';

/// MaterialData provides the official 5 units, topics, and syllabus learning resources
/// for GTU Subject: Artificial Intelligence with Prompt Engineering (DI05016011).
class MaterialData {
  static List<UnitModel> getUnits() {
    return [
      // UNIT 1
      UnitModel(
        id: 1,
        number: '01',
        title: 'Foundations of Artificial Intelligence and Generative AI',
        shortDescription:
            'Covering AI fundamentals, Narrow vs General AI, application domains, Generative AI principles, and basic NLP concepts.',
        hours: 6,
        topics: [
          const TopicModel(
            id: '1.1',
            title: 'Introduction to Artificial Intelligence',
            subtopics: [
              'Definition and history of Artificial Intelligence',
              'AI vs Machine Learning vs Deep Learning hierarchy',
            ],
            learningNotes:
                'Learning Notes: AI is the overarching discipline of building intelligent machines. Machine Learning uses statistical techniques to learn from data. Deep Learning employs multi-layered artificial neural networks.',
          ),
          const TopicModel(
            id: '1.2',
            title: 'Types of AI',
            subtopics: [
              'Narrow AI (Weak AI) designed for specific tasks',
              'General AI (AGI) hypothetical human-level intelligence',
            ],
            learningNotes:
                'Learning Notes: All current commercial AI models (ChatGPT, Gemini, computer vision systems) are classified as Narrow AI.',
          ),
          const TopicModel(
            id: '1.3',
            title: 'Applications of AI',
            subtopics: [
              'AI in daily life & personalized recommendations',
              'AI in education & adaptive learning',
              'AI in healthcare diagnostic imaging & drug discovery',
              'AI in cybersecurity anomaly detection',
            ],
            learningNotes:
                'Learning Notes: AI applications rely on pattern recognition to automate analytical decision-making across critical industries.',
          ),
          const TopicModel(
            id: '1.4',
            title: 'Introduction to Generative AI',
            subtopics: [
              'Concept of Generative AI vs Discriminative AI',
              'Types of Generative AI systems',
              'Text generation models',
              'Image generation models',
              'Code generation models',
            ],
            learningNotes:
                'Learning Notes: Discriminative AI predicts labels (P(Y|X)), whereas Generative AI models probability distribution (P(X,Y)) to synthesize brand new content.',
          ),
          const TopicModel(
            id: '1.5',
            title: 'Generative AI tools',
            subtopics: [
              'ChatGPT (OpenAI GPT architecture)',
              'Google Gemini (Multimodal foundation model)',
              'DALL·E (Diffusion-based image generator)',
            ],
            learningNotes:
                'Learning Notes: Modern tools use transformer-based architecture to process text, image, and code tokens seamlessly.',
          ),
          const TopicModel(
            id: '1.6',
            title: 'Basics of Natural Language Processing',
            subtopics: [
              'Concept of Natural Language Processing (NLP)',
              'Role of NLP in modern chatbots and LLMs',
            ],
            learningNotes:
                'Learning Notes: NLP enables computers to understand, interpret, and generate human languages by combining linguistics and computational algorithms.',
          ),
        ],
      ),

      // UNIT 2
      UnitModel(
        id: 2,
        number: '02',
        title: 'Basics of Large Language Models (LLMs)',
        shortDescription:
            'Exploring LLM training parameters, tokenization, vector embeddings, popular models, and real-world limitations.',
        hours: 9,
        topics: [
          const TopicModel(
            id: '2.1',
            title: 'Introduction to Large Language Models',
            subtopics: [
              'Concept of Large Language Models',
              'Training datasets, corpus scale, and model parameters',
            ],
            learningNotes:
                'Learning Notes: LLMs are deep learning models trained on billions of parameters over internet-scale textual datasets.',
          ),
          const TopicModel(
            id: '2.2',
            title: 'Working of LLMs',
            subtopics: [
              'Tokens & Tokenization process',
              'Embeddings (Conceptual representation in vector space)',
              'Autoregressive next-word prediction mechanism',
            ],
            learningNotes:
                'Learning Notes: Text is broken into tokens, mapped into dense mathematical vector spaces (embeddings), and evaluated probability-wise for next token prediction.',
          ),
          const TopicModel(
            id: '2.3',
            title: 'Popular LLM Models',
            subtopics: [
              'GPT Series (GPT-3.5, GPT-4, GPT-4o)',
              'Claude Series (Anthropic Claude 3.5 Sonnet)',
              'Llama Series (Meta Open-Weights Llama 3)',
              'Gemini Series (Google Gemini 1.5 Pro / Flash)',
            ],
            learningNotes:
                'Learning Notes: Frontier models vary by context window sizes, parameter counts, modal inputs, and licensing (proprietary vs open-weights).',
          ),
          const TopicModel(
            id: '2.4',
            title: 'Capabilities and Limitations',
            subtopics: [
              'Hallucination problem & false fact generation',
              'Context window boundaries & memory limits',
              'Bias & fairness in AI training corpora',
              'Computational cost & carbon footprint of AI models',
            ],
            learningNotes:
                'Learning Notes: Hallucinations occur when an LLM generates plausible-sounding but factually incorrect statements due to probabilistic token sampling.',
          ),
        ],
      ),

      // UNIT 3
      UnitModel(
        id: 3,
        number: '03',
        title: 'Prompt Engineering Fundamentals',
        shortDescription:
            'Mastering prompt components, lifecycle management, core prompting methods, and iterative design best practices.',
        hours: 10,
        topics: [
          const TopicModel(
            id: '3.1',
            title: 'Introduction to Prompt Engineering',
            subtopics: [
              'Definition and strategic importance',
              'Prompt engineering lifecycle (Design -> Test -> Refine)',
            ],
            learningNotes:
                'Learning Notes: Prompt engineering is the discipline of structuring textual input to reliably steer Generative AI models toward desired outputs.',
          ),
          const TopicModel(
            id: '3.2',
            title: 'Prompt Structure',
            subtopics: [
              'Instruction (Core task or directive)',
              'Context (Background information or constraints)',
              'Input data (Raw text or code to be transformed)',
              'Output format (JSON, Markdown, bullet points)',
            ],
            learningNotes:
                'Learning Notes: A well-formatted prompt clearly isolates instructions, context, input data, and explicit output formatting rules.',
          ),
          const TopicModel(
            id: '3.3',
            title: 'Prompting Methods',
            subtopics: [
              'Zero-shot prompting (Direct instruction without examples)',
              'Few-shot prompting (Providing input-output exemplars)',
              'Role-based prompting (Assigning persona/expertise)',
              'Instruction prompting (Explicit rule enforcement)',
            ],
            learningNotes:
                'Learning Notes: Few-shot prompting drastically improves task accuracy by demonstrating expected output formats directly within the prompt body.',
          ),
          const TopicModel(
            id: '3.4',
            title: 'Prompt Design Best Practices',
            subtopics: [
              'Writing clear, specific, and unambiguous prompts',
              'Systematic prompt testing and quality evaluation',
              'Iterative prompt refinement techniques',
            ],
            learningNotes:
                'Learning Notes: Avoid negative constraints ("don\'t do X") and favor positive explicit guidelines ("do Y in format Z").',
          ),
        ],
      ),

      // UNIT 4
      UnitModel(
        id: 4,
        number: '04',
        title: 'Prompt Engineering Techniques',
        shortDescription:
            'Advanced reasoning prompts, Chain-of-Thought, prompt chaining, task optimization, and basic RAG concepts.',
        hours: 10,
        topics: [
          const TopicModel(
            id: '4.1',
            title: 'Prompting Techniques',
            subtopics: [
              'Chain-of-Thought (CoT) prompting',
              'Prompt chaining (Sequential multi-stage prompts)',
              'Self-consistency prompting (Majority voting over paths)',
              'ReAct prompting (Reasoning + Acting loop)',
            ],
            learningNotes:
                'Learning Notes: Chain-of-Thought encourages the model to generate intermediate reasoning steps, significantly boosting performance on complex logic tasks.',
          ),
          const TopicModel(
            id: '4.2',
            title: 'Step-by-step reasoning prompts',
            subtopics: [
              'Decomposing multi-step mathematical/logical problems',
              'Using triggers like "Think step by step"',
            ],
            learningNotes:
                'Learning Notes: Forcing step-by-step evaluation prevents the LLM from jumping directly to incorrect mathematical or logical conclusions.',
          ),
          const TopicModel(
            id: '4.3',
            title: 'Prompt Engineering for Tasks',
            subtopics: [
              'Text summarization & key takeaway extraction',
              'Technical content & blog generation',
              'Code generation & refactoring',
              'Question answering & comprehension',
              'Multi-lingual language translation',
            ],
            learningNotes:
                'Learning Notes: Each task domain requires specific formatting constraints (e.g. JSON schema for code APIs, Markdown headers for blogs).',
          ),
          const TopicModel(
            id: '4.4',
            title: 'Retrieval Augmented Generation (RAG)',
            subtopics: [
              'Concept of RAG (Combining retrieval + LLM synthesis)',
              'Integrating external knowledge bases and PDF documents',
            ],
            learningNotes:
                'Learning Notes: RAG mitigates hallucinations by fetching relevant factual document chunks from a vector database and injecting them into the LLM prompt context.',
          ),
        ],
      ),

      // UNIT 5
      UnitModel(
        id: 5,
        number: '05',
        title: 'AI application development: Generative AI, Agentic AI',
        shortDescription:
            'Productivity AI, software dev workflows, AI debugging, API integration, AI application building, Agentic AI, and ethics.',
        hours: 10,
        topics: [
          const TopicModel(
            id: '5.1',
            title: 'Using AI Tools for Productivity',
            subtopics: [
              'Drafting professional academic emails',
              'Generating technical reports',
              'Creating presentation outlines & slides',
            ],
            learningNotes:
                'Learning Notes: AI tools accelerate administrative and communication workflows when provided structured bullet inputs.',
          ),
          const TopicModel(
            id: '5.2',
            title: 'AI in Software Development',
            subtopics: [
              'Automated code generation (Python/Dart)',
              'Code explanation & algorithm walkthroughs',
              'Generating docstrings & technical documentation',
            ],
            learningNotes:
                'Learning Notes: AI coders assist developers by converting natural language requirements into functional code snippets.',
          ),
          const TopicModel(
            id: '5.3',
            title: 'AI for Debugging Code',
            subtopics: [
              'Identifying syntax & logical errors in code',
              'Suggesting performance bug fixes using AI',
            ],
            learningNotes:
                'Learning Notes: Feeding stack traces and code snippets into LLMs provides immediate error diagnoses and refactored solutions.',
          ),
          const TopicModel(
            id: '5.4',
            title: 'Introduction to AI APIs',
            subtopics: [
              'Concept of REST APIs & SDK integration',
              'OpenAI API (GPT-4o endpoint integration)',
              'Gemini API (Google AI Studio Python SDK)',
            ],
            learningNotes:
                'Learning Notes: APIs allow custom applications (Flutter, Python backends) to send prompts and receive structured JSON AI responses programmatically.',
          ),
          const TopicModel(
            id: '5.5',
            title: 'Developing AI Applications',
            subtopics: [
              'Building an AI Chatbot',
              'Building an AI Blog Writer',
              'Building an AI Document Summarizer',
              'Building an AI Question Generator',
            ],
            learningNotes:
                'Learning Notes: Full AI applications combine custom UI inputs, backend API dispatchers, and formatted output displays.',
          ),
          const TopicModel(
            id: '5.6',
            title: 'Introduction to Agentic AI',
            subtopics: [
              'Concept of AI Agents vs simple Chatbots',
              'Autonomous task execution & tool calling',
              'Examples: AutoGPT framework',
              'Examples: CrewAI multi-agent orchestration',
            ],
            learningNotes:
                'Learning Notes: Agentic AI systems autonomously plan, execute tools (web search, code execution), evaluate outputs, and iterate until goals are achieved.',
          ),
          const TopicModel(
            id: '5.7',
            title: 'Responsible AI',
            subtopics: [
              'Ethical AI usage & plagiarism considerations',
              'Algorithmic bias & societal fairness',
              'Data privacy & user security in AI apps',
              'Risks and boundaries of AI systems',
            ],
            learningNotes:
                'Learning Notes: Responsible AI emphasizes transparency, security, non-discrimination, and human oversight in AI system deployments.',
          ),
        ],
      ),
    ];
  }

  static List<ResourceModel> getResources() {
    return const [
      // Books
      ResourceModel(
        id: 'b1',
        title: 'Artificial Intelligence: A Modern Approach',
        type: ResourceType.book,
        authorOrOrg: 'Stuart Russell, Peter Norvig',
        description:
            'The standard authoritative textbook on classical and modern Artificial Intelligence concepts.',
        url: 'http://lib.ysu.am/disciplines_bk/efdd4d1d4c2087fe1cbe03d9ced67f34.pdf',
        iconData: Icons.menu_book_rounded,
      ),
      ResourceModel(
        id: 'b2',
        title: 'Hands-On Large Language Models',
        type: ResourceType.book,
        authorOrOrg: 'Jay Alammar, Maarten Grootendorst',
        description:
            'Practical guide to understanding, fine-tuning, and deploying LLMs and transformer architectures.',
        url: 'https://sourceforge.net/projects/hand-on-llm.mirror/',
        iconData: Icons.auto_stories_rounded,
      ),
      ResourceModel(
        id: 'b3',
        title: 'Natural Language Processing with Python',
        type: ResourceType.book,
        authorOrOrg: 'Steven Bird, Ewan Klein, Edward Loper',
        description:
            'Foundational textbook on text processing, NLTK library usage, and computational linguistics.',
        url: 'https://www.researchgate.net/publication/220691633_Natural_Language_Processing_with_Python',
        iconData: Icons.book_rounded,
      ),
      ResourceModel(
        id: 'b4',
        title: 'Machine Learning with Python Cookbook',
        type: ResourceType.book,
        authorOrOrg: 'Chris Albon',
        description:
            'Practical code recipes for machine learning, feature extraction, and model evaluation in Python.',
        url: 'https://www.kufunda.net/publicdocs/Python%20Machine%20Learning%20Cookbook%20Practical%20Solutions%20from%20Preprocessing%20to%20Deep%20Learning%20(Chris%20Albon).pdf',
        iconData: Icons.import_contacts_rounded,
      ),
      ResourceModel(
        id: 'b5',
        title: 'Prompt Engineering Guide',
        type: ResourceType.book,
        authorOrOrg: 'DAIR.AI',
        description:
            'Comprehensive guide on modern prompt engineering techniques, papers, and practical patterns.',
        url: 'https://www.promptingguide.ai',
        iconData: Icons.menu_book_outlined,
      ),

      // Web Resources
      ResourceModel(
        id: 'w1',
        title: 'ChatGPT',
        type: ResourceType.onlineResource,
        authorOrOrg: 'OpenAI',
        description:
            'Leading conversational AI model platform for prompt experimentation and text generation.',
        url: 'https://chatgpt.com',
        iconData: Icons.language_rounded,
      ),
      ResourceModel(
        id: 'w2',
        title: 'Hugging Face',
        type: ResourceType.onlineResource,
        authorOrOrg: 'Hugging Face Inc.',
        description:
            'The central open-source hub for AI models, datasets, transformers, and machine learning spaces.',
        url: 'https://huggingface.co',
        iconData: Icons.hub_rounded,
      ),
      ResourceModel(
        id: 'w3',
        title: 'OpenAI Platform & Docs',
        type: ResourceType.onlineResource,
        authorOrOrg: 'OpenAI',
        description:
            'Official developer platform, API documentation, and prompt engineering best practices.',
        url: 'https://platform.openai.com',
        iconData: Icons.api_rounded,
      ),
      ResourceModel(
        id: 'w4',
        title: 'Prompt Engineering Guide Web',
        type: ResourceType.onlineResource,
        authorOrOrg: 'DAIR.AI Community',
        description:
            'Interactive web guide containing research summaries, zero-shot, few-shot, and CoT tutorials.',
        url: 'https://www.promptingguide.ai',
        iconData: Icons.school_rounded,
      ),
      ResourceModel(
        id: 'w5',
        title: 'Google AI Developers (Gemini API)',
        type: ResourceType.onlineResource,
        authorOrOrg: 'Google',
        description:
            'Official portal for Google Gemini models, Python SDK, AI Studio, and multimodal prompting.',
        url: 'https://ai.google.dev',
        iconData: Icons.terminal_rounded,
      ),
      ResourceModel(
        id: 'w6',
        title: 'Claude AI',
        type: ResourceType.onlineResource,
        authorOrOrg: 'Anthropic',
        description:
            'Frontier AI assistant known for long context window understanding and complex reasoning.',
        url: 'https://claude.ai',
        iconData: Icons.psychology_rounded,
      ),
    ];
  }
}
