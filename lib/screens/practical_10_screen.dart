import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/chat_message.dart';
import '../services/chat_api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/chat_header.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/error_message_card.dart';
import '../widgets/typing_indicator.dart';

/// Practical10Screen implements GTU Practical 10:
/// "Develop a simple AI chatbot using API integration (OpenAI/Gemini) with Python."
class Practical10Screen extends StatefulWidget {
  const Practical10Screen({super.key});

  @override
  State<Practical10Screen> createState() => _Practical10ScreenState();
}

class _Practical10ScreenState extends State<Practical10Screen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Chat State
  bool _isLoading = false;
  String _status = 'ready'; // "ready", "thinking", "error"
  String _activeProvider = 'groq/gemini';
  String _activeModel = 'llama-3.3-70b-versatile';
  int _lastExecutionTimeMs = 0;
  String? _errorMessage;

  // Student Observation Controller
  final TextEditingController _observationController = TextEditingController(
    text:
        'The Flutter chatbot sends user messages along with conversation history to the Python FastAPI backend. The backend forwards context securely to the AI API (Groq/Gemini) and returns the generated response to the chat UI.',
  );

  @override
  void initState() {
    super.initState();
    _checkHealth();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _observationController.dispose();
    super.dispose();
  }

  Future<void> _checkHealth() async {
    final health = await ChatApiService.checkHealth();
    if (!mounted) return;

    setState(() {
      if (health['status'] == 'ok') {
        _status = 'ready';
        _activeProvider = health['provider'] ?? 'groq/gemini';
        _errorMessage = null;
      } else {
        _status = 'ready'; // fallback online mode
        _activeProvider = 'groq/gemini';
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _isLoading) return;

    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: 'user',
      content: text,
    );

    setState(() {
      _messages.add(userMsg);
      _inputController.clear();
      _isLoading = true;
      _status = 'thinking';
      _errorMessage = null;
    });

    _scrollToBottom();

    try {
      final response = await ChatApiService.sendMessage(_messages);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        if (response.success) {
          _messages.add(response.message);
          _status = 'ready';
          _activeModel = response.model;
          _activeProvider = response.provider;
          _lastExecutionTimeMs = response.executionTimeMs;
          _errorMessage = null;
        } else {
          _status = 'error';
          _errorMessage = response.error ?? 'Failed to receive AI response.';
        }
      });

      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _status = 'error';
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _handleNewChat() {
    setState(() {
      _messages.clear();
      _status = 'ready';
      _errorMessage = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('New conversation started.', style: GoogleFonts.inter(fontSize: 12)),
        backgroundColor: AppTheme.surfaceCard,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleClearChat() {
    setState(() {
      _messages.clear();
      _status = 'ready';
      _errorMessage = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Conversation cleared successfully.', style: GoogleFonts.inter(fontSize: 12)),
        backgroundColor: AppTheme.surfaceCard,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _resetLaboratory() {
    setState(() {
      _messages.clear();
      _status = 'ready';
      _errorMessage = null;
      _lastExecutionTimeMs = 0;
    });

    _checkHealth();
  }

  @override
  Widget build(BuildContext context) {
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
                  'PRACTICAL 10',
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
                    color: AppTheme.primaryCyan.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppTheme.primaryCyan.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    'AI CHATBOT',
                    style: GoogleFonts.firaCode(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryCyan,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              'Generative AI Chatbot using API Integration',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Academic Banner
                  _buildAcademicHeader(),

                  const SizedBox(height: 14),

                  // Collapsible Objectives Card
                  _buildObjectivesCard(),

                  const SizedBox(height: 10),

                  // Collapsible Theory Card
                  _buildTheoryCard(),

                  const SizedBox(height: 10),

                  // Collapsible Procedure Card
                  _buildProcedureCard(),

                  const SizedBox(height: 10),

                  // Collapsible System Architecture View Card
                  _buildArchitectureCard(),

                  const SizedBox(height: 16),

                  // Chat Header Controls & Status
                  ChatHeader(
                    status: _status,
                    provider: _activeProvider,
                    model: _activeModel,
                    onCheckConnection: _checkHealth,
                    onNewChat: _handleNewChat,
                    onClearChat: _handleClearChat,
                  ),

                  const SizedBox(height: 14),

                  // Chat Info Expandable Box
                  _buildChatInfoCard(),

                  const SizedBox(height: 16),

                  // Welcome UI text banner if messages empty
                  if (_messages.isEmpty) _buildWelcomeBanner(),

                  // Conversation Messages List
                  ..._messages.map((msg) => ChatMessageBubble(message: msg)),

                  // Typing indicator when loading
                  if (_isLoading) const TypingIndicator(),

                  // Error Message Banner
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 10),
                    ErrorMessageCard(
                      errorMessage: _errorMessage!,
                      onRetry: _checkHealth,
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Student Observation Notes
                  _buildObservationCard(),

                  const SizedBox(height: 14),

                  // GTU Experimental Result Card
                  if (_messages.isNotEmpty && !_isLoading) _buildResultCard(),

                  const SizedBox(height: 16),

                  // Reset Laboratory Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _resetLaboratory,
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
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Sticky Bottom Chat Input Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: ChatInputBar(
              controller: _inputController,
              isLoading: _isLoading,
              onSend: _handleSendMessage,
            ),
          ),
        ],
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
                  color: AppTheme.primaryCyan.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'UNIT 5: AI TOOLS FOR SOFTWARE DEVELOPMENT',
                  style: GoogleFonts.firaCode(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryCyan,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Approx: 4 Hours',
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
            '"Develop a simple AI chatbot using API integration (OpenAI/Gemini) with Python."',
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
          '8 laboratory goals & client-server outcomes',
          style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Aim:', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: AppTheme.primaryCyan, fontSize: 12.5)),
                Text('To develop a simple AI chatbot using Python and Generative AI API integration.', style: GoogleFonts.inter(fontSize: 12, color: Colors.white70, height: 1.4)),
                const SizedBox(height: 10),
                Text('Objectives:', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: AppTheme.secondaryTeal, fontSize: 12.5)),
                const SizedBox(height: 4),
                _buildBullet('1. Understand AI API integration.'),
                _buildBullet('2. Understand client-server communication.'),
                _buildBullet('3. Send user input to a Python backend.'),
                _buildBullet('4. Connect Python with an AI API.'),
                _buildBullet('5. Receive AI-generated responses.'),
                _buildBullet('6. Display responses in a chatbot interface.'),
                _buildBullet('7. Handle API and network errors.'),
                _buildBullet('8. Understand basic multi-turn chatbot conversation flow.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(text, style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white70)),
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
          'Theory: Chatbot Architecture & API Integration',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 13.5,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          'Client-Server flow, API keys, & multi-turn history',
          style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('What is an AI Chatbot?', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: AppTheme.primaryCyan, fontSize: 12)),
                Text('An application that accepts natural language input from a user and generates contextual responses using a Generative AI model.', style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white70)),
                const SizedBox(height: 8),
                Text('Client-Server Architecture:', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: AppTheme.secondaryTeal, fontSize: 12)),
                Text('Flutter App → HTTP POST → Python FastAPI Backend → OpenAI/Gemini API → Response → Flutter Chat UI.', style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white70)),
                const SizedBox(height: 8),
                Text('Security Principle:', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 12)),
                Text('API keys remain securely stored in backend .env files and are never exposed to the client app.', style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white70)),
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
          '11-step execution workflow',
          style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBullet('1. Start the Python FastAPI backend server.'),
                _buildBullet('2. Configure OpenAI or Gemini API credentials in backend/.env.'),
                _buildBullet('3. Run the Flutter application.'),
                _buildBullet('4. Navigate to Practical 10 AI Chatbot.'),
                _buildBullet('5. Check connection status (● AI READY).'),
                _buildBullet('6. Enter an educational prompt in the input field.'),
                _buildBullet('7. Press Send (➤).'),
                _buildBullet('8. Observe the real HTTP request-response flow.'),
                _buildBullet('9. Ask a follow-up question to test multi-turn conversation context.'),
                _buildBullet('10. Inspect CHAT INFO for model name and latency.'),
                _buildBullet('11. Test CLEAR CHAT to reset conversation history.'),
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
              'SYSTEM ARCHITECTURE FLOW',
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
                '''Flutter Chat UI
      │
      │ HTTP POST /api/chat
      ▼
Python FastAPI Backend
      │
      │ API Request (Groq / Gemini)
      ▼
Generative AI API
      │
      │ Model Response
      ▼
Python Backend
      │
      │ JSON Response
      ▼
Flutter Chat UI''',
                textAlign: TextAlign.center,
                style: GoogleFonts.firaCode(fontSize: 11, color: AppTheme.secondaryTeal, height: 1.45),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatInfoCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem('PROVIDER', _activeProvider.toUpperCase()),
          Container(width: 1, height: 24, color: Colors.white12),
          _buildInfoItem('MODEL', _activeModel),
          Container(width: 1, height: 24, color: Colors.white12),
          _buildInfoItem('MESSAGES', '${_messages.length}'),
          Container(width: 1, height: 24, color: Colors.white12),
          _buildInfoItem('LATENCY', '${_lastExecutionTimeMs}ms'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.spaceGrotesk(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
        const SizedBox(height: 2),
        Text(value, style: GoogleFonts.firaCode(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.secondaryTeal.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.forum_rounded, color: AppTheme.secondaryTeal, size: 36),
          const SizedBox(height: 10),
          Text(
            'Ask a question to start the conversation.',
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try asking:\n"What is Artificial Intelligence?" or "Explain Python functions with a simple example."',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted, height: 1.4),
          ),
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
              hintText: 'Describe how the chatbot communicates with the AI API...',
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
                'PRACTICAL 10 EXPERIMENTAL RESULT',
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
            'An AI chatbot was successfully developed using Python API integration with a Generative AI model.',
            style: GoogleFonts.inter(fontSize: 12, color: Colors.white70, height: 1.4),
          ),
        ],
      ),
    );
  }
}
