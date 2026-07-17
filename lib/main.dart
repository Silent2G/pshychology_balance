import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'constants/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/subscription_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';
import 'l10n/app_localizations.dart';
import 'screens/welcome_screen.dart';
import 'screens/test_intro_screen.dart';
import 'screens/test_question_screen.dart';
import 'screens/test_result_screen.dart';
import 'screens/share_result_screen.dart';
import 'screens/navigation_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/session_complete_screen.dart';
import 'screens/paywall_screen.dart';
import 'widgets/ai_consent_dialog.dart';
import 'firebase_options.dart';
import 'services/openai_service.dart';
import 'services/firestore_service.dart';
import 'services/onesignal_service.dart';
import 'services/remote_config_service.dart';
import 'services/subscription_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Android 15 (SDK 35+) forces edge-to-edge. Opt in explicitly and make the
  // system bars transparent so Flutter draws behind them; every screen already
  // wraps its content in SafeArea, so nothing is hidden behind the bars.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  // Don't pass statusBarColor/systemNavigationBarColor: in edgeToEdge mode the
  // system already draws transparent bars, and passing non-null colors makes
  // Flutter's engine call the deprecated Window.setStatusBarColor /
  // setNavigationBarColor APIs (removed in Android 15+).
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarContrastEnforced: false,
    ),
  );

  // Firebase is required for the app's providers, so init it up front — but
  // never let a failure here keep the app from launching.
  bool firebaseReady = false;
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    firebaseReady = true;
  } catch (e) {
    debugPrint('Firebase init failed: $e');
  }

  WakelockPlus.enable();

  // Crashlytics — catch all Flutter + async errors in release mode
  if (firebaseReady && !kDebugMode) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  // Render the UI immediately. The services below make network calls (Remote
  // Config fetch, RevenueCat, OneSignal permission prompt) that can be slow or
  // blocked in restricted environments (e.g. store review), which would leave
  // the app stuck on a blank screen if awaited before runApp(). They all have
  // safe fallbacks — Remote Config → default values, RevenueCat → cached
  // status, OneSignal → push only — so we initialize them in the background.
  runApp(const MyApp());

  if (firebaseReady) {
    unawaited(RemoteConfigService().initialize());
    unawaited(SubscriptionService().initialize());
  }
  unawaited(OneSignalService().initialize());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) {
            final authProvider = AuthProvider();
            // Initialize AuthProvider after creation
            WidgetsBinding.instance.addPostFrameCallback((_) {
              authProvider.initializeAfterFirebase();
            });
            return authProvider;
          },
        ),
        ChangeNotifierProvider(create: (context) => SubscriptionProvider()),
        ChangeNotifierProvider(create: (context) => LocaleProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: Consumer2<LocaleProvider, ThemeProvider>(
        builder: (context, localeProvider, themeProvider, child) {
          return MaterialApp(
            title: 'AI Psychology Balance',
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeProvider.themeMode,
            locale: localeProvider.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('uk'), Locale('en'), Locale('es'), Locale('hi'), Locale('zh')],
            home: const AppNavigator(),
          );
        },
      ),
    );
  }
}

