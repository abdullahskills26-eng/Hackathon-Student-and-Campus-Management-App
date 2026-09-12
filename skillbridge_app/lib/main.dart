import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Guarded so the app still starts with placeholder Firebase credentials.
  // Without this, an invalid config throws here and nothing renders at all --
  // including the instructor dashboard, which does not use Firebase.
  bool firebaseReady = false;
  String? firebaseError;
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    firebaseReady = true;
  } catch (e) {
    firebaseError = e.toString();
  }

  runApp(SkillBridgeApp(
    firebaseReady: firebaseReady,
    firebaseError: firebaseError,
  ));
}
