import 'package:flutter/material.dart';

import '../../features/coordinator/applications/applications_screen.dart';
import '../../features/coordinator/batches/batches_screen.dart';
import '../../features/coordinator/coordinator_home.dart';
import '../../features/coordinator/notices_screen.dart';
import '../../features/coordinator/reports/reports_screen.dart';
import '../../features/shared/notifications/notifications_screen.dart';
import '../../features/shared/profile/profile_screen.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  void go(BuildContext c, Widget page) =>
      Navigator.pushReplacement(c, MaterialPageRoute(builder: (_) => page));

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('SkillBridge — Campus Coordinator')),
        drawer: Drawer(
            child: ListView(children: [
          const DrawerHeader(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Icon(Icons.school, size: 38),
                SizedBox(height: 8),
                Text('Campus Coordinator',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text('Lahore Campus')
              ])),
          ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () => go(context, const CoordinatorHome())),
          ListTile(
              leading: const Icon(Icons.inbox),
              title: const Text('Applications'),
              onTap: () => go(context, const ApplicationsScreen())),
          ListTile(
              leading: const Icon(Icons.groups),
              title: const Text('Batches'),
              onTap: () => go(context, const BatchesScreen())),
          ListTile(
              leading: const Icon(Icons.campaign),
              title: const Text('Campus Notices'),
              onTap: () => go(context, const NoticesScreen())),
          ListTile(
              leading: const Icon(Icons.assessment),
              title: const Text('Reports'),
              onTap: () => go(context, const ReportsScreen())),
          ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              onTap: () => go(context, const NotificationsScreen())),
          ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () => go(context, const ProfileScreen())),
        ])),
        body: child,
      );
}
