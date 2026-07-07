import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../widgets/common_header.dart';
import '../widgets/mood_face.dart';

class TestIntroScreen extends StatelessWidget {
  final VoidCallback? onStart;
  final VoidCallback? onBack;

  const TestIntroScreen({super.key, this.onStart, this.onBack});

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
          image: DecorationImage(image: AssetImage('assets/background.png'), fit: BoxFit.cover),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with back button
              CommonHeader(onBack: onBack, showBackButton: true),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04), // 15px on 375px
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: screenHeight * 0.048), // ~39px on 812px
                      // Title
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: localizations.testIntroInvite,
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w500,
                                fontSize: 20,
                                height: 1.2, // 24px / 20px
                                color: Color(0xFFBC91DB),
                              ),
                            ),
                            TextSpan(
                              text: localizations.psychotypeTest,
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                                height: 1.2, // 24px / 20px
                                color: Color(0xFFBC91DB),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03), // ~24px
                      // Instructions
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          localizations.chooseEmoji,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            height: 1.25, // 20px / 16px
                            color: Color(0xFF000000),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.022), // ~18px
                      // Answer options
                      Column(
                        children: [
                          _buildEmojiOption(
                            level: 0,
                            text: localizations.notAboutMe,
                            screenWidth: screenWidth,
                          ),
                          SizedBox(height: screenHeight * 0.022), // 18px gap
                          _buildEmojiOption(
                            level: 1,
                            text: localizations.ratherNot,
                            screenWidth: screenWidth,
                          ),
                          SizedBox(height: screenHeight * 0.022), // 18px gap
                          _buildEmojiOption(
                            level: 2,
                            text: localizations.partially,
                            screenWidth: screenWidth,
                          ),
                          SizedBox(height: screenHeight * 0.022), // 18px gap
                          _buildEmojiOption(
                            level: 3,
                            text: localizations.fullyAboutMe,
                            screenWidth: screenWidth,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // "Start" button
              Padding(
                padding: EdgeInsets.only(
                  left: screenWidth * 0.04,
                  right: screenWidth * 0.04,
                  bottom: screenHeight * 0.037, // ~30px on 812px
                ),
                child: GestureDetector(
                  onTap: onStart,
                  child: Container(
                    height: screenHeight * 0.062, // 50px on 812px
                    decoration: BoxDecoration(color: const Color(0xFFBC91DB), borderRadius: BorderRadius.circular(99)),
                    child: Center(
                      child: Text(
                        localizations.start,
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmojiOption({required int level, required String text, required double screenWidth}) {
    return Container(
      width: double.infinity,
      height: screenWidth * 0.16, // 60px on 375px
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
      decoration: BoxDecoration(
        image: const DecorationImage(image: AssetImage('assets/bg_emoji_card.png'), fit: BoxFit.fill),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        children: [
          SizedBox(width: screenWidth * 0.028), // ~10px left padding
          MoodFace(level: level, size: screenWidth * 0.12), // 44.88px on 375px
          SizedBox(width: screenWidth * 0.038), // 18px gap
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
              fontSize: 16,
              height: 1.25, // 20px / 16px
              color: Color(0xFF000000),
            ),
          ),
        ],
      ),
    );
  }
}
