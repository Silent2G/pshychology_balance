import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  // Languages the app ships translations for.
  static const List<String> supportedLanguageCodes = ['uk', 'en', 'es', 'hi', 'zh'];

  // Start from the phone's language (if supported) so a first-launch user sees
  // the app in their own language without opening settings.
  Locale _locale = Locale(_deviceLanguageOrDefault());

  Locale get locale => _locale;

  LocaleProvider() {
    _loadSavedLocale();
  }

  // First supported language among the device's preferred locales, else English.
  static String _deviceLanguageOrDefault() {
    for (final locale in WidgetsBinding.instance.platformDispatcher.locales) {
      if (supportedLanguageCodes.contains(locale.languageCode)) {
        return locale.languageCode;
      }
    }
    return 'en';
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('language_code');
    // An explicit prior choice always wins; otherwise keep the device language
    // detected above (which keeps following the phone until the user overrides).
    if (saved != null && supportedLanguageCodes.contains(saved)) {
      _locale = Locale(saved);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;

    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
    notifyListeners();
  }

  String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'uk':
        return 'Українська';
      case 'en':
        return 'Англійська';
      case 'es':
        return 'Іспанська';
      case 'hi':
        return 'Індійська хінді';
      case 'zh':
        return 'Китайська';
      default:
        return 'Українська';
    }
  }
}


