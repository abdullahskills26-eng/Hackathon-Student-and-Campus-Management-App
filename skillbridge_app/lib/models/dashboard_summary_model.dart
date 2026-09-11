/// Aggregate counters for the instructor dashboard home.
///
/// Shape matches `GET /api/v1/dashboard/summary`.
class DashboardSummary {
  final int totalClasses;
  final int totalStudents;
  final int activeNotices;
  final int pendingAssignments;

  DashboardSummary({
    required this.totalClasses,
    required this.totalStudents,
    required this.activeNotices,
    required this.pendingAssignments,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalClasses: json['total_classes'] ?? 0,
      totalStudents: json['total_students'] ?? 0,
      activeNotices: json['active_notices'] ?? 0,
      pendingAssignments: json['pending_assignments'] ?? 0,
    );
  }
}
