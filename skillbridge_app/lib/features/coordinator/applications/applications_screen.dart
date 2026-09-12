import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/widgets/app_shell.dart';

class ApplicationsScreen extends StatelessWidget {
  const ApplicationsScreen({super.key});

  Future<void> action(
      BuildContext context, DocumentSnapshot d, String status) async {
    String reason = '';
    if (status == 'Rejected') {
      final c = TextEditingController();
      final ok = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
                  title: const Text('Rejection Reason'),
                  content: TextField(
                      controller: c,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Reason')),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel')),
                    FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Reject'))
                  ]));
      if (ok != true) return;
      reason = c.text.trim();
    }
    await d.reference.update({
      'status': status,
      'rejectionReason': reason,
      'updatedAt': FieldValue.serverTimestamp()
    });
  }

  @override
  Widget build(BuildContext context) => AppShell(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('applications')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (c, s) {
        if (s.hasError) return Center(child: Text('Error: ${s.error}'));
        if (!s.hasData) return const Center(child: CircularProgressIndicator());
        if (s.data!.docs.isEmpty) {
          return const Center(child: Text('No applications found.'));
        }
        return ListView(padding: const EdgeInsets.all(16), children: [
          const Text('Application Inbox',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...s.data!.docs.map((d) {
            final a = d.data();
            return Card(
                child: ListTile(
                    title: Text(a['fullName'] ?? ''),
                    subtitle: Text(
                        '${a['selectedCourse'] ?? ''} • ${a['preferredCampus'] ?? ''}\nStatus: ${a['status'] ?? ''}'),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                        onSelected: (v) => action(context, d, v),
                        itemBuilder: (_) => const [
                              PopupMenuItem(
                                  value: 'Accepted', child: Text('Accept')),
                              PopupMenuItem(
                                  value: 'Waiting List',
                                  child: Text('Wait List')),
                              PopupMenuItem(
                                  value: 'Rejected', child: Text('Reject'))
                            ])));
          })
        ]);
      }));
}
