import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../core/constants/firestore_collections.dart';
import '../models/application_model.dart';
import '../models/assignment_model.dart';
import '../models/attendance_model.dart';
import '../models/campus_model.dart';
import '../models/career_checklist_model.dart';
import '../models/course_model.dart';
import '../models/submission_model.dart';

typedef DocMap = Map<String, dynamic>;

/// Firestore, Auth and Storage handles plus the queries the app needs.
class FirebaseService {
  static final db = FirebaseFirestore.instance;
  static final auth = FirebaseAuth.instance;
  static final storage = FirebaseStorage.instance;

  /// The signed-in user's uid, or the demo student uid when running
  /// unauthenticated so the student screens still have something to read.
  static String get currentUid =>
      auth.currentUser?.uid ?? 'demo_flutter_student_1';

  static Stream<DocumentSnapshot<DocMap>> userDoc(String uid) =>
      db.collection(FirestoreCollections.users).doc(uid).snapshots();

  static Future<void> ensureCoordinatorProfile(User user) async {
    final ref = db.collection(FirestoreCollections.users).doc(user.uid);
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

  // ------------------------------------------------------------- Courses

  static Future<List<CourseModel>> fetchCourses() async {
    final snap = await db.collection(FirestoreCollections.courses).get();
    return snap.docs.map(CourseModel.fromDoc).toList();
  }

  static Future<CourseModel?> fetchCourse(String courseId) async {
    final doc =
        await db.collection(FirestoreCollections.courses).doc(courseId).get();
    return doc.exists ? CourseModel.fromDoc(doc) : null;
  }

  // ------------------------------------------------------------- Campuses

  static Future<List<CampusModel>> fetchCampuses() async {
    final snap = await db.collection(FirestoreCollections.campuses).get();
    return snap.docs.map(CampusModel.fromDoc).toList();
  }

  // --------------------------------------------------------- Applications

  static Future<String> submitApplication(ApplicationModel application) async {
    final ref = await db
        .collection(FirestoreCollections.applications)
        .add(application.toMap());
    return ref.id;
  }

  /// Applications for one student, newest first.
  ///
  /// Ordering is done client-side: a `where` + `orderBy` on different fields
  /// needs a composite index, which a fresh Firebase project will not have.
  static Stream<List<ApplicationModel>> watchApplications(String uid) {
    return db
        .collection(FirestoreCollections.applications)
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map(ApplicationModel.fromDoc).toList();
      list.sort((a, b) {
        final at = a.createdAt, bt = b.createdAt;
        if (at == null && bt == null) return 0;
        if (at == null) return 1;
        if (bt == null) return -1;
        return bt.compareTo(at);
      });
      return list;
    });
  }

  // ------------------------------------------------------------- Batches

  static Future<DocMap?> fetchBatch(String batchId) async {
    final doc =
        await db.collection(FirestoreCollections.batches).doc(batchId).get();
    return doc.data();
  }

  /// The batch the student is enrolled in, read from `users/{uid}.batchId`.
  static Future<DocMap?> fetchStudentBatch(String uid) async {
    final user =
        await db.collection(FirestoreCollections.users).doc(uid).get();
    final batchId = user.data()?['batchId']?.toString();
    if (batchId == null || batchId.isEmpty) return null;
    final batch = await fetchBatch(batchId);
    if (batch == null) return null;
    return {...batch, 'batchId': batchId};
  }

  // ---------------------------------------------------------- Attendance

  static Future<List<AttendanceModel>> fetchAttendance(String uid) async {
    final snap = await db
        .collection(FirestoreCollections.attendance)
        .where('uid', isEqualTo: uid)
        .get();
    final list = snap.docs.map(AttendanceModel.fromDoc).toList();
    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  // --------------------------------------------------------- Assignments

  static Future<List<AssignmentModel>> fetchAssignments({
    String? batchId,
  }) async {
    Query<DocMap> query = db.collection(FirestoreCollections.assignments);
    if (batchId != null && batchId.isNotEmpty) {
      query = query.where('batchId', isEqualTo: batchId);
    }
    final snap = await query.get();
    return snap.docs
        .map((d) => AssignmentModel.fromMap(d.data(), d.id))
        .toList();
  }

  // --------------------------------------------------------- Submissions

  static Future<List<SubmissionModel>> fetchSubmissions(String uid) async {
    final snap = await db
        .collection(FirestoreCollections.submissions)
        .where('uid', isEqualTo: uid)
        .get();
    return snap.docs.map(SubmissionModel.fromDoc).toList();
  }

  /// Creates or replaces the submission for one assignment.
  ///
  /// The document id is `{assignmentId}_{uid}`, which makes re-submitting
  /// idempotent instead of piling up duplicates.
  static Future<void> saveSubmission(SubmissionModel submission) async {
    final id = '${submission.assignmentId}_${submission.uid}';
    await db
        .collection(FirestoreCollections.submissions)
        .doc(id)
        .set(submission.toMap(), SetOptions(merge: true));
  }

  // -------------------------------------------------------------- Notices

  static Future<List<DocMap>> fetchNotices({int limit = 5}) async {
    final snap = await db
        .collection(FirestoreCollections.notices)
        .limit(limit)
        .get();
    return snap.docs.map((d) => {...d.data(), 'id': d.id}).toList();
  }

  // ---------------------------------------------------- Career checklist

  static Future<CareerChecklistModel> fetchCareerChecklist(String uid) async {
    final doc =
        await db.collection(FirestoreCollections.users).doc(uid).get();
    final raw = doc.data()?['careerChecklist'];
    return CareerChecklistModel.fromMap(
        raw is Map ? Map<String, dynamic>.from(raw) : null);
  }

  static Future<void> saveCareerChecklist(
    String uid,
    CareerChecklistModel checklist,
  ) async {
    await db.collection(FirestoreCollections.users).doc(uid).set(
      {'careerChecklist': checklist.toMap()},
      SetOptions(merge: true),
    );
  }
}
