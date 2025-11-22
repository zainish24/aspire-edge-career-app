import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aspire_edge/constants.dart';
import 'package:aspire_edge/models/feedback_model.dart';
import 'package:aspire_edge/services/feedback_service.dart';

class AdminFeedbackDetailScreen extends StatefulWidget {
  final FeedbackModel feedback;

  const AdminFeedbackDetailScreen({
    super.key,
    required this.feedback,
  });

  @override
  State<AdminFeedbackDetailScreen> createState() => _AdminFeedbackDetailScreenState();
}

class _AdminFeedbackDetailScreenState extends State<AdminFeedbackDetailScreen> {
  final FeedbackService _feedbackService = FeedbackService();
  final List<String> statusOptions = ['New', 'In Review', 'Resolved', 'Archived'];
  final List<String> categoryOptions = [
    'bug report',
    'suggestion',
    'positive feedback',
    'negative feedback'
  ];
  
  String _selectedStatus = 'New'; // Default value to prevent null
  String _selectedCategory = 'suggestion'; // Default value
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    // Initialize with actual values from feedback
    _selectedStatus = 'New'; // widget.feedback.status ?? 'New';
    _selectedCategory = widget.feedback.category;
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isUpdating = true);
    try {
      await _feedbackService.updateFeedbackStatus(widget.feedback.feedbackId, newStatus);
      setState(() => _selectedStatus = newStatus);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status updated to $newStatus'),
          backgroundColor: AppColors.success,
        )
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating status: $e'),
          backgroundColor: AppColors.error,
        )
      );
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  Future<void> _updateCategory(String newCategory) async {
    setState(() => _isUpdating = true);
    try {
      await _feedbackService.updateFeedbackCategory(widget.feedback.feedbackId, newCategory);
      setState(() => _selectedCategory = newCategory);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Category updated to ${_formatCategory(newCategory)}'),
          backgroundColor: AppColors.success,
        )
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating category: $e'),
          backgroundColor: AppColors.error,
        )
      );
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  Future<void> _deleteFeedback() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Feedback'),
        content: const Text('Are you sure you want to delete this feedback? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isUpdating = true);
      try {
        await _feedbackService.deleteFeedback(widget.feedback.feedbackId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Feedback deleted successfully'),
            backgroundColor: AppColors.success,
          )
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting feedback: $e'),
            backgroundColor: AppColors.error,
          )
        );
      } finally {
        setState(() => _isUpdating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Feedback Details',
          style: TextStyle(
            color: AppColors.black,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_rounded, color: AppColors.error),
            onPressed: _deleteFeedback,
            tooltip: 'Delete Feedback',
          ),
        ],
      ),
      body: _isUpdating
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  Container(
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
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
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
                                "Feedback Details",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "From ${widget.feedback.name}",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.feedback_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Status and Category Cards
                  isSmallScreen
                      ? Column(
                          children: [
                            _buildActionCard(
                              'Status',
                              _selectedStatus,
                              Icons.flag_rounded,
                              _getStatusColor(_selectedStatus),
                              statusOptions,
                              _updateStatus,
                            ),
                            const SizedBox(height: 12),
                            _buildActionCard(
                              'Category',
                              _selectedCategory,
                              _getCategoryIcon(_selectedCategory),
                              _getCategoryColor(_selectedCategory),
                              categoryOptions,
                              _updateCategory,
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: _buildActionCard(
                                'Status',
                                _selectedStatus,
                                Icons.flag_rounded,
                                _getStatusColor(_selectedStatus),
                                statusOptions,
                                _updateStatus,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildActionCard(
                                'Category',
                                _selectedCategory,
                                _getCategoryIcon(_selectedCategory),
                                _getCategoryColor(_selectedCategory),
                                categoryOptions,
                                _updateCategory,
                              ),
                            ),
                          ],
                        ),

                  const SizedBox(height: 20),

                  // Feedback Content Card
                  Container(
                    padding: const EdgeInsets.all(16),
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
                        const Row(
                          children: [
                            Icon(Icons.message_rounded, color: AppColors.primary, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Feedback Message',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.lightGrey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.feedback.message,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.black,
                              height: 1.4,
                            ),
                          ),
                        ),
                        if (widget.feedback.rating > 0) ...[
                          const SizedBox(height: 16),
                          _buildRatingSection(),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // User Information Card
                  Container(
                    padding: const EdgeInsets.all(16),
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
                        const Row(
                          children: [
                            Icon(Icons.person_rounded, color: AppColors.primary, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'User Information',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow('Name', widget.feedback.name, Icons.person_outline_rounded),
                        if (widget.feedback.email.isNotEmpty)
                          _buildInfoRow('Email', widget.feedback.email, Icons.email_rounded),
                        if (widget.feedback.phone.isNotEmpty)
                          _buildInfoRow('Phone', widget.feedback.phone, Icons.phone_rounded),
                        _buildInfoRow('Career', widget.feedback.careerTitle, Icons.work_rounded),
                        _buildInfoRow('Submitted', _formatDate(widget.feedback.date), Icons.calendar_today_rounded),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildActionCard(
    String title,
    String value,
    IconData icon,
    Color color,
    List<String> options,
    Function(String) onUpdate,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
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
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButton<String>(
                value: value,
                items: options.map((option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(
                      _formatCategory(option),
                      style: TextStyle(
                        fontSize: 14,
                        color: color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    onUpdate(newValue);
                  }
                },
                isExpanded: true,
                underline: const SizedBox(),
                icon: Icon(Icons.arrow_drop_down_rounded, color: color),
                dropdownColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.star_rounded, color: Colors.amber, size: 20),
            SizedBox(width: 8),
            Text(
              'User Rating',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildRatingStars(widget.feedback.rating),
            const SizedBox(width: 8),
            Text(
              '${widget.feedback.rating}/5',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingStars(int rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
          color: Colors.amber,
          size: 20,
        );
      }),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 16),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkGrey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'New': return AppColors.primary;
      case 'In Review': return AppColors.warning;
      case 'Resolved': return AppColors.success;
      case 'Archived': return AppColors.grey;
      default: return AppColors.grey;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'positive feedback': return AppColors.success;
      case 'negative feedback': return AppColors.error;
      case 'bug report': return AppColors.warning;
      case 'suggestion': return AppColors.primary;
      default: return AppColors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'positive feedback': return Icons.thumb_up_rounded;
      case 'negative feedback': return Icons.thumb_down_rounded;
      case 'bug report': return Icons.bug_report_rounded;
      case 'suggestion': return Icons.lightbulb_rounded;
      default: return Icons.feedback_rounded;
    }
  }

  String _formatCategory(String category) {
    return category.replaceAll('_', ' ').split(' ').map((word) {
      if (word.isEmpty) return '';
      return '${word[0].toUpperCase()}${word.substring(1)}';
    }).join(' ');
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy • HH:mm').format(date);
  }
}