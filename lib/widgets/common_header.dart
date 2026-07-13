import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_palette.dart';

class CommonHeader extends StatelessWidget {
  final VoidCallback? onBack;
  final bool showBackButton;

  const CommonHeader({
    super.key,
    this.onBack,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.043), // 16px on 375px
      child: Row(
        children: [
          // Back button (if needed)
          if (showBackButton)
            GestureDetector(
              onTap: onBack,
              child: Container(
                width: screenWidth * 0.133, // 50px on 375px
                height: screenWidth * 0.133,
                decoration: context.palette.isDark
                    ? BoxDecoration(
                        color: context.palette.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: context.palette.surfaceBorder, width: 1.5),
                      )
                    : const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/bg_circle_button.png'),
                          fit: BoxFit.fill,
                        ),
                        shape: BoxShape.circle,
                      ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/ic_arrow_back.svg',
                    width: screenWidth * 0.085, // 32px on 375px
                    height: screenWidth * 0.085,
                    colorFilter: const ColorFilter.mode(Color(0xFFBC91DB), BlendMode.srcIn),
                  ),
                ),
              ),
            )
          else
            SizedBox(width: screenWidth * 0.133), // Placeholder if no button
          const Spacer(),
          // Head logo (same size as main screen)
          SizedBox(
            width: screenWidth * 0.171, // 64px on 375px
            height: screenHeight * 0.106, // 86px on 812px
            child: Image.asset('assets/logo_head.png', fit: BoxFit.contain),
          ),
          const Spacer(),
          SizedBox(width: screenWidth * 0.133), // Placeholder for alignment
        ],
      ),
    );
  }
}

