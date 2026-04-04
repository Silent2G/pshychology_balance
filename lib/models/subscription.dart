class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final String price;
  final String period;
  final List<String> features;
  final bool isPopular;

  // Product IDs for App Store and Google Play (fill when created in stores)
  final String? appleProductId;
  final String? googleProductId;
  
  // Package ID in RevenueCat (e.g. $rc_monthly, $rc_six_month, $rc_annual)
  final String? packageId;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.period,
    required this.features,
    this.isPopular = false,
    this.appleProductId,
    this.googleProductId,
    this.packageId,
  });

  // Get Product ID by platform
  String? getProductId(bool isIOS) {
    return isIOS ? appleProductId : googleProductId;
  }
}

class SubscriptionStatus {
  final bool isPremium;
  final DateTime? expirationDate;
  final String? subscriptionPlanId;
  final String? platform; // 'apple' or 'google'

  SubscriptionStatus({required this.isPremium, this.expirationDate, this.subscriptionPlanId, this.platform});

  bool get isActive {
    if (!isPremium) return false;
    if (expirationDate == null) return true;
    return DateTime.now().isBefore(expirationDate!);
  }

  Map<String, dynamic> toJson() {
    return {
      'isPremium': isPremium,
      'expirationDate': expirationDate?.millisecondsSinceEpoch,
      'subscriptionPlanId': subscriptionPlanId,
      'platform': platform,
    };
  }

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) {
    return SubscriptionStatus(
      isPremium: json['isPremium'] ?? false,
      expirationDate: json['expirationDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['expirationDate'])
          : null,
      subscriptionPlanId: json['subscriptionPlanId'],
      platform: json['platform'],
    );
  }
}

// Predefined subscription plans
class SubscriptionPlans {
  static final monthly = SubscriptionPlan(
    id: 'monthly',
    name: 'Місячна підписка',
    description: 'Доступ до всіх функцій на 1 місяць',
    price: '₴149', // Fallback price, will be replaced by real from RevenueCat
    period: 'місяць',
    features: [
      'Необмежені сесії з AI психологом',
      'Персоналізовані рекомендації',
      'Історія всіх сесій',
      'Щотижневі звіти прогресу',
      'Пріоритетна підтримка',
    ],
    appleProductId: 'premium_monthly',
    googleProductId: 'premium_monthly',
    packageId: '\$rc_monthly', // Package ID from RevenueCat Dashboard
  );

  static final sixMonth = SubscriptionPlan(
    id: 'six_month',
    name: 'Піврічна підписка',
    description: 'Доступ до всіх функцій на 6 місяців',
    price: '₴799', // Fallback price, will be replaced by real from RevenueCat
    period: '6 місяців',
    features: [
      'Все з місячної підписки',
      'Економія порівняно з місячною',
      'Ексклюзивні вправи і техніки',
      'Персональний план розвитку',
    ],
    appleProductId: 'premium_6_month',
    googleProductId: 'premium_6_month',
    packageId: '\$rc_six_month', // Package ID from RevenueCat Dashboard
  );

  static final yearly = SubscriptionPlan(
    id: 'yearly',
    name: 'Річна підписка',
    description: 'Доступ до всіх функцій на 1 рік',
    price: '₴1299', // Fallback price, will be replaced by real from RevenueCat
    period: 'рік',
    features: [
      'Все з місячної підписки',
      'Економія 27% порівняно з місячною',
      'Ексклюзивні вправи і техніки',
      'Персональний план розвитку',
      'Доступ до майбутніх оновлень',
    ],
    isPopular: true,
    appleProductId: 'premium_annual',
    googleProductId: 'premium_annual',
    packageId: '\$rc_annual', // Package ID from RevenueCat Dashboard
  );

  static List<SubscriptionPlan> get all => [monthly, sixMonth, yearly];
}
