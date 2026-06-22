/// Centralized legal links used across the app (paywall, profile, consent).
class LegalLinks {
  /// Privacy policy (hosted on Firebase Hosting, ai-psychology-balance project).
  static const String privacyPolicyUrl =
      'https://ai-psychology-balance.web.app/privacy.html';

  /// Apple's standard Terms of Use (EULA). Required by Guideline 3.1.2(c)
  /// for apps offering auto-renewable subscriptions.
  static const String termsOfUseUrl =
      'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/';
}
