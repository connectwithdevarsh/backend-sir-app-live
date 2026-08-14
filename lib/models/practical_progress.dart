/// PracticalProgress model stores local completion state and completion timestamp.
class PracticalProgress {
  final int practicalId;
  final bool isCompleted;
  final DateTime? completedAt;

  const PracticalProgress({
    required this.practicalId,
    required this.isCompleted,
    this.completedAt,
  });

  PracticalProgress copyWith({
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return PracticalProgress(
      practicalId: practicalId,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
