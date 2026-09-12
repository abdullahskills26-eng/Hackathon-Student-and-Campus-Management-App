import 'package:flutter/foundation.dart';

import '../../../models/assignment_model.dart';
import '../../../models/submission_model.dart';

class StudentAssignmentStore extends ValueNotifier<List<StudentAssignment>> {
  StudentAssignmentStore._() : super(_initialAssignments);

  static final StudentAssignmentStore instance = StudentAssignmentStore._();

  static const List<StudentAssignment> _initialAssignments = [
    StudentAssignment(
      id: 'FLUT-A1',
      title: 'Flutter UI Assignment',
      course: 'Flutter Development',
      dueDate: '15 September 2026',
      status: 'Pending',
      maxMarks: 100,
      description:
          'Build a responsive, multi-page student dashboard and course catalog using Material 3 widgets in Flutter.',
      instructions:
          'Complete the layout for wide and mobile screen sizes, implement responsive cards, and ensure full accessibility labels.',
    ),
    StudentAssignment(
      id: 'PYTH-A1',
      title: 'Python Data Processing Task',
      course: 'Python Programming',
      dueDate: '18 September 2026',
      status: 'Submitted',
      maxMarks: 100,
      submission: AssignmentSubmission(
        fileName: 'data_pipeline_v1.py',
        fileSizeBytes: 24576,
        url: 'https://github.com/student/python-data-processing',
        note:
            'Submitted initial draft with CSV processing scripts and unit tests.',
        submittedAt: '16 September 2026',
      ),
      description:
          'Clean and analyze student enrollment datasets using Python data structures and standard library modules.',
      instructions:
          'Write clean, modular Python code to read CSV records, aggregate course completion metrics, and output summary reports.',
    ),
    StudentAssignment(
      id: 'DBMS-A1',
      title: 'SQL Database Project',
      course: 'Database Management',
      dueDate: '20 September 2026',
      status: 'Graded',
      maxMarks: 100,
      grade: '85%',
      feedback: 'Good database design and implementation.',
      submission: AssignmentSubmission(
        fileName: 'campus_schema_final.sql',
        fileSizeBytes: 68100,
        url: 'https://db-diagrams.io/d/campus-mgmt-erd',
        note:
            'Included complete ERD diagram, DDL script, and sample query execution plans.',
        submittedAt: '14 September 2026',
      ),
      description:
          'Design a normalized relational database schema for campus management and student records.',
      instructions:
          'Submit the ER diagram, schema DDL scripts, and SQL queries demonstrating joins, aggregations, and indexing.',
    ),
  ];

  int get pendingCount => value.where((a) => a.isPending).length;
  int get completedCount => value.where((a) => a.isCompleted).length;
  int get submittedCount => value.where((a) => a.isSubmitted).length;
  int get gradedCount => value.where((a) => a.isGraded).length;
  int get totalCount => value.length;

  StudentAssignment? getById(String id) {
    try {
      return value.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  void submitAssignment({
    required String assignmentId,
    String? fileName,
    String? filePath,
    int? fileSizeBytes,
    String? url,
    String? note,
  }) {
    const now = '12 September 2026';
    final currentList = value;
    value = [
      for (final a in currentList)
        if (a.id == assignmentId)
          a.copyWith(
            status: 'Submitted',
            submission: AssignmentSubmission(
              fileName: fileName,
              filePath: filePath,
              fileSizeBytes: fileSizeBytes,
              url: url,
              note: note,
              submittedAt: now,
            ),
          )
        else
          a,
    ];
  }
}
