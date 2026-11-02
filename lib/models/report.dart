import 'package:cloud_firestore/cloud_firestore.dart';

class Report {
  final String? id;
  final String imageUrl;
  final double lat;
  final double long;
  final String issueType;
  final String severity;
  final String status;
  final String userId;
  final DateTime timestamp;

  Report({
    this.id,
    required this.imageUrl,
    required this.lat,
    required this.long,
    required this.issueType,
    required this.severity,
    required this.status,
    required this.userId,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'lat': lat,
      'long': long,
      'issueType': issueType,
      'severity': severity,
      'status': status,
      'userId': userId,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory Report.fromMap(Map<String, dynamic> map, String id) {
    return Report(
      id: id,
      imageUrl: map['imageUrl'] as String,
      lat: (map['lat'] as num).toDouble(),
      long: (map['long'] as num).toDouble(),
      issueType: map['issueType'] as String,
      severity: map['severity'] as String,
      status: map['status'] as String,
      userId: map['userId'] as String,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}
