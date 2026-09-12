/// A student's submission against an assignment.
///
/// Reconstructed from usage in the student assignment screens — the class was
/// not supplied. On Flutter web [filePath] is always null (the browser exposes
/// bytes, not paths), so treat [fileName] and [fileSizeBytes] as the reliable
/// fields there.
class AssignmentSubmission {
  final String? fileName;
  final String? filePath;
  final int? fileSizeBytes;
  final String? url;
  final String? note;
  final String submittedAt;

  const AssignmentSubmission({
    this.fileName,
    this.filePath,
    this.fileSizeBytes,
    this.url,
    this.note,
    required this.submittedAt,
  });

  bool get hasFile => fileName != null && fileName!.isNotEmpty;
  bool get hasUrl => url != null && url!.isNotEmpty;
  bool get hasNote => note != null && note!.isNotEmpty;

  /// Human-readable size, or an empty string when the size is unknown.
  String get formattedFileSize {
    final bytes = fileSizeBytes;
    if (bytes == null || bytes <= 0) return '';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  AssignmentSubmission copyWith({
    String? fileName,
    String? filePath,
    int? fileSizeBytes,
    String? url,
    String? note,
    String? submittedAt,
  }) =>
      AssignmentSubmission(
        fileName: fileName ?? this.fileName,
        filePath: filePath ?? this.filePath,
        fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
        url: url ?? this.url,
        note: note ?? this.note,
        submittedAt: submittedAt ?? this.submittedAt,
      );
}
