import 'package:flutter/material.dart';
import '../widgets/common_header.dart';
import '../l10n/app_localizations.dart';

class TestQuestionScreen extends StatefulWidget {
  final int questionIndex; // Question index (0-9)
  final int questionNumber;
  final int totalQuestions;
  final Function(int) onAnswerSelected;
  final VoidCallback? onNext;
  final VoidCallback? onBack;

  const TestQuestionScreen({
    super.key,
    required this.questionIndex,
    required this.questionNumber,
    required this.totalQuestions,
    required this.onAnswerSelected,
    this.onNext,
    this.onBack,
  });

  @override
  State<TestQuestionScreen> createState() => _TestQuestionScreenState();
}

class _TestQuestionScreenState extends State<TestQuestionScreen> {
  int? selectedAnswer;
  bool _isProcessing = false; // Flag to prevent double taps

  @override
  void initState() {
    super.initState();
    selectedAnswer = null;
    _isProcessing = false;
  }

  @override
  void didUpdateWidget(TestQuestionScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.questionIndex != widget.questionIndex) {
      setState(() {
        selectedAnswer = null;
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    // Get question dynamically from localization
    final questions = localizations.testQuestions;
    final question = widget.questionIndex < questions.length 
        ? questions[widget.questionIndex] 
        : '';
    
    print('TestQuestionScreen build called for question ${widget.questionNumber}, index ${widget.questionIndex}');
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
          child: Column(
            children: [
              // Back button and logo
              CommonHeader(onBack: widget.onBack, showBackButton: true),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 50.0),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Question
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                          child: SizedBox(
                            width: double.infinity,
                            child: Text(
                              question,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                                height: 1.2, // 24px / 20px
                                color: Color(0xFFBC91DB),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.05), // Spacing between text and emoji
                        // Emoji row
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(4, (index) {
                              return _buildEmojiButton(
                                emojiIndex: index,
                                isSelected: selectedAnswer == index,
                                onTap: _isProcessing ? null : () => _selectAnswer(index),
                                screenWidth: screenWidth,
                              );
                            }),
                          ),
                        ),
                      ],
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

  void _selectAnswer(int answerIndex) {
    // Prevent double taps
    if (_isProcessing) {
      return;
    }
    
    setState(() {
      selectedAnswer = answerIndex;
      _isProcessing = true;
    });
    
    // Save answer
    widget.onAnswerSelected(answerIndex);
    
    // Auto navigate to next screen with 500ms delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && widget.onNext != null) {
        widget.onNext!();
      }
    });
  }

  Widget _buildEmojiButton({
    required int emojiIndex,
    required bool isSelected,
    required VoidCallback? onTap,
    required double screenWidth,
  }) {
    final buttonSize = screenWidth * 0.189; // 71px on 375px
    final emojiSize = screenWidth * 0.12; // 44.88px on 375px

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFBC91DB) : null,
          image: isSelected ? null : const DecorationImage(image: AssetImage('assets/bg_emoji.png'), fit: BoxFit.fill),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Image.asset(
            'assets/ic_emoji_${emojiIndex + 1}.png',
            width: emojiSize,
            height: emojiSize,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
