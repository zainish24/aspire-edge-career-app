import 'dart:async';

import 'package:flutter/material.dart';
import 'package:aspire_edge/constants.dart';
import 'package:aspire_edge/models/quiz_model.dart';
import 'package:aspire_edge/models/career_model.dart';
import 'package:aspire_edge/services/quiz_service.dart';
import 'career_quiz_result_screen.dart';

class CareerQuizWelcomeScreen extends StatelessWidget {
  final QuizModel quiz;
  final CareerModel career;
  final VoidCallback onStartQuiz;

  const CareerQuizWelcomeScreen({
    super.key,
    required this.quiz,
    required this.career,
    required this.onStartQuiz,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // Modern App Bar
          SliverAppBar(
            backgroundColor: Colors.transparent,
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              expandedTitleScale: 1.5,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (career.images.isNotEmpty)
                    Positioned.fill(
                      child: Image.network(
                        career.images.first,
                        fit: BoxFit.cover,
                      ),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: Padding(
              padding: const EdgeInsets.only(left: 8, top: 8),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),

          // Welcome Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // Welcome Title
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Career Quiz: ${career.title}",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          quiz.description.isNotEmpty
                              ? quiz.description
                              : "Test your knowledge about ${career.title} career path and discover your suitability",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black.withOpacity(0.7),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Quiz Info Cards
                  _buildInfoCard(
                    icon: Icons.quiz_outlined,
                    title: "Total Questions",
                    value: "${quiz.questions.length}",
                    description: "Multiple choice questions",
                  ),

                  const SizedBox(height: 12),

                  _buildInfoCard(
                    icon: Icons.timer_outlined,
                    title: "Time per Question",
                    value: "30 seconds",
                    description: "Think fast, answer wisely",
                  ),

                  const SizedBox(height: 12),

                  _buildInfoCard(
                    icon: Icons.emoji_events_outlined,
                    title: "Scoring System",
                    value: "Points based",
                    description: "Earn points for correct answers",
                  ),

                  const SizedBox(height: 40),

                  // Start Quiz Button
                  Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        onTap: onStartQuiz,
                        borderRadius: BorderRadius.circular(16),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.play_arrow_rounded, 
                                color: Colors.white, size: 24),
                              const SizedBox(width: 8),
                              Text(
                                "Start Quiz Now",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black.withOpacity(0.6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CareerQuizScreen extends StatefulWidget {
  final CareerModel career;

  const CareerQuizScreen({
    super.key,
    required this.career,
  });

  @override
  State<CareerQuizScreen> createState() => _CareerQuizScreenState();
}

class _CareerQuizScreenState extends State<CareerQuizScreen> {
  int currentQuestionIndex = 0;
  int totalScore = 0;
  QuizModel? quiz;
  bool isLoading = true;
  bool showWelcome = true;
  Map<String, String?> selectedAnswers = {};
  Map<String, int> questionTimers = {};
  Map<String, bool> timeExpired = {};
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _loadQuiz() async {
    try {
      final quizData =
          await QuizService().getQuizByCareerId(widget.career.careerId);

      if (mounted) {
        setState(() {
          quiz = quizData;
          isLoading = false;

          if (quiz != null) {
            for (var question in quiz!.questions) {
              questionTimers[question.questionId] = 30;
            }
          }
        });

        if (quiz != null) {
          setState(() {
            showWelcome = true;
          });
        }
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      print('Error loading quiz: $error');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to load quiz: $error"),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _startTimer() {
    _timer?.cancel();
    final currentQuestion = quiz!.questions[currentQuestionIndex];
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (questionTimers[currentQuestion.questionId]! > 0) {
            questionTimers[currentQuestion.questionId] =
                questionTimers[currentQuestion.questionId]! - 1;
          } else {
            _handleTimeExpired();
          }
        });
      }
    });
  }

  void _handleTimeExpired() {
    _timer?.cancel();
    final currentQuestion = quiz!.questions[currentQuestionIndex];
    setState(() {
      timeExpired[currentQuestion.questionId] = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && currentQuestionIndex < quiz!.questions.length - 1) {
        _navigateToQuestion(currentQuestionIndex + 1);
      } else if (mounted) {
        _showCompletionDialog();
      }
    });
  }

  void _answerQuestion(int questionIndex, String option) {
    final question = quiz!.questions[questionIndex];
    if (timeExpired[question.questionId] == true) return;

    _timer?.cancel();

    setState(() {
      selectedAnswers[question.questionId] = option;
      totalScore += question.scoreMap[option] ?? 0;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && currentQuestionIndex < quiz!.questions.length - 1) {
        _navigateToQuestion(currentQuestionIndex + 1);
      } else if (mounted) {
        _showCompletionDialog();
      }
    });
  }

  void _navigateToQuestion(int index) {
    if (index >= 0 && index < quiz!.questions.length) {
      setState(() {
        currentQuestionIndex = index;
      });
      _startTimer();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Quiz Complete"),
        content: const Text(
            "You've completed all questions. Would you like to see your results?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Review"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showResults();
            },
            child: const Text("See Results"),
          ),
        ],
      ),
    );
  }

  void _showResults() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CareerQuizResultScreen(
          score: totalScore,
          totalQuestions: quiz!.questions.length,
          quizTitle: quiz!.title,
          career: widget.career,
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: (currentQuestionIndex + 1) / (quiz?.questions.length ?? 1),
            backgroundColor: Colors.grey.withOpacity(0.3),
            color: AppColors.primary,
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Question ${currentQuestionIndex + 1} of ${quiz?.questions.length ?? 0}",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "${((currentQuestionIndex + 1) / (quiz?.questions.length ?? 1) * 100).toInt()}% Complete",
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimerIndicator() {
    final currentQuestion = quiz!.questions[currentQuestionIndex];
    final timeLeft = questionTimers[currentQuestion.questionId] ?? 30;
    final isExpired = timeExpired[currentQuestion.questionId] == true;
    final isLowTime = timeLeft <= 10 && timeLeft > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isExpired
            ? AppColors.error.withOpacity(0.1)
            : isLowTime
                ? AppColors.warning.withOpacity(0.1)
                : AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isExpired
              ? AppColors.error
              : isLowTime
                  ? AppColors.warning
                  : AppColors.primary,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            size: 16,
            color: isExpired
                ? AppColors.error
                : isLowTime
                    ? AppColors.warning
                    : AppColors.primary,
          ),
          const SizedBox(width: 6),
          Text(
            '$timeLeft',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: isExpired
                  ? AppColors.error
                  : isLowTime
                      ? AppColors.warning
                      : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionNavigation() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Question Navigation",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(quiz!.questions.length, (index) {
              final question = quiz!.questions[index];
              final isCurrent = index == currentQuestionIndex;
              final isAnswered = selectedAnswers.containsKey(question.questionId);
              final isExpired = timeExpired[question.questionId] == true;

              return GestureDetector(
                onTap: () => _navigateToQuestion(index),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? AppColors.primary
                        : isExpired
                            ? AppColors.error.withOpacity(0.1)
                            : isAnswered
                                ? AppColors.primary.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCurrent
                          ? AppColors.primary
                          : isExpired
                              ? AppColors.error
                              : isAnswered
                                  ? AppColors.primary
                                  : Colors.grey.withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: isCurrent ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ] : null,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: isCurrent
                            ? Colors.white
                            : isExpired
                                ? AppColors.error
                                : isAnswered
                                    ? AppColors.primary
                                    : Colors.black.withOpacity(0.6),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    return score == 0 ? AppColors.error : AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 20),
              Text(
                "Loading Quiz...",
                style: TextStyle(
                  color: Colors.black.withOpacity(0.6),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (quiz == null) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text("${widget.career.title} Quiz"),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.quiz_outlined,
                size: 64,
                color: Colors.black.withOpacity(0.3),
              ),
              const SizedBox(height: 20),
              Text(
                "Quiz Not Available",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "No quiz has been created for this career yet.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black.withOpacity(0.6),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Go Back"),
              ),
            ],
          ),
        ),
      );
    }

    if (showWelcome) {
      return CareerQuizWelcomeScreen(
        quiz: quiz!,
        career: widget.career,
        onStartQuiz: () {
          setState(() {
            showWelcome = false;
          });
          _startTimer();
        },
      );
    }

    final question = quiz!.questions[currentQuestionIndex];
    final isLastQuestion = currentQuestionIndex == quiz!.questions.length - 1;
    final isAnswered = selectedAnswers.containsKey(question.questionId);
    final isExpired = timeExpired[question.questionId] == true;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          quiz!.title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          _buildTimerIndicator(),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProgressIndicator(),
            const SizedBox(height: 20),

            // Question Container
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Question ${currentQuestionIndex + 1}",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    question.questionText,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                      color: isExpired ? AppColors.error : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Options
            Expanded(
              child: ListView.builder(
                itemCount: question.options.length,
                itemBuilder: (context, index) {
                  final option = question.options[index];
                  final isSelected =
                      selectedAnswers[question.questionId] == option;
                  final score = question.scoreMap[option] ?? 0;
                  final scoreColor = _getScoreColor(score);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? scoreColor.withOpacity(0.1)
                            : isExpired
                                ? AppColors.error.withOpacity(0.05)
                                : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(
                          color: isSelected
                              ? scoreColor
                              : isExpired
                                  ? AppColors.error
                                  : Colors.grey.withOpacity(0.3),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: isExpired
                              ? null
                              : () => _answerQuestion(currentQuestionIndex, option),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? scoreColor
                                          : isExpired
                                              ? AppColors.error
                                              : Colors.grey,
                                      width: 2,
                                    ),
                                    color: isSelected
                                        ? scoreColor
                                        : Colors.transparent,
                                  ),
                                  child: isSelected
                                      ? Icon(
                                          Icons.check,
                                          size: 16,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    option,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected
                                          ? scoreColor
                                          : isExpired
                                              ? AppColors.error
                                              : Colors.black,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: scoreColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      "+$score",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            _buildQuestionNavigation(),
            const SizedBox(height: 16),

            // Navigation buttons
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: currentQuestionIndex > 0
                            ? () => _navigateToQuestion(currentQuestionIndex - 1)
                            : null,
                        borderRadius: BorderRadius.circular(12),
                        child: Center(
                          child: Text(
                            "Previous",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: currentQuestionIndex > 0
                                  ? Colors.black
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: isAnswered || isExpired
                            ? () {
                                if (isLastQuestion) {
                                  _showCompletionDialog();
                                } else {
                                  _navigateToQuestion(currentQuestionIndex + 1);
                                }
                              }
                            : null,
                        borderRadius: BorderRadius.circular(12),
                        child: Center(
                          child: Text(
                            isLastQuestion ? "Complete Quiz" : "Next",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
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
    );
  }
}