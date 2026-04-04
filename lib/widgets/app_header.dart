import 'package:flutter/material.dart';
import '../constants/app_text.dart';

class AppHeader extends StatelessWidget {
  final double? screenWidth;
  final double? screenHeight;
  final bool showDotsMenu;
  final VoidCallback? onDotsPressed;
  final Widget? rightWidget;
  final String? title;
  final bool showLogo;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const AppHeader({
    super.key,
    this.screenWidth,
    this.screenHeight,
    this.showDotsMenu = true,
    this.onDotsPressed,
    this.rightWidget,
    this.title,
    this.showLogo = true,
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final currentScreenWidth = screenWidth ?? screenSize.width;
    final currentScreenHeight = screenHeight ?? screenSize.height;

    // If title passed, show simple header
    if (title != null) {
      return Text(title!, style: AppText.getHeadingStyle(24).copyWith(color: Color(0xFF75B3E1)));
    }

    // Reduce sizes on mobile (all screens below 900px)
    final isMobile = currentScreenHeight < 900;
    final logoSize = isMobile ? currentScreenWidth * 0.13 : currentScreenWidth * 0.187;
    final titleFontSize = isMobile ? currentScreenWidth * 0.038 : currentScreenWidth * 0.053;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left: back button + logo with name
        Row(
          children: [
            // Back button (if showBackButton = true)
            if (showBackButton) ...[_buildBackButton(), SizedBox(width: currentScreenWidth * 0.032)],

            // Logo (if showLogo = true)
            if (showLogo) ...[
              Container(
                width: logoSize,
                height: logoSize,
                decoration: BoxDecoration(
                  image: const DecorationImage(image: AssetImage('assets/logo.jpg'), fit: BoxFit.fill),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              SizedBox(width: currentScreenWidth * 0.032),
            ],

            // Name
            Text(
              'AI PSYCHOLOGY \nBALANCE',
              textAlign: TextAlign.left,
              style: AppText.getHeadingStyle(titleFontSize).copyWith(color: const Color(0xFF75B3E1), height: 1.3),
            ),
          ],
        ),

        // Right element (three dots or custom widget)
        if (rightWidget != null)
          rightWidget!
        else if (showDotsMenu)
          _buildDotsMenu()
        else
          const SizedBox(width: 24), // Placeholder for alignment
      ],
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: onBackPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(Icons.arrow_back_ios, color: const Color(0xFF75B3E1), size: 20),
      ),
    );
  }

  Widget _buildDotsMenu() {
    return GestureDetector(
      onTap: onDotsPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          3,
          (index) => Container(
            width: 3,
            height: 3,
            margin: const EdgeInsets.symmetric(vertical: 1),
            decoration: const BoxDecoration(color: Color(0xFF272727), shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}
