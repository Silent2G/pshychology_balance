import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/onesignal_service.dart';
import '../services/subscription_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final OneSignalService _oneSignalService = OneSignalService();
  final SubscriptionService _subscriptionService = SubscriptionService();
  User? _user;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    // Init will be called via initializeAfterFirebase()
  }

  void _init() {
    // Get current user synchronously
    _user = _authService.currentUser;
    _isInitialized = true;
    notifyListeners();

    // Sync user data with external services if present
    if (_user != null) {
      _syncUserWithServices(_user!);
    }

    // Listen to auth state changes
    _authService.authStateChanges.listen((User? user) {
      _user = user;

      // Sync user data with external services
      if (user != null) {
        _syncUserWithServices(user);
      } else {
        _clearUserFromServices();
      }

      notifyListeners();
    });
  }

  /// Sync user data with OneSignal and RevenueCat
  Future<void> _syncUserWithServices(User user) async {
    try {
      // Set User ID in OneSignal
      await _oneSignalService.setExternalUserId(user.uid);

      // Set User ID in RevenueCat
      await _subscriptionService.setUserId(user.uid);

      // Set email in OneSignal if available
      if (user.email != null) {
        await _oneSignalService.setEmail(user.email!);
      }

      print('✅ Данные пользователя синхронизированы с OneSignal и RevenueCat');
    } catch (e) {
      print('❌ Ошибка синхронизации пользователя с сервисами: $e');
    }
  }

  /// Clear user data from external services
  Future<void> _clearUserFromServices() async {
    try {
      await _oneSignalService.removeExternalUserId();
      await _subscriptionService.logOut();
      print('✅ Данные пользователя очищены из внешних сервисов');
    } catch (e) {
      print('❌ Ошибка очистки данных пользователя: $e');
    }
  }

  // Method for init after Firebase init
  void initializeAfterFirebase() {
    _init();
  }

  // Register with email and password
  Future<bool> signUpWithEmailAndPassword({required String email, required String password}) async {
    try {
      _setLoading(true);
      _clearError();

      final result = await _authService.signUpWithEmailAndPassword(email: email, password: password);

      if (result != null) {
        _user = result.user;
        if (_user != null) {
          await _syncUserWithServices(_user!);
        }
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with email and password
  Future<bool> signInWithEmailAndPassword({required String email, required String password}) async {
    try {
      _setLoading(true);
      _clearError();

      final result = await _authService.signInWithEmailAndPassword(email: email, password: password);

      if (result != null) {
        _user = result.user;
        if (_user != null) {
          await _syncUserWithServices(_user!);
        }
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      _clearError();

      final result = await _authService.signInWithGoogle();

      if (result != null) {
        _user = result.user;
        if (_user != null) {
          await _syncUserWithServices(_user!);
        }
        return true;
      }
      // User cancelled, don't show error
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with Apple
  Future<bool> signInWithApple() async {
    try {
      _setLoading(true);
      _clearError();

      final result = await _authService.signInWithApple();

      if (result != null) {
        _user = result.user;
        if (_user != null) {
          await _syncUserWithServices(_user!);
        }
        return true;
      }
      // User cancelled, don't show error
      return false;
    } catch (e) {
      // Remove "Exception: " prefix from error message
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }
      _setError(errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _setLoading(true);
      _clearError();

      await _clearUserFromServices();
      await _authService.signOut();
      _user = null;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Password reset
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.resetPassword(email);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}
