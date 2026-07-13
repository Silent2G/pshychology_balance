import 'package:flutter/material.dart';
import '../constants/app_palette.dart';
import '../widgets/app_background.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/common_header.dart';
import '../providers/subscription_provider.dart';
import 'paywall_screen.dart';
import '../l10n/app_localizations.dart';

class SubscriptionScreen extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onContinue;

  const SubscriptionScreen({
    super.key,
    this.onBack,
    this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final subscriptionProvider = context.watch<SubscriptionProvider>();
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return Scaffold(
      backgroundColor: context.palette.scaffold,
      body: AppBackground(
        lightImage: 'assets/background_main.png',
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header with back button
                CommonHeader(
                  onBack: onBack ?? () => Navigator.of(context).pop(),
                  showBackButton: true,
                ),
                SizedBox(height: screenHeight * 0.049), // ~40px on 812px

                // Main content
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.043), // ~16px on 375px
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: subscriptionProvider.isPremium
                        ? [_buildCurrentSubscriptionCard(context, localizations, subscriptionProvider)]
                        : [
                    // Main text
                    Text(
                      localizations.subscriptionMainText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        height: 1.25, // 20px / 16px
                        color: context.palette.textPrimary,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.039), // ~32px on 812px

                    // Decorative arrow down
                    SizedBox(
                      width: screenWidth * 0.093, // ~35px on 375px
                      height: screenHeight * 0.073, // ~59px on 812px
                      child: Image.asset(
                        'assets/arrow_down.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.039), // ~32px on 812px

                    // "Why subscription?" header
                    Text(
                      localizations.whySubscription,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        height: 1.2, // 24px / 20px
                        color: Color(0xFFBC91DB),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02), // ~16px on 812px

                    // Explanation text
                    Text(
                      localizations.subscriptionExplanation,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        height: 1.25, // 20px / 16px
                        color: context.palette.textPrimary,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.015), // ~12px on 812px

                    // Benefits list
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBenefitItem(context, localizations.benefitWorkingPractices, screenWidth),
                        SizedBox(height: screenHeight * 0.015), // ~12px on 812px
                        _buildBenefitItem(context, localizations.benefitPocketPsychologist, screenWidth),
                        SizedBox(height: screenHeight * 0.015),
                        _buildBenefitItem(context, localizations.benefitSupport, screenWidth),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.049), // ~40px on 812px

                    // "Continue" button
                    GestureDetector(
                      onTap: onContinue ??
                          () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const PaywallScreen(),
                              ),
                            );
                          },
                      child: Container(
                        width: double.infinity,
                        height: screenHeight * 0.062, // ~50px on 812px
                        decoration: BoxDecoration(
                          color: const Color(0xFFBC91DB),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Center(
                          child: Text(
                            localizations.continueButton,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              height: 1.25, // 20px / 16px
                              color: Color(0xFFFFFFFF),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.024), // Bottom spacing
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentSubscriptionCard(
    BuildContext context,
    AppLocalizations l,
    SubscriptionProvider sub,
  ) {
    const accent = Color(0xFFBC91DB);
    const green = Color(0xFF3BA55D);
    final status = sub.status;
    final daysRemaining = sub.getDaysRemaining();
    final managedVia = status.platform == 'google' ? l.managedViaGooglePlay : l.managedViaAppStore;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.palette.surfaceBorder, width: 1.5),
        boxShadow: [
          BoxShadow(color: accent.withOpacity(0.12), blurRadius: 18, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + "Active" status pill
          Row(
            children: [
              Expanded(
                child: Text(
                  l.yourSubscription,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: accent,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: green.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: green, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text(
                      l.statusActive,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Plan name
          Text(
            _planName(l, status.subscriptionPlanId),
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700,
              fontSize: 22,
              color: context.palette.textPrimary,
            ),
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: Color(0xFFEDE6F3)),
          const SizedBox(height: 16),
          if (status.expirationDate != null)
            _infoRow(Icons.event_available_outlined, '${l.activeUntil} ${_formatDate(status.expirationDate!)}'),
          if (daysRemaining != null && daysRemaining >= 0) _infoRow(Icons.hourglass_bottom_outlined, l.daysLeft(daysRemaining)),
          _infoRow(Icons.store_outlined, managedVia),
          const SizedBox(height: 8),
          // Manage subscription (opens native store management)
          GestureDetector(
            onTap: () => _openManageSubscription(status.platform),
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: context.palette.surface,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: accent, width: 1.5),
              ),
              child: Center(
                child: Text(
                  l.manageSubscription,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: accent,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Map the store product id to a localized plan name.
  String _planName(AppLocalizations l, String? productId) {
    final id = (productId ?? '').toLowerCase();
    if (id.contains('annual') || id.contains('year')) return l.planNameYearly;
    if (id.contains('6') || id.contains('six')) return l.planNameSixMonth;
    if (id.contains('month')) return l.planNameMonthly;
    return l.premiumPlan;
  }

  String _formatDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}.${two(d.month)}.${d.year}';
  }

  Future<void> _openManageSubscription(String? platform) async {
    final url = platform == 'google'
        ? 'https://play.google.com/store/account/subscriptions'
        : 'https://apps.apple.com/account/subscriptions';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFFBC91DB)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
                fontSize: 15,
                color: Color(0xFF3A3A3A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(BuildContext context, String text, double screenWidth) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(
          'assets/ic_todo_list.svg',
          width: screenWidth * 0.048, // ~18px on 375px
          height: screenWidth * 0.048,
          colorFilter: const ColorFilter.mode(Color(0xFFBC91DB), BlendMode.srcIn),
        ),
        SizedBox(width: screenWidth * 0.032), // ~12px on 375px
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
              fontSize: 16,
              height: 1.25, // 20px / 16px
              color: context.palette.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

