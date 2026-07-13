import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_palette.dart';
import '../providers/theme_provider.dart';
import '../l10n/app_localizations.dart';

class ThemeDialog extends StatelessWidget {
  const ThemeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localizations = AppLocalizations.of(context)!;
    final palette = context.palette;
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    final options = <Map<String, Object>>[
      {'mode': ThemeMode.system, 'name': localizations.themeSystem, 'icon': Icons.brightness_auto_outlined},
      {'mode': ThemeMode.light, 'name': localizations.themeLight, 'icon': Icons.light_mode_outlined},
      {'mode': ThemeMode.dark, 'name': localizations.themeDark, 'icon': Icons.dark_mode_outlined},
    ];

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.043),
      child: Container(
        width: screenWidth * 0.917,
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: palette.accentText, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title with close button
            Container(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.064, vertical: screenHeight * 0.02),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: palette.accentText.withOpacity(0.2), width: 1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    localizations.chooseTheme,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      height: 1.5,
                      color: Color(0xFFBC91DB),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(Icons.close, size: screenWidth * 0.053, color: const Color(0xFFBC91DB)),
                  ),
                ],
              ),
            ),
            // Options
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.043),
              child: Column(
                children: options.map((option) {
                  final mode = option['mode'] as ThemeMode;
                  final isSelected = themeProvider.themeMode == mode;
                  return Padding(
                    padding: EdgeInsets.only(bottom: screenHeight * 0.012),
                    child: GestureDetector(
                      onTap: () {
                        themeProvider.setThemeMode(mode);
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        width: double.infinity,
                        height: screenHeight * 0.071,
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.043),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFBC91DB) : palette.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: palette.accentText, width: 1),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              option['icon'] as IconData,
                              size: screenWidth * 0.056,
                              color: isSelected ? Colors.white : const Color(0xFFBC91DB),
                            ),
                            SizedBox(width: screenWidth * 0.03),
                            Expanded(
                              child: Text(
                                option['name'] as String,
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  height: 1.5,
                                  color: isSelected ? Colors.white : const Color(0xFFBC91DB),
                                ),
                              ),
                            ),
                            if (isSelected) Icon(Icons.check, color: Colors.white, size: screenWidth * 0.053),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
