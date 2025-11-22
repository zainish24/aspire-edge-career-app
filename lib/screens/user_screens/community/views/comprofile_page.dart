// screens/user_screens/community/comprofile_page.dart
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aspire_edge/models/community_model.dart';
import 'package:aspire_edge/services/community_service.dart';
import 'package:aspire_edge/theme/app_theme.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'components/community_components.dart';

import 'follow_list_page.dart';
import 'comment_modal.dart';
import 'package:aspire_edge/routes/screen_export.dart'; 

class ComProfilePage extends StatefulWidget {
  final String userId;
  final String userName;

  const ComProfilePage({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<ComProfilePage> createState() => _ComProfilePageState();
}

class _ComProfilePageState extends State<ComProfilePage> {
  final CommunityService _communityService = CommunityService();
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  late Stream<CommunityUser> _userStream;
  late Stream<List<CommunityPost>> _userPostsStream;

  File? profileImage;
  CommunityUser? _currentCommunityUser;

  @override
  void initState() {
    super.initState();
    _initializeStreams();
  }

  void _initializeStreams() {
    _userStream = _communityService.getUserStream(widget.userId);
    _userPostsStream = _communityService.getUserPosts(widget.userId);
  }

  void _refreshData() {
    setState(() {
      _initializeStreams();
    });
  }

  // Updated method to navigate to edit profile with proper data
  void _navigateToEditProfile() async {
    if (_currentCommunityUser == null) return;
    
    final updatedData = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          profileImage: profileImage,
          profilePic: _currentCommunityUser!.profilePic, // Pass existing profile pic
          fullName: _currentCommunityUser!.name, // Use the actual name from community user
          email: _currentUser?.email ?? '',
          tier: _currentCommunityUser!.careerLevel, // Use career level as tier
        ),
      ),
    );
    
