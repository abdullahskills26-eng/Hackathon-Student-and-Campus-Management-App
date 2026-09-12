import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../models/assignment_model.dart';
import '../../../models/submission_model.dart';
import 'student_assignment_store.dart';

class _SubmissionResult {
  final String? note;
  final String? url;
  final String? fileName;
  final String? filePath;
  final int? fileSize;

  const _SubmissionResult(
      {this.note, this.url, this.fileName, this.filePath, this.fileSize});
}

class _AssignmentSubmissionDialog extends StatefulWidget {
  const _AssignmentSubmissionDialog();

  @override
  State<_AssignmentSubmissionDialog> createState() =>
      _AssignmentSubmissionDialogState();
}

class _AssignmentSubmissionDialogState
    extends State<_AssignmentSubmissionDialog> {
  late final TextEditingController noteController;
  late final TextEditingController urlController;
  String? selectedFileName;
  String? selectedFilePath;
  int? selectedFileSize;
  String? validationError;

  @override
  void initState() {
    super.initState();
    noteController = TextEditingController();
    urlController = TextEditingController();
  }

  @override
  void dispose() {
    noteController.dispose();
    urlController.dispose();
    super.dispose();
  }

  Future<void> pickFile() async {
    try {
      // `withData: true` is required on web, where the browser hands back
      // bytes rather than a filesystem path (PlatformFile.path is always null
      // there).
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        withData: true,
        allowedExtensions: [
          'pdf',
          'doc',
          'docx',
          'ppt',
          'pptx',
          'xls',
          'xlsx',
          'zip',
          'rar',
          'txt',
          'jpg',
          'jpeg',
          'png',
        ],
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (!mounted) return;
        setState(() {
          selectedFileName = file.name;
          selectedFilePath = file.path;
          selectedFileSize = file.size;
          validationError = null;
        });
      }
    } catch (_) {}
  }

  void removeFile() {
    setState(() {
      selectedFileName = null;
      selectedFilePath = null;
      selectedFileSize = null;
    });
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Submit Assignment'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // File upload section
              const Text('Assignment File', style: TextStyle()),
              const SizedBox(height: 8),
              if (selectedFileName != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: Theme.of(context).colorScheme.primary),
                    borderRadius: BorderRadius.circular(8),
                    color: Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withValues(alpha: 0.2),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.insert_drive_file_outlined),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedFileName!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            if (selectedFileSize != null &&
                                selectedFileSize! > 0)
                              Text(
                                _formatFileSize(selectedFileSize!),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        tooltip: 'Remove file',
                        onPressed: removeFile,
                      ),
                    ],
                  ),
                )
              else
                OutlinedButton.icon(
                  onPressed: pickFile,
                  icon: const Icon(Icons.upload_file_outlined),
                  label: const Text('Choose File'),
                ),
              const SizedBox(height: 4),
              const Text(
                'Supported: PDF, DOC, DOCX, PPT, XLS, ZIP, TXT, JPG, PNG',
                style: TextStyle(),
              ),
              const SizedBox(height: 18),
              // Submission URL
              TextFormField(
                controller: urlController,
                decoration: const InputDecoration(
                  labelText: 'Submission URL (Optional)',
                  hintText: 'https://github.com/... or cloud link',
                  prefixIcon: Icon(Icons.link),
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) {
                  if (validationError != null) {
                    setState(() => validationError = null);
                  }
                },
              ),
              const SizedBox(height: 18),
              // Submission Note
              TextFormField(
                controller: noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Submission Note (Optional)',
                  hintText: 'Add comments, context, or instructions...',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) {
                  if (validationError != null) {
                    setState(() => validationError = null);
                  }
                },
              ),
              if (validationError != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 18,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          validationError!,
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onErrorContainer,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final note = noteController.text.trim();
            final url = urlController.text.trim();
            final hasFile = selectedFileName != null;
            final hasUrl = url.isNotEmpty;
            final hasNote = note.isNotEmpty;
            if (!hasFile && !hasUrl && !hasNote) {
              setState(() {
                validationError =
                    'Please upload a file, enter a URL, or add a submission note.';
              });
              return;
            }
            Navigator.of(context).pop(_SubmissionResult(
              note: hasNote ? note : null,
              url: hasUrl ? url : null,
              fileName: selectedFileName,
              filePath: selectedFilePath,
              fileSize: selectedFileSize,
            ));
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}

class StudentAssignmentDetailsScreen extends StatefulWidget {
  const StudentAssignmentDetailsScreen({
    super.key,
    required this.assignment,
  });

  final StudentAssignment assignment;

  @override
  State<StudentAssignmentDetailsScreen> createState() =>
      _StudentAssignmentDetailsScreenState();
}

