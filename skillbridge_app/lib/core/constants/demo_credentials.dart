/// Demo accounts used by the quick-login buttons.
///
/// These must exist in Firebase Authentication — the buttons only prefill the
/// form; sign-in still goes through Firebase Auth.
class DemoCredentials {
  DemoCredentials._();

  static const String password = 'skillbridge123';

  static const DemoAccount student = DemoAccount(
    email: 'student@skillbridge.org',
    name: 'Ayesha Khan',
    role: 'student',
    description: 'Flutter student — Lahore Campus',
  );

  static const DemoAccount instructor = DemoAccount(
    email: 'instructor@skillbridge.org',
    name: 'Sir Hamza',
    role: 'instructor',
    description: 'Flutter instructor — Lahore Campus',
  );

  static const DemoAccount coordinator = DemoAccount(
    email: 'admin@skillbridge.org',
    name: 'Campus Coordinator',
    role: 'coordinator',
    description: 'Campus coordinator — Lahore',
  );

  static const List<DemoAccount> all = [student, instructor, coordinator];
}

class DemoAccount {
  final String email;
  final String name;
  final String role;
  final String description;

  const DemoAccount({
    required this.email,
    required this.name,
    required this.role,
    required this.description,
  });
}
