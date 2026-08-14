import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/rag_document.dart';
import '../models/rag_response.dart';
import '../services/rag_api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/document_status_card.dart';
import '../widgets/document_upload_card.dart';
import '../widgets/rag_answer_card.dart';
import '../widgets/rag_processing_indicator.dart';
import '../widgets/rag_prompt_card.dart';
import '../widgets/retrieved_context_card.dart';
import '../widgets/source_citation_card.dart';

/// Practical11Screen implements GTU Practical 11:
/// "Build a basic RAG application for document-based question answering using an AI tool or API."
class Practical11Screen extends StatefulWidget {
  const Practical11Screen({super.key});

  @override
  State<Practical11Screen> createState() => _Practical11ScreenState();
}

class _Practical11ScreenState extends State<Practical11Screen> {
  // RAG Document & Processing State
  RagDocument? _activeDocument;
  bool _isProcessingDocument = false;
  int _processingStep = 1;

  // Question & Query State
  final TextEditingController _questionController = TextEditingController(
    text: 'What is Generative AI?',
  );
  bool _isQuerying = false;
  RagResponse? _ragResponse;
  String? _errorMessage;

  // Student Observation Controller
  final TextEditingController _observationController = TextEditingController(
    text:
        'Retrieving relevant document chunks ground the AI answer in actual text context. Out-of-context queries like "What is the capital of France?" correctly return "The answer could not be found in the provided document."',
  );

  @override
  void dispose() {
    _questionController.dispose();
    _observationController.dispose();
    super.dispose();
  }