class _StudentAssignmentDetailsScreenState
    extends State<StudentAssignmentDetailsScreen> {
  late StudentAssignment _assignment;

  @override
  void initState() {
    super.initState();
    _assignment = widget.assignment;
  }

  Future<void> _showSubmissionDialog() async {
    final result = await showDialog<_SubmissionResult>(
      context: context,
      builder: (_) => const _AssignmentSubmissionDialog(),
    );

    if (result == null || !mounted) return;

    // Update the shared store.
    StudentAssignmentStore.instance.submitAssignment(
      assignmentId: _assignment.id,
      fileName: result.fileName,
      filePath: result.filePath,
      fileSizeBytes: result.fileSize,
      url: result.url,
      note: result.note,
    );

    // Update local state.
    setState(() {
      _assignment = _assignment.copyWith(
        status: 'Submitted',
        submission: AssignmentSubmission(
          fileName: result.fileName,
          filePath: result.filePath,
          fileSizeBytes: result.fileSize,
          url: result.url,
          note: result.note,
          submittedAt: '12 September 2026',
        ),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Assignment submitted successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPending = _assignment.isPending;
    final isSubmitted = _assignment.isSubmitted;
    final isGraded = _assignment.isGraded;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pop(_assignment);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Assignment Details'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(_assignment),
          ),
        ),
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 840),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _HeaderCard(assignment: _assignment),
                  const SizedBox(height: 20),
                  if (isGraded) ...[
                    _GradingCard(assignment: _assignment),
                    const SizedBox(height: 20),
                  ],
                  if (isSubmitted ||
                      (isGraded && _assignment.submission != null)) ...[
                    _SubmissionSummaryCard(submission: _assignment.submission),
                    const SizedBox(height: 20),
                  ],
                  _DescriptionCard(description: _assignment.description),
                  const SizedBox(height: 20),
                  _InstructionsCard(instructions: _assignment.instructions),
                  const SizedBox(height: 28),
                  if (isPending)
                    FilledButton.icon(
                      onPressed: _showSubmissionDialog,
                      icon: const Icon(Icons.upload_file_outlined),
                      label: const Text('Submit Assignment'),
                    )
                  else
                    OutlinedButton.icon(
                      onPressed: null,
                      icon: Icon(
                        isGraded
                            ? Icons.verified_outlined
                            : Icons.check_circle_outline,
                      ),
                      label: Text(
                        isGraded
                            ? 'Assignment Graded'
                            : 'Assignment Already Submitted',
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.assignment});

  final StudentAssignment assignment;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    assignment.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                const SizedBox(width: 12),
                _StatusChip(status: assignment.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              assignment.course,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                  ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 20,
              runSpacing: 10,
              children: [
                _MetaItem(
                  icon: Icons.calendar_today_outlined,
                  label: 'Due Date',
                  value: assignment.dueDate,
                ),
                _MetaItem(
                  icon: Icons.military_tech_outlined,
                  label: 'Max Marks',
                  value: '${assignment.maxMarks} points',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        Text(value),
      ],
    );
  }
}

class _DescriptionCard extends StatelessWidget {
  const _DescriptionCard({required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _InstructionsCard extends StatelessWidget {
  const _InstructionsCard({required this.instructions});

  final String instructions;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Instructions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              instructions,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _SubmissionSummaryCard extends StatelessWidget {
  const _SubmissionSummaryCard({required this.submission});

  final AssignmentSubmission? submission;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (submission == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: colorScheme.primary),
                const SizedBox(width: 10),
                Text(
                  'Submission Details',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Submitted on: ${submission!.submittedAt}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            if (submission!.hasFile) ...[
              const SizedBox(height: 12),
              Text(
                'Uploaded File:',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.insert_drive_file_outlined,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        submission!.fileName!,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (submission!.formattedFileSize.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(
                        submission!.formattedFileSize,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ],
            if (submission!.hasUrl) ...[
              const SizedBox(height: 12),
              Text(
                'Submission URL:',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.link, color: colorScheme.primary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SelectableText(
                        submission!.url!,
                        style: TextStyle(
                          color: colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (submission!.hasNote) ...[
              const SizedBox(height: 12),
              Text(
                'Submission Note:',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(submission!.note!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GradingCard extends StatelessWidget {
  const _GradingCard({required this.assignment});

  final StudentAssignment assignment;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.tertiaryContainer.withValues(alpha: 0.35),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.verified, color: colorScheme.primary),
                    const SizedBox(width: 10),
                    Text(
                      'Graded Result',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                if (assignment.grade != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      assignment.grade!,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
              ],
            ),
            if (assignment.submission?.submittedAt != null) ...[
              const SizedBox(height: 14),
              Text('Submitted on: ${assignment.submission!.submittedAt}'),
            ],
            if (assignment.feedback != null) ...[
              const SizedBox(height: 10),
              Text(
                'Instructor Feedback:',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(assignment.feedback!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

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