class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  int _currentScreenIndex = 0;
  List<int> _testAnswers = [];
  String _testPsychotype = '';
  String _testDescription = '';
  List<String> _testRecommendations = [];
  bool _isAnalyzing = false;

  final List<Widget> _screens = [];
  final OpenAIService _openAIService = OpenAIService();
  final FirestoreService _firestoreService = FirestoreService();
  Locale? _lastLocale;

  @override
  void initState() {
    super.initState();
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
            _initializeScreens(context);
          });
        }
      });
    }

    // Initialize screens on first launch
    if (_screens.isEmpty) {
      _initializeScreens(context);
    }

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading indicator while AuthProvider is not initialized
        if (!authProvider.isInitialized) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // If user is not authenticated, show welcome screen
        if (!authProvider.isAuthenticated) {
          return const WelcomeScreen();
        }

        // If user is authenticated, show main navigation
        if (_screens.isEmpty || _currentScreenIndex >= _screens.length) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return _screens[_currentScreenIndex];
      },
    );
  }

  void _initializeScreens(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) return;

    _screens.clear();
    _screens.addAll([
      // 0 - NavigationScreen (main screen after auth)
      NavigationScreen(
        onChatTap: () => _checkSubscriptionAndNavigateToChat(context),
        onStartTest: () => _navigateToScreen(3), // Navigate to TestIntroScreen
      ),
      // 1 - ChatScreen (chat)
      ChatScreen(
        onNext: () => _navigateToScreen(3),
        onEndSession: () => _navigateToScreen(16), // Navigate to session complete screen
        onBack: () => _navigateToScreen(0), // Back to main screen
      ),
      // 2 - PaywallScreen (subscription paywall)
      PaywallScreen(
        onSubscribed: () => _navigateToScreen(1), // After purchase navigate to chat
        onBack: () => _navigateToScreen(0), // Back to main screen
      ),
      // 3 - TestIntroScreen
      TestIntroScreen(
        onStart: () {
          print('Почати натиснуто, переходимо до першого питання (індекс 4)');
          print('Кількість екранів: ${_screens.length}');
          _navigateToScreen(4);
        },
        onBack: () => _navigateToScreen(0), // Back to main screen
      ),
    ]);

    // Add question screens
    for (int i = 0; i < 10; i++) {
      _screens.add(
        TestQuestionScreen(
          questionIndex: i, // Pass index instead of text
          questionNumber: i + 1,
          totalQuestions: 10,
          onAnswerSelected: (value) {
            if (_testAnswers.length <= i) {
              _testAnswers.add(value);
            } else {
              _testAnswers[i] = value;
            }
          },
          onNext: () {
            if (i < 9) {
              _navigateToScreen(4 + i + 1);
            } else {
              // For last question go directly to results screen
              print('Останнє питання, переходимо до результатів...');
              print('Поточні відповіді: $_testAnswers');

              // Ensure last answer is saved
              // Important for fast clicks
              if (_testAnswers.length <= i) {
                print('Попередження: остання відповідь ще не збережена, очікуємо...');
                // Give time for answer to be saved
                Future.delayed(const Duration(milliseconds: 100), () {
                  if (mounted) {
                    _proceedToResults();
                  }
                });
              } else {
                _proceedToResults();
              }
            }
          },
          onBack: () {
            if (i == 0) {
              _navigateToScreen(3); // Back to TestIntroScreen
            } else {
              _navigateToScreen(4 + i - 1); // Back to previous question
            }
          },
        ),
      );
    }

    // Add result screens
    _screens.addAll([
      TestResultScreen(
        psychotype: _testPsychotype.isEmpty ? localizations.analyzing : _testPsychotype,
        description: _testDescription.isEmpty ? localizations.waitAnalyzing : _testDescription,
        recommendations: _testRecommendations,
        isLoading: _isAnalyzing,
        onGoToChat: () => _checkSubscriptionAndNavigateToChat(context), // Navigate to chat with subscription check
        onShare: () => _navigateToScreen(15), // Navigate to share screen
        onBack: () => _navigateToScreen(0), // Back to main screen
      ),
      // ShareResultScreen (share result screen)
      ShareResultScreen(
        psychotype: _testPsychotype.isEmpty ? localizations.analyzing : _testPsychotype,
        onBack: () => _navigateToScreen(14), // Back to results screen
      ),
      // SessionCompleteScreen (session complete screen)
      SessionCompleteScreen(
        onGoToMain: () => _navigateToScreen(0), // Back to main screen
        onBack: () => _checkSubscriptionAndNavigateToChat(context), // Back to chat with subscription check
      ),
    ]);
  }

  /// Navigate to results screen after last question
  void _proceedToResults() async {
    print('Переходимо до результатів. Кількість відповідей: ${_testAnswers.length}');

    // Required by App Store Guideline 5.1.1(i)/5.1.2(i): obtain consent before
    // sending the user's test answers to the third-party AI service (OpenAI).
    final consented = await ensureAiConsent(context);
    if (!consented || !mounted) return;

    // Set loading state before navigation
    final localizations = AppLocalizations.of(context);
    setState(() {
      _isAnalyzing = true;
      _testPsychotype = localizations?.analyzing ?? 'Аналіз...';
      _testDescription = localizations?.waitAnalyzing ?? 'Зачекайте, аналізуємо ваші відповіді...';
      _testRecommendations = [];
    });

    // Update screens
    _initializeScreens(context);

    // Navigate to results screen with loading
    _navigateToScreen(14);

    // Run analysis in background (without await!)
    _calculateResult();
  }

  /// Check subscription and navigate to chat or show paywall
  Future<void> _checkSubscriptionAndNavigateToChat(BuildContext context) async {
    final subscriptionProvider = Provider.of<SubscriptionProvider>(context, listen: false);

    // Refresh subscription status before check
    await subscriptionProvider.refreshStatus();

    if (subscriptionProvider.isPremium) {
      // If subscription is active - navigate to chat
      _navigateToScreen(1);
    } else {
      // If no subscription - show paywall
      _navigateToScreen(2);
    }
  }

  void _navigateToScreen(int index) {
    print(
      '_navigateToScreen called: index=$index, currentIndex=$_currentScreenIndex, screens length=${_screens.length}',
    );
    if (index >= 0 && index < _screens.length && mounted) {
      print('Setting state to index $index');
      setState(() {
        _currentScreenIndex = index;
      });
      print('State set, new index: $_currentScreenIndex');
    } else {
      print('Navigation error: index=$index, screens length=${_screens.length}, mounted=$mounted');
    }
  }

  Future<void> _calculateResult() async {
    const maxRetries = 3; // Max 3 retries
    int attempt = 0;

    while (attempt < maxRetries) {
      try {
        attempt++;
        print('Починаємо аналіз результатів тесту (спроба $attempt/$maxRetries)...');
        print('Кількість відповідей: ${_testAnswers.length}');
        print('Відповіді: $_testAnswers');

        // Verify all answers are received
        if (_testAnswers.length != 10) {
          throw Exception('Не всі питання відповідені. Отримано ${_testAnswers.length} з 10');
        }

        // Verify all answers are in valid range
        for (int i = 0; i < _testAnswers.length; i++) {
          if (_testAnswers[i] < 0 || _testAnswers[i] > 3) {
            throw Exception('Невірна відповідь на питання ${i + 1}: ${_testAnswers[i]}');
          }
        }

        final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
        final languageCode = localeProvider.locale.languageCode;
        final result = await _openAIService.analyzeTestResults(_testAnswers, languageCode);
        print('Отримано результат від OpenAI: $result');

        // Verify result is valid
        if (result['psychotype'] == null || result['psychotype'].toString().isEmpty) {
          throw Exception('Отримано порожній результат від OpenAI');
        }

        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final userId = authProvider.user?.uid;

        final localizations = AppLocalizations.of(context);
        setState(() {
          _testPsychotype = result['psychotype'] ?? (localizations?.undefinedType ?? 'Невизначений тип');
          _testDescription =
              result['description'] ?? (localizations?.failedToGetDescription ?? 'Не вдалося отримати опис');
          _testRecommendations = List<String>.from(result['recommendations'] ?? []);
          _isAnalyzing = false;
        });

        print('Результат встановлено: $_testPsychotype');

        // Update results screen immediately after receiving data
        _initializeScreens(context);

        // Save test result to Firestore
        if (userId != null) {
          try {
            await _firestoreService.saveTestResult(
              userId,
              _testPsychotype,
              _testDescription,
              _testRecommendations,
              _testAnswers,
            );
            print('Результат збережено в Firestore');
          } catch (firestoreError) {
            print('Помилка збереження в Firestore: $firestoreError');
            // Don't interrupt execution, just log error
          }
        }

        // Successfully completed, exit loop
        return;
      } catch (e) {
        print('Помилка аналізу (спроба $attempt/$maxRetries): $e');

        // If this is last attempt, show error
        if (attempt >= maxRetries) {
          final localizations = AppLocalizations.of(context);
          setState(() {
            _testPsychotype = localizations?.analysisError ?? 'Помилка аналізу';
            _testDescription =
                localizations?.analysisErrorDescription ??
                'На жаль, не вдалося проаналізувати результати. Спробуйте ще раз.';
            _testRecommendations = [];
            _isAnalyzing = false;
          });
          _initializeScreens(context);
          return;
        }

        // Wait before next attempt (exponential backoff)
        await Future.delayed(Duration(milliseconds: 1000 * attempt));
      }
    }
  }
}
