import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// ChatHeader renders the top bar for Practical 10 AI Chatbot.
class ChatHeader extends StatelessWidget {
  final String status; // "ready", "thinking", "error"
  final String provider;
  final String model;
  final VoidCallback onCheckConnection;
  final VoidCallback onNewChat;
  final VoidCallback onClearChat;

  const ChatHeader({
    super.key,
    required this.status,
    required this.provider,
    required this.model,
    required this.onCheckConnection,
    required this.onNewChat,
    required this.onClearChat,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor = AppTheme.secondaryTeal;
    String statusText = '● AI READY';

    if (status == 'thinking') {
      statusColor = AppTheme.primaryCyan;
      statusText = '● THINKING...';
    } else if (status == 'error') {
      statusColor = Colors.redAccent;
      statusText = '● CONNECTION ERROR';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.smart_toy_rounded,
                  color: statusColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AIPE AI CHAT',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          statusText,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                        if (provider.isNotEmpty && provider != 'none') ...[
                          Text(
                            ' • $provider ($model)',
                            style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textMuted),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, color: Colors.white70, size: 20),
                color: const Color(0xFF0F172A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                onSelected: (val) {
                  if (val == 'health') onCheckConnection();
                  if (val == 'new') onNewChat();
                  if (val == 'clear') _showClearDialog(context);
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: 'health',
                    child: Row(
                      children: [
                        const Icon(Icons.wifi_find_rounded, color: AppTheme.primaryCyan, size: 16),
                        const SizedBox(width: 8),
                        Text('Check Connection', style: GoogleFonts.inter(fontSize: 12, color: Colors.white)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'new',
                    child: Row(
                      children: [
                        const Icon(Icons.add_rounded, color: AppTheme.secondaryTeal, size: 16),
                        const SizedBox(width: 8),
                        Text('＋ New Chat', style: GoogleFonts.inter(fontSize: 12, color: Colors.white)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'clear',
                    child: Row(
                      children: [
                        const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 16),
                        const SizedBox(width: 8),
                        Text('🗑 Clear Chat', style: GoogleFonts.inter(fontSize: 12, color: Colors.redAccent)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showClearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Clear Conversation?',
          style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
        ),
        content: Text(
          'This will remove all current messages from memory. This action cannot be undone.',
          style: GoogleFonts.inter(color: Colors.white70, fontSize: 12.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CANCEL', style: GoogleFonts.spaceGrotesk(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onClearChat();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text('CLEAR CHAT', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
