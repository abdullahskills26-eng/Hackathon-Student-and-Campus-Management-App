import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  static final db = FirebaseFirestore.instance;
  static final auth = FirebaseAuth.instance;
  static final storage = FirebaseStorage.instance;

  static Stream<DocumentSnapshot<Map<String, dynamic>>> userDoc(String uid) =>
      db.collection('users').doc(uid).snapshots();

  static Future<void> ensureCoordinatorProfile(User user) async {
    final ref = db.collection('users').doc(user.uid);
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set({
        'name': 'Campus Coordinator — Lahore',
        'email': user.email ?? '',
        'phone': '',
        'role': 'coordinator',
        'city': 'Lahore',
        'campus': 'Lahore Campus',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
