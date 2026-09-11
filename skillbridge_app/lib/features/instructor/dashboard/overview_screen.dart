import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/state_renderers.dart';
import '../../../models/dashboard_summary_model.dart';
import '../../../models/notice_model.dart';
import '../../../services/api_service.dart';
import 'widgets/metric_card.dart';

/// Screen 10 — instructor home: KPI tiles plus the class notice board.
class OverviewScreen extends StatefulWidget {
  final ApiService api;
  final List<Notice> sessionNotices;

  const OverviewScreen({
    super.key,
    required this.api,
    required this.sessionNotices,
  });

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  bool _loading = true;
  String? _error;
  DashboardSummary? _summary;
  int _atRiskCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final summary = await widget.api.fetchDashboardSummary();
      final atRisk = await widget.api.fetchAtRiskCount();
      if (!mounted) return;
      setState(() {
        _summary = summary;
        _atRiskCount = atRisk;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _openAddNoticeDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.campaign, color: AppColors.amber),
            SizedBox(width: 8),
            Text('Add Notice'),
          ],
        ),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Enter announcement text…',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryIndigo,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isEmpty) return;
              Navigator.pop(ctx);
              try {
                final notice = await widget.api.createNotice(text);
                if (!mounted) return;
                setState(() {
                  widget.sessionNotices.insert(0, notice);
                });
                _loadData(); // refresh active_notices count
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notice posted successfully')),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString())),
                );
              }
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingState();
    if (_error != null) {
      return ErrorRetry(message: _error!, onRetry: _loadData);
    }

    final summary = _summary!;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---- Metric Cards Grid ----
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 900 ? 4 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              MetricCard(
                label: 'Classes Today',
                value: '${summary.totalClasses}',
                icon: Icons.class_,
                color: AppColors.primaryIndigo,
              ),
              MetricCard(
                label: 'Total Students',
                value: '${summary.totalStudents}',
                icon: Icons.groups,
                color: AppColors.emeraldGreen,
              ),
              MetricCard(
                label: 'At-Risk Alerts',
                value: '$_atRiskCount',
                icon: Icons.warning_amber_rounded,
                color: AppColors.crimsonRed,
              ),
              MetricCard(
                label: 'Active Notices',
                value: '${summary.activeNotices}',
                icon: Icons.campaign,
                color: AppColors.amber,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ---- Notices Section Header ----
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Class Notices',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: _openAddNoticeDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Notice'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.amber,
                  foregroundColor: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ---- Notices List (session-local: backend has no GET /notices) ----
          if (widget.sessionNotices.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'No notices posted this session yet. Use "Add Notice" to create one.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...widget.sessionNotices.map(
              (n) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.amber,
                    child: Icon(Icons.campaign, color: Colors.white, size: 20),
                  ),
                  title: Text(n.text),
                  subtitle: Text(n.createdAt),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
