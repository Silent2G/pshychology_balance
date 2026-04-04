import 'package:onesignal_flutter/onesignal_flutter.dart';

class OneSignalService {
  static final OneSignalService _instance = OneSignalService._internal();
  factory OneSignalService() => _instance;
  OneSignalService._internal();

  bool _initialized = false;

  /// Initialize OneSignal
  Future<void> initialize() async {
    if (_initialized) {
      print('⚠️ OneSignal уже инициализирован');
      return;
    }

    try {
      // IMPORTANT: Replace with your OneSignal App ID from Dashboard
      const oneSignalAppId = '249f56d5-f421-4c32-9aa3-4256055a3dee';

      // OneSignal initialization
      OneSignal.initialize(oneSignalAppId);

      // Request notification permission
      await OneSignal.Notifications.requestPermission(true);

      print('✅ OneSignal инициализирован');
      _initialized = true;

      // Setup notification handlers
      _setupNotificationHandlers();
    } catch (e) {
      print('❌ Ошибка инициализации OneSignal: $e');
    }
  }

  /// Setup notification handlers
  void _setupNotificationHandlers() {
    // Handle notification open
    OneSignal.Notifications.addClickListener((event) {
      print('🔔 Уведомление открыто: ${event.notification.notificationId}');
      _handleNotificationOpened(event);
    });

    // Handle notification received in foreground
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      print('🔔 Получено уведомление в foreground: ${event.notification.notificationId}');
      // Show notification by default
      event.notification.display();
    });
  }

  /// Handle notification open
  void _handleNotificationOpened(OSNotificationClickEvent event) {
    final additionalData = event.notification.additionalData;

    if (additionalData != null) {
      print('📦 Additional data: $additionalData');

      // Handle different notification types
      if (additionalData.containsKey('action')) {
        final action = additionalData['action'];

        switch (action) {
          case 'open_chat':
            // Open chat
            print('Открыть чат');
            break;
          case 'open_test':
            // Open test
            print('Открыть тест');
            break;
          case 'open_premium':
            // Open subscription screen
            print('Открыть premium');
            break;
          default:
            print('Неизвестное действие: $action');
        }
      }
    }
  }

  /// Set external User ID (to link with your system)
  Future<void> setExternalUserId(String userId) async {
    try {
      await OneSignal.login(userId);
      print('✅ OneSignal User ID установлен: $userId');
    } catch (e) {
      print('❌ Ошибка установки User ID: $e');
    }
  }

  /// Remove external User ID (on user logout)
  Future<void> removeExternalUserId() async {
    try {
      await OneSignal.logout();
      print('✅ OneSignal User ID удален');
    } catch (e) {
      print('❌ Ошибка удаления User ID: $e');
    }
  }

  /// Set user email
  Future<void> setEmail(String email) async {
    try {
      await OneSignal.User.addEmail(email);
      print('✅ Email установлен: $email');
    } catch (e) {
      print('❌ Ошибка установки email: $e');
    }
  }

  /// Remove email
  Future<void> removeEmail(String email) async {
    try {
      await OneSignal.User.removeEmail(email);
      print('✅ Email удален');
    } catch (e) {
      print('❌ Ошибка удаления email: $e');
    }
  }

  /// Set tags for user segmentation
  Future<void> setTags(Map<String, dynamic> tags) async {
    try {
      await OneSignal.User.addTags(tags);
      print('✅ Теги установлены: $tags');
    } catch (e) {
      print('❌ Ошибка установки тегов: $e');
    }
  }

  /// Remove tags
  Future<void> removeTags(List<String> tagKeys) async {
    try {
      await OneSignal.User.removeTags(tagKeys);
      print('✅ Теги удалены: $tagKeys');
    } catch (e) {
      print('❌ Ошибка удаления тегов: $e');
    }
  }

  /// Get notification permission status
  Future<bool> hasNotificationPermission() async {
    try {
      final permission = await OneSignal.Notifications.permission;
      return permission;
    } catch (e) {
      print('❌ Ошибка проверки разрешения: $e');
      return false;
    }
  }

  /// Request notification permission
  Future<bool> requestNotificationPermission() async {
    try {
      final permission = await OneSignal.Notifications.requestPermission(true);
      print('✅ Разрешение на уведомления: $permission');
      return permission;
    } catch (e) {
      print('❌ Ошибка запроса разрешения: $e');
      return false;
    }
  }

  /// Disable/enable notifications
  Future<void> setNotificationsEnabled(bool enabled) async {
    try {
      await OneSignal.Notifications.requestPermission(enabled);
      print('✅ Уведомления ${enabled ? "включены" : "отключены"}');
    } catch (e) {
      print('❌ Ошибка изменения статуса уведомлений: $e');
    }
  }

  /// Get OneSignal Player ID
  String? getPlayerId() {
    try {
      final pushSubscription = OneSignal.User.pushSubscription;
      return pushSubscription.id;
    } catch (e) {
      print('❌ Ошибка получения Player ID: $e');
      return null;
    }
  }

  /// Get Push Token
  String? getPushToken() {
    try {
      final pushSubscription = OneSignal.User.pushSubscription;
      return pushSubscription.token;
    } catch (e) {
      print('❌ Ошибка получения Push Token: $e');
      return null;
    }
  }

  /// Send event (for analytics and triggers)
  Future<void> sendEvent(String eventName, {Map<String, dynamic>? properties}) async {
    try {
      // OneSignal 5.x uses Outcomes
      // For custom events use Data Tags
      if (properties != null) {
        await OneSignal.User.addTags(properties);
      }
      print('✅ Событие отправлено: $eventName');
    } catch (e) {
      print('❌ Ошибка отправки события: $e');
    }
  }

  /// Set user language
  Future<void> setLanguage(String languageCode) async {
    try {
      await OneSignal.User.setLanguage(languageCode);
      print('✅ Язык установлен: $languageCode');
    } catch (e) {
      print('❌ Ошибка установки языка: $e');
    }
  }
}
