import 'package:flutter/material.dart';
import '../constants/app_palette.dart';
import '../widgets/app_background.dart';
import 'package:provider/provider.dart';
import '../widgets/common_header.dart';
import '../providers/auth_provider.dart';
import '../providers/subscription_provider.dart';
import '../services/firestore_service.dart';
import '../models/test_result.dart';
import '../l10n/app_localizations.dart';
import 'test_result_screen.dart';
import 'share_result_screen.dart';
import 'chat_screen.dart';
import 'paywall_screen.dart';

class TestHistoryScreen extends StatelessWidget {
  const TestHistoryScreen({super.key});

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
    final authProvider = Provider.of<AuthProvider>(context);
    final userId = authProvider.user?.uid;

    if (userId == null) {
      return Scaffold(
        backgroundColor: context.palette.scaffold,
        body: AppBackground(
          lightImage: 'assets/background_main.png',
          child: const SafeArea(
            child: Center(
              child: Text(
                'Необхідно авторизуватися',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  color: Color(0xFFA3A3A3),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.palette.scaffold,
      body: AppBackground(
        lightImage: 'assets/background_main.png',
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04), // 15px on 375px
            child: StreamBuilder<List<TestResult>>(
              stream: FirestoreService().getUserTestResults(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFBC91DB))),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      '${localizations.error}: ${snapshot.error}',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        color: Color(0xFFA3A3A3),
                      ),
                    ),
                  );
                }

                final testResults = snapshot.data ?? [];

                if (testResults.isEmpty) {
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        CommonHeader(showBackButton: true, onBack: () => Navigator.of(context).pop()),
                        SizedBox(height: screenHeight * 0.037),
                        Center(
                          child: Text(
                            localizations.historyEmpty,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: Color(0xFFA3A3A3),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          CommonHeader(showBackButton: true, onBack: () => Navigator.of(context).pop()),
                          SizedBox(height: screenHeight * 0.037), // ~30px on 812px
                        ],
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.only(
                        bottom: screenHeight * 0.15, // Bottom spacing for bottom menu
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final testResult = testResults[index];
                          return _buildTestResultItem(context, testResult, screenWidth, screenHeight, localizations);
                        }, childCount: testResults.length),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  Widget _buildTestResultItem(BuildContext context, TestResult testResult, double screenWidth, double screenHeight, AppLocalizations localizations) {
    return GestureDetector(
      onTap: () {
        // Open test results screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TestResultScreen(
              psychotype: testResult.psychotype,
              description: testResult.description,
              recommendations: testResult.recommendations,
              isLoading: false,
              onGoToChat: () async {
                Navigator.of(context).pop();
                // Check subscription before opening chat
                final subscriptionProvider = Provider.of<SubscriptionProvider>(context, listen: false);
                await subscriptionProvider.refreshStatus();
                
                if (subscriptionProvider.isPremium) {
                  // If subscription active - open chat
                  if (context.mounted) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(onBack: () => Navigator.of(context).pop()),
                      ),
                    );
                  }
                } else {
                  // If no subscription - show paywall
                  if (context.mounted) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PaywallScreen(
                          onSubscribed: () {
                            // After subscription purchase open chat
                            Navigator.of(context).pop(); // Close paywall
                            if (context.mounted) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(onBack: () => Navigator.of(context).pop()),
                                ),
                              );
                            }
                          },
                          onBack: () => Navigator.of(context).pop(),
                        ),
                      ),
                    );
                  }
                }
              },
              onShare: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        ShareResultScreen(psychotype: testResult.psychotype, onBack: () => Navigator.of(context).pop()),
                  ),
                );
              },
              onBack: () => Navigator.of(context).pop(),
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: screenHeight * 0.03), // 24px on 812px
        width: screenWidth * 0.917, // 344px on 375px
        height: screenHeight * 0.111, // 90px on 812px
        decoration: context.palette.isDark
            ? BoxDecoration(
                color: context.palette.surface,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: context.palette.surfaceBorder, width: 1.5),
              )
            : BoxDecoration(
                image: const DecorationImage(image: AssetImage('assets/bg_card_history.png'), fit: BoxFit.fill),
                borderRadius: BorderRadius.circular(99),
              ),
        child: Stack(
          children: [
            // Main content
            Padding(
              padding: EdgeInsets.only(
                left: screenWidth * 0.037, // 14px on 375px
                right:
                    screenWidth * 0.037 +
                    screenWidth * 0.197 +
                    screenWidth * 0.021, // 14px + 74px (button) + 8px (spacing)
              ),
              child: Row(
                children: [
                  // Psychotype image (same as results screen)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: Image.asset(
                      'assets/test_result_${_getImageIndex(testResult.psychotype)}.png',
                      width: screenWidth * 0.168, // 63px on 375px
                      height: screenWidth * 0.168,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.032), // 12px
                  // Text
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Psychotype name
                        Text(
                          testResult.psychotype,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            height: 1.21, // 17px / 14px
                            color: Color(0xFFBC91DB),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: screenHeight * 0.015), // 12px gap
                        // Time and date
                        Row(
                          children: [
                            Text(
                              _formatTime(testResult.createdAt),
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                height: 1.21,
                                color: Color(0xFFA3A3A3),
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.021), // 8px
                            Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(color: Color(0xFFA3A3A3), shape: BoxShape.circle),
                            ),
                            SizedBox(width: screenWidth * 0.021), // 8px
                            Text(
                              _formatDate(testResult.createdAt),
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                height: 1.21,
                                color: Color(0xFFA3A3A3),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // "Saved" button on right
            Positioned(
              right: screenWidth * 0.037, // 14px
              top: screenHeight * 0.042, // 34px on 812px
              child: Container(
                width: screenWidth * 0.197, // 74px on 375px
                height: screenHeight * 0.027, // 22px on 812px
                decoration: BoxDecoration(color: const Color(0xFFBC91DB), borderRadius: BorderRadius.circular(99)),
                child: Center(
                  child: Text(
                    localizations.saved,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w400,
                      fontSize: 10,
                      height: 1.2, // 12px / 10px
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
