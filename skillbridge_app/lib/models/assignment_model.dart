/// An assignment or quiz. Shape matches `GET /api/v1/assignments`.
class Assignment {
  final int id;
  final String title;
  final String dueDate;
  final int maxMarks;
  final int submissionsCount;

  Assignment({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.maxMarks,
    required this.submissionsCount,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'],
      title: json['title'] ?? 'Untitled',
      dueDate: json['due_date']?.toString() ?? '',
      maxMarks: json['max_marks'] ?? 0,
      submissionsCount: json['submissions_count'] ?? 0,
    );
  }
}
