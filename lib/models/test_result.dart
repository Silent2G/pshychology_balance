import 'package:cloud_firestore/cloud_firestore.dart';

class TestResult {
  final String id;
  final String userId;
  final String psychotype;
  final String description;
  final List<String> recommendations;
  final List<int> answers;
  final DateTime createdAt;

  TestResult({
    required this.id,
    required this.userId,
    required this.psychotype,
    required this.description,
    required this.recommendations,
    required this.answers,
    required this.createdAt,
  });

  factory TestResult.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      return DateTime.now();
    }

    return TestResult(
      id: doc.id,
      userId: data['userId'] ?? '',
      psychotype: data['psychotype'] ?? '',
      description: data['description'] ?? '',
      recommendations: List<String>.from(data['recommendations'] ?? []),
      answers: List<int>.from(data['answers'] ?? []),
      createdAt: parseDateTime(data['createdAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'psychotype': psychotype,
      'description': description,
      'recommendations': recommendations,
      'answers': answers,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}
