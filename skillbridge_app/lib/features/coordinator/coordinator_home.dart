import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/widgets/app_shell.dart';
import '../../services/seed_service.dart';

class CoordinatorHome extends StatefulWidget {
  const CoordinatorHome({super.key});
  @override
  State<CoordinatorHome> createState() => _S();
}

class _S extends State<CoordinatorHome> {
  bool seeding = false;

  Stream<int> count(String col, {String? field, String? value}) =>
      FirebaseFirestore.instance.collection(col).snapshots().map((s) =>
          field == null
              ? s.size
              : s.docs.where((d) => d.data()[field] == value).length);

  Future<void> seed() async {
    setState(() => seeding = true);
    try {
      await SeedService.seed();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Demo data seeded successfully.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Seed failed: $e')));
      }
    } finally {
      if (mounted) setState(() => seeding = false);
    }
  }

  @override
  Widget build(BuildContext context) => AppShell(
          child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('applications')
                  .snapshots(),
              builder: (c, snap) {
        if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snap.data!.docs;
        final accepted =
            docs.where((d) => d.data()['status'] == 'Accepted').length;
        return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Coordinator Dashboard',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text('Lahore Campus'),
              const SizedBox(height: 20),
              Wrap(spacing: 14, runSpacing: 14, children: [
                _card('Applications This Month', '${docs.length}', Icons.inbox),
                _card('Accepted Students', '$accepted', Icons.check_circle),
                _cardStream(
                    'Average Attendance', 'attendance', Icons.calendar_today),
                _cardStream(
                    'Pending Assignments', 'assignments', Icons.assignment),
              ]),
              const SizedBox(height: 24),
              SizedBox(
                  width: 220,
                  child: FilledButton.icon(
                      onPressed: seeding ? null : seed,
                      icon: const Icon(Icons.storage),
                      label: Text(seeding ? 'Seeding...' : 'Seed Demo Data'))),
            ]));
      }));

  Widget _card(String t, String v, IconData i) => SizedBox(
      width: 250,
      height: 130,
      child: Card(
          child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(i),
                const Spacer(),
                Text(t),
                Text(v,
                    style: const TextStyle(
                        fontSize: 26, fontWeight: FontWeight.bold))
              ]))));

  Widget _cardStream(String t, String col, IconData i) => StreamBuilder(
      stream: FirebaseFirestore.instance.collection(col).snapshots(),
      builder: (c, s) => _card(t, s.hasData ? '${s.data!.size}' : '—', i));
}
