import 'package:firebase_core/firebase_core.dart';

/// Firebase configuration for the SkillBridge project (`skillbridge-32f45`).
///
/// These values are not secrets: they ship inside every built web bundle and
/// are public by design. Access is controlled by the Firestore and Storage
/// security rules (see firestore.rules / storage.rules at the repo root),
/// not by hiding this file.
///
/// Regenerate with `flutterfire configure` if you add Android or iOS targets.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => const FirebaseOptions(
        apiKey: 'AIzaSyDMxdiscRn7jhZgav8LYtjUPqLeiDn_OHA',
        authDomain: 'skillbridge-32f45.firebaseapp.com',
        projectId: 'skillbridge-32f45',
        storageBucket: 'skillbridge-32f45.firebasestorage.app',
        messagingSenderId: '1068190447078',
        appId: '1:1068190447078:web:0a287ed9a8783f40fb9227',
        measurementId: 'G-STVMLVWEDJ',
      );

  /// True once real project values are in place.
  static bool get isConfigured =>
      !currentPlatform.projectId.startsWith('REPLACE_WITH');
}
