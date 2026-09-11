import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/state_renderers.dart';
import '../../../models/assignment_model.dart';
import '../../../services/api_service.dart';
import 'widgets/info_chip.dart';

/// Screen 11 — create assignments/quizzes and review submission counts.
class AssignmentsScreen extends StatefulWidget {
  final ApiService api;
  const AssignmentsScreen({super.key, required this.api});

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  bool _loading = true;
  String? _error;
  List<Assignment> _assignments = [];

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  Future<void> _loadAssignments() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final assignments = await widget.api.fetchAssignments();
      if (!mounted) return;
      setState(() {
        _assignments = assignments;
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

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void _openCreateAssignmentDialog() {
    final titleController = TextEditingController();
    final marksController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.assignment_add, color: AppColors.primaryIndigo),
                  SizedBox(width: 8),
                  Text('New Assignment'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        hintText: 'e.g. Chapter 4 Quiz',
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setDialogState(() => selectedDate = picked);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Due Date',
                          suffixIcon: Icon(Icons.calendar_today, size: 18),
                        ),
                        child: Text(
                          selectedDate == null
                              ? 'Select a date'
                              : _formatDate(selectedDate!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: marksController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Max Marks',
                        hintText: 'e.g. 100',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryIndigo,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    final title = titleController.text.trim();
                    final marks = int.tryParse(marksController.text.trim());

                    if (title.isEmpty || selectedDate == null || marks == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please fill all fields correctly.')),
                      );
                      return;
                    }

                    Navigator.pop(ctx);
                    final dueDateStr = _formatDate(selectedDate!);

                    try {
                      await widget.api.createAssignment(
                        title: title,
                        dueDate: dueDateStr,
                        maxMarks: marks,
                      );
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Assignment created successfully')),
                      );
                      _loadAssignments();
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    }
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateAssignmentDialog,
        icon: const Icon(Icons.add),
        label: const Text('New Assignment'),
      ),
      body: _loading
          ? const LoadingState()
          : _error != null
              ? ErrorRetry(message: _error!, onRetry: _loadAssignments)
              : RefreshIndicator(
                  onRefresh: _loadAssignments,
                  child: _assignments.isEmpty
                      ? const EmptyState(
                          message: 'No assignments created yet.',
                          icon: Icons.assignment_outlined,
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
                          itemCount: _assignments.length,
                          itemBuilder: (context, index) {
                            final a = _assignments[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryIndigo
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(Icons.assignment,
                                          color: AppColors.primaryIndigo),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            a.title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Wrap(
                                            spacing: 14,
                                            runSpacing: 4,
                                            children: [
                                              InfoChip(
                                                icon: Icons.event,
                                                label: 'Due: ${a.dueDate}',
                                              ),
                                              InfoChip(
                                                icon: Icons.grade,
                                                label: 'Max: ${a.maxMarks}',
                                              ),
                                              InfoChip(
                                                icon: Icons.upload_file,
                                                label:
                                                    '${a.submissionsCount} submissions',
                                                color: AppColors.emeraldGreen,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
    );
  }
}
