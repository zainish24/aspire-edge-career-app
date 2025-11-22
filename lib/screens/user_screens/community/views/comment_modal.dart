// screens/user_screens/community/comment_modal.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:aspire_edge/models/community_model.dart';
import 'package:aspire_edge/services/community_service.dart';
import 'package:aspire_edge/theme/app_theme.dart';
import 'components/community_components.dart';

class CommentModal extends StatefulWidget {
  final String postId;

  const CommentModal({super.key, required this.postId});

  @override
  _CommentModalState createState() => _CommentModalState();
}

class _CommentModalState extends State<CommentModal> {
  final TextEditingController _commentController = TextEditingController();
  final CommunityService _communityService = CommunityService();
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  CommunityUser? _currentUserData;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserProfile();
  }

  Future<void> _loadCurrentUserProfile() async {
    if (_currentUser == null) return;
    
    try {
      final userData = await _communityService.getUser(_currentUser.uid);
      if (mounted) {
        setState(() {
          _currentUserData = userData;
        });
      }
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      if (mounted) {
        setState(() {
          _currentUserData = CommunityUser(
            userId: _currentUser.uid,
            name: _currentUser.displayName ?? 'User',
            createdAt: DateTime.now(),
          );
        });
      }
    }
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) {
      _showSnackbar('Please enter a comment');
      return;
    }
    
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackbar('You must be logged in to comment.');
      return;
    }

    try {
      final comment = Comment(
        commentId: '',
        userId: user.uid,
        userName: _currentUserData?.name ?? 'User',
        userAvatar: _currentUserData?.profilePic,
        commentContent: _commentController.text.trim(),
        timestamp: DateTime.now(),
      );

      await _communityService.addComment(widget.postId, comment);
      
      if (mounted) {
        _commentController.clear();
        FocusScope.of(context).unfocus();
        _showSnackbar('Comment added!');
      }
    } catch (e) {
      _showSnackbar('Failed to post comment. Please try again.');
    }
  }

  Future<void> _deleteComment(String commentId) async {
    try {
      await _communityService.deleteComment(widget.postId, commentId);
      _showSnackbar('Comment deleted successfully!');
    } catch (e) {
      _showSnackbar('Failed to delete comment: $e');
    }
  }

  Future<void> _editComment(String commentId, String currentContent) async {
    final newContentController = TextEditingController(text: currentContent);
    
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorders.radiusLg),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Comment',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: AppText.headlineSmall,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: newContentController,
                  decoration: InputDecoration(
                    hintText: 'Enter your comment...',
                    hintStyle: TextStyle(color: AppColors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppBorders.radiusMd),
                      borderSide: BorderSide(color: AppColors.lightGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppBorders.radiusMd),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                  maxLines: 3,
                  style: TextStyle(color: AppColors.black),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: AppColors.grey),
                      ),
                    ),
                    const SizedBox(width: 12),
                    PrimaryButton(
                      text: 'Save',
                      onPressed: () async {
                        if (newContentController.text.trim().isNotEmpty) {
                          try {
                            await FirebaseFirestore.instance
                                .collection('community_posts')
                                .doc(widget.postId)
                                .collection('comments')
                                .doc(commentId)
                                .update({
                              'commentContent': newContentController.text.trim(),
                              'editedAt': FieldValue.serverTimestamp(),
                            });
                            
                            if (mounted) {
                              Navigator.of(context).pop();
                              _showSnackbar('Comment updated successfully!');
                            }
                          } catch (e) {
                            if (mounted) {
                              _showSnackbar('Failed to update comment: $e');
                            }
                          }
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      newContentController.dispose();
    });
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorders.radiusMd),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.lightGrey),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.chat_bubble_outline, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Career Discussion',
                  style: TextStyle(
                    fontSize: AppText.headlineSmall,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.grey),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Comments List
          Expanded(
            child: StreamBuilder<List<Comment>>(
              stream: _communityService.getComments(widget.postId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  debugPrint('Comments error: ${snapshot.error}');
                  return ErrorRetryWidget(
                    message: 'Failed to load comments',
                    onRetry: () => setState(() {}),
                  );
                }

                final comments = snapshot.data ?? [];

                if (comments.isEmpty) {
                  return EmptyStateWidget(
                    title: 'No comments yet',
                    message: 'Be the first to share your thoughts on this career topic!',
                    buttonText: 'Start Discussion',
                    onButtonPressed: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                      Future.delayed(const Duration(milliseconds: 300), () {
                        FocusScope.of(context).requestFocus(FocusNode());
                      });
                    },
                    icon: Icons.chat_bubble_outline,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    final isMyComment = comment.userId == _currentUser?.uid;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.lightBackground,
                        borderRadius: BorderRadius.circular(AppBorders.radiusMd),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CommunityAvatar(
                            photoUrl: comment.userAvatar,
                            userName: comment.userName,
                            size: 36,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      comment.userName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: AppText.bodyMedium,
                                        color: AppColors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      timeago.format(comment.timestamp),
                                      style: TextStyle(
                                        color: AppColors.grey,
                                        fontSize: AppText.labelSmall,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  comment.commentContent,
                                  style: TextStyle(
                                    fontSize: AppText.bodyMedium,
                                    color: AppColors.darkGrey,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isMyComment)
                            PopupMenuButton<String>(
                              onSelected: (String result) {
                                if (result == 'edit') {
                                  _editComment(comment.commentId, comment.commentContent);
                                } else if (result == 'delete') {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Dialog(
                                        backgroundColor: AppColors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(AppBorders.radiusLg),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Delete Comment',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: AppText.headlineSmall,
                                                  color: AppColors.black,
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              Text(
                                                'Are you sure you want to delete this comment? This action cannot be undone.',
                                                style: TextStyle(
                                                  color: AppColors.darkGrey,
                                                  fontSize: AppText.bodyMedium,
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  TextButton(
                                                    onPressed: () => Navigator.of(context).pop(),
                                                    child: Text(
                                                      'Cancel',
                                                      style: TextStyle(color: AppColors.grey),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  PrimaryButton(
                                                    text: 'Delete',
                                                    onPressed: () {
                                                      Navigator.of(context).pop();
                                                      _deleteComment(comment.commentId);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }
                              },
                              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                PopupMenuItem<String>(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 18, color: AppColors.primary),
                                      const SizedBox(width: 8),
                                      Text('Edit'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, size: 18, color: AppColors.error),
                                      const SizedBox(width: 8),
                                      Text('Delete'),
                                    ],
                                  ),
                                ),
                              ],
                              icon: Icon(Icons.more_vert, size: 18, color: AppColors.grey),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Comment Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border(
                top: BorderSide(color: AppColors.lightGrey),
              ),
            ),
            child: Row(
              children: [
                if (_currentUser != null)
                  CommunityAvatar(
                    photoUrl: _currentUserData?.profilePic,
                    userName: _currentUserData?.name ?? 'User',
                    size: 40,
                  )
                else
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.person, color: AppColors.white, size: 18),
                  ),
                
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.lightBackground,
                      borderRadius: BorderRadius.circular(AppBorders.radiusLg),
                    ),
                    child: TextField(
                      controller: _commentController,
                      style: TextStyle(
                        color: AppColors.black,
                        fontSize: AppText.bodyMedium,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Share your thoughts on this career topic...',
                        hintStyle: TextStyle(
                          color: AppColors.grey,
                          fontSize: AppText.bodyMedium,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      onSubmitted: (_) => _submitComment(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.send,
                      color: AppColors.white,
                      size: 18,
                    ),
                  ),
                  onPressed: _submitComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}