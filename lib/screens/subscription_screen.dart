import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/common_header.dart';
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
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/background_main.png'), fit: BoxFit.cover),
        ),
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
                    children: [
                    // Main text
                    Text(
                      localizations.subscriptionMainText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        height: 1.25, // 20px / 16px
                        color: Color(0xFF000000),
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
                        color: Color(0xFF000000),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.015), // ~12px on 812px

                    // Benefits list
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBenefitItem(localizations.benefitWorkingPractices, screenWidth),
                        SizedBox(height: screenHeight * 0.015), // ~12px on 812px
                        _buildBenefitItem(localizations.benefitPocketPsychologist, screenWidth),
                        SizedBox(height: screenHeight * 0.015),
                        _buildBenefitItem(localizations.benefitSupport, screenWidth),
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

  Widget _buildBenefitItem(String text, double screenWidth) {
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
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
              fontSize: 16,
              height: 1.25, // 20px / 16px
              color: Color(0xFF000000),
            ),
          ),
        ),
      ],
    );
  }
}

