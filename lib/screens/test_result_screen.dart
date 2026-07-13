import 'package:flutter/material.dart';
import '../constants/app_palette.dart';
import '../widgets/app_background.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;
import '../widgets/common_header.dart';
import '../l10n/app_localizations.dart';

class TestResultScreen extends StatelessWidget {
  final String psychotype;
  final String description;
  final List<String> recommendations;
  final bool isLoading;
  final VoidCallback? onGoToChat;
  final VoidCallback? onShare;
  final VoidCallback? onBack;

  const TestResultScreen({
    super.key,
    required this.psychotype,
    required this.description,
    this.recommendations = const [],
    this.isLoading = false,
    this.onGoToChat,
    this.onShare,
    this.onBack,
  });

  // Psychotype to image number mapping (1-5)
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
      backgroundColor: context.palette.scaffold,
      body: AppBackground(
        lightImage: 'assets/background_main.png',
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
                SizedBox(height: screenHeight * 0.029), // ~15px on 812px
                // "Your psychotype" header - show only when not loading
                if (!isLoading) ...[
                  Text(
                    localizations.yourPsychotype,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                      fontSize: screenWidth * 0.053, // 20px on 375px
                      height: 1.2, // 24px / 20px
                      color: const Color(0xFFBC91DB),
                    ),
                  ),
                  // Psychotype name
                  Text(
                    psychotype.isEmpty ? 'Аналіз...' : psychotype,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                      fontSize: screenWidth * 0.053, // ~30px on 375px
                      height: 1.2,
                      color: const Color(0xFF9557C2), // Dark purple
                    ),
                  ),
                ],
                // SizedBox(height: screenHeight * 0.01), // ~24px
                // Illustration or loading indicator
                if (isLoading)
                  SizedBox(
                    width: screenWidth * 0.851, // 319px on 375px
                    height: screenWidth * 0.851, // 319px on 375px
                    child: const Center(
                      child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFBC91DB))),
                    ),
                  )
                else
                  SizedBox(
                    width: screenWidth * 0.851, // 319px on 375px
                    height: screenWidth * 0.851, // 319px on 375px
                    child: Image.asset('assets/test_result_${_getImageIndex(psychotype)}.png', fit: BoxFit.contain),
                  ),
                // SizedBox(height: screenHeight * 0.017), // ~30px
                // Description
                Text(
                  isLoading
                      ? localizations.waitAnalyzing
                      : (description.isEmpty ? localizations.waitAnalyzing : description),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                    fontSize: screenWidth * 0.043, // 16px on 375px
                    height: 1.25, // 20px / 16px
                    color: context.palette.textPrimary,
                  ),
                ),
                SizedBox(height: screenHeight * 0.04), // ~32px
                // "Tips" section
                if (!isLoading && recommendations.isNotEmpty) ...[
                  Text(
                    localizations.tips,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                      fontSize: screenWidth * 0.053, // 20px on 375px
                      height: 1.2, // 24px / 20px
                      color: const Color(0xFFBC91DB),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02), // ~16px
                  // Recommendations list
                  ...recommendations.map(
                    (recommendation) => Padding(
                      padding: EdgeInsets.only(bottom: screenHeight * 0.015), // ~12px
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // List icon
                          Padding(
                            padding: EdgeInsets.only(top: screenHeight * 0.01, right: screenWidth * 0.032), // 12px
                            child: SvgPicture.asset(
                              'assets/ic_todo_list.svg',
                              width: screenWidth * 0.048, // 18px on 375px
                              height: screenWidth * 0.048,
                            ),
                          ),
                          // Recommendation text
                          Expanded(
                            child: Text(
                              recommendation,
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w500,
                                fontSize: screenWidth * 0.043, // 16px on 375px
                                height: 1.25, // 20px / 16px
                                color: context.palette.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02), // ~16px
                ],
                // Buttons
                if (!isLoading) ...[
                  SizedBox(height: screenHeight * 0.02), // ~16px
                  // "Go to chat" button
                  GestureDetector(
                    onTap: onGoToChat,
                    child: Container(
                      width: double.infinity,
                      height: screenHeight * 0.062, // 50px on 812px
                      decoration: BoxDecoration(
                        color: const Color(0xFFBC91DB),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Center(
                        child: Text(
                          localizations.goToChat,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w700,
                            fontSize: screenWidth * 0.043, // 16px on 375px
                            height: 1.25, // 20px / 16px
                            color: const Color(0xFFFFFFFF),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02), // ~16px
                  // "Share result" button
                  GestureDetector(
                    onTap: onShare,
                    child: Container(
                      width: double.infinity,
                      height: screenHeight * 0.062, // 50px on 812px
                      decoration: BoxDecoration(
                        color: const Color(0xFFBC91DB),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Center(
                        child: Text(
                          localizations.shareResult,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w700,
                            fontSize: screenWidth * 0.043, // 16px on 375px
                            height: 1.25, // 20px / 16px
                            color: const Color(0xFFFFFFFF),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                SizedBox(height: screenHeight * 0.037), // ~30px bottom
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom painter for drawing star
class StarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFBC91DB)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final innerRadius = radius * 0.4;

    final path = Path();
    final angle = math.pi / 4; // 45 degrees for 4-point star

    for (int i = 0; i < 8; i++) {
      final currentAngle = i * angle - math.pi / 2;
      final r = (i % 2 == 0) ? radius : innerRadius;
      final x = center.dx + r * math.cos(currentAngle);
      final y = center.dy + r * math.sin(currentAngle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
