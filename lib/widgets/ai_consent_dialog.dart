import 'package:flutter/material.dart';
import '../constants/app_palette.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import '../services/ai_consent_service.dart';
import '../constants/legal_links.dart';

/// Ensures the user has consented to sharing their data with the third-party
/// AI service (OpenAI) before any personal data is sent.
///
/// Returns `true` if the user has already consented or agrees now, `false`
/// if the user declines. Required by App Store Guideline 5.1.1(i) / 5.1.2(i).
Future<bool> ensureAiConsent(BuildContext context) async {
  final service = AiConsentService();
  if (await service.hasConsented()) return true;
  if (!context.mounted) return false;

  final agreed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const _AiConsentDialog(),
  );

  if (agreed == true) {
    await service.setConsented();
    return true;
  }
  return false;
}

class _AiConsentDialog extends StatelessWidget {
  const _AiConsentDialog();

  Future<void> _openPrivacyPolicy() async {
    final url = Uri.parse(LegalLinks.privacyPolicyUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return AlertDialog(
      backgroundColor: context.palette.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        l.aiConsentTitle,
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: context.palette.textPrimary,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.aiConsentMessage,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                height: 1.4,
                color: context.palette.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _openPrivacyPolicy,
              child: Text(
                l.privacyPolicy,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFFBC91DB),
                  decoration: TextDecoration.underline,
                  decorationColor: Color(0xFFBC91DB),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            l.aiConsentDecline,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: context.palette.textSecondary,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            l.aiConsentAgree,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: Color(0xFFBC91DB),
            ),
          ),
        ),
      ],
    );
  }
}
