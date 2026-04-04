import 'package:flutter/material.dart';
import '../widgets/common_header.dart';
import '../l10n/app_localizations.dart';

class SessionCompleteScreen extends StatelessWidget {
  final VoidCallback? onGoToMain;
  final VoidCallback? onBack;

  const SessionCompleteScreen({super.key, this.onGoToMain, this.onBack});

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
              // Common header with back button and logo
              CommonHeader(onBack: onBack, showBackButton: true),
              SizedBox(height: screenHeight * 0.227), // ~225px on 812px (spacing to content)
              // Main content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Content container
                      SizedBox(
                        width: screenWidth * 0.92, // 345px on 375px
                        child: Column(
                          children: [
                            // Text
                            SizedBox(
                              width: screenWidth * 0.92, // 345px
                              child: Text(
                                localizations.sessionCompleted,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20,
                                  height: 1.2, // 24px / 20px
                                  color: Color(0xFFBC91DB),
                                ),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.048), // 39px gap
                            // Robot illustration
                            SizedBox(
                              width: screenWidth * 0.637, // 239px on 375px
                              height: screenWidth * 0.637, // 239px on 375px
                              child: Image.asset('assets/finish_session.png', fit: BoxFit.contain),
                            ),
                            SizedBox(height: screenHeight * 0.048), // 39px gap
                            // "To main page" button
                            GestureDetector(
                              onTap: onGoToMain ?? () {},
                              child: Container(
                                width: screenWidth * 0.92, // 345px on 375px
                                height: screenHeight * 0.062, // 50px on 812px
                                decoration: BoxDecoration(
                                  color: const Color(0xFFBC91DB),
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                child: Center(
                                  child: Text(
                                    localizations.toMainPage,
                                    style: const TextStyle(
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
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
