import 'package:flutter/material.dart';
import '../constants/app_palette.dart';
import '../widgets/app_background.dart';
import '../widgets/common_header.dart';
import '../widgets/mood_face.dart';
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
    
    final answerLabels = localizations.answerOptionLabels;

    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return Scaffold(
      backgroundColor: context.palette.scaffold,
      body: AppBackground(
        lightImage: 'assets/background_main.png',
        child: SafeArea(
          child: Column(
            children: [
              // Back button and logo
              CommonHeader(onBack: widget.onBack, showBackButton: true),
              // Progress indicator
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06, vertical: 6),
                child: Column(
                  children: [
                    Text(
                      '${widget.questionNumber} / ${widget.totalQuestions}',
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Color(0xFF9B8AAE),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: widget.totalQuestions == 0
                            ? 0
                            : widget.questionNumber / widget.totalQuestions,
                        minHeight: 6,
                        backgroundColor: const Color(0xFFECE4F3),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFBC91DB)),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(top: screenHeight * 0.03, bottom: 40),
                  child: Column(
                    children: [
                      // Question
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                        child: Text(
                          question,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                            height: 1.3,
                            color: Color(0xFFBC91DB),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.045),
                      // Answer option cards
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                        child: Column(
                          children: List.generate(4, (index) {
                            return _buildAnswerCard(
                              index: index,
                              label: answerLabels.length > index ? answerLabels[index] : '',
                              isSelected: selectedAnswer == index,
                              onTap: _isProcessing ? null : () => _selectAnswer(index),
                            );
                          }),
                        ),
                      ),
                    ],
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

  Widget _buildAnswerCard({
    required int index,
    required String label,
    required bool isSelected,
    required VoidCallback? onTap,
  }) {
    const accent = Color(0xFFBC91DB);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        gradient: isSelected
            ? const LinearGradient(
                colors: [Color(0xFFCBA6E8), accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isSelected ? null : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected ? Colors.transparent : const Color(0xFFEDE6F3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected ? accent.withOpacity(0.32) : Colors.black.withOpacity(0.04),
            blurRadius: isSelected ? 16 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                // Leading line-style mood face
                MoodFace(
                  level: index,
                  size: 42,
                  color: isSelected ? Colors.white : null,
                ),
                const SizedBox(width: 16),
                // Label
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      fontSize: 16,
                      color: isSelected ? Colors.white : const Color(0xFF4A4458),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Trailing selection indicator
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.white : const Color(0xFFD8CCE8),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check_rounded, size: 18, color: accent)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
