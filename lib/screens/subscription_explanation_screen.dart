import 'package:flutter/material.dart';
import '../constants/app_text.dart';
import '../widgets/background_widget.dart';
import '../widgets/app_header.dart';

class SubscriptionExplanationScreen extends StatelessWidget {
  final VoidCallback? onContinue;
  final VoidCallback? onBack;

  const SubscriptionExplanationScreen({super.key, this.onContinue, this.onBack});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // Adaptive sizes
    final paddingTop = screenHeight * 0.06;
    final paddingHorizontal = screenWidth * 0.02;
    final paddingBottom = screenHeight * 0.04;

    final contentWidth = screenWidth - (paddingHorizontal * 2);
    final buttonHeight = 40.0; // 50/812
    final buttonWidth = 200.0;
    final contentSpacing = screenHeight * 0.074; // 60/812
    final blockSpacing = screenHeight * 0.007; // 30/812

    // Adaptive font sizes
    final bodyFontSize = screenWidth * 0.043; // 16/375
    final sectionFontSize = screenWidth * 0.037; // 14/375

    return Scaffold(
      body: BackgroundWidget(
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
                  AppHeader(
                    showBackButton: true,
                    onBackPressed: onBack,
                    rightWidget: Icon(Icons.more_vert, color: const Color(0xFF75B3E1), size: screenWidth * 0.064),
                  ),
                  SizedBox(height: contentSpacing),

                  // Main content
                  Container(
                    width: contentWidth,
                    padding: EdgeInsets.all(screenWidth * 0.003), // 20/375
                    // decoration: ShapeDecoration(
                    //   color: Colors.white,
                    //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    // ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section 1 - About psychologists
                        _buildModernSection(
                          iconPath: 'assets/ic_people_1.png',
                          title: 'Я - штучний психолог',
                          description:
                              'У реальному житті багато психологів орієнтовані на гроші - більше сесій, більше записів, більше оплат.',
                          benefits: [
                            'У мене немає емоцій, інтересу, адібності',
                            'Я не веду тебе на кількість сесій',
                            'Я веду тебе до результату',
                          ],
                          fontSize: sectionFontSize,
                          screenHeight: screenHeight,
                        ),
                        SizedBox(height: blockSpacing),

                        // Section 2 - About subscription
                        _buildModernSection(
                          iconPath: 'assets/ic_people_2.png',
                          title: 'Навіщо підписка?',
                          description:
                              'Це не просто "взяти з тебе гроші". Це — підтримка розвитку цього додатку, щоб зробити його ще сильнішим і доступнішим для інших.',
                          benefits: [
                            'Практики, що працюють',
                            'Кишенькового психолога 24/7',
                            'Підтримку в моменти тривоги, сорому, емоційного болю',
                          ],
                          fontSize: sectionFontSize,
                          screenHeight: screenHeight,
                        ),
                        SizedBox(height: blockSpacing),

                        // Section 3 - About app
                        _buildModernSection(
                          iconPath: 'assets/ic_people_3.png',
                          title: 'AI Psychology Balance',
                          description: 'Це твій простір для усвідомлення, чесності з собою і пошуку балансу.',
                          benefits: [
                            'Додаток створений не для того, щоб навішати ярлики',
                            'Дає тобі просту, але точну карту внутрішнього стану',
                            'Немає "нормальних" чи "ненормальних" - є твоє унікальне "зараз"',
                          ],
                          fontSize: sectionFontSize,
                          screenHeight: screenHeight,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: contentSpacing),

                  // Continue button
                  Container(
                    width: buttonWidth,
                    height: buttonHeight,
                    decoration: ShapeDecoration(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: onContinue,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Продовжити',
                                style: TextStyle(
                                  color: const Color(0xFF272727),
                                  fontSize: bodyFontSize,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.027), // 10/375
                              Image.asset(
                                'assets/ic_leaves_3.png',
                                width: screenWidth * 0.048, // 18/375
                                height: screenWidth * 0.048, // 18/375
                                color: const Color(0xFF4CAF50),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernSection({
    required String iconPath,
    required String title,
    required String description,
    List<String>? benefits,
    required double fontSize,
    required double screenHeight,
  }) {
    return Container(
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF75B3E1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: Image.asset(iconPath, width: 24, height: 24, color: const Color(0xFF75B3E1))),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppText.getHeadingStyle(
                    fontSize + 4,
                  ).copyWith(color: Colors.black, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(description, style: AppText.getBodyStyle(fontSize).copyWith(color: Colors.black, height: 1.4)),
                if (benefits != null) ...[
                  SizedBox(height: 12),
                  ...benefits
                      .map(
                        (benefit) => Padding(
                          padding: EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 4,
                                height: 4,
                                margin: EdgeInsets.only(top: 6, right: 8),
                                decoration: BoxDecoration(color: const Color(0xFF75B3E1), shape: BoxShape.circle),
                              ),
                              Expanded(
                                child: Text(
                                  benefit,
                                  style: AppText.getBodyStyle(fontSize).copyWith(color: Colors.black, height: 1.3),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
