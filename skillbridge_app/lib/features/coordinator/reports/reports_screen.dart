import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/widgets/app_shell.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) => AppShell(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('applications')
                  .snapshots(),
              builder: (c, s) {
        if (!s.hasData) return const Center(child: CircularProgressIndicator());
        final apps = s.data!.docs;
        final accepted =
            apps.where((d) => d.data()['status'] == 'Accepted').length;
        return ListView(padding: const EdgeInsets.all(20), children: [
          const Text('Coordinator Reports',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _r('Applications this month', '${apps.length}'),
          _r('Accepted students', '$accepted'),
          StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection('attendance').snapshots(),
              builder: (c, a) => _r('Average attendance',
                  a.hasData && a.data!.size > 0 ? 'Data available' : '—')),
          _pending(context)
        ]);
      }));

  Widget _r(String a, String b) => Card(
      child: ListTile(
          title: Text(a),
          trailing: Text(b,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))));

  Widget _pending(BuildContext context) => StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('assignments')
          .where('status', isEqualTo: 'Pending')
          .snapshots(),
      builder: (c, s) =>
          _r('Pending assignments', s.hasData ? '${s.data!.size}' : '—'));
}
