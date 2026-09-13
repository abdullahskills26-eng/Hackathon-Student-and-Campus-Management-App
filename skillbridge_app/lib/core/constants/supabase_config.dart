/// Supabase configuration, supplied at build time.
///
/// Values come from `--dart-define`, so nothing is committed to git:
///
///   flutter run -d chrome \
///     --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
///     --dart-define=SUPABASE_ANON_KEY=eyJhbGciOi...
///
/// Only the **anon / publishable** key belongs here. It is safe in a client
/// the same way the Firebase apiKey is — it identifies the project and grants
/// nothing on its own, because Storage access is decided by RLS policies.
///
/// The **service_role / secret** key must never appear in this app. It
/// bypasses every policy. If you ever need it, it belongs in the FastAPI
/// backend behind an environment variable.
class SupabaseConfig {
  SupabaseConfig._();

  static const String url = String.fromEnvironment('SUPABASE_URL');

  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Private bucket that holds every uploaded file.
  static const String bucket = 'skillbridge-files';

  /// Folder prefixes inside the bucket. The second path segment is always the
  /// owner's Firebase UID, which is what the Storage RLS policies match on.
  static String profilePicture(String uid, String fileName) =>
      'profile_pictures/$uid/$fileName';

  static String assignmentFile(
    String uid,
    String assignmentId,
    String fileName,
  ) =>
      'assignments/$uid/${assignmentId}_$fileName';

  /// How long a generated signed URL stays valid.
  static const Duration signedUrlTtl = Duration(hours: 1);

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;

  /// Shown in the UI when the dart-defines are missing.
  static const String setupHint =
      'Supabase is not configured. Rebuild with '
      '--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...';
}
