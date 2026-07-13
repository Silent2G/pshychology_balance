import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_palette.dart';

class CommonHeader extends StatelessWidget {
  final VoidCallback? onBack;
  final bool showBackButton;

  /// Optional circular action buttons rendered at the top-right of the header.
  /// The logo stays centered regardless of how many actions are provided.
  final List<Widget> actions;

  const CommonHeader({
    super.key,
    this.onBack,
    this.showBackButton = true,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.043), // 16px on 375px
      child: SizedBox(
        height: screenHeight * 0.106, // 86px on 812px — matches logo height
        child: Stack(
          children: [
            // Head logo — always centered
            Center(
              child: SizedBox(
                width: screenWidth * 0.171, // 64px on 375px
                height: screenHeight * 0.106, // 86px on 812px
                child: Image.asset('assets/logo_head.png', fit: BoxFit.contain),
              ),
            ),
            // Back button (left)
            Align(
              alignment: Alignment.centerLeft,
              child: showBackButton
                  ? GestureDetector(
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
                  : SizedBox(width: screenWidth * 0.133), // Placeholder if no button
            ),
            // Action buttons (right)
            if (actions.isNotEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: Row(mainAxisSize: MainAxisSize.min, children: actions),
              ),
          ],
        ),
      ),
    );
  }
}

/// Circular icon button styled to match [CommonHeader]'s back button.
/// Reused for header actions such as "start over" and "end session".
class CircleHeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  const CircleHeaderButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final size = screenWidth * 0.115; // ~43px on 375px — slightly smaller than back button

    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          margin: EdgeInsets.only(left: screenWidth * 0.024), // ~9px gap between actions
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
            child: Icon(icon, size: size * 0.5, color: const Color(0xFFBC91DB)),
          ),
        ),
      ),
    );
  }
}

