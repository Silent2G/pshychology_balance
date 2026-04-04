import 'package:cloud_firestore/cloud_firestore.dart';

class ChatSession {
  final String id;
  final String userId;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isCompleted;
  final List<ChatMessage> messages;

  ChatSession({
    required this.id,
    required this.userId,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.isCompleted,
    required this.messages,
  });

  factory ChatSession.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      return DateTime.now();
    }

    return ChatSession(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? 'Чат',
      createdAt: parseDateTime(data['createdAt']),
      updatedAt: parseDateTime(data['updatedAt']),
      isCompleted: data['isCompleted'] ?? false,
      messages:
          (data['messages'] as List<dynamic>?)?.map((m) => ChatMessage.fromMap(m as Map<String, dynamic>)).toList() ??
          [],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isCompleted': isCompleted,
      'messages': messages.map((m) => m.toMap()).toList(),
    };
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? imagePath;
  final String? audioPath;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.imagePath,
    this.audioPath,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      return DateTime.now();
    }

    return ChatMessage(
      text: map['text'] ?? '',
      isUser: map['isUser'] ?? false,
      timestamp: parseDateTime(map['timestamp']),
      imagePath: map['imagePath'] as String?,
      audioPath: map['audioPath'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.millisecondsSinceEpoch,
      if (imagePath != null) 'imagePath': imagePath,
      if (audioPath != null) 'audioPath': audioPath,
    };
  }
}
