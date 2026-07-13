import 'package:flutter/material.dart';
import '../constants/app_palette.dart';
import '../widgets/app_background.dart';
import '../widgets/common_header.dart';
import '../services/password_recovery_service.dart';
import '../l10n/app_localizations.dart';
import 'registration_screen.dart';

class PasswordRecoveryScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onLogin;

  const PasswordRecoveryScreen({super.key, this.onBack, this.onLogin});

  @override
  State<PasswordRecoveryScreen> createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _passwordRecoveryService = PasswordRecoveryService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    final localizations = AppLocalizations.of(context)!;
    if (_emailController.text.trim().isEmpty) {
      _showError(localizations.enterEmail);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();

      // Send password recovery link
      await _passwordRecoveryService.sendRecoveryCode(email);

      if (mounted) {
        _showSuccess(localizations.passwordRecoveryLinkSent);

        // Go back - user will get link on email and follow it
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        _showError(e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return Scaffold(
      backgroundColor: context.palette.scaffold,
      body: AppBackground(
        lightImage: 'assets/background.png',
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.043),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: screenHeight * 0.012), // ~10px
                      // Header with back button and logo
                      CommonHeader(onBack: widget.onBack ?? () => Navigator.of(context).pop(), showBackButton: true),

                      SizedBox(height: screenHeight * 0.07), // ~57px
                      // Main content
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Title and description
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  localizations.passwordRecovery,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w600,
                                    fontSize: screenWidth * 0.064, // ~24px
                                    height: 1.5, // 36/24
                                    color: const Color(0xFFBC91DB),
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.03), // ~24px
                                Text(
                                  localizations.passwordRecoveryDescription,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w400,
                                    fontSize: screenWidth * 0.037, // ~14px
                                    height: 1.5, // 21/14
                                    color: context.palette.textPrimary,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: screenHeight * 0.04), // ~32px
                            // Email field
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  localizations.email,
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w600,
                                    fontSize: screenWidth * 0.043, // ~16px
                                    height: 1.25, // 20/16
                                    color: context.palette.textPrimary,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.01), // ~8px
                                Container(
                                  height: screenHeight * 0.062, // ~50px
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.053, // ~20px
                                  ),
                                  decoration: context.palette.isDark
                                      ? BoxDecoration(
                                          color: context.palette.surface,
                                          borderRadius: BorderRadius.circular(99),
                                          border: Border.all(color: context.palette.surfaceBorder, width: 1.5),
                                        )
                                      : BoxDecoration(
                                          color: Colors.white,
                                          image: const DecorationImage(
                                            image: AssetImage('assets/bg_text_field.png'),
                                            fit: BoxFit.fill,
                                          ),
                                          borderRadius: BorderRadius.circular(99),
                                        ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextFormField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      textAlignVertical: TextAlignVertical.center,
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w400,
                                        fontSize: screenWidth * 0.043, // ~16px
                                        height: 1.0,
                                        color: context.palette.textPrimary,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'name@example.com',
                                        hintStyle: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w400,
                                          fontSize: screenWidth * 0.043,
                                          height: 1.0,
                                          color: const Color(0xFFB8B8B8),
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: screenHeight * 0.04), // ~32px
                            // "Forgot password? Sign in" link
                            GestureDetector(
                              onTap:
                                  widget.onLogin ??
                                  () {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) => RegistrationScreen(
                                          initialIsLogin: true,
                                          onBack: () => Navigator.of(context).pop(),
                                        ),
                                      ),
                                    );
                                  },
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w400,
                                    fontSize: screenWidth * 0.043, // ~16px
                                    height: 1.25,
                                    color: context.palette.textPrimary,
                                  ),
                                  children: [
                                    TextSpan(text: '${localizations.rememberPassword} '),
                                    TextSpan(
                                      text: localizations.login,
                                      style: TextStyle(color: Color(0xFFBC91DB), fontWeight: FontWeight.w600),
                                    ),
                                  ],
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
              // "Continue" button at bottom
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.043, vertical: screenHeight * 0.02),
                child: SizedBox(
                  height: screenHeight * 0.062, // ~50px
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (_isLoading || _emailController.text.trim().isEmpty) ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFBC91DB),
                      disabledBackgroundColor: const Color(0xFFE9CFFB),
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.027, // ~10px
                        vertical: screenHeight * 0.012, // ~10px
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: screenWidth * 0.064,
                            height: screenWidth * 0.064,
                            child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            localizations.continueText,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w700,
                              fontSize: screenWidth * 0.043, // ~16px
                              height: 1.25,
                              color: Colors.white,
                            ),
                          ),
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
