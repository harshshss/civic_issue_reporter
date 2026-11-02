import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/report.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Submit a new report
  Future<void> submitReport(Report report) async {
    try {
      await _firestore.collection('reports').add(report.toMap());
      
      // Update user karma points
      await _updateUserKarma(report.userId, 10); // Add 10 points per report
    } catch (e) {
      print('Error submitting report: $e');
      rethrow;
    }
  }

  // Get all reports
  Stream<List<Report>> getReports() {
    return _firestore
        .collection('reports')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Report.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Get reports by user
  Stream<List<Report>> getUserReports(String userId) {
    return _firestore
        .collection('reports')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Report.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Update report status
  Future<void> updateReportStatus(String reportId, String status) async {
    try {
      await _firestore.collection('reports').doc(reportId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating report status: $e');
      rethrow;
    }
  }

  // Get user data
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Update user karma points
  Future<void> _updateUserKarma(String userId, int points) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'karmaPoints': FieldValue.increment(points),
      });
    } catch (e) {
      print('Error updating karma points: $e');
    }
  }

  // Get leaderboard (top users by karma)
  Future<List<Map<String, dynamic>>> getLeaderboard({int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('karmaPoints', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error getting leaderboard: $e');
      return [];
    }
  }
}
