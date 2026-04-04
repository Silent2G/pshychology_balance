import 'package:flutter/material.dart';
import 'registration_screen.dart';
import '../l10n/app_localizations.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _navigateToRegistration(BuildContext context, bool isLogin) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RegistrationScreen(
          initialIsLogin: isLogin,
          onRegister: isLogin ? null : () => Navigator.of(context).pop(),
          onLogin: isLogin ? () => Navigator.of(context).pop() : null,
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/background.png'), fit: BoxFit.cover),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: screenWidth * 0.043,
              right: screenWidth * 0.043,
              bottom: MediaQuery.of(context).padding.bottom + screenHeight * 0.02, // Extra bottom spacing
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.018), // ~39px on 812px
                // Head logo
                SizedBox(
                  width: screenWidth * 0.229, // ~86px on 375px
                  height: screenHeight * 0.142, // ~115px on 812px
                  child: Image.asset('assets/logo_head.png', fit: BoxFit.contain),
                ),

                SizedBox(height: 40), // ~20px
                // "Hello! I'm AI Psychologist" header
                Text(
                  localizations.welcomeHello,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                    fontSize: screenWidth * 0.064, // ~24px on 375px
                    height: 1.208, // 29/24
                    color: const Color(0xFFBC91DB),
                  ),
                ),

                SizedBox(height: screenHeight * 0.05), // ~50px
                // First description text
                Text(
                  localizations.welcomeDescription1,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400,
                    fontSize: screenWidth * 0.053, // ~20px on 375px
                    height: 1.2, // 24/20
                    color: const Color(0xFF272727),
                  ),
                ),

                SizedBox(height: screenHeight * 0.02), // ~42px
                // Down arrow
                SizedBox(
                  width: screenWidth * 0.093, // ~35px on 375px
                  height: screenHeight * 0.073, // ~59px on 812px
                  child: Image.asset('assets/arrow_down.png', fit: BoxFit.contain),
                ),

                SizedBox(height: screenHeight * 0.023), // ~19px
                // Second description text
                Text(
                  localizations.welcomeDescription2,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400,
                    fontSize: screenWidth * 0.053, // ~20px on 375px
                    height: 1.2, // 24/20
                    color: const Color(0xFF272727),
                  ),
                ),

                SizedBox(height: screenHeight * 0.04), // ~32px (reduced from 64px)
                // Buttons
                Column(
                  children: [
                    _buildPurpleButton(
                      context: context,
                      text: localizations.login,
                      onPressed: () => _navigateToRegistration(context, true),
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                    ),
                    SizedBox(height: screenHeight * 0.02), // ~16px
                    _buildPurpleButton(
                      context: context,
                      text: localizations.register,
                      onPressed: () => _navigateToRegistration(context, false),
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                    ),
                    SizedBox(height: screenHeight * 0.03), // Extra bottom spacing
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPurpleButton({
    required BuildContext context,
    required String text,
    required VoidCallback onPressed,
    required double screenWidth,
    required double screenHeight,
  }) {
    return SizedBox(
      height: screenHeight * 0.062, // ~50px on 812px
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFBC91DB),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.027, // ~10px
            vertical: screenHeight * 0.012, // ~10px
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
            fontSize: screenWidth * 0.043, // ~16px on 375px
            height: 1.25, // 20/16
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
