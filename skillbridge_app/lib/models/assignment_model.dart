import 'submission_model.dart';

/// An assignment as the student sees it.
///
/// Reconstructed from usage in the student assignment screens — the class was
/// not supplied. Distinct from [Assignment] below, which is the instructor's
/// REST-backed shape.
class StudentAssignment {
  final String id;
  final String title;
  final String course;
  final String dueDate;
  final String status; // 'Pending' | 'Submitted' | 'Graded'
  final int maxMarks;
  final String description;
  final String instructions;
  final String? grade;
  final String? feedback;
  final AssignmentSubmission? submission;

  const StudentAssignment({
    required this.id,
    required this.title,
    required this.course,
    required this.dueDate,
    required this.status,
    required this.maxMarks,
    required this.description,
    required this.instructions,
    this.grade,
    this.feedback,
    this.submission,
  });

  bool get isPending => status == 'Pending';
  bool get isSubmitted => status == 'Submitted';
  bool get isGraded => status == 'Graded';
  bool get isCompleted => isSubmitted || isGraded;

  StudentAssignment copyWith({
    String? title,
    String? course,
    String? dueDate,
    String? status,
    int? maxMarks,
    String? description,
    String? instructions,
    String? grade,
    String? feedback,
    AssignmentSubmission? submission,
  }) =>
      StudentAssignment(
        id: id,
        title: title ?? this.title,
        course: course ?? this.course,
        dueDate: dueDate ?? this.dueDate,
        status: status ?? this.status,
        maxMarks: maxMarks ?? this.maxMarks,
        description: description ?? this.description,
        instructions: instructions ?? this.instructions,
        grade: grade ?? this.grade,
        feedback: feedback ?? this.feedback,
        submission: submission ?? this.submission,
      );
}

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
