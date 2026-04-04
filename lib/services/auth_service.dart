import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import '../firebase_options.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  bool _googleSignInInitialized = false;

  Future<void> _ensureGoogleSignInInitialized() async {
    if (_googleSignInInitialized) return;
    await GoogleSignIn.instance.initialize(
      serverClientId: defaultTargetPlatform == TargetPlatform.iOS
          ? DefaultFirebaseOptions.ios.iosClientId
          : null,
    );
    _googleSignInInitialized = true;
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state change stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register with email and password
  Future<UserCredential?> signUpWithEmailAndPassword({required String email, required String password}) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await _analytics.logSignUp(signUpMethod: 'email');
      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword({required String email, required String password}) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      await _analytics.logLogin(loginMethod: 'email');
      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      await _ensureGoogleSignInInitialized();
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      final authorization = await account.authorizationClient
          .authorizationForScopes(['email', 'profile']);
      final credential = GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: authorization?.accessToken,
      );
      final result = await _auth.signInWithCredential(credential);
      await _analytics.logLogin(loginMethod: 'google');
      return result;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        print('ℹ️ Пользователь отменил вход через Google');
        return null;
      }
      print('❌ Ошибка входа через Google: $e');
      throw Exception('Помилка входу через Google');
    } catch (e) {
      print('❌ Ошибка входа через Google: $e');
      throw Exception('Помилка входу через Google');
    }
  }

  // Sign in with Apple
  Future<UserCredential?> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
      );

      // Check identityToken presence
      if (credential.identityToken == null) {
        print('❌ Ошибка: identityToken отсутствует');
        throw Exception('Не вдалося отримати токен авторизації від Apple');
      }

      final oauthCredential = OAuthProvider(
        "apple.com",
      ).credential(idToken: credential.identityToken, accessToken: credential.authorizationCode);

      final result = await _auth.signInWithCredential(oauthCredential);
      await _analytics.logLogin(loginMethod: 'apple');
      return result;
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        print('ℹ️ Пользователь отменил вход через Apple');
        return null;
      }
      print('❌ Ошибка авторизации Apple: ${e.code} - ${e.message}');
      throw Exception('Помилка авторизації Apple: ${e.message}');
    } on FirebaseAuthException catch (e) {
      print('❌ Ошибка Firebase при входе через Apple: ${e.code} - ${e.message}');
      throw Exception(_handleAuthException(e));
    } catch (e) {
      print('❌ Неожиданная ошибка входа через Apple: $e');
      throw Exception('Помилка входу через Apple: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([_auth.signOut(), GoogleSignIn.instance.signOut()]);
    } catch (e) {
      print('❌ Ошибка выхода: $e');
      throw Exception('Помилка виходу');
    }
  }

  // Password reset
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Firebase Auth error handling
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Користувача з таким email не знайдено';
      case 'wrong-password':
        return 'Невірний пароль';
      case 'email-already-in-use':
        return 'Користувач з таким email вже існує';
      case 'weak-password':
        return 'Пароль занадто слабкий';
      case 'invalid-email':
        return 'Невірний формат email';
      case 'user-disabled':
        return 'Акаунт заблоковано';
      case 'too-many-requests':
        return 'Занадто багато спроб. Спробуйте пізніше';
      case 'operation-not-allowed':
        return 'Операція не дозволена';
      default:
        return 'Сталася помилка авторизації';
    }
  }
}
