import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/widgets/app_shell.dart';

class BatchesScreen extends StatelessWidget {
  const BatchesScreen({super.key});

  Future<void> create(BuildContext context) async {
    final course = TextEditingController(text: 'Flutter Development'),
        campus = TextEditingController(text: 'Lahore Campus'),
        name = TextEditingController(text: 'FL-2026-01'),
        seats = TextEditingController(text: '30'),
        date = TextEditingController(text: '2026-10-15'),
        inst = TextEditingController(text: 'Sir Hamza');
    await showDialog(
        context: context,
        builder: (_) => AlertDialog(
                title: const Text('Create Batch'),
                content: SizedBox(
                    width: 420,
                    child: SingleChildScrollView(
                        child: Column(children: [
                      for (final x in [course, campus, name, seats, date, inst])
                        Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: TextField(
                                controller: x,
                                decoration: InputDecoration(
                                    labelText: [
                                  'Course',
                                  'Campus',
                                  'Batch',
                                  'Seats',
                                  'Start Date',
                                  'Instructor'
                                ][[course, campus, name, seats, date, inst]
                                        .indexOf(x)])))
                    ]))),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('batches')
                            .doc(name.text.trim())
                            .set({
                          'batchId': name.text.trim(),
                          'courseName': course.text,
                          'campus': campus.text,
                          'seats': int.tryParse(seats.text) ?? 0,
                          'startDate': date.text,
                          'instructorName': inst.text,
                          'status': 'Open',
                          'createdAt': FieldValue.serverTimestamp()
                        });
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: const Text('Create'))
                ]));
  }

  @override
  Widget build(BuildContext context) => AppShell(
          child: Column(children: [
        Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              const Expanded(
                  child: Text('Batch Management',
                      style:
                          TextStyle(fontSize: 26, fontWeight: FontWeight.bold))),
              FilledButton.icon(
                  onPressed: () => create(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Create Batch'))
            ])),
        Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream:
                    FirebaseFirestore.instance.collection('batches').snapshots(),
                builder: (c, s) {
                  if (!s.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (s.data!.docs.isEmpty) {
                    return const Center(child: Text('No batches found.'));
                  }
                  return ListView(
                      children: s.data!.docs.map((d) {
                    final a = d.data();
                    return Card(
                        child: ListTile(
                            title: Text(a['batchId'] ?? d.id),
                            subtitle: Text(
                                '${a['courseName'] ?? ''} • ${a['campus'] ?? ''}\nSeats: ${a['seats'] ?? 0} • Start: ${a['startDate'] ?? ''}\nInstructor: ${a['instructorName'] ?? ''}'),
                            isThreeLine: true,
                            trailing: PopupMenuButton<String>(
                                onSelected: (v) =>
                                    d.reference.update({'status': v}),
                                itemBuilder: (_) => const [
                                      PopupMenuItem(
                                          value: 'Open', child: Text('Open')),
                                      PopupMenuItem(
                                          value: 'Closed', child: Text('Close'))
                                    ])));
                  }).toList());
                }))
      ]));
}
