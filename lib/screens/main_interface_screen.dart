import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../l10n/app_localizations.dart';

class MainInterfaceScreen extends StatelessWidget {
  final VoidCallback? onStartTest;
  final VoidCallback? onStartChat;
  final VoidCallback? onViewHistory;
  final VoidCallback? onGoToProfile;
  final VoidCallback? onChatTap;

  const MainInterfaceScreen({
    super.key,
    this.onStartTest,
    this.onStartChat,
    this.onViewHistory,
    this.onGoToProfile,
    this.onChatTap,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/background_main.png'), fit: BoxFit.cover),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.043),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Head logo (no top padding, same as CommonHeader)
                SizedBox(
                  width: screenWidth * 0.171, // ~64px on 375px
                  height: screenHeight * 0.106, // ~86px on 812px
                  child: Image.asset('assets/logo_head.png', fit: BoxFit.contain),
                ),

                SizedBox(height: screenHeight * 0.04), // ~32px
                // "Take test" button
                _buildLargeButton(
                  context: context,
                  icon: Image.asset(
                    'assets/ic_test.png',
                    width: screenWidth * 0.168, // ~63px on 375px
                    height: screenWidth * 0.168,
                    fit: BoxFit.cover,
                  ),
                  title: localizations.takeTest,
                  subtitle: localizations.learnYourPsychotype,
                  onTap: onStartTest,
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                ),

                SizedBox(height: screenHeight * 0.02), // ~16px
                // "Chat with AI" button
                _buildLargeButton(
                  context: context,
                  icon: Image.asset(
                    'assets/ic_talk.png',
                    width: screenWidth * 0.168, // ~63px on 375px
                    height: screenWidth * 0.168,
                    fit: BoxFit.cover,
                  ),
                  title: localizations.talkToAI,
                  subtitle: localizations.personalPsychologist,
                  onTap: onChatTap ?? onStartChat,
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                ),

                SizedBox(height: screenHeight * 0.04), // ~32px
                // Description text
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: localizations.aiPsychologyNewGeneration,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w700,
                          fontSize: screenWidth * 0.053, // ~20px on 375px
                          height: 1.2, // 24/20
                          color: const Color(0xFFBC91DB),
                        ),
                      ),
                      TextSpan(
                        text: localizations.createdInUkraine,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w400,
                          fontSize: screenWidth * 0.053, // ~20px on 375px
                          height: 1.2, // 24/20
                          color: const Color(0xFF272727),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: MediaQuery.of(context).padding.bottom + screenHeight * 0.1,
                ), // Spacing for bottom nav
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLargeButton({
    required BuildContext context,
    required Widget icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    required double screenWidth,
    required double screenHeight,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: screenHeight * 0.111, // ~90px on 812px
        width: double.infinity,
        decoration: BoxDecoration(
          image: const DecorationImage(image: AssetImage('assets/bg_large_button.png'), fit: BoxFit.fill),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.043), // ~16px
          child: Row(
            children: [
              // Icon
              Container(
                width: screenWidth * 0.168, // ~63px on 375px
                height: screenWidth * 0.168, // ~63px on 375px
                decoration: BoxDecoration(color: const Color(0xFFBC91DB), shape: BoxShape.circle),
                child: Center(child: icon),
              ),

              SizedBox(width: screenWidth * 0.043), // ~16px
              // Text
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w700,
                        fontSize: screenWidth * 0.043, // ~16px
                        height: 1.25, // 20/16
                        color: const Color(0xFFBC91DB),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.002), // ~2px
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w400,
                        fontSize: screenWidth * 0.032, // ~12px
                        height: 1.25, // 15/12
                        color: const Color(0xFF272727),
                      ),
                    ),
                  ],
                ),
              ),

              // Right arrow
              SvgPicture.asset(
                'assets/ic_arrow_right.svg',
                width: screenWidth * 0.027, // ~10px on 375px
                height: screenHeight * 0.022, // ~18px on 812px
              ),
            ],
          ),
        ),
      ),
    );
  }
}
