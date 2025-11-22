import 'package:flutter/material.dart';
import 'package:aspire_edge/constants.dart';
import 'package:aspire_edge/models/career_model.dart';
import 'package:aspire_edge/models/quiz_model.dart';
import 'package:aspire_edge/routes/screen_export.dart';
import '../../feedback/views/admin_feedback_career_screen.dart';
import 'package:aspire_edge/services/career_service.dart';
import 'package:aspire_edge/services/quiz_service.dart';

class AdminCareerDetailScreen extends StatefulWidget {
  final String careerId;
  final CareerModel? initial;

  const AdminCareerDetailScreen(
      {super.key, required this.careerId, this.initial});

  @override
  State<AdminCareerDetailScreen> createState() =>
      _AdminCareerDetailScreenState();
}

class _AdminCareerDetailScreenState extends State<AdminCareerDetailScreen> {
  CareerModel? _career;
  QuizModel? _quiz;
  bool _loading = true;

  final CareerService _careerService = CareerService();
  final QuizService _quizService = QuizService();

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      _career = widget.initial;
      _loading = false;
    }
    _loadCareerData();
    _checkForQuiz();
  }

  Future<void> _loadCareerData() async {
    try {
      final career = await _careerService.fetchCareerOnce(widget.careerId);
      if (career != null) {
        setState(() {
          _career = career;
        });
      }
    } catch (e) {
      print("Error loading career: $e");
    }
  }

  Future<void> _checkForQuiz() async {
    try {
      print("Looking for quizzes with careerId: ${widget.careerId}");
      final quiz = await _quizService.getQuizByCareerId(widget.careerId);

      if (quiz != null) {
        print("Quiz found: ${quiz.quizId}, title: ${quiz.title}");
        setState(() {
          _quiz = quiz;
        });
      } else {
        print("No quizzes found for careerId: ${widget.careerId}");
      }
    } catch (e) {
      print("Error checking for quiz: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  void _navigateToQuizScreen() {
    Navigator.of(context).pushNamed(
      adminAddEditQuizScreenRoute,
      arguments: {
        'careerId': widget.careerId,
        'careerData': _career,
        'quizData': _quiz,
      },
    ).then((value) {
      if (value == true) {
        _checkForQuiz();
      }
    });
  }

  void _navigateToFeedbackScreen() {
    if (_career != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AdminCareerFeedbackScreen(
            careerId: _career!.careerId,
            careerTitle: _career!.title,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Career data not available')),
      );
    }
  }

  void _navigateToResourcesScreen() {
    if (_career != null) {
      Navigator.of(context).pushNamed(
        adminResourceScreenRoute,
        arguments: {
          'careerId': widget.careerId,
          'careerTitle': _career!.title,
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Career data not available')),
      );
    }
  }

  Widget _buildHeaderBanner() {
    final imageUrl =
        _career?.images.isNotEmpty == true ? _career!.images.first : '';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            Color(0xFF6366F1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _career?.title ?? "Career Details",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                if (_career?.industryName.isNotEmpty == true)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _career!.industryName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                if (_career?.salaryRange != null &&
                    _career!.salaryRange!.isNotEmpty)
                  Row(
                    children: [
                      Icon(Icons.attach_money_rounded,
                          color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        _career!.salaryRange!,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholderImage();
                      },
                    ),
                  )
                : _buildPlaceholderImage(),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        Icons.work_rounded,
        color: Colors.white,
        size: 32,
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String description,
    required String buttonText,
    required IconData icon,
    required VoidCallback onPressed,
    Color? buttonColor,
    bool hasContent = false,
    String? contentTitle,
    String? contentDescription,
    String? contentMetadata,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              color: AppColors.darkGrey,
              fontSize: 14,
            ),
          ),
          if (hasContent && contentTitle != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contentTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                  if (contentDescription != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      contentDescription,
                      style: const TextStyle(
                        color: AppColors.darkGrey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                  if (contentMetadata != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      contentMetadata,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor ?? AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.circle,
              color: AppColors.primary,
              size: 8,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGrey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Career Details",
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: AppColors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _loadCareerData,
            icon: Icon(Icons.refresh_rounded, color: AppColors.primary),
            tooltip: "Refresh",
          ),
          IconButton(
            icon: Icon(Icons.edit_rounded, color: AppColors.primary),
            onPressed: () {
              Navigator.of(context)
                  .push(
                MaterialPageRoute(
                  builder: (_) => AdminCareerAddEditScreen(
                    careerId: widget.careerId,
                    careerData: _career,
                  ),
                ),
              )
                  .then((value) {
                if (value == true) {
                  _loadCareerData();
                }
              });
            },
          ),
        ],
      ),
      
      
      
      
      
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _career == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        color: AppColors.darkGrey,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Career not found",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkGrey,
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Header Banner
                      _buildHeaderBanner(),

                      const SizedBox(height: 16),

                      // Career Information
                      _buildInfoCard(
                        "Career Information",
                        [
                          if (_career!.description != null &&
                              _career!.description!.isNotEmpty)
                            _buildDetailItem(
                                "Description", _career!.description!),
                          if (_career!.skillNames.isNotEmpty)
                            _buildDetailItem("Required Skills",
                                _career!.skillNames.join(', ')),
                          if (_career!.educationPathNames.isNotEmpty)
                            _buildDetailItem("Education Paths",
                                _career!.educationPathNames.join(', ')),
                          _buildDetailItem(
                              "Created Date",
                              _career!.createdAt
                                      .toDate()
                                      .toString()
                                      .split(' ')[0]),
                        ],
                      ),

                      // Learning Resources
                      _buildActionCard(
                        title: "Learning Resources",
                        description:
                            "Manage blogs, videos, and e-books to help users learn about this career path.",
                        buttonText: "Manage Resources",
                        icon: Icons.library_books_rounded,
                        onPressed: _navigateToResourcesScreen,
                        buttonColor: AppColors.primary,
                      ),

                      // Career Quiz
                      _buildActionCard(
                        title: "Career Quiz",
                        description: _quiz == null
                            ? "No quiz has been created for this career yet. Create one to help users assess their fit."
                            : "Manage the quiz for this career to help users assess their compatibility.",
                        buttonText: _quiz == null ? "Create Quiz" : "Edit Quiz",
                        icon: Icons.quiz_rounded,
                        onPressed: _navigateToQuizScreen,
                        buttonColor: _quiz == null
                            ? AppColors.primary
                            : AppColors.primaryLight,
                        hasContent: _quiz != null,
                        contentTitle: _quiz?.title ?? "",
                        contentDescription:
                            _quiz?.description.isNotEmpty == true
                                ? _quiz!.description
                                : null,
                        contentMetadata: _quiz != null
                            ? "Questions: ${_quiz!.questions.length}"
                            : null,
                      ),

                      // User Feedback
                      _buildActionCard(
                        title: "User Feedback",
                        description:
                            "View feedback submitted by users about this career path and their experiences.",
                        buttonText: "View Feedback",
                        icon: Icons.feedback_rounded,
                        onPressed: _navigateToFeedbackScreen,
                        buttonColor: AppColors.primary,
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }
}