  Future<void> _handleLoadSampleNotes() async {
    setState(() {
      _isProcessingDocument = true;
      _processingStep = 1;
      _errorMessage = null;
      _ragResponse = null;
    });

    const sampleContent = """AIPE LAB - ARTIFICIAL INTELLIGENCE & PROMPT ENGINEERING NOTES
Subject Code: DI05016011 | Diploma IT 5th Semester | GTU Syllabus

1. INTRODUCTION TO ARTIFICIAL INTELLIGENCE
Artificial Intelligence (AI) is a branch of computer science devoted to creating computing systems capable of performing cognitive tasks that traditionally require human intelligence. These tasks include learning from experience, logical reasoning, automated problem-solving, natural language processing, and visual perception.

2. MACHINE LEARNING & DEEP LEARNING
Machine Learning (ML) is a subset of Artificial Intelligence that enables algorithms to automatically learn patterns from data and improve decision accuracy without being explicitly programmed. Deep Learning (DL) utilizes multi-layer artificial neural networks inspired by biological brain structures to process unstructured inputs such as images, audio, and large text datasets.

3. GENERATIVE AI & LARGE LANGUAGE MODELS (LLMs)
Generative AI refers to algorithms designed to create new, original content including text, images, computer code, audio, and video. Large Language Models (LLMs) like GPT-4 and Llama-3 are trained on massive text corpora to predict probabilistic sequences of words, enabling conversational capabilities, code generation, summarization, and translation.

4. PROMPT ENGINEERING TECHNIQUES
Prompt Engineering is the practice of structuring, refining, and optimizing natural language inputs provided to LLM models to achieve precise, reliable outputs. Essential techniques include Zero-Shot, Few-Shot, Chain-of-Thought (CoT), and Role-Based Prompting.

5. RETRIEVAL-AUGMENTED GENERATION (RAG)
Retrieval-Augmented Generation (RAG) is an architectural framework that enhances LLM accuracy by retrieving relevant factual information from external document vector indices and injecting those retrieved text chunks into the model prompt context. RAG prevents model hallucination, ensures answer grounding, and allows question answering over private domain documents.""";

    final bytes = utf8.encode(sampleContent);

    for (int i = 1; i <= 4; i++) {
      await Future.delayed(const Duration(milliseconds: 350));
      if (mounted) setState(() => _processingStep = i + 1);
    }

    try {
      final doc = await RagApiService.uploadDocument('sample_ai_notes.txt', bytes);
      if (!mounted) return;
      setState(() {
        _activeDocument = doc;
        _isProcessingDocument = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessingDocument = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _handleUploadDocument() async {
    // Simulated upload trigger for web compatibility
    await _handleLoadSampleNotes();
  }

  Future<void> _handleAskQuestion() async {
    final qText = _questionController.text.trim();
    if (qText.isEmpty || _activeDocument == null || _isQuerying) return;

    setState(() {
      _isQuerying = true;
      _errorMessage = null;
      _ragResponse = null;
    });

    try {
      final res = await RagApiService.queryDocument(_activeDocument!.documentId, qText);

      if (!mounted) return;

      setState(() {
        _isQuerying = false;
        if (res.success) {
          _ragResponse = res;
          _errorMessage = null;
        } else {
          _errorMessage = res.error ?? 'Failed to execute RAG query.';
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isQuerying = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _removeDocument() {
    setState(() {
      _activeDocument = null;
      _ragResponse = null;
      _errorMessage = null;
    });
  }

  void _resetLaboratory() {
    setState(() {
      _activeDocument = null;
      _questionController.text = 'What is Generative AI?';
      _ragResponse = null;
      _errorMessage = null;
      _isProcessingDocument = false;
      _isQuerying = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Practical 11 state reset to default.', style: GoogleFonts.inter(fontSize: 12)),
        backgroundColor: AppTheme.surfaceCard,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool canAsk = _activeDocument != null && _activeDocument!.status == 'ready' && !_isQuerying;

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: AppTheme.bgDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'PRACTICAL 11',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryTeal.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppTheme.secondaryTeal.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    'RAG DOCUMENT Q&A',
                    style: GoogleFonts.firaCode(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryTeal,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              'Ask Questions From Your Own Documents',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Academic Header Banner
            _buildAcademicHeader(),

            const SizedBox(height: 16),

            // Collapsible Aim & Objectives
            _buildObjectivesCard(),

            const SizedBox(height: 12),

            // Collapsible Theory Card
            _buildTheoryCard(),

            const SizedBox(height: 12),

            // Collapsible Procedure Card
            _buildProcedureCard(),

            const SizedBox(height: 12),

            // Collapsible RAG Architecture View
            _buildArchitectureCard(),

            const SizedBox(height: 12),

            // Collapsible RAG Limitations Card
            _buildLimitationsCard(),

            const SizedBox(height: 20),

            // Section 1: Document Upload & Status
            Text(
              '1. DOCUMENT UPLOAD & INDEXING',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryCyan,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),

            if (_activeDocument == null && !_isProcessingDocument)
              DocumentUploadCard(
                isProcessing: _isProcessingDocument,
                onUploadPressed: _handleUploadDocument,
                onLoadSamplePressed: _handleLoadSampleNotes,
              ),

            if (_isProcessingDocument)
              RagProcessingIndicator(currentStep: _processingStep),

            if (_activeDocument != null && !_isProcessingDocument)
              DocumentStatusCard(
                document: _activeDocument!,
                onRemove: _removeDocument,
              ),

            const SizedBox(height: 20),

            // Section 2: Question Input Field
            Text(
              '2. ASK A DOCUMENT QUESTION',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryCyan,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _questionController,
                    enabled: canAsk,
                    maxLines: 2,
                    style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
                    decoration: InputDecoration(
                      hintText: _activeDocument == null
                          ? 'Upload and process a document first...'
                          : 'Ask something about your document...',
                      hintStyle: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted),
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      contentPadding: const EdgeInsets.all(12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: canAsk ? _handleAskQuestion : null,
                      icon: _isQuerying
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                              ),
                            )
                          : const Icon(Icons.search_rounded, size: 20),
                      label: Text(
                        _isQuerying ? 'RETRIEVING & GENERATING...' : '🔍 ASK DOCUMENT',
                        style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 0.8,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryCyan,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Error Banner
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              _buildErrorCard(_errorMessage!),
            ],

            // Section 3: RAG Output Displays
            if (_ragResponse != null) ...[
              const SizedBox(height: 20),

              // Grounded AI Answer Card
              RagAnswerCard(response: _ragResponse!),

              const SizedBox(height: 14),

              // Source Citations Card
              if (_ragResponse!.sources.isNotEmpty)
                SourceCitationCard(sources: _ragResponse!.sources),

              const SizedBox(height: 14),

              // Retrieved Context Chunks Card
              if (_ragResponse!.retrievedChunks.isNotEmpty)
                RetrievedContextCard(chunks: _ragResponse!.retrievedChunks),

              const SizedBox(height: 14),

              // RAG Grounding Prompt Viewer Card
              RagPromptCard(prompt: _ragResponse!.prompt),

              const SizedBox(height: 16),

              // Student Observation Notes
              _buildObservationCard(),

              const SizedBox(height: 18),

              // GTU Result Certificate Card
              _buildResultCard(),
            ],

            const SizedBox(height: 20),

            // Reset Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _resetLaboratory,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: Text(
                  'RESET LABORATORY',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAcademicHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryTeal.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'UNIT 5: AI TOOLS FOR SOFTWARE DEVELOPMENT',
                  style: GoogleFonts.firaCode(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryTeal,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'RAG Pipeline',
                style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'OFFICIAL GTU OUTCOME',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryCyan,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '"Build a basic RAG application for document-based question answering using an AI tool or API."',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: Colors.white,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObjectivesCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          'Aim & Practical Objectives',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 13.5,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          '9 laboratory goals and vector search outcomes',
          style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Aim:', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: AppTheme.primaryCyan, fontSize: 12.5)),
                Text('To build a basic Retrieval-Augmented Generation application for document-based question answering.', style: GoogleFonts.inter(fontSize: 12, color: Colors.white70, height: 1.4)),
                const SizedBox(height: 10),
                Text('Objectives:', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: AppTheme.secondaryTeal, fontSize: 12.5)),
                const SizedBox(height: 4),
                _buildBullet('1', 'Understand the basic concept of RAG.'),
                _buildBullet('2', 'Upload and process a document.'),
                _buildBullet('3', 'Extract text from a document.'),
                _buildBullet('4', 'Divide text into chunks.'),
                _buildBullet('5', 'Retrieve relevant information.'),
                _buildBullet('6', 'Provide retrieved context to an LLM.'),
                _buildBullet('7', 'Generate document-based answers.'),
                _buildBullet('8', 'Display source information.'),
                _buildBullet('9', 'Understand why retrieval improves document QA.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBullet(String num, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$num. ', style: GoogleFonts.firaCode(fontSize: 11.5, color: AppTheme.primaryCyan)),
          Expanded(child: Text(text, style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white70))),
        ],
      ),
    );
  }

  Widget _buildTheoryCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          'Theory: Retrieval-Augmented Generation',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 13.5,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          'Retrieval + Generation, Chunking, & Vector Search',
          style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('What is RAG?', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: AppTheme.primaryCyan, fontSize: 12)),
                Text('Retrieval-Augmented Generation combines Retrieval + Generation. Instead of relying solely on parametric LLM knowledge, it retrieves relevant text chunks from private documents and injects them as prompt context.', style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white70)),
                const SizedBox(height: 8),
                Text('Why RAG?', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: AppTheme.secondaryTeal, fontSize: 12)),
                Text('RAG prevents model hallucinations, ensures factual grounding, and enables question answering over private or domain-specific documents.', style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcedureCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          'Procedure & Laboratory Steps',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 13.5,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          '13-step RAG experiment workflow',
          style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBullet('1', 'Start the Python FastAPI backend.'),
                _buildBullet('2', 'Configure embedding and LLM API providers.'),
                _buildBullet('3', 'Open Practical 11 RAG Document Q&A.'),
                _buildBullet('4', 'Upload a PDF/TXT or load sample AI notes.'),
                _buildBullet('5', 'Observe text extraction and document chunking.'),
                _buildBullet('6', 'Observe vector embedding generation and indexing.'),
                _buildBullet('7', 'Enter a question related to the document.'),
                _buildBullet('8', 'Click 🔍 ASK DOCUMENT.'),
                _buildBullet('9', 'Inspect top-K retrieved text chunks and relevance scores.'),
                _buildBullet('10', 'Inspect the exact RAG grounding prompt sent to the LLM.'),
                _buildBullet('11', 'Observe the grounded AI answer.'),
                _buildBullet('12', 'Test an out-of-context question (e.g. "What is the capital of France?").'),
                _buildBullet('13', 'Observe grounded response stating information is not in the document.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArchitectureCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryCyan.withValues(alpha: 0.3)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Row(
          children: [
            const Icon(Icons.account_tree_rounded, color: AppTheme.primaryCyan, size: 18),
            const SizedBox(width: 8),
            Text(
              'RAG SYSTEM ARCHITECTURE FLOW',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryCyan,
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF070B15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: SelectableText(
                '''DOCUMENT (PDF / TXT)
      │
      ▼
TEXT EXTRACTION
      │
      ▼
TEXT CHUNKING (Size: 800, Overlap: 100)
      │
      ▼
VECTOR EMBEDDINGS (TF-IDF / Density)
      │
      ▼
VECTOR STORE / COSINE INDEX
      │
      ├── USER QUESTION
      │        │
      │        ▼
      │   QUESTION EMBEDDING
      │        │
      └───────>├─ COSINE RANKING
               │
               ▼
         TOP-K CHUNKS (K=4)
               │
               ▼
         RAG PROMPT CONTEXT
               │
               ▼
         REAL LLM (Groq/Gemini)
               │
               ▼
         GROUNDED ANSWER + CITATIONS''',
                textAlign: TextAlign.center,
                style: GoogleFonts.firaCode(fontSize: 10.5, color: AppTheme.secondaryTeal, height: 1.45),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLimitationsCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 18),
            const SizedBox(width: 8),
            Text(
              'RAG LIMITATIONS & BEST PRACTICES',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLimitationItem('Retrieval quality directly impacts answer accuracy; poor chunking reduces context precision.'),
                _buildLimitationItem('Embeddings capture semantic similarity but may miss exact numerical or tabular constraints.'),
                _buildLimitationItem('If a question falls outside document context, strict grounding must instruct the LLM to decline.'),
                _buildLimitationItem('Large documents require efficient vector indexing to maintain sub-second retrieval speeds.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLimitationItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
          Expanded(child: Text(text, style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white70))),
        ],
      ),
    );
  }

  Widget _buildObservationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'STUDENT OBSERVATION NOTES',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryCyan,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _observationController,
            maxLines: 3,
            style: GoogleFonts.inter(fontSize: 12, color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Describe how retrieval of document information affected the AI-generated answer...',
              hintStyle: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted),
              filled: true,
              fillColor: const Color(0xFF0F172A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.secondaryTeal.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_rounded, color: AppTheme.secondaryTeal, size: 20),
              const SizedBox(width: 8),
              Text(
                'PRACTICAL 11 EXPERIMENTAL RESULT',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.secondaryTeal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'A basic RAG application was developed for document-based question answering using document retrieval and a Generative AI model.',
            style: GoogleFonts.inter(fontSize: 12, color: Colors.white70, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String errorMsg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RAG Execution Error',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  errorMsg,
                  style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
