import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_palette.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final overlapHeight = screenWidth * 0.08; // "Peek" height of Home button

    return Container(
      color: Colors.transparent,
      height: screenHeight * 0.074 + overlapHeight, // Height increased by peek amount
      margin: EdgeInsets.only(
        bottom: screenHeight * 0.012, // ~10px
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Nav bar panel, lowered by peek height
          Positioned(
            left: (screenWidth - screenWidth * 0.733) / 2,
            top: overlapHeight, // Lowered by peek height
            child: Container(
              width: screenWidth * 0.733, // ~275px on 375px
              height: screenHeight * 0.074, // ~60px on 812px
              decoration: BoxDecoration(
                color: context.palette.surface,
                borderRadius: BorderRadius.circular(99),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFA1A1A1).withOpacity(0.25),
                    blurRadius: 11.6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
          // History (left) - enlarged tap area
          Positioned(
            left: (screenWidth - screenWidth * 0.733) / 2 + screenWidth * 0.053,
            top: overlapHeight,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(1),
              child: Container(
                width: screenWidth * 0.16, // ~60px on 375px (enlarged area)
                height: screenHeight * 0.074, // ~60px on 812px
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  'assets/ic_history.svg',
                  width: screenWidth * 0.053, // ~20px on 375px
                  height: screenWidth * 0.053, // ~20px on 375px
                  colorFilter: ColorFilter.mode(
                    currentIndex == 1 ? const Color(0xFFBC91DB) : context.palette.textMuted,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
          // Home (center) - circle with shadow, now inside layout bounds
          Positioned(
            left: (screenWidth - screenWidth * 0.733) / 2 + (screenWidth * 0.733 - screenWidth * 0.16) / 2,
            top: 0, // Now at top: 0 since container is taller
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(0),
              child: Container(
                width: screenWidth * 0.16,
                height: screenWidth * 0.16,
                decoration: BoxDecoration(
                  color: context.palette.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFDFDFDF).withOpacity(0.25),
                      blurRadius: 17.8,
                      offset: const Offset(1, -13),
                    ),
                  ],
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/ic_house.svg',
                    width: screenWidth * 0.064,
                    height: screenWidth * 0.064,
                    colorFilter: ColorFilter.mode(
                      currentIndex == 0 ? const Color(0xFFBC91DB) : context.palette.textMuted,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Profile (right) - enlarged tap area
          Positioned(
            right: (screenWidth - screenWidth * 0.733) / 2 + screenWidth * 0.053,
            top: overlapHeight,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(2),
              child: Container(
                width: screenWidth * 0.16, // ~60px on 375px (enlarged area)
                height: screenHeight * 0.074, // ~60px on 812px
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  'assets/ic_profile.svg',
                  width: screenWidth * 0.053, // ~20px on 375px
                  height: screenWidth * 0.053, // ~20px on 375px
                  colorFilter: ColorFilter.mode(
                    currentIndex == 2 ? const Color(0xFFBC91DB) : context.palette.textMuted,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
