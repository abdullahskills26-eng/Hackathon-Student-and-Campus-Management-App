import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants/api_config.dart';
import '../models/assignment_model.dart';
import '../models/dashboard_summary_model.dart';
import '../models/notice_model.dart';
import '../models/user_model.dart';

/// Error surfaced to the UI when a request fails or the backend is unreachable.
class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

/// Centralised REST client for the FastAPI backend.
class ApiService {
  final String baseUrl;
  ApiService({this.baseUrl = kApiBaseUrl});

  Uri _u(String path) => Uri.parse('$baseUrl$path');

  /// GET /dashboard/summary
  Future<DashboardSummary> fetchDashboardSummary() async {
    try {
      final res = await http.get(_u('/dashboard/summary'));
      if (res.statusCode == 200) {
        return DashboardSummary.fromJson(jsonDecode(res.body));
      }
      throw ApiException('Failed to load summary (${res.statusCode})');
    } catch (e) {
      throw ApiException('Error fetching dashboard summary: $e');
    }
  }

  /// GET /students
  Future<List<Student>> fetchStudents() async {
    try {
      final res = await http.get(_u('/students'));
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        return data.map((e) => Student.fromJson(e)).toList();
      }
      throw ApiException('Failed to load students (${res.statusCode})');
    } catch (e) {
      throw ApiException('Error fetching students: $e');
    }
  }

  /// POST /attendance/mark
  Future<void> markAttendance(int studentId, String status) async {
    try {
      final res = await http.post(
        _u('/attendance/mark'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'student_id': studentId, 'status': status}),
      );
      if (res.statusCode != 200) {
        throw ApiException('Failed to update attendance (${res.statusCode})');
      }
    } catch (e) {
      throw ApiException('Error marking attendance: $e');
    }
  }

  /// GET /assignments
  Future<List<Assignment>> fetchAssignments() async {
    try {
      final res = await http.get(_u('/assignments'));
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        return data.map((e) => Assignment.fromJson(e)).toList();
      }
      throw ApiException('Failed to load assignments (${res.statusCode})');
    } catch (e) {
      throw ApiException('Error fetching assignments: $e');
    }
  }

  /// POST /assignments/create
  Future<Assignment> createAssignment({
    required String title,
    required String dueDate,
    required int maxMarks,
  }) async {
    try {
      final res = await http.post(
        _u('/assignments/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': title,
          'due_date': dueDate,
          'max_marks': maxMarks,
        }),
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        return Assignment.fromJson(body['assignment']);
      }
      throw ApiException('Failed to create assignment (${res.statusCode})');
    } catch (e) {
      throw ApiException('Error creating assignment: $e');
    }
  }

  /// POST /notices/create
  Future<Notice> createNotice(String text) async {
    try {
      final res = await http.post(
        _u('/notices/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text}),
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        return Notice.fromJson(body['notice']);
      }
      throw ApiException('Failed to post notice (${res.statusCode})');
    } catch (e) {
      throw ApiException('Error posting notice: $e');
    }
  }

  /// GET /batch/progress
  Future<int> fetchAtRiskCount() async {
    try {
      final res = await http.get(_u('/batch/progress'));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        return body['at_risk_count'] ?? 0;
      }
      throw ApiException('Failed to load batch progress (${res.statusCode})');
    } catch (e) {
      throw ApiException('Error fetching batch progress: $e');
    }
  }
}
