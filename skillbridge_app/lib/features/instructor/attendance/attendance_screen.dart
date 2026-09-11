import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/state_renderers.dart';
import '../../../models/user_model.dart';
import '../../../services/api_service.dart';

/// Screen 10 (cont.) — one-tap attendance marking for the batch roster.
class AttendanceScreen extends StatefulWidget {
  final ApiService api;
  const AttendanceScreen({super.key, required this.api});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  bool _loading = true;
  String? _error;
  List<Student> _students = [];
  final Set<int> _updatingIds = {}; // tracks per-row in-flight requests

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final students = await widget.api.fetchStudents();
      if (!mounted) return;
      setState(() {
        _students = students;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _toggleAttendance(Student student, String newStatus) async {
    setState(() => _updatingIds.add(student.id));
    try {
      await widget.api.markAttendance(student.id, newStatus);
      if (!mounted) return;
      // Optimistically update local state for instant feedback.
      setState(() {
        final idx = _students.indexWhere((s) => s.id == student.id);
        if (idx != -1) {
          _students[idx] = student.copyWithStatus(newStatus);
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _updatingIds.remove(student.id));
    }
  }

  Color _attendanceColor(double pct) {
    if (pct < 75) return AppColors.crimsonRed;
    if (pct < 90) return AppColors.amber;
    return AppColors.emeraldGreen;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingState();
    if (_error != null) {
      return ErrorRetry(message: _error!, onRetry: _loadStudents);
    }

    return RefreshIndicator(
      onRefresh: _loadStudents,
      child: _students.isEmpty
          ? const EmptyState(
              message: 'No students found.',
              icon: Icons.person_off_outlined,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _students.length,
              itemBuilder: (context, index) {
                final student = _students[index];
                final isUpdating = _updatingIds.contains(student.id);
                final chipColor = _attendanceColor(student.attendancePercentage);

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor:
                              AppColors.primaryIndigo.withValues(alpha: 0.12),
                          child: Text(
                            student.name.isNotEmpty
                                ? student.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: AppColors.primaryIndigo,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      student.name,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  if (student.isAtRisk) ...[
                                    const SizedBox(width: 6),
                                    const Icon(Icons.warning_amber_rounded,
                                        color: AppColors.crimsonRed, size: 16),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: chipColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${student.attendancePercentage.toStringAsFixed(1)}% attendance',
                                  style: TextStyle(
                                    color: chipColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isUpdating)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        else
                          Row(
                            children: [
                              IconButton(
                                tooltip: 'Mark Present',
                                icon: Icon(
                                  Icons.check_circle,
                                  color: student.status == 'Present'
                                      ? AppColors.emeraldGreen
                                      : Colors.grey.shade400,
                                ),
                                onPressed: () =>
                                    _toggleAttendance(student, 'Present'),
                              ),
                              IconButton(
                                tooltip: 'Mark Absent',
                                icon: Icon(
                                  Icons.cancel,
                                  color: student.status == 'Absent'
                                      ? AppColors.crimsonRed
                                      : Colors.grey.shade400,
                                ),
                                onPressed: () =>
                                    _toggleAttendance(student, 'Absent'),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
