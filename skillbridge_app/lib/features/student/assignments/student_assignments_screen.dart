import 'package:flutter/material.dart';

import '../../../models/assignment_model.dart';
import 'student_assignment_details_screen.dart';
import 'student_assignment_store.dart';

class StudentAssignmentsScreen extends StatefulWidget {
  const StudentAssignmentsScreen({super.key});

  @override
  State<StudentAssignmentsScreen> createState() =>
      _StudentAssignmentsScreenState();
}

class _StudentAssignmentsScreenState extends State<StudentAssignmentsScreen> {
  String _selectedFilter = 'All';

  Future<void> _openAssignmentDetails(
      BuildContext context, StudentAssignment assignment) async {
    await Navigator.of(context).push<StudentAssignment>(
      MaterialPageRoute(
        builder: (_) => StudentAssignmentDetailsScreen(assignment: assignment),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ValueListenableBuilder<List<StudentAssignment>>(
      valueListenable: StudentAssignmentStore.instance,
      builder: (context, assignments, _) {
        final totalCount = assignments.length;
        final pendingCount = assignments.where((a) => a.isPending).length;
        final submittedCount = assignments.where((a) => a.isSubmitted).length;
        final gradedCount = assignments.where((a) => a.isGraded).length;

        final filteredAssignments = _selectedFilter == 'All'
            ? assignments
            : assignments.where((a) => a.status == _selectedFilter).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Assignments'),
          ),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final contentWidth =
                    constraints.maxWidth >= 800 ? 1120.0 : 680.0;

                return Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: contentWidth),
                    child: ListView(
                      padding: const EdgeInsets.all(24),
                      children: [
                        Text(
                          'Assignments',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Track, submit, and review your course assignments.',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                        ),
                        const SizedBox(height: 24),
                        _AssignmentSummary(
                          total: totalCount,
                          pending: pendingCount,
                          submitted: submittedCount,
                          graded: gradedCount,
                          activeFilter: _selectedFilter,
                          onSelectFilter: (filter) {
                            setState(() => _selectedFilter = filter);
                          },
                        ),
                        const SizedBox(height: 28),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedFilter == 'All'
                                  ? 'All assignments'
                                  : '$_selectedFilter assignments',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              '${filteredAssignments.length} of $totalCount',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        if (filteredAssignments.isEmpty)
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.assignment_turned_in_outlined,
                                      size: 48,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'No $_selectedFilter assignments found.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else
                          ...filteredAssignments.map(
                            (assignment) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _AssignmentCardItem(
                                assignment: assignment,
                                onViewDetails: () =>
                                    _openAssignmentDetails(context, assignment),
                              ),
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
      },
    );
  }
}

class _AssignmentSummary extends StatelessWidget {
  const _AssignmentSummary({
    required this.total,
    required this.pending,
    required this.submitted,
    required this.graded,
    required this.activeFilter,
    required this.onSelectFilter,
  });

  final int total;
  final int pending;
  final int submitted;
  final int graded;
  final String activeFilter;
  final ValueChanged<String> onSelectFilter;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth >= 600
            ? (constraints.maxWidth - (3 * 12)) / 4
            : (constraints.maxWidth - 12) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _SummaryItemCard(
              label: 'Total',
              value: '$total',
              icon: Icons.assignment_outlined,
              isSelected: activeFilter == 'All',
              width: cardWidth,
              onTap: () => onSelectFilter('All'),
            ),
            _SummaryItemCard(
              label: 'Pending',
              value: '$pending',
              icon: Icons.schedule_outlined,
              isSelected: activeFilter == 'Pending',
              width: cardWidth,
              onTap: () => onSelectFilter('Pending'),
            ),
            _SummaryItemCard(
              label: 'Submitted',
              value: '$submitted',
              icon: Icons.task_alt_outlined,
              isSelected: activeFilter == 'Submitted',
              width: cardWidth,
              onTap: () => onSelectFilter('Submitted'),
            ),
            _SummaryItemCard(
              label: 'Graded',
              value: '$graded',
              icon: Icons.verified_outlined,
              isSelected: activeFilter == 'Graded',
              width: cardWidth,
              onTap: () => onSelectFilter('Graded'),
            ),
          ],
        );
      },
    );
  }
}

class _SummaryItemCard extends StatelessWidget {
  const _SummaryItemCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.isSelected,
    required this.width,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool isSelected;
  final double width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: width,
      child: Card(
        color: isSelected ? colorScheme.primaryContainer : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isSelected
              ? BorderSide(color: colorScheme.primary, width: 1.5)
              : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isSelected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        value,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? colorScheme.onPrimaryContainer
                                  : null,
                            ),
                      ),
                      Text(
                        label,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isSelected
                                  ? colorScheme.onPrimaryContainer
                                  : colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AssignmentCardItem extends StatelessWidget {
  const _AssignmentCardItem({
    required this.assignment,
    required this.onViewDetails,
  });

  final StudentAssignment assignment;
  final VoidCallback onViewDetails;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isGraded = assignment.isGraded;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        assignment.title,
                        style:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        assignment.course,
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _AssignmentStatusChip(status: assignment.status),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Due: ${assignment.dueDate}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.military_tech_outlined,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Max: ${assignment.maxMarks} pts',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                if (isGraded && assignment.grade != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.grade_outlined,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Grade: ${assignment.grade}',
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                if (isGraded && assignment.grade != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Grade: ${assignment.grade}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                const Spacer(),
                FilledButton.tonal(
                  onPressed: onViewDetails,
                  child: const Text('View Details'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AssignmentStatusChip extends StatelessWidget {
  const _AssignmentStatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case 'Pending':
        backgroundColor = colorScheme.errorContainer;
        textColor = colorScheme.onErrorContainer;
        icon = Icons.schedule_outlined;
        break;
      case 'Submitted':
        backgroundColor = colorScheme.secondaryContainer;
        textColor = colorScheme.onSecondaryContainer;
        icon = Icons.task_alt_outlined;
        break;
      case 'Graded':
        backgroundColor = colorScheme.primaryContainer;
        textColor = colorScheme.onPrimaryContainer;
        icon = Icons.verified_outlined;
        break;
      default:
        backgroundColor = colorScheme.surfaceContainerHighest;
        textColor = colorScheme.onSurfaceVariant;
        icon = Icons.info_outline;
    }

    return Chip(
      avatar: Icon(icon, size: 16, color: textColor),
      label: Text(
        status,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
      ),
      backgroundColor: backgroundColor,
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
