import 'package:shared_preferences/shared_preferences.dart';

/// Stores whether the user has agreed to share their data with the
/// third-party AI service (OpenAI). Required by App Store Guideline
/// 5.1.1(i) / 5.1.2(i): permission must be obtained before sending
/// personal data to a third-party AI service.
class AiConsentService {
  static final AiConsentService _instance = AiConsentService._internal();
  factory AiConsentService() => _instance;
  AiConsentService._internal();

  static const String _key = 'ai_data_sharing_consent_v1';

  Future<bool> hasConsented() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  Future<void> setConsented() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }

  /// Used when the user logs out, so a new user must consent again.
  Future<void> clearConsent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
