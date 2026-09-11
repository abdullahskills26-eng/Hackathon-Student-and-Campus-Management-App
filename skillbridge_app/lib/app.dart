import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/instructor/dashboard/instructor_shell.dart';

/// Root widget.
///
/// Currently opens straight onto the instructor shell. Once Firebase Auth
/// lands, `home` becomes the login screen and role detection routes to the
/// student / instructor / coordinator shell.
class SkillBridgeApp extends StatelessWidget {
  const SkillBridgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkillBridge',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const InstructorShell(),
    );
  }
}