    if (updatedData != null && mounted) {
      // Handle the updated data if needed
      setState(() {
        // Update any local state with the returned data
        if (updatedData["profilePic"] != null) {
          // You might want to update the community user data in Firestore
          _refreshData();
        }
      });
      
      // Show success message
      _showSnackbar('Profile updated successfully!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMyProfile = _currentUser?.uid == widget.userId;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: _buildAppBar(isMyProfile),
      body: StreamBuilder<CommunityUser>(
        stream: _userStream,
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          if (userSnapshot.hasError) {
            debugPrint('User stream error: ${userSnapshot.error}');
            return ErrorRetryWidget(
              message: 'Failed to load user profile',
              onRetry: _refreshData,
            );
          }

          if (!userSnapshot.hasData) {
            return const Center(
              child: Text('User not found'),
            );
          }

          final user = userSnapshot.data!;
          _currentCommunityUser = user; // Store the current user data

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildProfileHeader(user, isMyProfile),
                const SizedBox(height: 24),
                _buildProfileStats(user),
                const SizedBox(height: 24),
                _buildCareerInfo(user),
                const SizedBox(height: 24),
                _buildProfileActions(user, isMyProfile),
                const SizedBox(height: 24),
                _buildUserPostsSection(user),
              ],
            ),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(bool isMyProfile) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      centerTitle: false,
      iconTheme: const IconThemeData(color: AppColors.black),
      title: Text(
        "Profile",
        style: TextStyle(
          color: AppColors.black,
          fontWeight: FontWeight.w700,
          fontSize: AppText.headlineSmall,
        ),
      ),
      actions: [
        if (isMyProfile)
          IconButton(
            onPressed: _navigateToEditProfile,
            icon: Icon(Icons.edit_rounded, color: AppColors.primary),
          )
      ],
    );
  }

  Widget _buildProfileHeader(CommunityUser user, bool isMyProfile) {
    return CommunityCard(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              CommunityAvatar(
                photoUrl: user.profilePic,
                userName: user.name,
                size: 100,
              ),
              if (isMyProfile)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _navigateToEditProfile,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        size: 16,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            user.name,
            style: TextStyle(
              fontSize: AppText.headlineMedium,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 4),
          if (user.bio != null && user.bio!.isNotEmpty)
            Text(
              user.bio!,
              style: TextStyle(
                color: AppColors.grey,
                fontSize: AppText.bodyMedium,
              ),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 8),
          Text(
            'Joined ${_formatJoinDate(user.createdAt)}',
            style: TextStyle(
              color: AppColors.grey,
              fontSize: AppText.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  String _formatJoinDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 30) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  Widget _buildProfileStats(CommunityUser user) {
    return CommunityCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            user.followers.length.toString(),
            "Followers",
            onTap: () {
              if (user.followers.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FollowListPage(
                      title: 'Followers',
                      userIds: user.followers,
                    ),
                  ),
                );
              }
            },
          ),
          _buildStatItem(
            user.following.length.toString(),
            "Following",
            onTap: () {
              if (user.following.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FollowListPage(
                      title: 'Following',
                      userIds: user.following,
                    ),
                  ),
                );
              }
            },
          ),
          StreamBuilder<List<CommunityPost>>(
            stream: _userPostsStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                debugPrint('Posts count error: ${snapshot.error}');
                return _buildStatItem('0', "Posts", onTap: () {});
              }

              final postsCount = snapshot.hasData ? snapshot.data!.length : 0;
              return _buildStatItem(
                postsCount.toString(),
                "Posts",
                onTap: () {},
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: AppText.headlineSmall,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: AppColors.grey,
              fontSize: AppText.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCareerInfo(CommunityUser user) {
    final hasCareerInfo = (user.careerInterests?.isNotEmpty ?? false) ||
        (user.skills?.isNotEmpty ?? false) ||
        (user.careerLevel != null && user.careerLevel!.isNotEmpty);

    if (!hasCareerInfo) return const SizedBox();

    return CommunityCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.work_outline, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Career Information',
                style: TextStyle(
                  fontSize: AppText.bodyLarge,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Career Level
          if (user.careerLevel != null && user.careerLevel!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppBorders.radiusLg),
                    ),
                    child: Text(
                      user.careerLevel!,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: AppText.bodySmall,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Career Interests
          if (user.careerInterests?.isNotEmpty ?? false)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Career Interests',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: AppText.bodyMedium,
                      color: AppColors.darkGrey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: user.careerInterests!.map((interest) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.lightGrey,
                          borderRadius:
                              BorderRadius.circular(AppBorders.radiusLg),
                        ),
                        child: Text(
                          interest,
                          style: TextStyle(
                            fontSize: AppText.bodySmall,
                            color: AppColors.darkGrey,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

          // Skills
          if (user.skills?.isNotEmpty ?? false)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Skills',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: AppText.bodyMedium,
                    color: AppColors.darkGrey,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: user.skills!.map((skill) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(AppBorders.radiusLg),
                      ),
                      child: Text(
                        skill,
                        style: TextStyle(
                          fontSize: AppText.bodySmall,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),

          // Expert Badge
          if (user.isCareerExpert ?? false)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppBorders.radiusLg),
                  border: Border.all(color: Colors.amber),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified, color: Colors.amber, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Career Expert',
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: AppText.bodySmall,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileActions(CommunityUser user, bool isMyProfile) {
    if (isMyProfile) {
      return CommunityCard(
        child: Column(
          children: [
            _buildActionTile(
              "Edit Profile",
              Icons.edit_rounded,
              AppColors.primary,
              _navigateToEditProfile,
            ),
          ],
        ),
      );
    }

    return _FollowMessageSection(
      user: user,
      communityService: _communityService,
    );
  }

  Widget _buildActionTile(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.darkGrey,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: AppColors.grey,
      ),
    );
  }

  Widget _buildUserPostsSection(CommunityUser user) {
    return CommunityCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Posts",
            style: TextStyle(
              fontSize: AppText.headlineSmall,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<CommunityPost>>(
            stream: _userPostsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                );
              }

              if (snapshot.hasError) {
                debugPrint('User posts stream error: ${snapshot.error}');
                return ErrorRetryWidget(
                  message: 'Failed to load posts',
                  onRetry: _refreshData,
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return EmptyStateWidget(
                  title: _currentUser?.uid == widget.userId
                      ? 'No posts yet'
                      : 'No posts',
                  message: _currentUser?.uid == widget.userId
                      ? 'Share your first post with the community!'
                      : 'This user hasn\'t shared any posts yet.',
                  buttonText: _currentUser?.uid == widget.userId
                      ? 'Create Post'
                      : 'Browse Community',
                  onButtonPressed: () {
                    if (_currentUser?.uid == widget.userId) {
                      // Navigate to create post
                      _showSnackbar('Create post feature!');
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  icon: Icons.photo_library_outlined,
                );
              }

              final posts = snapshot.data!;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                  childAspectRatio: 1,
                ),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return _PostGridItem(
                    post: post,
                    communityService: _communityService,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _FollowMessageSection extends StatefulWidget {
  final CommunityUser user;
  final CommunityService communityService;

  const _FollowMessageSection({
    required this.user,
    required this.communityService,
  });

  @override
  State<_FollowMessageSection> createState() => _FollowMessageSectionState();
}

class _FollowMessageSectionState extends State<_FollowMessageSection> {
  bool _isFollowing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkIfFollowing();
  }

  void _checkIfFollowing() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      final isFollowing = await widget.communityService.isFollowing(
        currentUser.uid,
        widget.user.userId,
      );

      if (mounted) {
        setState(() {
          _isFollowing = isFollowing;
        });
      }
    } catch (e) {
      debugPrint('Error checking follow status: $e');
    }
  }

  void _toggleFollow() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    setState(() => _isLoading = true);

    try {
      await widget.communityService.toggleFollow(
        currentUser.uid,
        widget.user.userId,
      );

      if (mounted) {
        setState(() {
          _isFollowing = !_isFollowing;
        });
      }

      _showSnackbar(_isFollowing ? 'Followed!' : 'Unfollowed');
    } catch (e) {
      _showSnackbar('Error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CommunityCard(
      child: Row(
        children: [
          Expanded(
            child: PrimaryButton(
              text: _isFollowing ? 'Following' : 'Follow',
              onPressed: _isLoading ? null : () => _toggleFollow(),
              isLoading: _isLoading,
            ),
          ),
        ],
      ),
    );
  }
}

class _PostGridItem extends StatelessWidget {
  final CommunityPost post;
  final CommunityService communityService;

  const _PostGridItem({
    required this.post,
    required this.communityService,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showPostModal(context, post);
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.lightGrey, width: 0.5),
        ),
        child: _buildPostContent(),
      ),
    );
  }

  Widget _buildPostContent() {
    if (post.isImage && post.mediaUrl != null) {
      return _buildImageContent();
    } else if (post.isVideo && post.mediaUrl != null) {
      return _buildVideoContent();
    } else {
      return _buildTextContent();
    }
  }

  Widget _buildImageContent() {
    return Stack(
      children: [
        CachedNetworkImage(
          imageUrl: post.mediaUrl!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          placeholder: (context, url) => _buildLoadingPlaceholder(),
          errorWidget: (context, url, error) {
            return _buildTextContent();
          },
        ),
        Positioned(
          top: 4,
          right: 4,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.photo,
              color: Colors.white,
              size: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoContent() {
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: post.mediaUrl!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          placeholder: (context, url) => _buildLoadingPlaceholder(),
          errorWidget: (context, url, error) {
            return _buildTextContent();
          },
        ),
        Container(
          color: Colors.black.withOpacity(0.3),
          child: const Center(
            child: Icon(
              Icons.play_circle_fill,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.videocam,
              color: Colors.white,
              size: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextContent() {
    return Container(
      color: AppColors.primaryExtraLight,
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Text(
          post.postContent.length > 50
              ? '${post.postContent.substring(0, 50)}...'
              : post.postContent,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 6,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      color: AppColors.lightGrey,
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2,
        ),
      ),
    );
  }

  void _showPostModal(BuildContext context, CommunityPost post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _PostModalContent(
          post: post,
          communityService: communityService,
        );
      },
    );
  }
}

class _PostModalContent extends StatefulWidget {
  final CommunityPost post;
  final CommunityService communityService;

  const _PostModalContent({
    required this.post,
    required this.communityService,
  });

  @override
  State<_PostModalContent> createState() => _PostModalContentState();
}

class _PostModalContentState extends State<_PostModalContent> {
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _checkIfLiked();
  }

  void _checkIfLiked() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _isLiked = widget.post.likedBy.contains(user.uid);
    }
  }

  void _toggleLike() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackbar('Please login to like posts');
      return;
    }

    setState(() {
      _isLiked = !_isLiked;
    });

    try {
      await widget.communityService.toggleLike(widget.post.postId, user.uid);
    } catch (e) {
      setState(() {
        _isLiked = !_isLiked;
      });
      _showSnackbar('Error liking post');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header with user info and close button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.lightGrey),
              ),
            ),
            child: Row(
              children: [
                CommunityAvatar(
                  photoUrl: widget.post.userAvatar,
                  userName: widget.post.userName,
                  size: 40,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.userName,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: AppText.bodyLarge,
                        ),
                      ),
                      Text(
                        timeago.format(widget.post.timestamp),
                        style: TextStyle(
                          color: AppColors.grey,
                          fontSize: AppText.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Post Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Media
                  if (widget.post.mediaUrl != null &&
                      widget.post.mediaUrl!.isNotEmpty)
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(AppBorders.radiusMd),
                        color: AppColors.lightGrey,
                      ),
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppBorders.radiusMd),
                        child: widget.post.isVideo
                            ? Stack(
                                children: [
                                  CachedNetworkImage(
                                    imageUrl: widget.post.mediaUrl!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: 300,
                                    placeholder: (context, url) => Container(
                                      height: 300,
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      height: 300,
                                      color: AppColors.lightGrey,
                                      child: const Icon(Icons.broken_image),
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    child: Center(
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.5),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.play_arrow,
                                          color: Colors.white,
                                          size: 40,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : CachedNetworkImage(
                                imageUrl: widget.post.mediaUrl!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  height: 300,
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  height: 300,
                                  color: AppColors.lightGrey,
                                  child: const Icon(Icons.broken_image),
                                ),
                              ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Post Text Content
                  Text(
                    widget.post.postContent,
                    style: TextStyle(
                      fontSize: AppText.bodyLarge,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Likes count
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      '${widget.post.likes} ${widget.post.likes == 1 ? 'like' : 'likes'}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: AppText.bodyMedium,
                      ),
                    ),
                  ),

                  // Timestamp
                  Text(
                    timeago.format(widget.post.timestamp),
                    style: TextStyle(
                      color: AppColors.grey,
                      fontSize: AppText.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Action Buttons (Like, Comment only)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.lightGrey),
              ),
            ),
            child: Row(
              children: [
                // Like Button
                Expanded(
                  child: _PostActionButton(
                    icon: _isLiked ? Icons.favorite : Icons.favorite_outline,
                    label: 'Like',
                    isActive: _isLiked,
                    activeColor: AppColors.error,
                    onTap: _toggleLike,
                  ),
                ),

                // Comment Button
                Expanded(
                  child: _PostActionButton(
                    icon: Icons.chat_bubble_outline,
                    label: 'Comment',
                    onTap: () {
                      Navigator.pop(context); // Close current modal
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) =>
                            CommentModal(postId: widget.post.postId),
                      );
                    },
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

class _PostActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;
  final Color activeColor;

  const _PostActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
    this.activeColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppBorders.radiusMd),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isActive ? activeColor : AppColors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? activeColor : AppColors.grey,
                fontSize: AppText.bodySmall,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}