import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/common_header.dart';
import '../widgets/language_dialog.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import '../l10n/app_localizations.dart';
import 'subscription_screen.dart';
import 'test_history_screen.dart';
import 'social_media_screen.dart';
import 'history_screen.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onNavigateToHistory;

  const ProfileScreen({super.key, this.onNavigateToHistory});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('profile_image_path');
    if (imagePath != null && File(imagePath).existsSync()) {
      setState(() {
        _profileImage = File(imagePath);
      });
    }
  }

  Future<void> _saveProfileImage(String imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image_path', imagePath);
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);

      if (image != null) {
        // Save image to app persistent storage
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final String savedPath = '${appDir.path}/$fileName';
        final File savedImage = await File(image.path).copy(savedPath);

        await _saveProfileImage(savedPath);
        setState(() {
          _profileImage = savedImage;
        });
      }
    } catch (e) {
      if (mounted) {
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${localizations.errorSelectingPhoto}: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        final userEmail = user?.email ?? '';
        final userId = user?.uid;
        final screenSize = MediaQuery.of(context).size;
        final screenWidth = screenSize.width;
        final screenHeight = screenSize.height;

        return Scaffold(
          backgroundColor: const Color(0xFFFDFDFD),
          body: Container(
            width: screenWidth,
            height: screenHeight,
            decoration: const BoxDecoration(
              image: DecorationImage(image: AssetImage('assets/background_main.png'), fit: BoxFit.cover),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.043), // ~16px on 375px
                child: Column(
                  children: [
                    // Header without back button
                    CommonHeader(showBackButton: false),
                    SizedBox(height: screenHeight * 0.024), // ~20px on 812px
                    // Profile container on bg_profile_header.png
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(screenWidth * 0.034), // ~24px on 375px
                      decoration: const BoxDecoration(
                        image: DecorationImage(image: AssetImage('assets/bg_profile_header.png'), fit: BoxFit.fill),
                      ),
                      child: Column(
                        children: [
                          // Avatar with edit icon
                          Stack(
                            children: [
                              ClipOval(
                                child: _profileImage != null
                                    ? Image.file(
                                        _profileImage!,
                                        width: screenWidth * 0.213, // ~80px on 375px
                                        height: screenWidth * 0.213,
                                        fit: BoxFit.cover,
                                      )
                                    : SvgPicture.asset(
                                        'assets/ic_profile_empty.svg',
                                        width: screenWidth * 0.213, // ~80px on 375px
                                        height: screenWidth * 0.213,
                                      ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: _pickImage,
                                  child: Container(
                                    width: screenWidth * 0.08, // ~30px on 375px
                                    height: screenWidth * 0.08,
                                    child: Center(child: SvgPicture.asset('assets/ic_edit_photo.svg')),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.02), // ~16px on 812px
                          // Email
                          Text(
                            userEmail,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600, // SemiBold
                              fontSize: 14,
                              height: 1.0, // Line height
                              letterSpacing: 0, // 0%
                              color: Color(0xFFBC91DB),
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.024), // ~20px on 812px
                    // Statistics and menu
                    if (userId != null) ...[
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const TestHistoryScreen(),
                            ),
                          );
                        },
                        child: FutureBuilder<int>(
                          future: FirestoreService().getCompletedTestsCount(userId),
                          builder: (context, snapshot) {
                            return _buildMenuItem(
                              context,
                              localizations.testsPassed,
                              'assets/ic_tests_passed.svg',
                              value: '${snapshot.data ?? 0}',
                            );
                          },
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.012), // ~10px on 812px
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const HistoryScreen(
                                showBackButton: true,
                              ),
                            ),
                          );
                        },
                        child: FutureBuilder<int>(
                          future: FirestoreService().getSavedSessionsCount(userId),
                          builder: (context, snapshot) {
                            return _buildMenuItem(
                              context,
                              localizations.savedSessions,
                              'assets/ic_saved_sessions.svg',
                              value: '${snapshot.data ?? 0}',
                            );
                          },
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.012),
                      FutureBuilder<int>(
                        future: FirestoreService().getDaysOfUsage(userId),
                        builder: (context, snapshot) {
                          return _buildMenuItem(
                            context,
                            localizations.daysOfUsage,
                            'assets/ic_days_used.svg',
                            value: '${snapshot.data ?? 0}',
                          );
                        },
                      ),
                      SizedBox(height: screenHeight * 0.045),
                    ],

                    // Subscription
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SubscriptionScreen(
                              onBack: null, // Will use Navigator.pop
                            ),
                          ),
                        );
                      },
                      child: _buildMenuItem(context, localizations.subscription, 'assets/ic_subscription.svg', showArrow: true),
                    ),
                    SizedBox(height: screenHeight * 0.012),
                    // We're on social media
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SocialMediaScreen(
                              onBack: null, // Will use Navigator.pop
                            ),
                          ),
                        );
                      },
                      child: _buildMenuItem(context, localizations.socialMedia, 'assets/ic_social_media.svg', showArrow: true),
                    ),
                    SizedBox(height: screenHeight * 0.012),
                    // Language
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          barrierColor: Colors.black.withOpacity(0.3),
                          builder: (context) => const LanguageDialog(),
                        );
                      },
                      child: _buildMenuItem(context, localizations.language, 'assets/ic_language.svg', showArrow: true),
                    ),
                    SizedBox(height: screenHeight * 0.012),
                    // Privacy policy
                    GestureDetector(
                      onTap: () => _openPrivacyPolicy(context),
                      child: _buildMenuItem(
                        context,
                        localizations.privacyPolicy,
                        'assets/ic_policy.svg',
                        showArrow: true,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.012),
                    // Support
                    GestureDetector(
                      onTap: () => _openSupportEmail(context),
                      child: _buildMenuItem(context, localizations.support, 'assets/ic_support.svg', showArrow: true),
                    ),
                    SizedBox(height: screenHeight * 0.012),
                    // Logout
                    GestureDetector(
                      onTap: () => _showLogoutDialog(context),
                      child: _buildMenuItem(
                        context,
                        localizations.logout,
                        'assets/ic_exit.svg',
                        showArrow: true,
                        isDestructive: true,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.15), // Spacing for bottom menu
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    String iconPath, {
    String? value,
    bool showArrow = false,
    bool isDestructive = false,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final color = isDestructive ? const Color(0xFFCC3333) : const Color(0xFFBC91DB);

    return Container(
      width: double.infinity,
      height: screenWidth * 0.14, // 60px on 375px, same as in test
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.043), // ~16px on 375px
      decoration: BoxDecoration(
        image: const DecorationImage(image: AssetImage('assets/bg_card.png'), fit: BoxFit.fill),
        color: Colors.white,
        borderRadius: BorderRadius.circular(99), // Same as in test
      ),
      child: Row(
        children: [
          // Icon
          Container(
            // width: screenWidth * 0.107, // ~40px on 375px
            height: screenWidth * 0.107,
            child: Center(
              child: SvgPicture.asset(
                iconPath,
                // width: screenWidth * 0.064, // ~24px on 375px
                // height: screenWidth * 0.064,
              ),
            ),
          ),
          SizedBox(width: screenWidth * 0.03), // ~16px on 375px
          // Text
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600, // SemiBold
                fontSize: 14,
                height: 1.0, // Line height
                letterSpacing: 0, // 0%
                color: color,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          // Value in circle or arrow
          if (value != null)
            Container(
              width: screenWidth * 0.11, // ~30px on 375px
              height: screenWidth * 0.11,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                image: DecorationImage(image: AssetImage('assets/bg_circle.png'), fit: BoxFit.fill),
              ),
              child: Center(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: Color(0xFFBC91DB),
                  ),
                ),
              ),
            )
          else if (showArrow)
            Icon(Icons.arrow_forward_ios, color: Color(0xFFBC91DB), size: screenWidth * 0.05), // ~15px on 375px
        ],
      ),
    );
  }

  Future<void> _openPrivacyPolicy(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    final url = Uri.parse('https://www.termsfeed.com/live/00f9c6a6-b887-4fef-bcc9-1df2bd2aa00d');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(localizations.failedToOpenLink)));
      }
    }
  }

  Future<void> _openSupportEmail(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    final email = 'Aipsychologys@gmail.com';
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(localizations.failedToOpenEmail)));
      }
    }
  }

  void _showLogoutDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.logoutTitle),
          content: Text(localizations.logoutConfirm),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(localizations.cancel)),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                await authProvider.signOut();
              },
              child: Text(localizations.logout, style: const TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
