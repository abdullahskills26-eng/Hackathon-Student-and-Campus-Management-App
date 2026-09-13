import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/screens/auth_gate.dart';

/// Root widget.
///
/// [AuthGate] is the only entry point: it watches Firebase Auth, reads the
/// signed-in user's role from `users/{uid}`, and builds the one shell that
/// role is entitled to.
class SkillBridgeApp extends StatelessWidget {
  final bool firebaseReady;
  final String? firebaseError;

  const SkillBridgeApp({
    super.key,
    this.firebaseReady = false,
    this.firebaseError,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkillBridge',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      home: AuthGate(
        firebaseReady: firebaseReady,
        firebaseError: firebaseError,
      ),
    );
  }
}
