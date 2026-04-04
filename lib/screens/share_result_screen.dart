import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/common_header.dart';
import '../services/share_service.dart';
import '../l10n/app_localizations.dart';

class ShareResultScreen extends StatelessWidget {
  final String psychotype;
  final VoidCallback? onBack;

  const ShareResultScreen({
    super.key,
    required this.psychotype,
    this.onBack,
  });

  // Psychotype to image number mapping (1-5) - same logic as TestResultScreen
  int _getImageIndex(String psychotype) {
    final lowerPsychotype = psychotype.toLowerCase();
    if (lowerPsychotype.contains('аналітик') || lowerPsychotype.contains('analyst')) {
      return 1;
    } else if (lowerPsychotype.contains('баланс') || lowerPsychotype.contains('balance')) {
      return 2;
    } else if (lowerPsychotype.contains('соціальний') || lowerPsychotype.contains('social')) {
      return 3;
    } else if (lowerPsychotype.contains('інтроверт') || lowerPsychotype.contains('introvert')) {
      return 4;
    } else {
      // Default to 5th image
      return 5;
    }
  }

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
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Common header with back button and logo
                CommonHeader(
                  onBack: onBack,
                  showBackButton: true,
                ),
                SizedBox(height: screenHeight * 0.029),
                // "My psychotype" header
                Text(
                  localizations.myPsychotype,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                    fontSize: screenWidth * 0.053, // 20px on 375px
                    height: 1.2,
                    color: const Color(0xFFBC91DB),
                  ),
                ),
                // Psychotype name
                Text(
                  psychotype.isEmpty ? localizations.analyzing : psychotype,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                    fontSize: screenWidth * 0.053, // 20px on 375px
                    height: 1.2,
                    color: const Color(0xFFBC91DB),
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                // Illustration
                SizedBox(
                  width: screenWidth * 0.635, // 238px on 375px
                  height: screenWidth * 0.635,
                  child: Image.asset(
                    'assets/test_result_${_getImageIndex(psychotype)}.png',
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: screenHeight * 0.037),
                // "Share result in:" text
                Text(
                  localizations.shareResultIn,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400,
                    fontSize: screenWidth * 0.043, // 16px on 375px
                    height: 1.25,
                    color: const Color(0xFF9557C2),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                // Social media buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Facebook
                    _buildSocialButton(
                      context: context,
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                      iconPath: 'assets/ic_facebook.svg',
                      onTap: () {
                        ShareService.shareToFacebook(psychotype, context: context);
                      },
                    ),
                    SizedBox(width: screenWidth * 0.045), // 17px gap
                    // WhatsApp
                    _buildSocialButton(
                      context: context,
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                      iconPath: 'assets/ic_whatsapp.svg',
                      onTap: () {
                        ShareService.shareToWhatsApp(psychotype, context: context);
                      },
                    ),
                    SizedBox(width: screenWidth * 0.045),
                    // Instagram
                    _buildSocialButton(
                      context: context,
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                      iconPath: 'assets/ic_instagram.svg',
                      onTap: () {
                        ShareService.shareToInstagram(psychotype, context: context);
                      },
                    ),
                    SizedBox(width: screenWidth * 0.045),
                    // Telegram
                    _buildSocialButton(
                      context: context,
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                      iconPath: 'assets/ic_telegram.svg',
                      onTap: () {
                        ShareService.shareToTelegram(psychotype, context: context);
                      },
                    ),
                    SizedBox(width: screenWidth * 0.045),
                    // Link (general share)
                    _buildSocialButton(
                      context: context,
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                      iconPath: 'assets/ic_link.svg',
                      onTap: () {
                        ShareService.shareGeneral(psychotype, context: context);
                      },
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.037),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required BuildContext context,
    required double screenWidth,
    required double screenHeight,
    required String iconPath,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: Builder(
        builder: (builderContext) => InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(screenWidth * 0.133 / 2),
          child: Container(
            width: screenWidth * 0.133, // 50px on 375px
            height: screenWidth * 0.133,
            decoration: BoxDecoration(
              color: const Color(0xFFBC91DB),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SvgPicture.asset(
                iconPath,
                width: screenWidth * 0.064, // 24px on 375px
                height: screenWidth * 0.064,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

