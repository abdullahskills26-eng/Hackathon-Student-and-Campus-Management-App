import 'package:cloud_firestore/cloud_firestore.dart';

/// An assignment or quiz. Firestore collection: `assignments`.
class AssignmentModel {
  final String assignmentId;
  final String batchId;
  final String title;
  final String instructions;
  final int maxMarks;
  final DateTime? dueDate;

  const AssignmentModel({
    required this.assignmentId,
    required this.batchId,
    required this.title,
    required this.instructions,
    required this.maxMarks,
    this.dueDate,
  });

  factory AssignmentModel.fromMap(Map<String, dynamic> map, String id) {
    return AssignmentModel(
      assignmentId: id,
      batchId: (map['batchId'] ?? '').toString(),
      title: (map['title'] ?? 'Untitled assignment').toString(),
      instructions: (map['instructions'] ?? '').toString(),
      maxMarks:
          int.tryParse('${map['maxMarks'] ?? map['maximumMarks'] ?? 0}') ?? 0,
      dueDate: _parseDate(map['dueDate']),
    );
  }

  factory AssignmentModel.fromDoc(
          DocumentSnapshot<Map<String, dynamic>> doc) =>
      AssignmentModel.fromMap(doc.data() ?? {}, doc.id);

  static DateTime? _parseDate(Object? raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    return DateTime.tryParse(raw?.toString() ?? '');
  }

  Map<String, dynamic> toMap() => {
        'batchId': batchId,
        'title': title,
        'instructions': instructions,
        'maxMarks': maxMarks,
        'maximumMarks': maxMarks,
        'dueDate': dueDate == null ? null : Timestamp.fromDate(dueDate!),
      };

  bool get isOverdue =>
      dueDate != null && DateTime.now().isAfter(dueDate!);

  String get formattedDueDate {
    final d = dueDate;
    if (d == null) return 'No due date';
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/${d.year}';
  }
}

/// Instructor-facing assignment. Shape matches `GET /api/v1/assignments`
/// on the FastAPI backend — unrelated to the Firestore model above.
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
