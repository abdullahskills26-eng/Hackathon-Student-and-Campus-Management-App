import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/widgets/app_shell.dart';

class NoticesScreen extends StatelessWidget {
  const NoticesScreen({super.key});

  Future<void> add(BuildContext context) async {
    final title = TextEditingController(), body = TextEditingController();
    await showDialog(
        context: context,
        builder: (_) => AlertDialog(
                title: const Text('Post Campus Notice'),
                content: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextField(
                      controller: title,
                      decoration: const InputDecoration(labelText: 'Title')),
                  TextField(
                      controller: body,
                      maxLines: 4,
                      decoration: const InputDecoration(labelText: 'Notice'))
                ]),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('notices')
                            .add({
                          'title': title.text,
                          'body': body.text,
                          'campus': 'Lahore Campus',
                          'createdAt': FieldValue.serverTimestamp()
                        });
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: const Text('Post'))
                ]));
  }

  @override
  Widget build(BuildContext context) => AppShell(
          child: Column(children: [
        Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              const Expanded(
                  child: Text('Campus-Wide Notices',
                      style:
                          TextStyle(fontSize: 26, fontWeight: FontWeight.bold))),
              FilledButton.icon(
                  onPressed: () => add(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Post Notice'))
            ])),
        Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('notices')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (c, s) {
                  if (!s.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (s.data!.docs.isEmpty) {
                    return const Center(child: Text('No notices found.'));
                  }
                  return ListView(
                      children: s.data!.docs.map((d) {
                    final a = d.data();
                    return Card(
                        child: ListTile(
                            title: Text(a['title'] ?? ''),
                            subtitle: Text(
                                '${a['body'] ?? ''}\nCampus: ${a['campus'] ?? ''}'),
                            isThreeLine: true,
                            trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => d.reference.delete())));
                  }).toList());
                }))
      ]));
}
