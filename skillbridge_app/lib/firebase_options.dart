import 'package:firebase_core/firebase_core.dart';

/// Firebase project configuration.
///
/// These are placeholders. Replace them with your real project values, or
/// regenerate this file with `flutterfire configure`. Until then, Firebase
/// initialisation fails and every coordinator screen (which reads Firestore)
/// will show an error state. The instructor dashboard is unaffected — it talks
/// to the FastAPI backend, not Firebase.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => const FirebaseOptions(
        apiKey: 'REPLACE_WITH_FIREBASE_API_KEY',
        appId: 'REPLACE_WITH_FIREBASE_APP_ID',
        messagingSenderId: 'REPLACE_WITH_SENDER_ID',
        projectId: 'REPLACE_WITH_PROJECT_ID',
        storageBucket: 'REPLACE_WITH_STORAGE_BUCKET',
      );

  /// True once the placeholders above have been replaced with real values.
  static bool get isConfigured =>
      !currentPlatform.projectId.startsWith('REPLACE_WITH');
}
