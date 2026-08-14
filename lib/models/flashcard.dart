/// Flashcard represents an educational flip card with front question/concept and back answer/explanation.
class Flashcard {
  final String front;
  final String back;

  Flashcard({
    required this.front,
    required this.back,
  });

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      front: json['front'] ?? '',
      back: json['back'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'front': front,
        'back': back,
      };
}
