import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/widgets/app_shell.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _S();
}

class _S extends State<ProfileScreen> {
  final name = TextEditingController();
  final phone = TextEditingController();
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final u = FirebaseAuth.instance.currentUser;
    if (u != null) {
      final d =
          await FirebaseFirestore.instance.collection('users').doc(u.uid).get();
      name.text = d.data()?['name'] ?? '';
      phone.text = d.data()?['phone'] ?? '';
    }
    if (mounted) setState(() => loading = false);
  }

  Future<void> save() async {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(u.uid)
        .set({'name': name.text, 'phone': phone.text}, SetOptions(merge: true));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully.')));
    }
  }

  @override
  Widget build(BuildContext context) => AppShell(
      child: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: ListView(children: [
                const Text('Profile',
                    style:
                        TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextField(
                    controller: name,
                    decoration: const InputDecoration(
                        labelText: 'Name', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                Text('Email: ${FirebaseAuth.instance.currentUser?.email ?? ''}'),
                const SizedBox(height: 12),
                TextField(
                    controller: phone,
                    decoration: const InputDecoration(
                        labelText: 'Phone', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                const Text('City: Lahore'),
                const Text('Campus: Lahore Campus'),
                const SizedBox(height: 20),
                FilledButton(
                    onPressed: save, child: const Text('Save Profile')),
                const SizedBox(height: 10),
                OutlinedButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) {
                        Navigator.popUntil(context, (r) => r.isFirst);
                      }
                    },
                    child: const Text('Logout'))
              ])));
}
