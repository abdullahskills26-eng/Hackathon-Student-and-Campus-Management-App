import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/widgets/app_shell.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) => AppShell(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('notifications')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (c, s) {
        if (!s.hasData) return const Center(child: CircularProgressIndicator());
        if (s.data!.docs.isEmpty) {
          return const Center(child: Text('No notifications.'));
        }
        return ListView(padding: const EdgeInsets.all(16), children: [
          const Text('Notifications',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          ...s.data!.docs.map((d) {
            final a = d.data();
            return Card(
                child: ListTile(
                    leading: const Icon(Icons.notifications),
                    title: Text(a['title'] ?? ''),
                    subtitle: Text(a['message'] ?? '')));
          })
        ]);
      }));
}
