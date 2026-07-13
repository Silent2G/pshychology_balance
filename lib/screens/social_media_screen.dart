import 'package:flutter/material.dart';
import '../constants/app_palette.dart';
import '../widgets/app_background.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/common_header.dart';
import '../l10n/app_localizations.dart';

class SocialMediaScreen extends StatelessWidget {
  final VoidCallback? onBack;

  const SocialMediaScreen({super.key, this.onBack});

  Future<void> _openSocialMedia(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
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
                SizedBox(height: screenHeight * 0.08), // ~65px on 812px

                // Main content
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08), // ~30px on 375px
                  child: Column(
                    children: [
                      // Description text
                      Text(
                        localizations.socialMediaDescription,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          height: 1.25, // 20px / 16px
                          color: const Color(0xFFBC91DB),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.038), // ~31px on 812px

                      // Social network buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Facebook
                          GestureDetector(
                            onTap: () => _openSocialMedia('https://www.facebook.com/profile.php?id=61585117951980'),
                            child: Container(
                              width: screenWidth * 0.133, // 50px on 375px
                              height: screenWidth * 0.133,
                              decoration: BoxDecoration(
                                color: const Color(0xFFBC91DB),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  'assets/ic_facebook.svg',
                                  width: screenWidth * 0.064, // 24px on 375px
                                  height: screenWidth * 0.064,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.045), // ~17px on 375px

                          // Instagram
                          GestureDetector(
                            onTap: () => _openSocialMedia('https://www.instagram.com/ai_psychology_balance?utm_source=qr'),
                            child: Container(
                              width: screenWidth * 0.133, // 50px on 375px
                              height: screenWidth * 0.133,
                              decoration: BoxDecoration(
                                color: const Color(0xFFBC91DB),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  'assets/ic_instagram.svg',
                                  width: screenWidth * 0.053, // 20px on 375px
                                  height: screenWidth * 0.053,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.045), // ~17px on 375px

                          // TikTok
                          GestureDetector(
                            onTap: () => _openSocialMedia('https://www.tiktok.com/@ai_psychology_bal?_r=1'),
                            child: Container(
                              width: screenWidth * 0.133, // 50px on 375px
                              height: screenWidth * 0.133,
                              decoration: BoxDecoration(
                                color: const Color(0xFFBC91DB),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  'assets/ic_tiktok.svg',
                                  width: screenWidth * 0.064, // 24px on 375px
                                  height: screenWidth * 0.064,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.15), // Spacing for bottom menu
              ],
            ),
          ),
        ),
      ),
    );
  }
}
