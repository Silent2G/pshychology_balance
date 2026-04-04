import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../providers/locale_provider.dart';
import 'main_interface_screen.dart';
import 'profile_screen.dart';
import 'history_screen.dart';

class NavigationScreen extends StatefulWidget {
  final VoidCallback? onChatTap;
  final VoidCallback? onStartTest;

  const NavigationScreen({super.key, this.onChatTap, this.onStartTest});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _currentIndex = 0;
  Locale? _lastLocale;

  List<Widget> _screens = [];

  void _initializeScreens() {
    _screens = [
      MainInterfaceScreen(onChatTap: widget.onChatTap, onStartTest: widget.onStartTest),
      const HistoryScreen(),
      ProfileScreen(
        onNavigateToHistory: () {
          setState(() {
            _currentIndex = 1; // Switch to history screen
          });
        },
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _initializeScreens();
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    // Rebuild screens when locale changes
    if (_lastLocale != localeProvider.locale) {
      _lastLocale = localeProvider.locale;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _initializeScreens();
          });
        }
      });
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _screens[_currentIndex],
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: CustomBottomNavBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
