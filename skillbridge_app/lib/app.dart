import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/screens/role_selection_screen.dart';

/// Root widget.
///
/// `home` is currently the temporary role picker. Swap it for the real
/// `LoginScreen` (Firebase Auth + demo-role buttons) once that screen lands,
/// and route by the `role` field on users/{uid} from there.
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
      home: RoleSelectionScreen(
        firebaseReady: firebaseReady,
        firebaseError: firebaseError,
      ),
    );
  }
}
