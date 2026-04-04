import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text.dart';

class EmojiScale extends StatefulWidget {
  final Function(int) onValueChanged;
  final int? initialValue;

  const EmojiScale({super.key, required this.onValueChanged, this.initialValue});

  @override
  State<EmojiScale> createState() => _EmojiScaleState();
}

class _EmojiScaleState extends State<EmojiScale> {
  int? selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Emoji
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(4, (index) {
            final isSelected = selectedValue == index;
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedValue = index;
                });
                widget.onValueChanged(index);
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.lightBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected ? Border.all(color: AppColors.primaryBlue, width: 2) : null,
                ),
                child: Image.asset(
                  'assets/ic_emoji_${index + 1}.png',
                  width: isSelected ? 32 : 28,
                  height: isSelected ? 32 : 28,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        // Labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: AppText.emojiLabels.take(4).map((label) {
            return Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
