import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text.dart';

class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final IconData? icon;
  final String? imageAsset; // Path to image
  final double? width;
  final double height;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isPrimary = true,
    this.icon,
    this.imageAsset,
    this.width,
    this.height = 56,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.height,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: ElevatedButton(
          onPressed: widget.onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isPressed
                ? (widget.isPrimary ? AppColors.pressedBlue : AppColors.lightBlue)
                : (widget.isPrimary ? AppColors.primaryBlue : Colors.white),
            foregroundColor: widget.isPrimary ? Colors.white : AppColors.primaryBlue,
            elevation: widget.isPrimary ? 2 : 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide.none),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.text,
                style: AppText.buttonStyle.copyWith(color: widget.isPrimary ? Colors.white : Colors.black),
              ),
              if (widget.imageAsset != null) ...[
                const SizedBox(width: 8),
                Image.asset(widget.imageAsset!, width: 20, height: 20),
              ] else if (widget.icon != null) ...[
                const SizedBox(width: 8),
                Icon(widget.icon, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
