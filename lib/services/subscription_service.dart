import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/subscription.dart';

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  // RevenueCat API keys
  static const String _appleApiKey = 'appl_kVQvjrujtbMtuYFWTVyVjRgTVBd';
  static const String _googleApiKey = 'goog_HyIGoAqykmtObCkIAqBEKWWsyRk';

  // Subscription status cache
  SubscriptionStatus? _cachedStatus;

  // Stream for subscription status updates
  final _statusController = StreamController<SubscriptionStatus>.broadcast();
  Stream<SubscriptionStatus> get statusStream => _statusController.stream;

  // Initialization flags
  bool _initialized = false;
  bool _isInitializing = false;
  Completer<void>? _initCompleter;

  // Check if RevenueCat is configured
  bool get _isConfigured => _appleApiKey != 'YOUR_APPLE_API_KEY' && _googleApiKey != 'YOUR_GOOGLE_API_KEY';
  
  // Check if RevenueCat is initialized
  bool get isInitialized => _initialized;

  /// Initialize subscription service
  Future<void> initialize() async {
    // If already initialized, return
    if (_initialized) {
      print('ℹ️ RevenueCat уже инициализирован');
      return;
    }

    // If initializing, wait for completion
    if (_isInitializing && _initCompleter != null) {
      print('⏳ Ожидание завершения инициализации RevenueCat...');
      return _initCompleter!.future;
    }

    // Start initialization
    _isInitializing = true;
    _initCompleter = Completer<void>();

    try {
      // Temporarily disable RevenueCat if keys not configured
      if (!_isConfigured) {
        print('⚠️ RevenueCat не настроен (используются тестовые ключи)');
        // Load status from cache
        await _loadSubscriptionStatus();
        _initialized = true;
        _isInitializing = false;
        _initCompleter?.complete();
        return;
      }

      final apiKey = Platform.isIOS ? _appleApiKey : _googleApiKey;
      print('🔑 Используется API ключ: ${apiKey.substring(0, 10)}... (${Platform.isIOS ? "iOS" : "Android"})');
      
      final configuration = PurchasesConfiguration(apiKey);

      await Purchases.configure(configuration);

      print('✅ RevenueCat инициализирован');
      _initialized = true;

      // Subscribe to purchase updates
      Purchases.addCustomerInfoUpdateListener((customerInfo) {
        _handleCustomerInfoUpdate(customerInfo);
      });

      // Restore subscription status
      await refreshStatus();

      // Log expected Product IDs
      print('📋 Ожидаемые Product IDs:');
      for (final plan in SubscriptionPlans.all) {
        final productId = plan.getProductId(Platform.isIOS);
        print('   - ${plan.id}: $productId');
      }

      _initCompleter?.complete();
    } catch (e) {
      print('❌ Ошибка инициализации RevenueCat: $e');
      print('💡 Проверьте:');
      print('   1. Правильность API ключа в коде');
      print('   2. Подключение к интернету');
      print('   3. Настройки в RevenueCat Dashboard');
      // Load from cache
      await _loadSubscriptionStatus();
      _initialized = true; // Mark as initialized to avoid blocking app
      _initCompleter?.completeError(e);
    } finally {
      _isInitializing = false;
    }
  }

  /// Handle customer info update
  void _handleCustomerInfoUpdate(CustomerInfo customerInfo) {
    print('📦 Обновление информации о подписке');

    final isPremium = customerInfo.entitlements.active.isNotEmpty;

    if (isPremium) {
      final activeEntitlement = customerInfo.entitlements.active.values.first;
      final expirationDate = activeEntitlement.expirationDate;

      final status = SubscriptionStatus(
        isPremium: true,
        subscriptionPlanId: activeEntitlement.productIdentifier,
        platform: Platform.isIOS ? 'apple' : 'google',
        expirationDate: expirationDate != null ? DateTime.parse(expirationDate) : null,
      );

      _cachedStatus = status;
      _statusController.add(status);
      _saveSubscriptionStatus(status);
    } else {
      final status = SubscriptionStatus(isPremium: false);
      _cachedStatus = status;
      _statusController.add(status);
      _saveSubscriptionStatus(status);
    }
  }

  /// Get available products from stores
  Future<List<StoreProduct>> getAvailableProducts() async {
    try {
      // Wait for initialization if not yet complete
      if (!_initialized && _isInitializing && _initCompleter != null) {
        await _initCompleter!.future;
      }

      // Check if RevenueCat is configured
      if (!_isConfigured || !_initialized) {
        print('⚠️ RevenueCat не настроен или не инициализирован, возвращаем пустой список продуктов');
        return [];
      }

      final Set<String> productIds = {};

      // Collect all Product IDs
      for (final plan in SubscriptionPlans.all) {
        final productId = plan.getProductId(Platform.isIOS);
        if (productId != null && productId.isNotEmpty) {
          productIds.add(productId);
        }
      }

      if (productIds.isEmpty) {
        print('⚠️ Нет Product IDs для загрузки');
        return [];
      }

      // Get product info via RevenueCat
      final offerings = await Purchases.getOfferings();

      print('📦 Всего предложений: ${offerings.all.length}');
      print('📦 Текущее предложение: ${offerings.current?.identifier ?? "null"}');

      if (offerings.current == null) {
        print('⚠️ Нет активных предложений в RevenueCat');
        print('💡 Проверьте в RevenueCat Dashboard:');
        print('   1. Создано ли Offering с identifier "default"?');
        print('   2. Добавлены ли Packages к Offering?');
        print('   3. Настроены ли Products в App Store Connect / Play Console?');
        return [];
      }

      print('📦 Доступных пакетов: ${offerings.current!.availablePackages.length}');
      for (final package in offerings.current!.availablePackages) {
        print('   - ${package.identifier}: ${package.storeProduct.identifier} (${package.storeProduct.priceString})');
      }

      final products = offerings.current!.availablePackages.map((package) => package.storeProduct).toList();

      print('✅ Загружено ${products.length} продуктов');
      return products;
    } catch (e) {
      print('❌ Ошибка получения продуктов: $e');
      return [];
    }
  }

  /// Get packages with mapping to subscription plans
  Future<Map<String, Package>> getPackagesByProductId() async {
    try {
      // Wait for initialization if not yet complete
      if (!_initialized && _isInitializing && _initCompleter != null) {
        await _initCompleter!.future;
      }

      // Check if RevenueCat is configured
      if (!_isConfigured || !_initialized) {
        print('⚠️ RevenueCat не настроен или не инициализирован, возвращаем пустой список пакетов');
        return {};
      }

      final offerings = await Purchases.getOfferings();

      print('📦 Всего предложений: ${offerings.all.length}');
      print('📦 Текущее предложение: ${offerings.current?.identifier ?? "null"}');

      if (offerings.current == null) {
        print('⚠️ Нет активных предложений в RevenueCat');
        print('💡 Проверьте в RevenueCat Dashboard:');
        print('   1. Создано ли Offering с identifier "default"?');
        print('   2. Добавлены ли Packages к Offering?');
        print('   3. Настроены ли Products в App Store Connect / Play Console?');
        return {};
      }

      print('📦 Доступных пакетов: ${offerings.current!.availablePackages.length}');
      final Map<String, Package> packagesMap = {};

      for (final package in offerings.current!.availablePackages) {
        final productId = package.storeProduct.identifier;
        packagesMap[productId] = package;
        print('📦 Найден пакет: $productId -> ${package.identifier} (${package.storeProduct.priceString})');
      }

      print('✅ Загружено ${packagesMap.length} пакетов из RevenueCat');
      return packagesMap;
    } catch (e) {
      print('❌ Ошибка получения пакетов: $e');
      return {};
    }
  }

  /// Purchase subscription
  Future<bool> purchaseSubscription(SubscriptionPlan plan) async {
    try {
      // Wait for initialization if not yet complete
      if (!_initialized && _isInitializing && _initCompleter != null) {
        await _initCompleter!.future;
      }

      // Check if RevenueCat is configured
      if (!_isConfigured || !_initialized) {
        print('❌ RevenueCat не настроен или не инициализирован, покупка невозможна');
        return false;
      }

      // First try to find by Package ID (more reliable)
      final packageId = plan.packageId;
      final productId = plan.getProductId(Platform.isIOS);
      print('🛒 Попытка покупки: план ${plan.id}');
      if (packageId != null) {
        print('   Package ID: $packageId');
      }
      if (productId != null) {
        print('   Product ID: $productId');
      }

      if (packageId == null && (productId == null || productId.isEmpty)) {
        print('❌ Package ID и Product ID не определены для плана ${plan.id}');
        return false;
      }

      // Get offerings
      final offerings = await Purchases.getOfferings();

      if (offerings.current == null) {
        print('❌ Нет доступных предложений');
        return false;
      }

      print('📦 Доступные пакеты:');
      for (final pkg in offerings.current!.availablePackages) {
        print('   - Package: ${pkg.identifier}, Product: ${pkg.storeProduct.identifier}');
      }

      // Find package: first by Package ID, then by Product ID
      Package? package;
      try {
        if (packageId != null && packageId.isNotEmpty) {
          // Try to find by Package ID
          try {
            package = offerings.current!.availablePackages.firstWhere(
              (pkg) => pkg.identifier == packageId,
            );
            print('✅ Найден пакет по Package ID: ${package.identifier}');
          } catch (e) {
            print('⚠️ Пакет с Package ID $packageId не найден, пробуем по Product ID');
          }
        }
        
        // If not found by Package ID, search by Product ID
        if (package == null && productId != null && productId.isNotEmpty) {
          package = offerings.current!.availablePackages.firstWhere(
            (pkg) => pkg.storeProduct.identifier == productId,
          );
          print('✅ Найден пакет по Product ID: ${package.identifier}');
        }
        
        if (package == null) {
          throw Exception('Пакет не найден');
        }
      } catch (e) {
        print('❌ Пакет не найден');
        print('💡 Проверьте:');
        print('   1. Правильно ли настроен Package ID ($packageId) в модели SubscriptionPlan?');
        print('   2. Правильно ли настроен Product ID ($productId) в модели SubscriptionPlan?');
        print('   3. Добавлены ли эти ID в RevenueCat Dashboard?');
        print('   4. Связаны ли они с Package в Offering?');
        throw Exception('Пакет не найден');
      }

      // Purchase via RevenueCat
      final purchaseResult = await Purchases.purchasePackage(package);
      final customerInfo = purchaseResult.customerInfo;

      // Check purchase success
      final isPremium = customerInfo.entitlements.active.isNotEmpty;

      if (isPremium) {
        print('✅ Покупка успешна');
        _handleCustomerInfoUpdate(customerInfo);
        return true;
      } else {
        print('⚠️ Покупка не активировала подписку');
        return false;
      }
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        print('ℹ️ Покупка отменена пользователем');
      } else {
        print('❌ Ошибка покупки: ${e.message}');
      }
      return false;
    } catch (e) {
      print('❌ Ошибка покупки: $e');
      return false;
    }
  }

  /// Restore purchases
  Future<void> restorePurchases() async {
    try {
      print('🔄 Восстановление покупок...');

      final customerInfo = await Purchases.restorePurchases();
      _handleCustomerInfoUpdate(customerInfo);

      print('✅ Покупки восстановлены');
    } catch (e) {
      print('❌ Ошибка восстановления покупок: $e');
      rethrow;
    }
  }

  /// Refresh subscription status
  Future<void> refreshStatus() async {
    try {
      // Wait for initialization if not yet complete
      if (!_initialized && _isInitializing && _initCompleter != null) {
        await _initCompleter!.future;
      }

      // Check if RevenueCat is configured
      if (!_isConfigured || !_initialized) {
        // Load from cache
        await _loadSubscriptionStatus();
        return;
      }

      final customerInfo = await Purchases.getCustomerInfo();
      _handleCustomerInfoUpdate(customerInfo);
    } catch (e) {
      print('❌ Ошибка обновления статуса: $e');
      // Load from cache
      await _loadSubscriptionStatus();
    }
  }

  /// Get current subscription status
  Future<SubscriptionStatus> getSubscriptionStatus() async {
    if (_cachedStatus != null) {
      return _cachedStatus!;
    }

    return await _loadSubscriptionStatus();
  }

  /// Save subscription status locally
  Future<void> _saveSubscriptionStatus(SubscriptionStatus status) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('subscription_isPremium', status.isPremium);
    if (status.expirationDate != null) {
      await prefs.setInt('subscription_expirationDate', status.expirationDate!.millisecondsSinceEpoch);
    }
    if (status.subscriptionPlanId != null) {
      await prefs.setString('subscription_planId', status.subscriptionPlanId!);
    }
    if (status.platform != null) {
      await prefs.setString('subscription_platform', status.platform!);
    }

    print('💾 Статус подписки сохранен');
  }

  /// Load subscription status from local storage
  Future<SubscriptionStatus> _loadSubscriptionStatus() async {
    final prefs = await SharedPreferences.getInstance();

    final isPremium = prefs.getBool('subscription_isPremium') ?? false;
    final expirationTimestamp = prefs.getInt('subscription_expirationDate');
    final planId = prefs.getString('subscription_planId');
    final platform = prefs.getString('subscription_platform');

    final status = SubscriptionStatus(
      isPremium: isPremium,
      expirationDate: expirationTimestamp != null ? DateTime.fromMillisecondsSinceEpoch(expirationTimestamp) : null,
      subscriptionPlanId: planId,
      platform: platform,
    );

    _cachedStatus = status;
    return status;
  }

  /// Check if subscription is active
  Future<bool> isPremiumActive() async {
    final status = await getSubscriptionStatus();
    return status.isActive;
  }

  /// Set user ID for RevenueCat
  Future<void> setUserId(String userId) async {
    try {
      // Wait for initialization if not yet complete
      if (!_initialized && _isInitializing && _initCompleter != null) {
        await _initCompleter!.future;
      }

      // Check if RevenueCat is configured
      if (!_isConfigured || !_initialized) {
        print('⚠️ RevenueCat не настроен или не инициализирован, пропускаем setUserId');
        return;
      }

      await Purchases.logIn(userId);
      print('✅ User ID установлен: $userId');
    } catch (e) {
      print('❌ Ошибка установки User ID: $e');
    }
  }

  /// User logout
  Future<void> logOut() async {
    try {
      // Wait for initialization if not yet complete
      if (!_initialized && _isInitializing && _initCompleter != null) {
        await _initCompleter!.future;
      }

      // Check if RevenueCat is configured
      if (!_isConfigured || !_initialized) {
        print('⚠️ RevenueCat не настроен или не инициализирован, пропускаем logOut');
        await clearSubscriptionStatus();
        return;
      }

      await Purchases.logOut();
      print('✅ Пользователь вышел из RevenueCat');
      await clearSubscriptionStatus();
    } catch (e) {
      print('❌ Ошибка выхода: $e');
    }
  }

  /// Clear subscription status (for testing)
  Future<void> clearSubscriptionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('subscription_isPremium');
    await prefs.remove('subscription_expirationDate');
    await prefs.remove('subscription_planId');
    await prefs.remove('subscription_platform');

    _cachedStatus = null;

    final status = SubscriptionStatus(isPremium: false);
    _statusController.add(status);

    print('🗑️ Статус подписки очищен');
  }

  /// Dispose resources
  void dispose() {
    _statusController.close();
  }
}
