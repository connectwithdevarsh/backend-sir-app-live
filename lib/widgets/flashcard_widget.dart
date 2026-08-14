import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/flashcard.dart';
import '../theme/app_theme.dart';

/// FlashcardWidget renders interactive flip cards with previous/flip/next controls.
class FlashcardWidget extends StatefulWidget {
  final List<Flashcard> flashcards;

  const FlashcardWidget({
    super.key,
    required this.flashcards,
  });

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget> {
  int _currentIndex = 0;
  bool _showFront = true;

  void _nextCard() {
    if (_currentIndex < widget.flashcards.length - 1) {
      setState(() {
        _currentIndex++;
        _showFront = true;
      });
    }
  }

  void _prevCard() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _showFront = true;
      });
    }
  }

  void _flipCard() {
    setState(() {
      _showFront = !_showFront;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.flashcards.isEmpty) return const SizedBox.shrink();

    final card = widget.flashcards[_currentIndex];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryCyan.withValues(alpha: 0.3)),
      ),
      child: Column(
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
                  'FLASHCARD ${_currentIndex + 1} OF ${widget.flashcards.length}',
                  style: GoogleFonts.firaCode(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryCyan,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                _showFront ? 'FRONT (QUESTION)' : 'BACK (ANSWER)',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: _showFront ? Colors.amber : AppTheme.secondaryTeal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Flip Card Container
          InkWell(
            onTap: _flipCard,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 160),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _showFront ? const Color(0xFF070B15) : const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _showFront
                      ? Colors.amber.withValues(alpha: 0.4)
                      : AppTheme.secondaryTeal.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _showFront ? card.front : card.back,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: _showFront ? 15 : 13.5,
                      fontWeight: _showFront ? FontWeight.bold : FontWeight.normal,
                      color: _showFront ? Colors.white : const Color(0xFFE2E8F0),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'TAP TO FLIP 🔄',
                    style: GoogleFonts.firaCode(fontSize: 10, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Navigation Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton.icon(
                onPressed: _currentIndex > 0 ? _prevCard : null,
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: Text('PREVIOUS', style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _flipCard,
                icon: const Icon(Icons.rotate_right_rounded, size: 16),
                label: Text('FLIP', style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryCyan,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _currentIndex < widget.flashcards.length - 1 ? _nextCard : null,
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                label: Text('NEXT', style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
