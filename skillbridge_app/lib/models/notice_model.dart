/// A class notice. Shape matches the `notice` object returned by
/// `POST /api/v1/notices/create`.
class Notice {
  final int id;
  final String text;
  final String createdAt;

  Notice({required this.id, required this.text, required this.createdAt});

  factory Notice.fromJson(Map<String, dynamic> json) {
    return Notice(
      id: json['id'],
      text: json['text'] ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}
