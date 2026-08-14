import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/quiz_question.dart';
import '../theme/app_theme.dart';

/// QuizCard renders an interactive quiz question with selectable options, check answer button,
/// and AI explanation feedback.
class QuizCard extends StatefulWidget {
  final int index;
  final QuizQuestion question;
  final Function(int selectedIdx, bool isCorrect) onAnswerSubmitted;

  const QuizCard({
    super.key,
    required this.index,
    required this.question,
    required this.onAnswerSubmitted,
  });

  @override
  State<QuizCard> createState() => _QuizCardState();
}

class _QuizCardState extends State<QuizCard> {
  int? _selectedOption;
  bool _hasSubmitted = false;

  void _submitAnswer() {
    if (_selectedOption == null || _hasSubmitted) return;

    setState(() {
      _hasSubmitted = true;
    });

    final bool isCorrect = _selectedOption == widget.question.correctAnswer;
    widget.onAnswerSubmitted(_selectedOption!, isCorrect);
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.question;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
                  'QUESTION #${widget.index + 1}',
                  style: GoogleFonts.firaCode(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryCyan,
                  ),
                ),
              ),
              if (_hasSubmitted) ...[
                const Spacer(),
                Icon(
                  _selectedOption == q.correctAnswer
                      ? Icons.check_circle_rounded
                      : Icons.cancel_rounded,
                  color: _selectedOption == q.correctAnswer
                      ? AppTheme.secondaryTeal
                      : Colors.redAccent,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  _selectedOption == q.correctAnswer ? 'CORRECT' : 'INCORRECT',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _selectedOption == q.correctAnswer
                        ? AppTheme.secondaryTeal
                        : Colors.redAccent,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),

          Text(
            q.question,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),

          // Options List
          Column(
            children: q.options.asMap().entries.map((entry) {
              final optIdx = entry.key;
              final optText = entry.value;
              final bool isSelected = _selectedOption == optIdx;
              final bool isCorrectOpt = optIdx == q.correctAnswer;

              Color bg = const Color(0xFF0F172A);
              Color border = Colors.white.withValues(alpha: 0.1);

              if (_hasSubmitted) {
                if (isCorrectOpt) {
                  bg = AppTheme.secondaryTeal.withValues(alpha: 0.2);
                  border = AppTheme.secondaryTeal;
                } else if (isSelected && !isCorrectOpt) {
                  bg = Colors.redAccent.withValues(alpha: 0.2);
                  border = Colors.redAccent;
                }
              } else if (isSelected) {
                bg = AppTheme.primaryCyan.withValues(alpha: 0.2);
                border = AppTheme.primaryCyan;
              }

              final optionLabels = ['A', 'B', 'C', 'D'];
              final label = optIdx < optionLabels.length ? optionLabels[optIdx] : '${optIdx + 1}';

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: _hasSubmitted ? null : () => setState(() => _selectedOption = optIdx),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (_hasSubmitted
                                    ? (isCorrectOpt ? AppTheme.secondaryTeal : Colors.redAccent)
                                    : AppTheme.primaryCyan)
                                : Colors.white.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            label,
                            style: GoogleFonts.firaCode(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.black : Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            optText,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 8),

          if (!_hasSubmitted)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _selectedOption != null ? _submitAnswer : null,
                icon: const Icon(Icons.check_rounded, size: 16),
                label: Text(
                  '✓ CHECK ANSWER',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryCyan,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),

          if (_hasSubmitted && q.explanation.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF070B15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_rounded, color: Colors.amber, size: 14),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Explanation: ${q.explanation}',
                      style: GoogleFonts.inter(fontSize: 11, color: Colors.white70, height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// QuizResultCard displays the final quiz score card upon completion.
class QuizResultCard extends StatelessWidget {
  final int totalQuestions;
  final int correctCount;
  final VoidCallback onRetake;

  const QuizResultCard({
    super.key,
    required this.totalQuestions,
    required this.correctCount,
    required this.onRetake,
  });

  @override
  Widget build(BuildContext context) {
    final double percentage = totalQuestions > 0 ? (correctCount / totalQuestions) * 100 : 0.0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.secondaryTeal.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 40),
          const SizedBox(height: 8),
          Text(
            'QUIZ COMPLETED',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Score: $correctCount / $totalQuestions (${percentage.toStringAsFixed(1)}%)',
            style: GoogleFonts.firaCode(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.secondaryTeal,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatChip('Correct', '$correctCount', AppTheme.secondaryTeal),
              const SizedBox(width: 12),
              _buildStatChip('Incorrect', '${totalQuestions - correctCount}', Colors.redAccent),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetake,
            icon: const Icon(Icons.replay_rounded, size: 16),
            label: Text('RETAKE QUIZ', style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryCyan,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String val, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Text('$label: ', style: GoogleFonts.inter(fontSize: 11, color: Colors.white70)),
          Text(val, style: GoogleFonts.firaCode(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
