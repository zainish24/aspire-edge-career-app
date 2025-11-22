// screens/user_screens/community/follow_list_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aspire_edge/models/community_model.dart';
import 'package:aspire_edge/services/community_service.dart';
import 'package:aspire_edge/theme/app_theme.dart';
import 'components/community_components.dart';
import 'comprofile_page.dart';

class FollowListPage extends StatefulWidget {
  final String title;
  final List<String> userIds;

  const FollowListPage({
    super.key,
    required this.title,
    required this.userIds,
  });

  @override
  State<FollowListPage> createState() => _FollowListPageState();
}

class _FollowListPageState extends State<FollowListPage> {
  final CommunityService _communityService = CommunityService();
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: _buildAppBar(),
      body: _buildUserList(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      centerTitle: false,
      iconTheme: const IconThemeData(color: AppColors.black),
      title: Text(
        widget.title,
        style: TextStyle(
          color: AppColors.black,
          fontWeight: FontWeight.w700,
          fontSize: AppText.headlineSmall,
        ),
      ),
    );
  }

  Widget _buildUserList() {
    if (widget.userIds.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.userIds.length,
      itemBuilder: (context, index) {
        final userId = widget.userIds[index];
        return _buildUserListItem(userId);
      },
    );
  }

  Widget _buildUserListItem(String userId) {
    return FutureBuilder<CommunityUser>(
      future: _communityService.getUser(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildUserListShimmer();
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox.shrink();
        }

        final user = snapshot.data!;
        final isCurrentUser = _currentUser?.uid == userId;

        return CommunityCard(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CommunityAvatar(
              photoUrl: user.profilePic,
              userName: user.name,
              size: 50,
            ),
            title: Text(
              isCurrentUser ? '${user.name} (You)' : user.name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: AppText.bodyLarge,
                color: AppColors.black,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (user.bio != null && user.bio!.isNotEmpty)
                  Text(
                    user.bio!,
                    style: TextStyle(
                      color: AppColors.grey,
                      fontSize: AppText.bodySmall,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (user.careerLevel != null && user.careerLevel!.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppBorders.radiusMd),
                    ),
                    child: Text(
                      user.careerLevel!,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: AppText.labelSmall,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            trailing: isCurrentUser
                ? null
                : _FollowButton(
                    targetUserId: userId,
                    communityService: _communityService,
                  ),
            onTap: isCurrentUser
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ComProfilePage(
                          userId: userId,
                          userName: user.name,
                        ),
                      ),
                    );
                  },
          ),
        );
      },
    );
  }

  Widget _buildUserListShimmer() {
    return CommunityCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: LoadingShimmer(
          width: 50,
          height: 50,
          borderRadius: BorderRadius.circular(25),
        ),
        title: LoadingShimmer(
          width: 120,
          height: 16,
          borderRadius: BorderRadius.circular(8),
        ),
        subtitle: Container(
          margin: const EdgeInsets.only(top: 4),
          child: LoadingShimmer(
            width: 80,
            height: 12,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return EmptyStateWidget(
      title: widget.title == 'Followers' 
          ? 'No followers yet'
          : 'Not following anyone',
      message: widget.title == 'Followers'
          ? 'When someone follows you, they\'ll appear here.'
          : 'When you follow someone, they\'ll appear here.',
      buttonText: 'Browse Community',
      onButtonPressed: () => Navigator.pop(context),
      icon: widget.title == 'Followers' 
          ? Icons.people_outline_rounded
          : Icons.person_outline_rounded,
    );
  }
}

class _FollowButton extends StatefulWidget {
  final String targetUserId;
  final CommunityService communityService;

  const _FollowButton({
    required this.targetUserId,
    required this.communityService,
  });

  @override
  State<_FollowButton> createState() => __FollowButtonState();
}

class __FollowButtonState extends State<_FollowButton> {
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

    final isFollowing = await widget.communityService.isFollowing(
      currentUser.uid,
      widget.targetUserId,
    );
    
    if (mounted) {
      setState(() {
        _isFollowing = isFollowing;
      });
    }
  }

  void _toggleFollow() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    setState(() => _isLoading = true);

    try {
      await widget.communityService.toggleFollow(
        currentUser.uid,
        widget.targetUserId,
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
    return SizedBox(
      width: 100,
      height: 36,
      child: _isFollowing
          ? SecondaryButton(
              text: 'Following',
              onPressed: _isLoading ? null : _toggleFollow,
              isLoading: _isLoading,
            )
          : PrimaryButton(
              text: 'Follow',
              onPressed: _isLoading ? null : _toggleFollow,
              isLoading: _isLoading,
            ),
    );
  }
}