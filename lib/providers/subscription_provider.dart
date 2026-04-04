import 'package:flutter/foundation.dart';
import '../models/subscription.dart';
import '../services/subscription_service.dart';

class SubscriptionProvider with ChangeNotifier {
  final SubscriptionService _subscriptionService = SubscriptionService();
  SubscriptionStatus _status = SubscriptionStatus(isPremium: false);
  bool _isLoading = false;

  SubscriptionStatus get status => _status;
  bool get isLoading => _isLoading;
  bool get isPremium => _status.isActive;

  SubscriptionProvider() {
    _initialize();
  }

  /// Initialize subscription provider
  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Init subscription service (RevenueCat)
      await _subscriptionService.initialize();

      // Load current status
      await refreshStatus();

      // Subscribe to status updates
      _subscriptionService.statusStream.listen((status) {
        _status = status;
        _updateOneSignalTags(status);
        notifyListeners();
      });
    } catch (e) {
      print('Ошибка инициализации SubscriptionProvider: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Set user ID for RevenueCat
  Future<void> setUserId(String userId) async {
    try {
      await _subscriptionService.setUserId(userId);
    } catch (e) {
      print('Ошибка установки User ID: $e');
    }
  }

  /// User logout from RevenueCat
  Future<void> logOut() async {
    try {
      await _subscriptionService.logOut();
      _status = SubscriptionStatus(isPremium: false);
      notifyListeners();
    } catch (e) {
      print('Ошибка выхода из RevenueCat: $e');
    }
  }

  /// Refresh subscription status
  Future<void> refreshStatus() async {
    try {
      _status = await _subscriptionService.getSubscriptionStatus();
      await _updateOneSignalTags(_status);
      notifyListeners();
    } catch (e) {
      print('Ошибка обновления статуса подписки: $e');
    }
  }

  /// Update OneSignal tags on subscription change
  Future<void> _updateOneSignalTags(SubscriptionStatus status) async {
    // Tags disabled — free OneSignal plan allows only 1 tag per user
    // Use External User ID (set on login) for user targeting instead
  }

  /// Check premium feature access
  bool hasAccessTo(String feature) {
    // If premium active, access to all features
    if (isPremium) return true;

    // List of free features
    final freeFeatures = [
      'test', // Psychological test
      'first_chat', // First chat session
    ];

    return freeFeatures.contains(feature);
  }

  /// Get remaining subscription days
  int? getDaysRemaining() {
    if (!isPremium || _status.expirationDate == null) return null;

    final now = DateTime.now();
    final remaining = _status.expirationDate!.difference(now);

    return remaining.inDays;
  }

  /// Cancel subscription (clear local status for testing)
  Future<void> cancelSubscription() async {
    await _subscriptionService.clearSubscriptionStatus();
    _status = SubscriptionStatus(isPremium: false);
    notifyListeners();
  }

  @override
  void dispose() {
    _subscriptionService.dispose();
    super.dispose();
  }
}
