import 'package:flutter/material.dart';
import '../constants/app_palette.dart';
import '../widgets/app_background.dart';
import '../constants/app_text.dart';
import '../widgets/app_header.dart';

class TestResultShareScreen extends StatelessWidget {
  final String psychotype;
  final String description;
  final List<String> recommendations;
  final bool isLoading;
  final VoidCallback? onNext;
  final VoidCallback? onBack;

  const TestResultShareScreen({
    super.key,
    required this.psychotype,
    required this.description,
    this.recommendations = const [],
    this.isLoading = false,
    this.onNext,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // Adaptive sizes
    final paddingTop = 20.0;
    final paddingHorizontal = screenWidth * 0.04;
    final paddingBottom = screenHeight * 0.04;

    final contentWidth = screenWidth - (paddingHorizontal * 2);
    final buttonHeight = screenHeight * 0.062; // 50/812
    final buttonWidth = contentWidth;
    final contentSpacing = screenHeight * 0.074; // 60/812
    final blockSpacing = screenHeight * 0.037; // 30/812

    // Adaptive font sizes
    final resultFontSize = screenWidth * 0.064; // 24/375
    final bodyFontSize = screenWidth * 0.043; // 16/375

    return Scaffold(
      backgroundColor: context.palette.scaffold,
      body: AppBackground(
        lightImage: 'assets/background_main.png',
        child: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              width: screenWidth,
              constraints: BoxConstraints(minHeight: screenHeight),
              padding: EdgeInsets.only(
                top: paddingTop,
                left: paddingHorizontal,
                right: paddingHorizontal,
                bottom: paddingBottom,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header
                  AppHeader(showBackButton: true, onBackPressed: onBack),
                  SizedBox(height: contentSpacing),
                  // Content
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (isLoading)
                        // Show only loading during analysis
                        Column(
                          children: [
                            SizedBox(height: screenHeight * 0.25),
                            const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF75B3E1)),
                              strokeWidth: 3,
                            ),
                            SizedBox(height: blockSpacing * 1.5),
                            Text(
                              'Аналізуємо ваші відповіді...',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: bodyFontSize,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        )
                      else
                        // Show results after loading
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Result header
                            Text(
                              'Твій психотип:\n${psychotype}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: resultFontSize,
                                fontWeight: FontWeight.w700,
                                height: 1.3,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            SizedBox(height: blockSpacing),
                            // Large emoji - positive smiley
                            Container(
                              width: screenWidth * 0.2,
                              height: screenWidth * 0.2,
                              child: Image.asset(
                                'assets/ic_emoji_4.png', // Happy smiley
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.contain,
                              ),
                            ),
                            SizedBox(height: blockSpacing),
                            // Description
                            SizedBox(
                              width: contentWidth,
                              child: Text(
                                description,
                                textAlign: TextAlign.center,
                                style: AppText.getBodyStyle(
                                  bodyFontSize,
                                ).copyWith(color: Colors.black, fontWeight: FontWeight.w500, height: 1.4),
                              ),
                            ),
                            SizedBox(height: blockSpacing),
                            // Recommendations header
                            Text(
                              'Поради',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: resultFontSize,
                                fontWeight: FontWeight.w700,
                                height: 1.3,
                              ),
                            ),
                            SizedBox(height: blockSpacing * 0.5),
                            // Recommendations list
                            if (recommendations.isNotEmpty)
                              Container(
                                width: contentWidth,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    for (int i = 0; i < recommendations.length; i++) ...[
                                      _buildRecommendation(recommendations[i]),
                                      if (i < recommendations.length - 1) SizedBox(height: blockSpacing * 0.25),
                                    ],
                                  ],
                                ),
                              ),
                            SizedBox(height: contentSpacing),
                            // Button
                            GestureDetector(
                              onTap: onNext,
                              child: Container(
                                width: buttonWidth,
                                height: buttonHeight,
                                padding: EdgeInsets.all(screenWidth * 0.027), // 10/375
                                clipBehavior: Clip.antiAlias,
                                decoration: ShapeDecoration(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Перейти до чату',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: bodyFontSize,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendation(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(top: 8, right: 12),
          decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w400, height: 1.4),
          ),
        ),
      ],
    );
  }
}
