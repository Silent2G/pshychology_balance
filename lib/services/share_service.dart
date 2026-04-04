import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';

class ShareService {
  // App Store links
  static const String _appStoreUrl = 'https://apps.apple.com/us/app/ai-psychology-balance/id6754576157';
  static const String _playStoreUrl = 'https://play.google.com/store/apps/details?id=com.aipsychologybalance.app';

  /// Share to Facebook - use native Share sheet
  static Future<void> shareToFacebook(String psychotype, {BuildContext? context}) async {
    try {
      final text = _buildShareText(psychotype, context: context);
      final localizations = context != null ? AppLocalizations.of(context) : null;
      final subject = localizations != null
          ? '${localizations.myPsychotype}: $psychotype'
          : 'Мій психотип: $psychotype';
      await _shareWithPosition(text, subject: subject, context: context);
    } catch (e) {
      print('Ошибка шаринга в Facebook: $e');
    }
  }

  /// Share to WhatsApp
  static Future<void> shareToWhatsApp(String psychotype, {BuildContext? context}) async {
    try {
      final text = _buildShareText(psychotype);
      final encodedText = Uri.encodeComponent(text);

      // Try to open via WhatsApp app
      final whatsappUrl = Uri.parse('whatsapp://send?text=$encodedText');
      final whatsappWebUrl = Uri.parse('https://wa.me/?text=$encodedText');

      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(whatsappWebUrl)) {
        await launchUrl(whatsappWebUrl, mode: LaunchMode.externalApplication);
      } else {
        // If WhatsApp not installed, use general share
        await _shareWithPosition(text, context: context);
      }
    } catch (e) {
      print('Ошибка шаринга в WhatsApp: $e');
      // Fallback to general share
      await _shareWithPosition(_buildShareText(psychotype, context: context), context: context);
    }
  }

  /// Share to Instagram - use native Share sheet
  static Future<void> shareToInstagram(String psychotype, {BuildContext? context}) async {
    try {
      final text = _buildShareText(psychotype, context: context);

      // Copy text to clipboard for convenience
      await Clipboard.setData(ClipboardData(text: text));

      final localizations = context != null ? AppLocalizations.of(context) : null;
      final subject = localizations != null
          ? '${localizations.myPsychotype}: $psychotype'
          : 'Мій психотип: $psychotype';
      await _shareWithPosition(text, subject: subject, context: context);
    } catch (e) {
      print('Ошибка шаринга в Instagram: $e');
    }
  }

  /// Share to Telegram
  static Future<void> shareToTelegram(String psychotype, {BuildContext? context}) async {
    try {
      final text = _buildShareText(psychotype, context: context);
      final encodedText = Uri.encodeComponent(text);

      // Try to open via Telegram app
      final telegramUrl = Uri.parse('tg://msg?text=$encodedText');
      final telegramWebUrl = Uri.parse('https://t.me/share/url?url=&text=$encodedText');

      if (await canLaunchUrl(telegramUrl)) {
        await launchUrl(telegramUrl, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(telegramWebUrl)) {
        await launchUrl(telegramWebUrl, mode: LaunchMode.externalApplication);
      } else {
        // If Telegram not installed, use general share
        await _shareWithPosition(text, context: context);
      }
    } catch (e) {
      print('Ошибка шаринга в Telegram: $e');
      // Fallback to general share
      await _shareWithPosition(_buildShareText(psychotype, context: context), context: context);
    }
  }

  /// General share (native share sheet)
  static Future<void> shareGeneral(String psychotype, {BuildContext? context}) async {
    try {
      final text = _buildShareText(psychotype, context: context);
      final localizations = context != null ? AppLocalizations.of(context) : null;
      final subject = localizations != null
          ? '${localizations.myPsychotype}: $psychotype'
          : 'Мій психотип: $psychotype';
      await _shareWithPosition(text, subject: subject, context: context);
    } catch (e) {
      print('Ошибка общего шаринга: $e');
    }
  }

  /// Helper method for share with position (for iOS)
  static Future<void> _shareWithPosition(String text, {String? subject, BuildContext? context}) async {
    if (Platform.isIOS && context != null) {
      try {
        final mediaQuery = MediaQuery.of(context);
        final screenSize = mediaQuery.size;

        // Use screen center for sharePositionOrigin (required for iPad)
        // For iPhone not critical but won't cause error
        final rect = Rect.fromLTWH(screenSize.width / 2 - 50, screenSize.height / 2 - 50, 100, 100);

        await Share.share(text, subject: subject, sharePositionOrigin: rect);
        return;
      } catch (e) {
        print('Ошибка получения позиции для шаринга: $e');
        // Fallback without position
        await Share.share(text, subject: subject);
      }
    } else {
      // For Android
      await Share.share(text, subject: subject);
    }
  }

  /// Copy text to clipboard
  static Future<void> copyToClipboard(String psychotype, {BuildContext? context}) async {
    try {
      final text = _buildShareText(psychotype, context: context);
      await Clipboard.setData(ClipboardData(text: text));
    } catch (e) {
      print('Ошибка копирования в буфер обмена: $e');
    }
  }

  /// Build share text
  static String _buildShareText(String psychotype, {BuildContext? context}) {
    final localizations = context != null ? AppLocalizations.of(context) : null;

    // Determine language and build text
    String myPsychotypeText;
    String shareTestText;
    String appStoreLink;

    if (localizations != null) {
      myPsychotypeText = localizations.myPsychotype;
      shareTestText = localizations.shareTestText;
    } else {
      // Fallback to Ukrainian
      myPsychotypeText = 'Мій психотип';
      shareTestText = 'Пройшов тест на самопізнання в AI Psychology Balance! 🧠✨';
    }

    // Determine app store link
    if (Platform.isIOS) {
      appStoreLink = _appStoreUrl;
    } else {
      appStoreLink = _playStoreUrl;
    }

    return '$myPsychotypeText: $psychotype\n$shareTestText\n\n$appStoreLink';
  }
}
