import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aspire_edge/models/career_model.dart';
import 'package:aspire_edge/models/quiz_model.dart';
import 'package:aspire_edge/components/custom_dialog.dart';
import 'package:aspire_edge/theme/app_theme.dart';

class AdminAddEditQuizScreen extends StatefulWidget {
  final String careerId;
  final CareerModel? careerData;
  final QuizModel? quizData;

  const AdminAddEditQuizScreen(
      {super.key, required this.careerId, this.careerData, this.quizData});

  @override
  State<AdminAddEditQuizScreen> createState() => _AdminAddEditQuizScreenState();
}

class _AdminAddEditQuizScreenState extends State<AdminAddEditQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  List<QuizQuestion> _questions = [];
  bool _loading = false;
  bool _editMode = false;

  @override
  void initState() {
    super.initState();

    if (widget.quizData != null) {
      final data = widget.quizData!;
      _titleController.text = data.title;
      _descController.text = data.description;
      _questions = data.questions;
    } else {
      _editMode = true;
      _addNewQuestion();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      _editMode = !_editMode;
    });
  }

  void _addNewQuestion() {
    setState(() {
      _questions.add(QuizQuestion(
        questionId: DateTime.now().millisecondsSinceEpoch.toString(),
        questionText: '',
        options: ['', '', ''],
        scoreMap: {},
      ));
    });
  }

  void _removeQuestion(int index) {
    if (_questions.length > 1) {
      setState(() {
        _questions.removeAt(index);
      });
    } else {
      CustomDialog.show(context,
          message: "Quiz must have at least one question", isError: true);
    }
  }

  void _addOption(int questionIndex) {
    setState(() {
      _questions[questionIndex].options.add('');
      _questions[questionIndex].scoreMap[''] = 0;
    });
  }

  void _removeOption(int questionIndex, int optionIndex) {
    if (_questions[questionIndex].options.length > 2) {
      setState(() {
        final optionToRemove = _questions[questionIndex].options[optionIndex];
        _questions[questionIndex].options.removeAt(optionIndex);
        _questions[questionIndex].scoreMap.remove(optionToRemove);
      });
    } else {
      CustomDialog.show(context,
          message: "Question must have at least two options", isError: true);
    }
  }

  void _updateQuestionText(int index, String value) {
    setState(() {
      _questions[index] = QuizQuestion(
        questionId: _questions[index].questionId,
        questionText: value,
        options: _questions[index].options,
        scoreMap: _questions[index].scoreMap,
      );
    });
  }

  void _updateOptionText(int questionIndex, int optionIndex, String value) {
    setState(() {
      final oldOption = _questions[questionIndex].options[optionIndex];
      final score = _questions[questionIndex].scoreMap[oldOption] ?? 0;

      _questions[questionIndex].options[optionIndex] = value;
      _questions[questionIndex].scoreMap.remove(oldOption);
      _questions[questionIndex].scoreMap[value] = score;
    });
  }

  void _updateOptionScore(int questionIndex, int optionIndex, String value) {
    setState(() {
      final option = _questions[questionIndex].options[optionIndex];
      final score = int.tryParse(value) ?? 0;
      _questions[questionIndex].scoreMap[option] = score;
    });
  }

  Future<void> _saveQuiz() async {
    if (!_formKey.currentState!.validate()) return;

    for (int i = 0; i < _questions.length; i++) {
      final question = _questions[i];
      if (question.questionText.isEmpty) {
        CustomDialog.show(context,
            message: "Question ${i + 1} text cannot be empty", isError: true);
        return;
      }

      for (int j = 0; j < question.options.length; j++) {
        if (question.options[j].isEmpty) {
          CustomDialog.show(context,
              message: "Option ${j + 1} in Question ${i + 1} cannot be empty",
              isError: true);
          return;
        }
      }
    }

    setState(() => _loading = true);

    try {
      final quizId = widget.quizData?.quizId ??
          FirebaseFirestore.instance.collection('quizzes').doc().id;

      final quiz = QuizModel(
        quizId: quizId,
        careerId: widget.careerId,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        questions: _questions,
        createdAt: widget.quizData?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(quiz.quizId)
          .set(quiz.toMap());

      if (!mounted) return;

      CustomDialog.show(context,
          message: widget.quizData == null
              ? "Quiz added successfully"
              : "Quiz updated successfully",
          isError: false);

      if (mounted) {
        setState(() => _editMode = false);
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      CustomDialog.show(context,
          message: "Something went wrong: $e", isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(AppBorders.radiusLg),
        boxShadow: AppShadows.largeShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.quizData == null ? "Create New Quiz" : "Quiz Details",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  widget.quizData == null
                      ? "Add a new quiz for ${widget.careerData?.title ?? 'this career'}"
                      : "Manage quiz questions and settings",
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.9),
                    fontSize: AppText.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.quiz_rounded,
              color: AppColors.white,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.quizData != null;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.lightBackground,
          appBar: AppBar(
            elevation: 0,
            centerTitle: true,
            backgroundColor: AppColors.white,
            automaticallyImplyLeading: true,
            titleSpacing: 0,
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                isEdit ? "Quiz Details" : "Create Quiz",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: AppColors.black,
                ),
              ),
            ),
            actions: [
              if (isEdit && !_editMode)
                IconButton(
                  icon: Icon(Icons.edit, color: AppColors.primary),
                  onPressed: _toggleEditMode,
                  tooltip: "Edit Quiz",
                ),
              if (_editMode)
                IconButton(
                  icon: Icon(Icons.close, color: AppColors.darkGrey),
                  onPressed: () {
                    if (isEdit) {
                      setState(() => _editMode = false);
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  tooltip: "Cancel",
                ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Header Banner
                _buildHeaderSection(),

                const SizedBox(height: AppSpacing.sm),

                // Main Content
                Expanded(
                  child: SingleChildScrollView(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Column(
                      children: [
                        // Quiz Form
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius:
                                BorderRadius.circular(AppBorders.radiusLg),
                            boxShadow: AppShadows.mediumShadow,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Quiz Header
                                  _editMode
                                      ? _buildTextField(
                                          controller: _titleController,
                                          label: "Quiz Title",
                                          icon: Icons.quiz,
                                          validator: (v) =>
                                              (v == null || v.trim().isEmpty)
                                                  ? "Enter quiz title"
                                                  : null,
                                        )
                                      : Text(
                                          _titleController.text,
                                          style: TextStyle(
                                            fontSize: AppText.headlineMedium,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.black,
                                          ),
                                        ),
                                  const SizedBox(height: AppSpacing.md),
                                  _editMode
                                      ? _buildTextField(
                                          controller: _descController,
                                          label: "Description",
                                          icon: Icons.description,
                                          maxLines: 3,
                                        )
                                      : Text(
                                          _descController.text.isNotEmpty
                                              ? _descController.text
                                              : "No description provided",
                                          style: TextStyle(
                                            color: AppColors.darkGrey,
                                            fontSize: AppText.bodyMedium,
                                          ),
                                        ),

                                  const SizedBox(height: AppSpacing.lg),

                                  // Questions Section
                                  _buildQuestionsSection(),

                                  if (_editMode) ...[
                                    const SizedBox(height: AppSpacing.lg),

                                    // Add New Question Button - MOVED ABOVE CREATE QUIZ BUTTON
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        icon: Icon(Icons.add,
                                            color: AppColors.white, size: 20),
                                        onPressed: _addNewQuestion,
                                        label: Text(
                                          "Add New Question",
                                          style: TextStyle(
                                            color: AppColors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: AppText.bodyLarge,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.primaryLight,
                                          foregroundColor: AppColors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                AppBorders.radiusMd),
                                          ),
                                          elevation: 2,
                                          shadowColor: AppColors.primary
                                              .withOpacity(0.3),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: AppSpacing.md),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: AppSpacing.md),

                                    // Create/Update Quiz Button
                                    SizedBox(
                                      width: double.infinity,
                                      height: 56,
                                      child: ElevatedButton.icon(
                                        icon: Icon(
                                          isEdit ? Icons.save : Icons.add,
                                          color: AppColors.white,
                                          size: 20,
                                        ),
                                        onPressed: _loading ? null : _saveQuiz,
                                        label: Text(
                                          isEdit
                                              ? "Update Quiz"
                                              : "Create Quiz",
                                          style: TextStyle(
                                            color: AppColors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: AppText.bodyLarge,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: AppColors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                AppBorders.radiusMd),
                                          ),
                                          elevation: 2,
                                          shadowColor: AppColors.primary
                                              .withOpacity(0.3),
                                        ),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: AppSpacing.sm),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_loading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.35),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppBorders.radiusLg),
                    boxShadow: AppShadows.largeShadow,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: AppColors.primary),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        "Saving Quiz...",
                        style: TextStyle(
                          color: AppColors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: AppText.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildQuestionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Questions (${_questions.length})",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.black,
                fontSize: AppText.titleLarge,
              ),
            ),
            if (_editMode)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppBorders.radiusMd),
                ),
                child: Text(
                  "${_questions.length} questions",
                  style: TextStyle(
                    fontSize: AppText.labelMedium,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (!_editMode && _questions.isNotEmpty)
          SizedBox(
            height: 400,
            child: PageView.builder(
              itemCount: _questions.length,
              itemBuilder: (context, questionIndex) {
                return _buildQuestionPreview(questionIndex);
              },
            ),
          )
        else if (_editMode)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _questions.length,
            itemBuilder: (context, questionIndex) {
              return _buildQuestionCard(questionIndex);
            },
          )
        else
          _buildEmptyQuestionsState(),
      ],
    );
  }

  Widget _buildEmptyQuestionsState() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.primaryExtraLight,
        borderRadius: BorderRadius.circular(AppBorders.radiusLg),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(Icons.quiz_outlined, color: AppColors.primary, size: 48),
          const SizedBox(height: AppSpacing.md),
          Text(
            "No Questions Added",
            style: TextStyle(
              color: AppColors.black,
              fontWeight: FontWeight.w600,
              fontSize: AppText.titleLarge,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            "Add questions to create your quiz",
            style: TextStyle(
                color: AppColors.darkGrey, fontSize: AppText.bodyMedium),
            textAlign: TextAlign.center,
          ),
          if (_editMode) ...[
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              icon: Icon(Icons.add, size: 18),
              label: Text("Add First Question"),
              onPressed: _addNewQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppBorders.radiusMd),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuestionPreview(int questionIndex) {
    final question = _questions[questionIndex];

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppBorders.radiusLg),
        boxShadow: AppShadows.mediumShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Question ${questionIndex + 1}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: AppText.titleLarge,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              question.questionText,
              style: TextStyle(
                fontSize: AppText.bodyLarge,
                color: AppColors.darkGrey,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              "Options:",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: AppText.bodyLarge,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: ListView.builder(
                itemCount: question.options.length,
                itemBuilder: (context, optionIndex) {
                  final option = question.options[optionIndex];
                  final score = question.scoreMap[option] ?? 0;

                  return Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.lightBackground,
                      borderRadius: BorderRadius.circular(AppBorders.radiusMd),
                      border: Border.all(color: AppColors.lightGrey),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            option,
                            style: TextStyle(
                              fontSize: AppText.bodyMedium,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(AppBorders.radiusMd),
                          ),
                          child: Text(
                            "Score: $score",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: AppText.labelMedium,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(int questionIndex) {
    final question = _questions[questionIndex];

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppBorders.radiusLg),
        boxShadow: AppShadows.mediumShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Question ${questionIndex + 1}",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                    fontSize: AppText.titleMedium,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: AppColors.error, size: 20),
                  onPressed: () => _removeQuestion(questionIndex),
                  tooltip: "Remove Question",
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              initialValue: question.questionText,
              onChanged: (value) => _updateQuestionText(questionIndex, value),
              style: TextStyle(color: AppColors.black),
              decoration: InputDecoration(
                labelText: "Question Text",
                labelStyle: TextStyle(color: AppColors.darkGrey),
                filled: true,
                fillColor: AppColors.lightBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppBorders.radiusMd),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppBorders.radiusMd),
                  borderSide: BorderSide(color: AppColors.primary, width: 2.0),
                ),
                contentPadding: const EdgeInsets.all(AppSpacing.md),
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? "Enter question text"
                  : null,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              "Options",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.black,
                fontSize: AppText.titleSmall,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: question.options.length,
              itemBuilder: (context, optionIndex) {
                return _buildOptionRow(questionIndex, optionIndex);
              },
            ),
            const SizedBox(height: AppSpacing.md),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                icon: Icon(Icons.add, size: 16),
                label: Text("Add Option"),
                onPressed: () => _addOption(questionIndex),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  foregroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppBorders.radiusMd),
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionRow(int questionIndex, int optionIndex) {
    final option = _questions[questionIndex].options[optionIndex];
    final score = _questions[questionIndex].scoreMap[option] ?? 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextFormField(
              initialValue: option,
              onChanged: (value) =>
                  _updateOptionText(questionIndex, optionIndex, value),
              style: TextStyle(color: AppColors.black),
              decoration: InputDecoration(
                labelText: "Option ${optionIndex + 1}",
                labelStyle: TextStyle(color: AppColors.darkGrey),
                filled: true,
                fillColor: AppColors.lightBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppBorders.radiusMd),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppBorders.radiusMd),
                  borderSide: BorderSide(color: AppColors.primary, width: 2.0),
                ),
                contentPadding: const EdgeInsets.all(AppSpacing.md),
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? "Enter option text"
                  : null,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 1,
            child: TextFormField(
              initialValue: score.toString(),
              onChanged: (value) =>
                  _updateOptionScore(questionIndex, optionIndex, value),
              keyboardType: TextInputType.number,
              style: TextStyle(color: AppColors.black),
              decoration: InputDecoration(
                labelText: "Score",
                labelStyle: TextStyle(color: AppColors.darkGrey),
                filled: true,
                fillColor: AppColors.lightBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppBorders.radiusMd),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppBorders.radiusMd),
                  borderSide: BorderSide(color: AppColors.primary, width: 2.0),
                ),
                contentPadding: const EdgeInsets.all(AppSpacing.md),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          IconButton(
            icon: Icon(Icons.delete, color: AppColors.error, size: 20),
            onPressed: () => _removeOption(questionIndex, optionIndex),
            tooltip: "Remove Option",
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool readOnly = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        readOnly: readOnly,
        maxLines: maxLines,
        style: TextStyle(color: AppColors.black),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.darkGrey),
          prefixIcon: Icon(icon, color: AppColors.primary),
          filled: true,
          fillColor: AppColors.lightBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppBorders.radiusMd),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppBorders.radiusMd),
            borderSide: BorderSide(color: AppColors.primary, width: 2.0),
          ),
          contentPadding: const EdgeInsets.all(AppSpacing.md),
        ),
      ),
    );
  }
}
