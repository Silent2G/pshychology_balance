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

  /// Share to Facebook. Facebook (and Instagram) do NOT accept pre-filled text,
  /// so we share the result as an image when one is provided.
  static Future<void> shareToFacebook(String psychotype, {BuildContext? context, File? image}) async {
    try {
      final text = _buildShareText(psychotype, context: context);
      final localizations = context != null ? AppLocalizations.of(context) : null;
      final subject = localizations != null
          ? '${localizations.myPsychotype}: $psychotype'
          : 'Мій психотип: $psychotype';
      if (image != null) {
        await _shareImage(image, text, subject: subject, context: context);
      } else {
        await _shareWithPosition(text, subject: subject, context: context);
      }
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

  /// Share to Instagram. Instagram only accepts images (not text/links), so we
  /// share the result image via the native sheet when one is provided.
  static Future<void> shareToInstagram(String psychotype, {BuildContext? context, File? image}) async {
    try {
      final text = _buildShareText(psychotype, context: context);
      final localizations = context != null ? AppLocalizations.of(context) : null;
      final subject = localizations != null
          ? '${localizations.myPsychotype}: $psychotype'
          : 'Мій психотип: $psychotype';
      if (image != null) {
        // Caption on the clipboard so the user can paste it into their story/post.
        await Clipboard.setData(ClipboardData(text: text));
        await _shareImage(image, text, subject: subject, context: context);
      } else {
        await Clipboard.setData(ClipboardData(text: text));
        await _shareWithPosition(text, subject: subject, context: context);
      }
    } catch (e) {
      print('Ошибка шаринга в Instagram: $e');
    }
  }

  /// Share to Telegram via the canonical t.me share link (opens the Telegram app
  /// if installed, otherwise the web fallback — no custom scheme required).
  static Future<void> shareToTelegram(String psychotype, {BuildContext? context}) async {
    try {
      // Message body without the trailing link (the link goes in the url= param).
      final message = _buildShareText(psychotype, context: context, includeLink: false);
      final shareUrl = Uri.parse(
        'https://t.me/share/url'
        '?url=${Uri.encodeComponent(_appStoreLink())}'
        '&text=${Uri.encodeComponent(message)}',
      );
      await launchUrl(shareUrl, mode: LaunchMode.externalApplication);
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

  /// The store link for the current platform.
  static String _appStoreLink() => Platform.isIOS ? _appStoreUrl : _playStoreUrl;

  /// Share an image (with a caption) via the native share sheet — the reliable
  /// path for image-only platforms like Instagram and Facebook.
  static Future<void> _shareImage(File image, String text, {String? subject, BuildContext? context}) async {
    final files = [XFile(image.path)];
    if (Platform.isIOS && context != null) {
      final screenSize = MediaQuery.of(context).size;
      final rect = Rect.fromLTWH(screenSize.width / 2 - 50, screenSize.height / 2 - 50, 100, 100);
      await Share.shareXFiles(files, text: text, subject: subject, sharePositionOrigin: rect);
    } else {
      await Share.shareXFiles(files, text: text, subject: subject);
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

  /// Build share text. Set [includeLink] to false when the store link is passed
  /// separately (e.g. the Telegram url= param) to avoid duplicating it.
  static String _buildShareText(String psychotype, {BuildContext? context, bool includeLink = true}) {
    final localizations = context != null ? AppLocalizations.of(context) : null;

    // Determine language and build text
    String myPsychotypeText;
    String shareTestText;

    if (localizations != null) {
      myPsychotypeText = localizations.myPsychotype;
      shareTestText = localizations.shareTestText;
    } else {
      // Fallback to Ukrainian
      myPsychotypeText = 'Мій психотип';
      shareTestText = 'Пройшов тест на самопізнання в AI Psychology Balance! 🧠✨';
    }

    final base = '$myPsychotypeText: $psychotype\n$shareTestText';
    return includeLink ? '$base\n\n${_appStoreLink()}' : base;
  }
}
