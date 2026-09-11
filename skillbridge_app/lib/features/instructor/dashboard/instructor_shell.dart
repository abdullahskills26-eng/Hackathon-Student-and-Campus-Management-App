import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/notice_model.dart';
import '../../../services/api_service.dart';
import '../assignments/assignments_screen.dart';
import '../attendance/attendance_screen.dart';
import 'overview_screen.dart';

/// Adaptive navigation host for the instructor role.
///
/// NavigationRail at >= 700px wide, BottomNavigationBar below that.
class InstructorShell extends StatefulWidget {
  const InstructorShell({super.key});

  @override
  State<InstructorShell> createState() => _InstructorShellState();
}

class _InstructorShellState extends State<InstructorShell> {
  int _selectedIndex = 0;
  final ApiService _api = ApiService();

  /// Local notice cache — the backend exposes no GET /notices, so posted
  /// notices are only retained for the lifetime of this session.
  final List<Notice> _sessionNotices = [];

  static const List<String> _titles = [
    'Overview',
    'Attendance Tracker',
    'Assignment & Quiz Manager',
  ];

  void _onNavTap(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    final screens = [
      OverviewScreen(api: _api, sessionNotices: _sessionNotices),
      AttendanceScreen(api: _api),
      AssignmentsScreen(api: _api),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 700;

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                const Icon(Icons.school_rounded),
                const SizedBox(width: 10),
                Text(_titles[_selectedIndex]),
              ],
            ),
          ),
          body: isWide
              ? Row(
                  children: [
                    NavigationRail(
                      selectedIndex: _selectedIndex,
                      onDestinationSelected: _onNavTap,
                      labelType: NavigationRailLabelType.all,
                      backgroundColor: Colors.white,
                      selectedIconTheme:
                          const IconThemeData(color: AppColors.primaryIndigo),
                      destinations: const [
                        NavigationRailDestination(
                          icon: Icon(Icons.dashboard_outlined),
                          selectedIcon: Icon(Icons.dashboard),
                          label: Text('Overview'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.fact_check_outlined),
                          selectedIcon: Icon(Icons.fact_check),
                          label: Text('Attendance'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.assignment_outlined),
                          selectedIcon: Icon(Icons.assignment),
                          label: Text('Assignments'),
                        ),
                      ],
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(child: screens[_selectedIndex]),
                  ],
                )
              : screens[_selectedIndex],
          bottomNavigationBar: isWide
              ? null
              : BottomNavigationBar(
                  currentIndex: _selectedIndex,
                  onTap: _onNavTap,
                  selectedItemColor: AppColors.primaryIndigo,
                  type: BottomNavigationBarType.fixed,
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.dashboard_outlined),
                      activeIcon: Icon(Icons.dashboard),
                      label: 'Overview',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.fact_check_outlined),
                      activeIcon: Icon(Icons.fact_check),
                      label: 'Attendance',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.assignment_outlined),
                      activeIcon: Icon(Icons.assignment),
                      label: 'Assignments',
                    ),
                  ],
                ),
        );
      },
    );
  }
}
