import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../coordinator/coordinator_home.dart';
import '../../instructor/dashboard/instructor_shell.dart';
import '../../student/assignments/student_assignments_screen.dart';

/// TEMPORARY entry point — Screen 1 stand-in.
///
/// Replace this with the real `login_screen.dart` (Firebase Auth + the three
/// demo-role buttons) once it lands. It exists only so both finished roles are
/// reachable in the same build; it performs no authentication.
class RoleSelectionScreen extends StatelessWidget {
  final bool firebaseReady;
  final String? firebaseError;

  const RoleSelectionScreen({
    super.key,
    required this.firebaseReady,
    this.firebaseError,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.school_rounded,
                    size: 56, color: AppColors.primaryIndigo),
                const SizedBox(height: 16),
                const Text(
                  'SkillBridge',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Choose a role to open its dashboard',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const InstructorShell()),
                  ),
                  icon: const Icon(Icons.fact_check),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('Instructor Dashboard'),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Needs the FastAPI backend on port 8000',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CoordinatorHome()),
                  ),
                  icon: const Icon(Icons.admin_panel_settings),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('Coordinator Dashboard'),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.emeraldGreen,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Needs Firebase',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const StudentAssignmentsScreen()),
                  ),
                  icon: const Icon(Icons.school_outlined),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('Student — Assignments'),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.amber,
                    foregroundColor: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Partial — assignments only, on in-memory demo data',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                if (!firebaseReady) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.crimsonRed.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.crimsonRed.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.warning_amber_rounded,
                                color: AppColors.crimsonRed, size: 18),
                            SizedBox(width: 8),
                            Text('Firebase not configured',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.crimsonRed)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Coordinator screens will show errors until '
                          'lib/firebase_options.dart holds real project values. '
                          'Run `flutterfire configure` to generate them.'
                          '${firebaseError != null ? '\n\n$firebaseError' : ''}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
