import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/firestore_collections.dart';
import '../../../core/utils/state_renderers.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/custom_textfield.dart';
import '../../../services/firestore_service.dart';

/// Shared profile screen.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();

  late Future<Map<String, dynamic>> _future;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _load() async {
    final uid = FirebaseService.currentUid;
    final doc = await FirebaseFirestore.instance
        .collection(FirestoreCollections.users)
        .doc(uid)
        .get();
    final data = doc.data() ?? {};
    _name.text = (data['name'] ?? '').toString();
    _phone.text = (data['phone'] ?? '').toString();
    return {...data, 'uid': uid};
  }

  void _reload() => setState(() => _future = _load());

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance
          .collection(FirestoreCollections.users)
          .doc(FirebaseService.currentUid)
          .set({'name': _name.text.trim(), 'phone': _phone.text.trim()},
              SetOptions(merge: true));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not save: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.popUntil(context, (r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const LoadingState(message: 'Loading profile…');
            }
            if (snap.hasError) {
              return ErrorRetry(
                  message: snap.error.toString(), onRetry: _reload);
            }

            final data = snap.data!;
            final name = _name.text.isEmpty ? 'Your profile' : _name.text;
            final email = (data['email'] ??
                    FirebaseAuth.instance.currentUser?.email ??
                    '')
                .toString();

            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    AccentCard(
                      accent: AppColors.primary,
                      accentSoft: AppColors.primarySoft,
                      padding: const EdgeInsets.all(22),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.15),
                            foregroundImage:
                                (data['photoUrl'] ?? '').toString().isEmpty
                                    ? null
                                    : NetworkImage(
                                        data['photoUrl'].toString()),
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : '?',
                              style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 24),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(fontSize: 20)),
                                const SizedBox(height: 3),
                                Text(email,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall),
                                if ((data['role'] ?? '')
                                    .toString()
                                    .isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(
                                          AppColors.radiusPill),
                                    ),
                                    child: Text(
                                      data['role'].toString().toUpperCase(),
                                      style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.primary),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    CustomCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Edit details',
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _name,
                            label: 'Name',
                            prefixIcon: Icons.person_outline,
                            textCapitalization: TextCapitalization.words,
                          ),
                          const SizedBox(height: 14),
                          CustomTextField(
                            controller: _phone,
                            label: 'Phone',
                            prefixIcon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 18),
                          CustomButton(
                            label: 'Save profile',
                            icon: Icons.save_outlined,
                            expand: true,
                            isLoading: _saving,
                            onPressed: _save,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    CustomCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Campus',
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 14),
                          _Row(
                              label: 'City',
                              value: (data['city'] ?? '—').toString()),
                          _Row(
                              label: 'Campus',
                              value: (data['campus'] ??
                                      data['campusName'] ??
                                      '—')
                                  .toString()),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    CustomButton.outlined(
                      label: 'Log out',
                      icon: Icons.logout,
                      expand: true,
                      onPressed: _logout,
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child:
                Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13.5)),
        ],
      ),
    );
  }
}
