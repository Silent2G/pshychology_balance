import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_localizations.dart';

class LanguageDialog extends StatefulWidget {
  const LanguageDialog({super.key});

  @override
  State<LanguageDialog> createState() => _LanguageDialogState();
}

class _LanguageDialogState extends State<LanguageDialog> {
  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final localizations = AppLocalizations.of(context)!;
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    final languages = [
      {'code': 'uk', 'name': localizations.getLanguageName('uk')},
      {'code': 'en', 'name': localizations.getLanguageName('en')},
      {'code': 'es', 'name': localizations.getLanguageName('es')},
      {'code': 'hi', 'name': localizations.getLanguageName('hi')},
      {'code': 'zh', 'name': localizations.getLanguageName('zh')},
    ];

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.043), // ~16px on 375px
      child: Container(
        width: screenWidth * 0.917, // ~344px on 375px
        height: screenHeight * 0.53, // ~430px on 812px
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: const Color(0xFF9557C2), width: 1),
        ),
        child: Column(
          children: [
            // Title with close button
            Container(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.064, vertical: screenHeight * 0.02), // ~24px on 375px
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0x339557C2), width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    localizations.chooseLanguage,
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
                    child: Container(
                      width: screenWidth * 0.085, // ~32px on 375px
                      height: screenWidth * 0.085,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.close,
                          size: screenWidth * 0.053, // ~20px on 375px
                          color: const Color(0xFFBC91DB),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Language list
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(screenWidth * 0.043), // ~16px on 375px
                child: Column(
                  children: languages.map((language) {
                    final isSelected = localeProvider.locale.languageCode == language['code'];
                    return Padding(
                      padding: EdgeInsets.only(bottom: screenHeight * 0.012), // ~10px on 812px
                      child: GestureDetector(
                        onTap: () {
                          localeProvider.setLocale(Locale(language['code']!));
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          width: double.infinity,
                          height: screenHeight * 0.071, // ~57px on 812px
                          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.043), // ~16px on 375px
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFBC91DB) : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: const Color(0xFF9557C2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                language['name']!,
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  height: 1.5,
                                  color: isSelected ? Colors.white : const Color(0xFFBC91DB),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if (isSelected)
                                Container(
                                  width: screenWidth * 0.053, // ~20px on 375px
                                  height: screenWidth * 0.053,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: screenWidth * 0.053,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
