/// StudyPlanItem represents a single day schedule entry in an AI-generated study plan.
class StudyPlanItem {
  final int day;
  final String subject;
  final String topic;
  final String duration;
  final String activity;

  StudyPlanItem({
    required this.day,
    required this.subject,
    required this.topic,
    required this.duration,
    required this.activity,
  });

  factory StudyPlanItem.fromJson(Map<String, dynamic> json) {
    return StudyPlanItem(
      day: json['day'] ?? 1,
      subject: json['subject'] ?? '',
      topic: json['topic'] ?? '',
      duration: json['duration'] ?? '1 hour',
      activity: json['activity'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'day': day,
        'subject': subject,
        'topic': topic,
        'duration': duration,
        'activity': activity,
      };
}
