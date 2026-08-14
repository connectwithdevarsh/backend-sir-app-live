import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/chat_message.dart';
import '../theme/app_theme.dart';

/// ChatMessageBubble renders individual user or AI messages.
class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatMessageBubble({
    super.key,
    required this.message,
  });

  void _copyText(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppTheme.primaryCyan, size: 16),
            const SizedBox(width: 8),
            Text('Message copied to clipboard', style: GoogleFonts.inter(fontSize: 12)),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final min = time.minute.toString().padLeft(2, '0');
    return '$hour:$min';
  }

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppTheme.secondaryTeal.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.secondaryTeal.withValues(alpha: 0.4)),
              ),
              child: const Icon(Icons.smart_toy_rounded, color: AppTheme.secondaryTeal, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser ? AppTheme.primaryCyan.withValues(alpha: 0.15) : AppTheme.surfaceCard,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: Border.all(
                  color: isUser
                      ? AppTheme.primaryCyan.withValues(alpha: 0.4)
                      : Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isUser ? 'YOU' : 'AIPE AI ASSISTANT',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isUser ? AppTheme.primaryCyan : AppTheme.secondaryTeal,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(message.timestamp),
                        style: GoogleFonts.inter(fontSize: 9, color: AppTheme.textMuted),
                      ),
                      const Spacer(),
                      if (!isUser)
                        IconButton(
                          icon: const Icon(Icons.copy_rounded, size: 13, color: AppTheme.secondaryTeal),
                          onPressed: () => _copyText(context, message.content),
                          tooltip: 'Copy Response',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Code block or standard text rendering
                  if (message.content.contains('```'))
                    _buildCodeFormattedText(message.content)
                  else
                    SelectableText(
                      message.content.trim(),
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        color: Colors.white,
                        height: 1.45,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppTheme.primaryCyan.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primaryCyan.withValues(alpha: 0.4)),
              ),
              child: const Icon(Icons.person_rounded, color: AppTheme.primaryCyan, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCodeFormattedText(String text) {
    final parts = text.split('```');
    final List<Widget> children = [];

    for (int i = 0; i < parts.length; i++) {
      if (i % 2 == 0) {
        // Plain text
        if (parts[i].trim().isNotEmpty) {
          children.add(
            SelectableText(
              parts[i].trim(),
              style: GoogleFonts.inter(fontSize: 12.5, color: Colors.white, height: 1.45),
            ),
          );
        }
      } else {
        // Code snippet block
        String codeContent = parts[i].trim();
        if (codeContent.contains('\n')) {
          final firstLine = codeContent.split('\n').first.trim().toLowerCase();
          if (['python', 'dart', 'javascript', 'java', 'c', 'cpp', 'html', 'json', 'sql'].contains(firstLine)) {
            codeContent = codeContent.substring(firstLine.length).trim();
          }
        }

        children.add(
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF070B15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SelectableText(
                codeContent,
                style: GoogleFonts.firaCode(fontSize: 11.5, color: const Color(0xFFE2E8F0), height: 1.4),
              ),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}
