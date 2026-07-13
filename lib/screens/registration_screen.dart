import 'package:flutter/material.dart';
import '../constants/app_palette.dart';
import '../widgets/app_background.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';
import '../widgets/common_header.dart';
import '../constants/legal_links.dart';
import '../l10n/app_localizations.dart';
import 'password_recovery_screen.dart';

class RegistrationScreen extends StatefulWidget {
  final VoidCallback? onRegister;
  final VoidCallback? onLogin;
  final VoidCallback? onBack;
  final bool initialIsLogin;

  const RegistrationScreen({super.key, this.onRegister, this.onLogin, this.onBack, this.initialIsLogin = false});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  late bool _isLogin;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isLogin = widget.initialIsLogin;
    _emailController.addListener(() {
      setState(() {});
    });
    _passwordController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  void _submitForm() async {
    final localizations = AppLocalizations.of(context)!;
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      _showError(localizations.fillAllFields);
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    bool success;
    if (_isLogin) {
      success = await authProvider.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } else {
      success = await authProvider.signUpWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    }

    if (success) {
      if (mounted) Navigator.of(context).pop();
    } else if (authProvider.errorMessage != null) {
      _showError(authProvider.errorMessage!);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final screenSize = MediaQuery.of(context).size;
        final screenWidth = screenSize.width;
        final screenHeight = screenSize.height;

        return Scaffold(
          backgroundColor: context.palette.scaffold,
          body: AppBackground(
            lightImage: 'assets/background.png',
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.043),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: screenHeight * 0.012), // ~10px
                    // Common header with back button and logo
                    CommonHeader(onBack: widget.onBack ?? () => Navigator.of(context).pop(), showBackButton: true),

                    SizedBox(height: screenHeight * 0.07), // ~30px
                    // Form
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                decoration: BoxDecoration(
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
                          // Password field
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                localizations.password,
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w600,
                                  fontSize: screenWidth * 0.043, // ~16px
                                  height: 1.25,
                                  color: context.palette.textPrimary,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.01), // ~8px
                              Container(
                                height: screenHeight * 0.062, // ~50px
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.059, // ~22px
                                ),
                                decoration: BoxDecoration(
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
                                    controller: _passwordController,
                                    obscureText: true,
                                    textAlignVertical: TextAlignVertical.center,
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w400,
                                      fontSize: screenWidth * 0.043, // ~16px
                                      height: 1.0,
                                      color: context.palette.textPrimary,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: localizations.enterPassword,
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
                              if (_isLogin) ...[
                                SizedBox(height: screenHeight * 0.012), // ~10px
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => PasswordRecoveryScreen(
                                            onBack: () => Navigator.of(context).pop(),
                                            onLogin: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      localizations.forgotPassword,
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w400,
                                        fontSize: screenWidth * 0.043, // ~16px
                                        height: 1.25,
                                        color: const Color(0xFF9557C2),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),

                          SizedBox(height: screenHeight * 0.04), // ~32px
                          // Sign in/Register button
                          SizedBox(
                            height: screenHeight * 0.062, // ~50px
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  (authProvider.isLoading ||
                                      _emailController.text.trim().isEmpty ||
                                      _passwordController.text.trim().isEmpty)
                                  ? null
                                  : _submitForm,
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
                              child: authProvider.isLoading
                                  ? SizedBox(
                                      width: screenWidth * 0.064,
                                      height: screenWidth * 0.064,
                                      child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : Text(
                                      _isLogin ? localizations.login : localizations.register,
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

                          SizedBox(height: screenHeight * 0.04), // ~32px
                          // "or" divider
                          Row(
                            children: [
                              Expanded(child: Image.asset('assets/left_line.png', height: 1, fit: BoxFit.fitWidth)),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.035, // ~13px
                                ),
                                child: Text(
                                  localizations.or,
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w400,
                                    fontSize: screenWidth * 0.037, // ~14px
                                    height: 1.214, // 17/14
                                    color: context.palette.textPrimary,
                                  ),
                                ),
                              ),
                              Expanded(child: Image.asset('assets/right_line.png', height: 1, fit: BoxFit.fitWidth)),
                            ],
                          ),

                          SizedBox(height: screenHeight * 0.04), // ~32px
                          // Google and Apple buttons
                          Row(
                            children: [
                              Expanded(
                                child: _buildSocialButton(
                                  icon: SvgPicture.asset(
                                    'assets/ic_google.svg',
                                    width: screenWidth * 0.053, // ~20px
                                    height: screenWidth * 0.053, // ~20px
                                  ),
                                  text: 'Google',
                                  onPressed: () async {
                                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                    final success = await authProvider.signInWithGoogle();
                                    if (success) {
                                      if (mounted) Navigator.of(context).pop();
                                    } else if (authProvider.errorMessage != null) {
                                      _showError(authProvider.errorMessage!);
                                    }
                                  },
                                  screenWidth: screenWidth,
                                  screenHeight: screenHeight,
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.053), // ~20px
                              Expanded(
                                child: _buildSocialButton(
                                  icon: SvgPicture.asset(
                                    'assets/ic_apple.svg',
                                    width: screenWidth * 0.053, // ~20px
                                    height: screenWidth * 0.053, // ~20px
                                  ),
                                  text: 'Apple',
                                  onPressed: () async {
                                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                    final success = await authProvider.signInWithApple();
                                    if (success) {
                                      if (mounted) Navigator.of(context).pop();
                                    } else if (authProvider.errorMessage != null) {
                                      _showError(authProvider.errorMessage!);
                                    }
                                  },
                                  screenWidth: screenWidth,
                                  screenHeight: screenHeight,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.06), // ~48px
                    // Mode switch text
                    GestureDetector(
                      onTap: _toggleMode,
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
                            TextSpan(
                              text: _isLogin ? '${localizations.noAccount} ' : '${localizations.alreadyHaveAccount} ',
                            ),
                            TextSpan(
                              text: _isLogin ? localizations.register : localizations.login,
                              style: TextStyle(color: Color(0xFFBC91DB), fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.02),
                    GestureDetector(
                      onTap: () async {
                        final url = Uri.parse(LegalLinks.privacyPolicyUrl);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        }
                      },
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w400,
                            fontSize: screenWidth * 0.037,
                            height: 1.25,
                            color: const Color(0xFF888888),
                          ),
                          children: [
                            TextSpan(text: '${localizations.agreeToPrivacyPolicy} '),
                            TextSpan(
                              text: localizations.privacyPolicy,
                              style: TextStyle(
                                color: Color(0xFFBC91DB),
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                                decorationColor: Color(0xFFBC91DB),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).padding.bottom + screenHeight * 0.02),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSocialButton({
    required Widget icon,
    required String text,
    required VoidCallback onPressed,
    required double screenWidth,
    required double screenHeight,
  }) {
    return SizedBox(
      height: screenHeight * 0.062, // ~50px
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            SizedBox(width: screenWidth * 0.021), // ~8px
            Text(
              text,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w700,
                fontSize: screenWidth * 0.043, // ~16px
                height: 1.25,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
