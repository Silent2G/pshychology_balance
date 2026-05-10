import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'dart:ui' as ui;
import '../widgets/common_header.dart';
import '../models/subscription.dart';
import '../services/subscription_service.dart';
import '../providers/subscription_provider.dart';
import '../l10n/app_localizations.dart';

enum SubscriptionPlanType { monthly, sixMonth, yearly }

class PaywallScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onSubscribed;

  const PaywallScreen({super.key, this.onBack, this.onSubscribed});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  SubscriptionPlanType _selectedPlan = SubscriptionPlanType.yearly; // Default yearly (most popular)
  bool _isLoading = false;
  bool _isProcessing = false;
  final SubscriptionService _subscriptionService = SubscriptionService();
  Map<String, StoreProduct> _productsMap = {}; // productId -> StoreProduct mapping

  @override
  void initState() {
    super.initState();
    _initializeSubscriptions();
  }

  Future<void> _initializeSubscriptions() async {
    setState(() => _isLoading = true);

    try {
      await _subscriptionService.initialize();
      
      // Load packages from RevenueCat
      final packagesMap = await _subscriptionService.getPackagesByProductId();
      
      // Create productId -> StoreProduct mapping
      final Map<String, StoreProduct> productsMap = {};
      for (final entry in packagesMap.entries) {
        productsMap[entry.key] = entry.value.storeProduct;
        print('📦 Продукт: ${entry.key} - ${entry.value.storeProduct.priceString}');
      }
      
      if (mounted) {
        setState(() {
          _productsMap = productsMap;
        });
      }
      
      print('✅ Загружено ${productsMap.length} продуктов из RevenueCat');
    } catch (e) {
      print('❌ Ошибка инициализации подписок: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleRestore() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      await _subscriptionService.restorePurchases();
      final subscriptionProvider = Provider.of<SubscriptionProvider>(context, listen: false);
      await subscriptionProvider.refreshStatus();

      if (!mounted) return;
      final localizations = AppLocalizations.of(context)!;

      if (subscriptionProvider.isPremium) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.restoreSuccess), backgroundColor: Colors.green),
        );
        if (widget.onSubscribed != null) {
          widget.onSubscribed!();
        } else {
          Navigator.of(context).pop();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.restoreNoSubscription)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _openPrivacyPolicy() async {
    final url = Uri.parse('https://www.termsfeed.com/live/00f9c6a6-b887-4fef-bcc9-1df2bd2aa00d');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _handlePurchase() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      // Determine which plan is selected
      SubscriptionPlan plan;
      switch (_selectedPlan) {
        case SubscriptionPlanType.monthly:
          plan = SubscriptionPlans.monthly;
          break;
        case SubscriptionPlanType.sixMonth:
          plan = SubscriptionPlans.sixMonth;
          break;
        case SubscriptionPlanType.yearly:
          plan = SubscriptionPlans.yearly;
          break;
      }

      final success = await _subscriptionService.purchaseSubscription(plan);

      if (success && mounted) {
        // Update subscription status in provider
        final subscriptionProvider = Provider.of<SubscriptionProvider>(context, listen: false);
        await subscriptionProvider.refreshStatus();
        
        // Show success message
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Підписка успішно оформлена! 🎉'), backgroundColor: Colors.green));

        // Call callback
        if (widget.onSubscribed != null) {
          widget.onSubscribed!();
        } else {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Помилка: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  String _getLimitText(SubscriptionPlanType plan, AppLocalizations localizations) {
    switch (plan) {
      case SubscriptionPlanType.monthly:
        return localizations.paywallMonthlyDescription;
      case SubscriptionPlanType.sixMonth:
        return localizations.paywallSixMonthDescription;
      case SubscriptionPlanType.yearly:
        return localizations.paywallYearlyDescription;
    }
  }

  String _getTitle(SubscriptionPlanType plan, AppLocalizations localizations) {
    switch (plan) {
      case SubscriptionPlanType.monthly:
        return localizations.paywallMonthlyTitle;
      case SubscriptionPlanType.sixMonth:
        return localizations.paywallSixMonthTitle;
      case SubscriptionPlanType.yearly:
        return localizations.paywallYearlyTitle;
    }
  }

  String _getPeriod(SubscriptionPlanType plan, AppLocalizations localizations) {
    switch (plan) {
      case SubscriptionPlanType.monthly:
        return localizations.paywallMonthlyPeriod;
      case SubscriptionPlanType.sixMonth:
        return localizations.paywallSixMonthPeriod;
      case SubscriptionPlanType.yearly:
        return localizations.paywallYearlyPeriod;
    }
  }

  String? _getPrice(SubscriptionPlanType plan) {
    switch (plan) {
      case SubscriptionPlanType.monthly:
        final productId = SubscriptionPlans.monthly.getProductId(Platform.isIOS);
        final product = productId != null ? _productsMap[productId] : null;
        return product?.priceString;
      case SubscriptionPlanType.sixMonth:
        final productId = SubscriptionPlans.sixMonth.getProductId(Platform.isIOS);
        final product = productId != null ? _productsMap[productId] : null;
        return product?.priceString;
      case SubscriptionPlanType.yearly:
        final productId = SubscriptionPlans.yearly.getProductId(Platform.isIOS);
        final product = productId != null ? _productsMap[productId] : null;
        return product?.priceString;
    }
  }

  bool get _pricesLoaded =>
      _getPrice(SubscriptionPlanType.monthly) != null &&
      _getPrice(SubscriptionPlanType.sixMonth) != null &&
      _getPrice(SubscriptionPlanType.yearly) != null;

  int _getTextLineCount(String text, double maxWidth) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w400, fontSize: 16, height: 1.25),
      ),
      maxLines: 2,
      textDirection: ui.TextDirection.ltr,
    );
    textPainter.layout(maxWidth: maxWidth);
    final lineMetrics = textPainter.computeLineMetrics();
    return lineMetrics.length;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
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
          child: Stack(
            children: [
              Column(
                children: [
                  // Header with back button
                  CommonHeader(onBack: widget.onBack ?? () => Navigator.of(context).pop(), showBackButton: true),
                  SizedBox(height: screenHeight * 0.049), // ~40px on 812px
                  // Main content
                  Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.043), // ~16px on 375px
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      // Illustration (expands to fill remaining space)
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: Image.asset(
                            'assets/paywall_logo.png',
                            fit: BoxFit.contain,
                            width: screenWidth * 0.736, // ~276px on 375px
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.037), // ~30px on 812px
                      // Limit text
                      Builder(
                        builder: (context) {
                          final limitText = _getLimitText(_selectedPlan, localizations);
                          final maxTextWidth = screenWidth * 0.85; // Max text width
                          final lineCount = _getTextLineCount(limitText, maxTextWidth);
                          final iconAlignment = lineCount == 1 ? CrossAxisAlignment.end : CrossAxisAlignment.center;

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: iconAlignment,
                            children: [
                              // Icon (aligned to bottom or center by line count)
                              SvgPicture.asset(
                                'assets/ic_todo_list.svg',
                                width: screenWidth * 0.048, // ~18px on 375px
                                height: screenWidth * 0.048,
                                colorFilter: const ColorFilter.mode(Color(0xFFBC91DB), BlendMode.srcIn),
                              ),
                              SizedBox(width: screenWidth * 0.032), // ~12px on 375px
                              // Text with fixed 2-line height, bottom aligned
                              Expanded(
                                child: SizedBox(
                                  height: 40, // 2 lines: 16px * 1.25 * 2 = 40px
                                  child: Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Text(
                                      limitText,
                                      style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16,
                                        height: 1.25, // 20px / 16px
                                        color: Color(0xFF000000),
                                      ),
                                      maxLines: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      SizedBox(height: screenHeight * 0.024), // ~20px on 812px
                      // Plan cards
                      Stack(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildPlanCard(
                                plan: SubscriptionPlanType.monthly,
                                title: _getTitle(SubscriptionPlanType.monthly, localizations),
                                price: _getPrice(SubscriptionPlanType.monthly),
                                period: _getPeriod(SubscriptionPlanType.monthly, localizations),
                                isSelected: _selectedPlan == SubscriptionPlanType.monthly,
                                screenWidth: screenWidth,
                                screenHeight: screenHeight,
                              ),
                              _buildPlanCard(
                                plan: SubscriptionPlanType.sixMonth,
                                title: _getTitle(SubscriptionPlanType.sixMonth, localizations),
                                price: _getPrice(SubscriptionPlanType.sixMonth),
                                period: _getPeriod(SubscriptionPlanType.sixMonth, localizations),
                                isSelected: _selectedPlan == SubscriptionPlanType.sixMonth,
                                screenWidth: screenWidth,
                                screenHeight: screenHeight,
                              ),
                              _buildPlanCard(
                                plan: SubscriptionPlanType.yearly,
                                title: _getTitle(SubscriptionPlanType.yearly, localizations),
                                price: _getPrice(SubscriptionPlanType.yearly),
                                period: _getPeriod(SubscriptionPlanType.yearly, localizations),
                                isSelected: _selectedPlan == SubscriptionPlanType.yearly,
                                screenWidth: screenWidth,
                                screenHeight: screenHeight,
                              ),
                            ],
                          ),
                          if (!_isLoading && !_pricesLoaded)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                child: const Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFBC91DB)),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              // "Purchase" button (fixed at bottom)
              Padding(
                padding: EdgeInsets.only(
                  left: screenWidth * 0.043,
                  right: screenWidth * 0.043,
                  top: screenHeight * 0.012,
                  bottom: screenHeight * 0.008,
                ),
                child: GestureDetector(
                  onTap: (_isProcessing || !_pricesLoaded) ? null : _handlePurchase,
                  child: Container(
                    width: double.infinity,
                    height: screenHeight * 0.062, // ~50px on 812px
                    decoration: BoxDecoration(
                      color: (_isProcessing || !_pricesLoaded) ? Colors.grey : const Color(0xFFBC91DB),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Center(
                      child: _isProcessing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              localizations.paywallBuyButton,
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                height: 1.25,
                                color: Color(0xFFFFFFFF),
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              // Restore purchases button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.043),
                child: GestureDetector(
                  onTap: _isProcessing ? null : _handleRestore,
                  child: SizedBox(
                    width: double.infinity,
                    height: screenHeight * 0.044,
                    child: Center(
                      child: Text(
                        localizations.restorePurchases,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          height: 1.25,
                          color: Color(0xFFBC91DB),
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFFBC91DB),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Privacy policy link
              Padding(
                padding: EdgeInsets.only(
                  left: screenWidth * 0.043,
                  right: screenWidth * 0.043,
                  bottom: screenHeight * 0.016,
                ),
                child: GestureDetector(
                  onTap: _openPrivacyPolicy,
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w400,
                        fontSize: 11,
                        height: 1.4,
                        color: Color(0xFF888888),
                      ),
                      children: [
                        TextSpan(text: '${localizations.agreeToPrivacyPolicy} '),
                        TextSpan(
                          text: localizations.privacyPolicy,
                          style: const TextStyle(
                            decoration: TextDecoration.underline,
                            color: Color(0xFF888888),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
                ],
              ),
              // Loading indicator
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFBC91DB)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required SubscriptionPlanType plan,
    required String title,
    required String? price,
    required String period,
    required bool isSelected,
    required double screenWidth,
    required double screenHeight,
  }) {
    final backgroundColor = isSelected ? const Color(0xFFBC91DB) : Colors.white;
    final textColor = isSelected ? Colors.white : const Color(0xFFBC91DB);
    // final borderColor = isSelected ? const Color(0xFF9557C2) : const Color(0xFFBC91DB);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlan = plan;
        });
      },
      child: Container(
        width: screenWidth * 0.277, // ~104px on 375px
        height: screenHeight * 0.17, // ~138px on 812px
        decoration: BoxDecoration(
          color: backgroundColor,
          image: isSelected ? null : const DecorationImage(image: AssetImage('assets/bg_tarif.png'), fit: BoxFit.fill),
          borderRadius: BorderRadius.circular(32),
          // border: Border.all(color: isSelected ? const Color(0xFF9557C2) : borderColor, width: isSelected ? 2 : 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: screenHeight * 0.022),
            Column(
              children: [
                // Period (fixed height 24px)
                SizedBox(
                  height: 24,
                  child: Center(
                    child: Text(
                      period,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        height: 1.21, // 17px / 14px
                        color: textColor,
                      ),
                    ),
                  ),
                ),
                // Plan name
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    height: 1.25, // 20px / 16px
                    color: textColor,
                  ),
                ),
              ],
            ),
            Spacer(),
            // Price (pinned to bottom)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.016),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  price ?? '...',
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    height: 1.22,
                    color: textColor,
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.022),
          ],
        ),
      ),
    );
  }
}
