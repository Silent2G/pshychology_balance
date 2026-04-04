import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/common_header.dart';
import '../providers/auth_provider.dart';
import '../providers/subscription_provider.dart';
import '../services/firestore_service.dart';
import '../models/chat_session.dart' as models;
import '../l10n/app_localizations.dart';
import 'chat_screen.dart';
import 'paywall_screen.dart';

class HistoryScreen extends StatelessWidget {
  final bool showBackButton;
  final VoidCallback? onBack;

  const HistoryScreen({
    super.key,
    this.showBackButton = false,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final authProvider = Provider.of<AuthProvider>(context);
    final userId = authProvider.user?.uid;

    if (userId == null) {
      return Scaffold(body: Center(child: Text(localizations.error)));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/background_main.png'), fit: BoxFit.cover),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04), // 15px on 375px
            child: StreamBuilder<List<models.ChatSession>>(
              stream: FirestoreService().getUserChatSessions(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFBC91DB)),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(child: Text('${localizations.error}: ${snapshot.error}'));
                }

                final sessions = snapshot.data ?? [];

                if (sessions.isEmpty) {
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        CommonHeader(
                          showBackButton: showBackButton,
                          onBack: onBack ?? () => Navigator.of(context).pop(),
                        ),
                        SizedBox(height: screenHeight * 0.037),
                        Center(
                          child: Text(
                            localizations.historyEmpty,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: Color(0xFFA3A3A3),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          CommonHeader(
                            showBackButton: showBackButton,
                            onBack: onBack ?? () => Navigator.of(context).pop(),
                          ),
                          SizedBox(height: screenHeight * 0.037), // ~30px on 812px
                        ],
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.only(
                        bottom: showBackButton ? screenHeight * 0.037 : screenHeight * 0.15, // Bottom spacing only when no bottom menu
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final session = sessions[index];
                            return _buildHistoryItem(context, session, screenWidth, screenHeight, localizations);
                          },
                          childCount: sessions.length,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  /// Localize default chat title if it has format "Chat DD.MM.YYYY" or "Chat DD.MM.YYYY"
  String _localizeChatTitle(String title, AppLocalizations localizations) {
    // List of default "Chat" words in different languages
    final defaultChatWords = ['Чат', 'Chat', 'Chat', 'चैट', '聊天'];
    
    // Check if title starts with default word
    for (final chatWord in defaultChatWords) {
      if (title.startsWith('$chatWord ')) {
        // Extract date (everything after space)
        final datePart = title.substring(chatWord.length + 1);
        // Build new title in current language
        return '${localizations.chat} $datePart';
      } else if (title == chatWord) {
        // If title is just "Chat" without date
        return localizations.chat;
      }
    }
    
    // If not default title, return as is
    return title;
  }

  Widget _buildHistoryItem(BuildContext context, models.ChatSession session, double screenWidth, double screenHeight, AppLocalizations localizations) {
    return GestureDetector(
      onTap: () async {
        // Check subscription before opening chat
        final subscriptionProvider = Provider.of<SubscriptionProvider>(context, listen: false);
        await subscriptionProvider.refreshStatus();
        
        if (subscriptionProvider.isPremium) {
          // If subscription active - open chat
          if (context.mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ChatScreen(sessionId: session.id, onBack: () => Navigator.of(context).pop()),
              ),
            );
          }
        } else {
          // If no subscription - show paywall
          if (context.mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PaywallScreen(
                  onSubscribed: () {
                    // After subscription purchase open chat
                    Navigator.of(context).pop(); // Close paywall
                    if (context.mounted) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(sessionId: session.id, onBack: () => Navigator.of(context).pop()),
                        ),
                      );
                    }
                  },
                  onBack: () => Navigator.of(context).pop(),
                ),
              ),
            );
          }
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: screenHeight * 0.03), // 24px on 812px
        width: screenWidth * 0.917, // 344px on 375px
        height: screenHeight * 0.111, // 90px on 812px
        decoration: BoxDecoration(
          image: const DecorationImage(image: AssetImage('assets/bg_card_history.png'), fit: BoxFit.fill),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Stack(
          children: [
            // Main content
            Padding(
              padding: EdgeInsets.only(left: screenWidth * 0.037), // 14px on 375px
              child: Row(
                children: [
                  // History icon in purple circle
                  Container(
                    width: screenWidth * 0.168, // 63px on 375px
                    height: screenWidth * 0.168,
                    decoration: const BoxDecoration(color: Color(0xFFBC91DB), shape: BoxShape.circle),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/ic_history_chat.svg',
                        width: screenWidth * 0.075, // 28px on 375px
                        height: screenWidth * 0.075,
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.032), // 12px
                  // Text
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Chat title
                        Text(
                          _localizeChatTitle(session.title, localizations),
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            height: 1.21, // 17px / 14px
                            color: Color(0xFFBC91DB),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.015), // 12px gap
                        // Time and date
                        Row(
                          children: [
                            Text(
                              _formatTime(session.updatedAt),
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                height: 1.21,
                                color: Color(0xFFA3A3A3),
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.021), // 8px
                            Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(color: Color(0xFFA3A3A3), shape: BoxShape.circle),
                            ),
                            SizedBox(width: screenWidth * 0.021), // 8px
                            Text(
                              _formatDate(session.updatedAt),
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                height: 1.21,
                                color: Color(0xFFA3A3A3),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // "Saved" button on right
            Positioned(
              right: screenWidth * 0.037, // 14px
              top: screenHeight * 0.042, // 34px on 812px
              child: Container(
                width: screenWidth * 0.197, // 74px on 375px
                height: screenHeight * 0.027, // 22px on 812px
                decoration: BoxDecoration(color: const Color(0xFFBC91DB), borderRadius: BorderRadius.circular(99)),
                child: Center(
                  child: Text(
                    localizations.saved,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w400,
                      fontSize: 10,
                      height: 1.2, // 12px / 10px
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
