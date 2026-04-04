import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_session.dart';
import '../models/test_result.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============ Chat Sessions ============

  // Create new chat session
  Future<String> createChatSession(String userId, String title) async {
    print('Creating chat session for user: $userId');
    try {
      final now = DateTime.now().millisecondsSinceEpoch;

      // Create document with explicit ID
      final docRef = _firestore.collection('chatSessions').doc();
      final sessionId = docRef.id;
      print('Generated session ID: $sessionId');

      print('Setting document data...');
      await docRef
          .set({
            'userId': userId,
            'title': title,
            'createdAt': now,
            'updatedAt': now,
            'isCompleted': false,
            'messages': [],
          })
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              print('TIMEOUT: Firestore set operation took too long');
              throw Exception('Firestore timeout');
            },
          );

      print('Chat session created with ID: $sessionId');

      // Verify document was actually created
      print('Verifying document...');
      final doc = await docRef.get();
      print('Document exists: ${doc.exists}');
      print('Document data: ${doc.data()}');

      return sessionId;
    } catch (e) {
      print('ERROR creating chat session: $e');
      print('Error type: ${e.runtimeType}');
      rethrow;
    }
  }

  // Add message to chat
  Future<void> addMessageToChat(String sessionId, ChatMessage message) async {
    try {
      final messageText = message.text.length > 50 ? message.text.substring(0, 50) : message.text;
      print('Saving message to session $sessionId: $messageText...');

      final now = DateTime.now().millisecondsSinceEpoch;
      await _firestore.collection('chatSessions').doc(sessionId).update({
        'messages': FieldValue.arrayUnion([message.toMap()]),
        'updatedAt': now,
      });
      print('Message saved successfully');
    } catch (e) {
      print('Error saving message: $e');
      rethrow;
    }
  }

  // Update chat session title
  Future<void> updateChatSessionTitle(String sessionId, String title) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      await _firestore.collection('chatSessions').doc(sessionId).update({
        'title': title,
        'updatedAt': now,
      });
      print('Chat session title updated: $title');
    } catch (e) {
      print('Error updating chat session title: $e');
      rethrow;
    }
  }

  // Complete chat session
  Future<void> completeChatSession(String sessionId) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _firestore.collection('chatSessions').doc(sessionId).update({'isCompleted': true, 'updatedAt': now});
  }

  // Get all user chat sessions
  Stream<List<ChatSession>> getUserChatSessions(String userId) {
    return _firestore.collection('chatSessions').where('userId', isEqualTo: userId).snapshots().map((snapshot) {
      print('getUserChatSessions: found ${snapshot.docs.length} sessions');
      final sessions = snapshot.docs.map((doc) => ChatSession.fromFirestore(doc)).toList();
      // Sort locally by updatedAt
      sessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return sessions;
    });
  }

  // Get all sessions (for debugging)
  Future<void> debugPrintAllSessions() async {
    try {
      final snapshot = await _firestore.collection('chatSessions').get();
      print('=== ALL SESSIONS IN FIRESTORE ===');
      print('Total sessions: ${snapshot.docs.length}');
      for (var doc in snapshot.docs) {
        print('Session ID: ${doc.id}');
        print('Data: ${doc.data()}');
        print('---');
      }
    } catch (e) {
      print('Error getting all sessions: $e');
    }
  }

  // Get specific chat session
  Future<ChatSession?> getChatSession(String sessionId) async {
    final doc = await _firestore.collection('chatSessions').doc(sessionId).get();
    if (doc.exists) {
      return ChatSession.fromFirestore(doc);
    }
    return null;
  }

  // Get all user messages from all sessions (for AI context)
  Future<List<ChatMessage>> getAllUserMessages(String userId) async {
    try {
      // Get all user sessions without orderBy (to avoid index issues)
      final snapshot = await _firestore
          .collection('chatSessions')
          .where('userId', isEqualTo: userId)
          .get();

      final allMessages = <ChatMessage>[];
      final sessions = <ChatSession>[];
      
      // Convert documents to sessions
      for (var doc in snapshot.docs) {
        sessions.add(ChatSession.fromFirestore(doc));
      }
      
      // Sort sessions by creation date (oldest first)
      sessions.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      
      // Collect all messages in chronological order
      for (var session in sessions) {
        allMessages.addAll(session.messages);
      }

      print('Loaded ${allMessages.length} messages from ${sessions.length} sessions for user $userId');
      return allMessages;
    } catch (e) {
      print('Error loading all user messages: $e');
      return [];
    }
  }

  // Delete chat session
  Future<void> deleteChatSession(String sessionId) async {
    await _firestore.collection('chatSessions').doc(sessionId).delete();
  }

  // ============ Test Results ============

  // Save test result
  Future<String> saveTestResult(
    String userId,
    String psychotype,
    String description,
    List<String> recommendations,
    List<int> answers,
  ) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final docRef = await _firestore.collection('testResults').add({
      'userId': userId,
      'psychotype': psychotype,
      'description': description,
      'recommendations': recommendations,
      'answers': answers,
      'createdAt': now,
    });
    return docRef.id;
  }

  // Get all user test results
  Stream<List<TestResult>> getUserTestResults(String userId) {
    return _firestore
        .collection('testResults')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final results = snapshot.docs.map((doc) => TestResult.fromFirestore(doc)).toList();
          // Sort on client to avoid index requirement
          results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return results;
        });
  }

  // Get specific test result
  Future<TestResult?> getTestResult(String testId) async {
    final doc = await _firestore.collection('testResults').doc(testId).get();
    if (doc.exists) {
      return TestResult.fromFirestore(doc);
    }
    return null;
  }

  // Delete test result
  Future<void> deleteTestResult(String testId) async {
    await _firestore.collection('testResults').doc(testId).delete();
  }

  // ============ Statistics ============

  // Get completed tests count
  Future<int> getCompletedTestsCount(String userId) async {
    final snapshot = await _firestore.collection('testResults').where('userId', isEqualTo: userId).get();
    return snapshot.docs.length;
  }

  // Get saved sessions count
  Future<int> getSavedSessionsCount(String userId) async {
    final snapshot = await _firestore.collection('chatSessions').where('userId', isEqualTo: userId).get();
    return snapshot.docs.length;
  }

  // Get days of usage (from first session date)
  Future<int> getDaysOfUsage(String userId) async {
    try {
      final chatSnapshot = await _firestore
          .collection('chatSessions')
          .where('userId', isEqualTo: userId)
          .get();

      if (chatSnapshot.docs.isEmpty) return 0;

      DateTime? firstDate;
      for (final doc in chatSnapshot.docs) {
        final raw = doc.data()['createdAt'];
        final dt = raw == null
            ? null
            : raw is Timestamp
                ? raw.toDate()
                : raw is int
                    ? DateTime.fromMillisecondsSinceEpoch(raw)
                    : null;
        if (dt != null && (firstDate == null || dt.isBefore(firstDate))) {
          firstDate = dt;
        }
      }
      if (firstDate == null) return 0;

      final daysDiff = DateTime.now().difference(firstDate).inDays;
      return daysDiff + 1;
    } catch (e) {
      print('getDaysOfUsage error: $e');
      return 0;
    }
  }
}
