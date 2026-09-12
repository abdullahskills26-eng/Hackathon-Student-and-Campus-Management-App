import 'package:cloud_firestore/cloud_firestore.dart';

class SeedService {
  static final db = FirebaseFirestore.instance;

  static Future<void> seed() async {
    final batch = db.batch();
    final now = FieldValue.serverTimestamp();

    final courses = [
      ['Flutter Development', 'Beginner', '6 Months', 'Mobile app development'],
      ['Web Development', 'Beginner', '6 Months', 'Modern web development'],
      ['Cybersecurity', 'Intermediate', '6 Months', 'Cybersecurity fundamentals'],
      ['Digital Marketing', 'Beginner', '6 Months', 'Digital marketing skills'],
      ['Graphic Design', 'Beginner', '6 Months', 'Graphic design fundamentals'],
      ['UI/UX Design', 'Intermediate', '6 Months', 'UI and UX design'],
    ];
    for (final c in courses) {
      final r = db.collection('courses').doc();
      batch.set(r, {
        'name': c[0],
        'level': c[1],
        'duration': c[2],
        'description': c[3],
        'seatsAvailable': 30,
        'createdAt': now
      });
    }

    final campuses = [
      'Lahore Campus',
      'Islamabad Campus',
      'Rawalpindi Campus',
      'Multan Campus',
      'Faisalabad Campus',
      'Karachi Campus',
      'Peshawar Campus',
      'Quetta Campus'
    ];
    for (final c in campuses) {
      final r = db.collection('campuses').doc();
      batch.set(r, {
        'name': c,
        'city': c.replaceAll(' Campus', ''),
        'region': 'Pakistan',
        'createdAt': now
      });
    }

    final batchRef = db.collection('batches').doc('FL-2026-01');
    batch.set(batchRef, {
      'batchId': 'FL-2026-01',
      'courseName': 'Flutter Development',
      'campus': 'Lahore Campus',
      'seats': 30,
      'startDate': '2026-10-15',
      'instructorName': 'Sir Hamza',
      'status': 'Open',
      'createdAt': now
    });

    final statuses = [
      'Submitted',
      'Under Review',
      'Interview / Test',
      'Accepted',
      'Rejected'
    ];
    for (int i = 0; i < 5; i++) {
      final r = db.collection('applications').doc('demo_application_${i + 1}');
      batch.set(r, {
        'fullName': 'Demo Student ${i + 1}',
        'cnic': '35202-000000${i + 1}-0',
        'education': 'BS Computer Science',
        'city': 'Lahore',
        'selectedCourse': 'Flutter Development',
        'preferredCampus': 'Lahore Campus',
        'motivation': 'I want to learn IT skills and become job-ready.',
        'status': statuses[i],
        'rejectionReason': i == 4 ? 'Course seats are currently full.' : '',
        'createdAt': now
      });
    }

    for (int i = 1; i <= 12; i++) {
      final r = db.collection('users').doc('demo_flutter_student_$i');
      batch.set(r, {
        'name': 'Flutter Student $i',
        'email': 'student$i@skillbridge.org',
        'phone': '030000000$i',
        'role': 'student',
        'city': 'Lahore',
        'campus': 'Lahore Campus',
        'batchId': 'FL-2026-01',
        'createdAt': now
      });
    }

    final assignmentStatuses = ['Pending', 'Pending', 'Submitted', 'Marked'];
    for (int i = 1; i <= 4; i++) {
      final r = db.collection('assignments').doc('demo_assignment_$i');
      batch.set(r, {
        'title': 'Flutter Assignment $i',
        'dueDate': '2026-10-${10 + i}',
        'maximumMarks': 20,
        'instructions': 'Complete the assigned Flutter task.',
        'status': assignmentStatuses[i - 1],
        'batchId': 'FL-2026-01',
        'createdAt': now
      });
    }

    await batch.commit();
  }
}
