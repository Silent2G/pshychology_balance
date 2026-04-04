import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart' as functions;
import 'dart:math';

class PasswordRecoveryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final functions.FirebaseFunctions _functions = functions.FirebaseFunctions.instance;

  // Generate 4-digit code
  String _generateCode() {
    final random = Random();
    return (1000 + random.nextInt(9000)).toString(); // Generates number from 1000 to 9999
  }

  // Send password recovery link to email (Firebase standard method)
  Future<void> sendRecoveryCode(String email) async {
    try {
      // Use Firebase standard method for password recovery link
      // Firebase will check user existence and return error if not found
      // Remove actionCodeSettings to use standard Firebase link
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      if (e is FirebaseAuthException) {
        throw _handleAuthException(e);
      }
      rethrow;
    }
  }

  // Verify recovery code
  Future<bool> verifyRecoveryCode(String email, String code) async {
    try {
      final doc = await _firestore.collection('passwordRecoveryCodes').doc(email).get();

      if (!doc.exists) {
        throw Exception('Код не знайдено або застарів');
      }

      final data = doc.data()!;
      final storedCode = data['code'] as String;
      final expiresAt = DateTime.fromMillisecondsSinceEpoch(data['expiresAt'] as int);
      final used = data['used'] as bool;

      // Check if code was used
      if (used) {
        throw Exception('Цей код вже було використано');
      }

      // Check expiration
      if (DateTime.now().isAfter(expiresAt)) {
        throw Exception('Код застарів. Запросіть новий код');
      }

      // Verify code
      if (storedCode != code) {
        throw Exception('Невірний код підтвердження');
      }

      return true;
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Помилка перевірки коду: ${e.toString()}');
    }
  }

  // Mark code as used
  Future<void> markCodeAsUsed(String email) async {
    await _firestore.collection('passwordRecoveryCodes').doc(email).update({
      'used': true,
    });
  }

  // Change password after successful code verification
  // Uses action code for password change
  Future<void> changePassword(String email, String newPassword, String actionCode) async {
    try {
      // Verify code again before password change
      final doc = await _firestore.collection('passwordRecoveryCodes').doc(email).get();
      if (!doc.exists) {
        throw Exception('Сесія відновлення пароля не знайдена');
      }

      final data = doc.data()!;
      final used = data['used'] as bool;
      if (used) {
        throw Exception('Сесія відновлення пароля вже використана');
      }

      // Confirm password change with action code
      await _auth.confirmPasswordReset(code: actionCode, newPassword: newPassword);
      
      // Mark code as used
      await markCodeAsUsed(email);
    } catch (e) {
      if (e is FirebaseAuthException) {
        throw _handleAuthException(e);
      }
      rethrow;
    }
  }

  // Alternative: change password via temporary sign-in
  // Requires user to be temporarily signed in
  Future<void> changePasswordWithAuth(String email, String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email != email) {
        throw Exception('Потрібна авторизація для зміни пароля');
      }

      await user.updatePassword(newPassword);
      
      // Mark code as used
      await markCodeAsUsed(email);
    } catch (e) {
      if (e is FirebaseAuthException) {
        throw _handleAuthException(e);
      }
      rethrow;
    }
  }

  // Resend code
  Future<void> resendRecoveryCode(String email) async {
    // Remove old code
    await _firestore.collection('passwordRecoveryCodes').doc(email).delete();
    // Send new code
    await sendRecoveryCode(email);
    
    // Call Cloud Function for resend
    try {
      final callable = _functions.httpsCallable('resendPasswordRecoveryCode');
      await callable.call({'email': email});
    } catch (e) {
      // If Cloud Function not configured, just continue
      print('⚠️ Cloud Function для повторной відправки не налаштована');
    }
  }

  // Change password via Cloud Function
  Future<void> changePasswordViaCloudFunction(String email, String code, String newPassword) async {
    try {
      final callable = _functions.httpsCallable('changePasswordAfterVerification');
      final result = await callable.call({
        'email': email,
        'code': code,
        'newPassword': newPassword,
      });
      
      if (result.data['success'] == true) {
        return;
      } else {
        throw Exception(result.data['message'] ?? 'Помилка зміни пароля');
      }
    } catch (e) {
      if (e is FirebaseException) {
        final code = e.code;
        if (code == 'permission-denied') {
          throw Exception('Невірний код підтвердження');
        } else if (code == 'deadline-exceeded') {
          throw Exception('Код застарів. Запросіть новий код');
        } else if (code == 'failed-precondition') {
          throw Exception('Цей код вже було використано');
        } else if (code == 'not-found') {
          throw Exception('Код відновлення не знайдено');
        } else if (code == 'invalid-argument') {
          throw Exception('Невірні дані для зміни пароля');
        }
      }
      rethrow;
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Користувача з таким email не знайдено';
      case 'invalid-email':
        return 'Невірний формат email';
      case 'too-many-requests':
        return 'Занадто багато спроб. Спробуйте пізніше';
      default:
        return 'Сталася помилка: ${e.message}';
    }
  }
}

