import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:aspire_edge/config_example.dart';
import 'dart:convert';
import 'package:aspire_edge/models/community_model.dart';
import 'package:aspire_edge/services/community_service.dart';
import 'package:aspire_edge/theme/app_theme.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';
import 'components/community_components.dart';
import 'comment_modal.dart';
import 'comprofile_page.dart';

Future<String?> uploadToCloudinary(XFile file, String fileType) async {
  final String cloudinaryCloudName = CloudinaryConfig.cloudName;
  final String cloudinaryUploadPreset = CloudinaryConfig.uploadPreset;

  final cloudinaryResourceType = fileType == 'audio' ? 'raw' : fileType;
  final url = Uri.parse(
    'https://api.cloudinary.com/v1_1/$cloudinaryCloudName/$cloudinaryResourceType/upload',
  );

  final request = http.MultipartRequest('POST', url)
    ..fields['upload_preset'] = cloudinaryUploadPreset;

  try {
    final bytes = await file.readAsBytes();
    request.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: file.name),
    );

    final response = await request.send();
    final responseData = await response.stream.toBytes();
    final jsonResponse = jsonDecode(String.fromCharCodes(responseData));

    if (response.statusCode == 200) {
      return jsonResponse['secure_url'];
    } else {
      debugPrint(
          'Cloudinary upload failed: ${jsonResponse['error']['message']}');
      return null;
    }
  } catch (e) {
    debugPrint('Error uploading to Cloudinary: $e');
    return null;
  }
}

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage>
    with SingleTickerProviderStateMixin {
  final CommunityService _communityService = CommunityService();
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final ScrollController _scrollController = ScrollController();
  bool _refreshing = false;
  bool _isLoading = true;

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<Offset> _logoSlideAnimation;

  // Career community state
  String _selectedChannel = 'all';
  String? _selectedCareerField;
  List<String> _careerFields = [];
  bool _loadingCareers = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadInitialData();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeInOutCubic),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 1.0, curve: Curves.elasticOut),
      ),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _logoSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }

  Future<void> _loadInitialData() async {
    try {
      await Future.wait([
        _loadCareerFields(),
        Future.delayed(
            const Duration(milliseconds: 1500)), // Minimum loading time
      ]);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading initial data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadCareerFields() async {
    try {
      final fields = await _communityService.getCareerFields();
      if (mounted) {
        setState(() {
          _careerFields = fields;
          _loadingCareers = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading career fields: $e');
      if (mounted) {
        setState(() {
          _loadingCareers = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    if (_refreshing) return;

    setState(() {
      _refreshing = true;
    });

    await Future.wait([
      _loadCareerFields(),
      Future.delayed(const Duration(milliseconds: 500)),
    ]);

    if (mounted) {
      setState(() {
        _refreshing = false;
      });
    }
  }

  void _changeChannel(String channel) {
    setState(() {
      _selectedChannel = channel;
    });
  }

  void _changeCareerField(String? careerField) {
    setState(() {
      _selectedCareerField = careerField;
    });
  }

  // Enhanced Loading State like Home Screen
  Widget _buildEnhancedLoadingState() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withOpacity(0.05),
            AppColors.lightBackground,
          ],
        ),
      ),
      child: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SlideTransition(
                  position: _logoSlideAnimation,
                  child: ScaleTransition(
                    scale: _logoScaleAnimation,
                    child: SizedBox(
                      width: 300,
                      height: 300,
                      child: Image.asset(
                        'assets/logo/aspire_edge.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Text with fade animation
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Text(
                        'Aspire Edge',
                        style: TextStyle(
                          fontSize: 32,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loading Career Community...',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.darkGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: 280,
                        child: LinearProgressIndicator(
                          backgroundColor: AppColors.lightGrey,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.primary),
                          borderRadius: BorderRadius.circular(12),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: _buildAppBar(),
      body: _isLoading
          ? _buildEnhancedLoadingState()
          : AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: RefreshIndicator(
                      onRefresh: _refreshData,
                      color: AppColors.primary,
                      backgroundColor: AppColors.white,
                      child: CustomScrollView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(
                            child: Column(
                              children: [
                                const SizedBox(height: 8),
                                // New Post Section
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: _NewPostSection(
                                    communityService: _communityService,
                                    selectedCareerField: _selectedCareerField,
                                    onCareerFieldChanged: _changeCareerField,
                                    careerFields: _careerFields,
                                    loadingCareers: _loadingCareers,
                                    onPostCreated: _refreshData,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Career Channels
                                _buildCareerChannels(),
                              ],
                            ),
                          ),
                          // Posts List
                          _buildPostsList(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        'Career Community',
        style: TextStyle(
          color: AppColors.black,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
      backgroundColor: AppColors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: AppColors.black),
      actions: [
        if (_currentUser != null)
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: StreamBuilder<CommunityUser>(
              stream: _communityService.getUserStream(_currentUser!.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.lightGrey,
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                }

                final user = snapshot.data;
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ComProfilePage(
                          userId: _currentUser!.uid,
                          userName: user?.name ?? 'User',
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                      image: user?.profilePic != null
                          ? DecorationImage(
                              image: NetworkImage(user!.profilePic!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: user?.profilePic == null
                        ? Center(
                            child: Text(
                              user?.name.isNotEmpty == true
                                  ? user!.name[0].toUpperCase()
                                  : 'U',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildCareerChannels() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
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
                  'Career Community',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Icon(Icons.work_outline, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Career Field:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.lightBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.lightGrey),
                    ),
                    child: _loadingCareers
                        ? Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedCareerField,
                              isExpanded: true,
                              icon: Icon(Icons.arrow_drop_down,
                                  size: 24, color: AppColors.grey),
                              hint: Text(
                                'All Careers',
                                style: TextStyle(
                                    fontSize: 14, color: AppColors.grey),
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: null,
                                  child: Text(
                                    'All Careers',
                                    style: TextStyle(color: AppColors.darkGrey),
                                  ),
                                ),
                                ..._careerFields.map((field) {
                                  return DropdownMenuItem(
                                    value: field,
                                    child: Text(
                                      field,
                                      style: TextStyle(
                                          fontSize: 14, color: AppColors.black),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                              ],
                              onChanged: _changeCareerField,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildChannelChip('All', 'all', Icons.home),
                const SizedBox(width: 8),
                _buildChannelChip(
                    'Career Advice', 'career-advice', Icons.work_outline),
                const SizedBox(width: 8),
                _buildChannelChip('Interview Prep', 'interview-prep',
                    Icons.edit_calendar_outlined),
                const SizedBox(width: 8),
                _buildChannelChip(
                    'Skill Sharing', 'skill-sharing', Icons.school_outlined),
                const SizedBox(width: 8),
                _buildChannelChip('Success Stories', 'success-stories',
                    Icons.emoji_events_outlined),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChannelChip(String label, String value, IconData icon) {
    final isSelected = _selectedChannel == value;
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.lightGrey,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _changeChannel(value),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isSelected ? Colors.white : AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.darkGrey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPostsList() {
    Stream<List<CommunityPost>> postsStream;

    if (_selectedChannel != 'all' || _selectedCareerField != null) {
      postsStream = _communityService.getCareerPosts(
        careerField: _selectedCareerField,
        postCategory: _selectedChannel != 'all' ? _selectedChannel : null,
      );
    } else {
      postsStream = _communityService.getCommunityPosts();
    }

    return StreamBuilder<List<CommunityPost>>(
      stream: postsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _PostShimmer(),
              ),
              childCount: 4,
            ),
          );
        }

        if (snapshot.hasError) {
          debugPrint('Posts error: ${snapshot.error}');
          return SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
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
                children: [
                  Icon(Icons.error_outline, size: 48, color: AppColors.error),
                  const SizedBox(height: 12),
                  Text(
                    'Failed to load posts',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please check your connection and try again',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: Text(
                      'Try Again',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final posts = snapshot.data ?? [];

        if (posts.isEmpty) {
          return SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.work_outline,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _selectedChannel != 'all'
                        ? 'No posts in ${_getChannelName(_selectedChannel)}'
                        : _selectedCareerField != null
                            ? 'No posts in $_selectedCareerField'
                            : 'No posts yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedChannel != 'all'
                        ? 'Be the first to share in this category!'
                        : _selectedCareerField != null
                            ? 'Be the first to share about $_selectedCareerField!'
                            : 'Start the conversation by sharing your first post!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: Text(
                      'Create First Post',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final post = posts[index];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  top: index == 0 ? 0 : 8,
                ),
                child: _PostCard(
                  post: post,
                  communityService: _communityService,
                ),
              );
            },
            childCount: posts.length,
          ),
        );
      },
    );
  }

  String _getChannelName(String channel) {
    switch (channel) {
      case 'career-advice':
        return 'Career Advice';
      case 'interview-prep':
        return 'Interview Prep';
      case 'skill-sharing':
        return 'Skill Sharing';
      case 'success-stories':
        return 'Success Stories';
      default:
        return 'this category';
    }
  }
}

class _NewPostSection extends StatefulWidget {
  final CommunityService communityService;
  final String? selectedCareerField;
  final ValueChanged<String?> onCareerFieldChanged;
  final List<String> careerFields;
  final bool loadingCareers;
  final VoidCallback onPostCreated;

  const _NewPostSection({
    required this.communityService,
    this.selectedCareerField,
    required this.onCareerFieldChanged,
    required this.careerFields,
    required this.loadingCareers,
    required this.onPostCreated,
  });

  @override
  State<_NewPostSection> createState() => _NewPostSectionState();
}

class _NewPostSectionState extends State<_NewPostSection> {
  final TextEditingController _postController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  CommunityUser? _currentUser;

  String? _selectedCareerField;
  String _selectedPostType = 'question';
  final List<String> _selectedSkills = [];
  List<String> _commonSkills = [];
  bool _loadingSkills = true;

  // New state for media attachment
  XFile? _selectedMedia;
  String? _mediaType;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _selectedCareerField = widget.selectedCareerField;
    _loadCommonSkills();
  }

  @override
  void didUpdateWidget(covariant _NewPostSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCareerField != oldWidget.selectedCareerField) {
      setState(() {
        _selectedCareerField = widget.selectedCareerField;
      });
    }
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userData = await widget.communityService.getUser(user.uid);
        if (mounted) {
          setState(() {
            _currentUser = userData;
          });
        }
      } catch (e) {
        debugPrint('Error loading current user: $e');
        if (mounted) {
          setState(() {
            _currentUser = CommunityUser(
              userId: user.uid,
              name: 'User',
              createdAt: DateTime.now(),
            );
          });
        }
      }
    }
  }

  Future<void> _loadCommonSkills() async {
    try {
      final skills = await widget.communityService.getCommonSkills();
      if (mounted) {
        setState(() {
          // Remove duplicates by converting to Set and back to List
          _commonSkills = skills.toSet().toList();
          _loadingSkills = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading common skills: $e');
      if (mounted) {
        setState(() {
          _loadingSkills = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery, imageQuality: 75);
      if (image != null) {
        setState(() {
          _selectedMedia = image;
          _mediaType = 'image';
        });
      }
    } catch (e) {
      _showSnackbar('Failed to pick image: $e');
    }
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        setState(() {
          _selectedMedia = video;
          _mediaType = 'video';
        });
      }
    } catch (e) {
      _showSnackbar('Failed to pick video: $e');
    }
  }

  void _removeMedia() {
    setState(() {
      _selectedMedia = null;
      _mediaType = null;
    });
  }

  Future<void> _createPost() async {
    if (_postController.text.trim().isEmpty && _selectedMedia == null) {
      _showSnackbar('Please enter some content or select media');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackbar('Please login to post');
      return;
    }

    setState(() => _isUploading = true);

    try {
      String? mediaUrl;

      // Upload media if selected
      if (_selectedMedia != null) {
        mediaUrl = await uploadToCloudinary(_selectedMedia!, _mediaType!);
        if (mediaUrl == null) {
          _showSnackbar('Failed to upload media');
          return;
        }
      }

      // FIXED: Only use careerTags for skills, not relevantSkills
      final post = CommunityPost(
        postId: '',
        userId: _currentUser!.userId,
        userName: _currentUser?.name ?? 'User',
        userAvatar: _currentUser?.profilePic,
        postContent: _postController.text.trim(),
        mediaUrl: mediaUrl,
        mediaType: _mediaType,
        timestamp: DateTime.now(),
        careerField: _selectedCareerField,
        postType: _selectedPostType,
        relevantSkills: [], // Keep empty - we're using careerTags instead
        isExpertPost: _currentUser?.isCareerExpert ?? false,
        careerTags: _selectedSkills, // This is where skills are stored
        postCategory: _getPostCategory(),
      );

      await widget.communityService.createPost(post);

      // Clear form after successful post
      _postController.clear();
      _selectedMedia = null;
      _mediaType = null;
      _selectedSkills.clear();

      _showSnackbar('Post shared successfully! 🎉');
      FocusScope.of(context).unfocus();
      widget.onPostCreated();
    } catch (e) {
      _showSnackbar('Failed to create post: $e');
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  String? _getPostCategory() {
    switch (_selectedPostType) {
      case 'question':
        return 'career-advice';
      case 'experience':
        return 'success-stories';
      case 'tip':
        return 'skill-sharing';
      case 'success_story':
        return 'success-stories';
      default:
        return null;
    }
  }

  String _getPostTypeLabel(String postType) {
    switch (postType) {
      case 'question':
        return 'Question';
      case 'experience':
        return 'Experience';
      case 'tip':
        return 'Tip';
      case 'success_story':
        return 'Success Story';
      case 'resource':
        return 'Resource';
      default:
        return 'Post';
    }
  }

  void _showSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _toggleSkill(String skill) {
    setState(() {
      if (_selectedSkills.contains(skill)) {
        _selectedSkills.remove(skill);
      } else {
        _selectedSkills.add(skill);
      }
    });
  }

  void _showCareerPostingOptions() {
    // Use a delay to ensure smooth animation
    Future.delayed(Duration(milliseconds: 50), () {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => _CareerPostingOptions(
          selectedCareerField: _selectedCareerField,
          selectedPostType: _selectedPostType,
          selectedSkills: _selectedSkills,
          careerFields: widget.careerFields,
          commonSkills: _commonSkills,
          loadingCareers: widget.loadingCareers,
          loadingSkills: _loadingSkills,
          onCareerFieldChanged: (value) {
            setState(() {
              _selectedCareerField = value;
            });
            widget.onCareerFieldChanged(value);
          },
          onPostTypeChanged: (value) {
            setState(() {
              _selectedPostType = value;
            });
          },
          onSkillToggled: _toggleSkill,
          onClear: () {
            setState(() {
              _selectedCareerField = null;
              _selectedPostType = 'question';
              _selectedSkills.clear();
            });
            widget.onCareerFieldChanged(null);
            Navigator.pop(context); // Close modal after clear
          },
        ),
      ).then((_) {
        // Update UI when modal closes
        setState(() {});
      });
    });
  }

  Widget _buildSelectedOptionsPreview() {
    final hasSelections =
        _selectedCareerField != null || _selectedSkills.isNotEmpty;

    if (!hasSelections) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_selectedCareerField != null)
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Career: ',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkGrey,
                            ),
                          ),
                          Text(
                            _selectedCareerField!,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    if (_selectedSkills.isNotEmpty)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Skills: ${_selectedSkills.join(', ')}',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.darkGrey,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    if (_selectedPostType != 'question')
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Type: ',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkGrey,
                            ),
                          ),
                          Text(
                            _getPostTypeLabel(_selectedPostType),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _showCareerPostingOptions,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.edit,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMediaPreview() {
    if (_mediaType == 'image') {
      if (kIsWeb) {
        // For web, convert XFile to bytes and create a memory image
        return FutureBuilder<Uint8List>(
          future: _selectedMedia!.readAsBytes(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: AppColors.grey),
                  const SizedBox(height: 8),
                  Text('Failed to load image',
                      style: TextStyle(color: AppColors.grey)),
                ],
              );
            }
            return Image.memory(
              snapshot.data!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 200,
            );
          },
        );
      } else {
        // For mobile, use Image.file
        return Image.file(
          File(_selectedMedia!.path),
          fit: BoxFit.cover,
          width: double.infinity,
          height: 200,
        );
      }
    } else {
      // Video preview
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.videocam, size: 48, color: AppColors.grey),
          const SizedBox(height: 8),
          Text(
            'Video Selected',
            style: TextStyle(color: AppColors.grey),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                      image: _currentUser?.profilePic != null
                          ? DecorationImage(
                              image: NetworkImage(_currentUser!.profilePic!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _currentUser?.profilePic == null
                        ? Center(
                            child: Text(
                              _currentUser?.name.isNotEmpty == true
                                  ? _currentUser!.name[0].toUpperCase()
                                  : 'U',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentUser?.name ?? 'Loading...',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Share your career thoughts...',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Selected Options Preview
              _buildSelectedOptionsPreview(),

              // Show selected media preview
              if (_selectedMedia != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: AppColors.lightGrey,
                        ),
                        child: _buildMediaPreview(),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: _removeMedia,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.close,
                                size: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              Container(
                decoration: BoxDecoration(
                  color: AppColors.lightBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _postController,
                  style: TextStyle(
                    color: AppColors.black,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText:
                        "Share career advice, interview experiences, or success stories... 💼",
                    hintStyle: TextStyle(
                      color: AppColors.grey,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  maxLines: 4,
                  minLines: 1,
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ),
              const SizedBox(height: 16),
              if (_isUploading)
                _buildUploadingIndicator()
              else
                Column(
                  children: [
                    // Media buttons in a scrollable row
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: (_selectedCareerField != null ||
                                      _selectedSkills.isNotEmpty)
                                  ? AppColors.primary.withOpacity(0.15)
                                  : AppColors.lightBackground,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: (_selectedCareerField != null ||
                                        _selectedSkills.isNotEmpty)
                                    ? AppColors.primary
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: _MediaButton(
                              icon: Icons.work_outline,
                              label: 'Career',
                              onTap: _showCareerPostingOptions,
                              isActive: _selectedCareerField != null ||
                                  _selectedSkills.isNotEmpty,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _MediaButton(
                            icon: Icons.photo_library_outlined,
                            label: 'Photo',
                            onTap: _pickImage,
                          ),
                          const SizedBox(width: 8),
                          _MediaButton(
                            icon: Icons.videocam_outlined,
                            label: 'Video',
                            onTap: _pickVideo,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Post button - full width on mobile
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (_postController.text.trim().isNotEmpty ||
                                _selectedMedia != null)
                            ? _createPost
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              (_postController.text.trim().isNotEmpty ||
                                      _selectedMedia != null)
                                  ? AppColors.primary
                                  : AppColors.lightGrey,
                          foregroundColor:
                              (_postController.text.trim().isNotEmpty ||
                                      _selectedMedia != null)
                                  ? Colors.white
                                  : AppColors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: _isUploading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Post',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
            ])));
  }

  Widget _buildUploadingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Text(
            'Posting...',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const _MediaButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive
                  ? AppColors.primary
                  : AppColors.primary.withOpacity(0.7),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isActive
                    ? AppColors.primary
                    : AppColors.primary.withOpacity(0.7),
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: 4),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CareerPostingOptions extends StatefulWidget {
  final String? selectedCareerField;
  final String selectedPostType;
  final List<String> selectedSkills;
  final List<String> careerFields;
  final List<String> commonSkills;
  final bool loadingCareers;
  final bool loadingSkills;
  final ValueChanged<String?> onCareerFieldChanged;
  final ValueChanged<String> onPostTypeChanged;
  final ValueChanged<String> onSkillToggled;
  final VoidCallback onClear;

  const _CareerPostingOptions({
    required this.selectedCareerField,
    required this.selectedPostType,
    required this.selectedSkills,
    required this.careerFields,
    required this.commonSkills,
    required this.loadingCareers,
    required this.loadingSkills,
    required this.onCareerFieldChanged,
    required this.onPostTypeChanged,
    required this.onSkillToggled,
    required this.onClear,
  });

  @override
  State<_CareerPostingOptions> createState() => _CareerPostingOptionsState();
}

class _CareerPostingOptionsState extends State<_CareerPostingOptions> {
  final List<String> _postTypes = [
    'question',
    'experience',
    'tip',
    'success_story',
    'resource'
  ];

  // Use a Set to track unique skills and prevent duplicates
  Set<String> get _uniqueSkills {
    return Set<String>.from(widget.commonSkills);
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Container(
      height: MediaQuery.of(context).size.height * (isTablet ? 0.7 : 0.85),
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  'Career Post Options',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 18 : 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, size: isSmallScreen ? 20 : 24),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Content in a scrollable area
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Career Field Section
                  _buildCareerFieldSection(isSmallScreen),
                  const SizedBox(height: 20),

                  // Post Type Section
                  _buildPostTypeSection(isSmallScreen),
                  const SizedBox(height: 20),

                  // Skills Section - FIXED: No duplicates
                  _buildSkillsSection(isSmallScreen),
                  const SizedBox(height: 20),

                  // Selected items summary
                  _buildSelectedSummary(isSmallScreen),
                ],
              ),
            ),
          ),

          // Action Buttons - Fixed at bottom
          const SizedBox(height: 16),
          _buildActionButtons(isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildCareerFieldSection(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Career Field',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: isSmallScreen ? 14 : 16,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 8),
        widget.loadingCareers
            ? const Center(child: CircularProgressIndicator())
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.careerFields.map((field) {
                  final isSelected = widget.selectedCareerField == field;
                  return GestureDetector(
                    onTap: () {
                      widget.onCareerFieldChanged(isSelected ? null : field);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            isSelected ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.lightGrey,
                          width: 1.5,
                        ),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 12 : 16,
                          vertical: isSmallScreen ? 8 : 10,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSelected)
                              Icon(Icons.check,
                                  size: isSmallScreen ? 14 : 16,
                                  color: Colors.white),
                            if (isSelected) const SizedBox(width: 6),
                            Text(
                              field,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 12 : 13,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.darkGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
      ],
    );
  }

  Widget _buildPostTypeSection(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Post Type',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: isSmallScreen ? 14 : 16,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _postTypes.map((type) {
              final isSelected = widget.selectedPostType == type;
              return GestureDetector(
                onTap: () {
                  widget.onPostTypeChanged(type);
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          isSelected ? AppColors.primary : AppColors.lightGrey,
                      width: 1.5,
                    ),
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 12 : 16,
                      vertical: isSmallScreen ? 8 : 10,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getPostTypeIcon(type),
                          size: isSmallScreen ? 14 : 16,
                          color: isSelected ? Colors.white : AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _getPostTypeLabel(type),
                          style: TextStyle(
                            fontSize: isSmallScreen ? 12 : 13,
                            fontWeight: FontWeight.w600,
                            color:
                                isSelected ? Colors.white : AppColors.darkGrey,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 6),
                          Icon(Icons.check,
                              size: isSmallScreen ? 12 : 14,
                              color: Colors.white),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsSection(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Relevant Skills',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: isSmallScreen ? 14 : 16,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 8),
        widget.loadingSkills
            ? const Center(child: CircularProgressIndicator())
            : _uniqueSkills.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: isSmallScreen ? 14 : 16,
                            color: AppColors.grey),
                        const SizedBox(width: 8),
                        Text(
                          'No skills available',
                          style: TextStyle(
                            color: AppColors.grey,
                            fontSize: isSmallScreen ? 12 : 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _uniqueSkills.map((skill) {
                      final isSelected = widget.selectedSkills.contains(skill);
                      return GestureDetector(
                        onTap: () {
                          widget.onSkillToggled(skill);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.lightGrey,
                              width: 1.5,
                            ),
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 12 : 16,
                              vertical: isSmallScreen ? 8 : 10,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isSelected)
                                  Icon(Icons.check,
                                      size: isSmallScreen ? 12 : 14,
                                      color: Colors.white),
                                if (isSelected) const SizedBox(width: 6),
                                Text(
                                  skill,
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 12 : 13,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.darkGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
      ],
    );
  }

  Widget _buildSelectedSummary(bool isSmallScreen) {
    if (widget.selectedCareerField == null && widget.selectedSkills.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.lightGrey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline,
                size: isSmallScreen ? 14 : 16, color: AppColors.grey),
            const SizedBox(width: 8),
            Text(
              'No options selected',
              style: TextStyle(
                color: AppColors.grey,
                fontSize: isSmallScreen ? 12 : 14,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle,
                  size: isSmallScreen ? 14 : 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Selected Options:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  fontSize: isSmallScreen ? 12 : 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (widget.selectedCareerField != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Career: ${widget.selectedCareerField}',
                      style: TextStyle(
                        color: AppColors.darkGrey,
                        fontSize: isSmallScreen ? 12 : 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (widget.selectedSkills.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Skills: ${widget.selectedSkills.join(', ')}',
                      style: TextStyle(
                        color: AppColors.darkGrey,
                        fontSize: isSmallScreen ? 12 : 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          if (widget.selectedPostType.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Type: ${_getPostTypeLabel(widget.selectedPostType)}',
                      style: TextStyle(
                        color: AppColors.darkGrey,
                        fontSize: isSmallScreen ? 12 : 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isSmallScreen) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: widget.onClear,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 10 : 12),
            ),
            child: Text(
              'Clear All',
              style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 10 : 12),
            ),
            child: Text(
              'Apply',
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getPostTypeLabel(String postType) {
    switch (postType) {
      case 'question':
        return 'Question';
      case 'experience':
        return 'Experience';
      case 'tip':
        return 'Tip';
      case 'success_story':
        return 'Success Story';
      case 'resource':
        return 'Resource';
      default:
        return 'Post';
    }
  }

  IconData _getPostTypeIcon(String postType) {
    switch (postType) {
      case 'question':
        return Icons.question_answer_outlined;
      case 'experience':
        return Icons.work_outline;
      case 'tip':
        return Icons.lightbulb_outline;
      case 'success_story':
        return Icons.emoji_events_outlined;
      case 'resource':
        return Icons.attach_file;
      default:
        return Icons.post_add;
    }
  }
}

// ... (Keep all the remaining classes: _PostCard, _PostHeader, _PostMedia, _PostActions,
// _PostActionButton, _FollowButton, _PostShimmer exactly as they were in your previous code)

class _PostCard extends StatefulWidget {
  final CommunityPost post;
  final CommunityService communityService;

  const _PostCard({required this.post, required this.communityService});

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  bool _isLiked = false;
  bool _showLikeAnimation = false;
  bool _liking = false;

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

  Future<void> _toggleLike() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackbar('Please login to like posts');
      return;
    }

    setState(() {
      _liking = true;
    });

    try {
      await widget.communityService.toggleLike(widget.post.postId, user.uid);
      setState(() {
        _isLiked = !_isLiked;
      });
    } catch (e) {
      _showSnackbar('Failed to like post');
    } finally {
      setState(() {
        _liking = false;
      });
    }
  }

  void _handleDoubleTap() {
    if (!_isLiked) {
      setState(() {
        _showLikeAnimation = true;
      });

      _toggleLike().then((_) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            setState(() {
              _showLikeAnimation = false;
            });
          }
        });
      });
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
    return CommunityCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PostHeader(
              post: widget.post, communityService: widget.communityService),

          // FIXED: Only show career field and careerTags (skills), not duplicate skills
          if (widget.post.careerField != null ||
              widget.post.careerTags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (widget.post.careerField != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.work_outline,
                              size: 12, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            widget.post.careerField!,
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  // FIXED: Only show career tags (skills)
                  ...widget.post.careerTags
                      .map((tag) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.lightGrey,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.darkGrey),
                            ),
                          ))
                      .toList(),
                ],
              ),
            ),

          if (widget.post.postContent.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                widget.post.postContent,
                style: TextStyle(
                    fontSize: 14, color: AppColors.black, height: 1.5),
              ),
            ),

          if (widget.post.mediaUrl != null && widget.post.mediaUrl!.isNotEmpty)
            _PostMedia(
              post: widget.post,
              mediaUrl: widget.post.mediaUrl!,
              mediaType: widget.post.mediaType,
              onDoubleTap: _handleDoubleTap,
              showLikeAnimation: _showLikeAnimation,
            ),

          _PostActions(
            post: widget.post,
            isLiked: _isLiked,
            liking: _liking,
            onLike: _toggleLike,
            onComment: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => CommentModal(postId: widget.post.postId),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PostHeader extends StatelessWidget {
  final CommunityPost post;
  final CommunityService communityService;

  const _PostHeader({required this.post, required this.communityService});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CommunityUser>(
      future: communityService.getUser(post.userId),
      builder: (context, userSnapshot) {
        final user = userSnapshot.data;
        final currentUserAvatar = user?.profilePic ?? post.userAvatar;
        final currentUserName = user?.name ?? post.userName;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              CommunityAvatar(
                photoUrl: currentUserAvatar,
                userName: currentUserName,
                size: 40,
                showBorder: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ComProfilePage(
                          userId: post.userId, userName: currentUserName),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(currentUserName,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: AppColors.black)),
                    const SizedBox(height: 2),
                    Text(timeago.format(post.timestamp),
                        style: TextStyle(color: AppColors.grey, fontSize: 12)),
                  ],
                ),
              ),
              _FollowButton(
                  userId: post.userId, communityService: communityService),
            ],
          ),
        );
      },
    );
  }
}

class _PostMedia extends StatelessWidget {
  final CommunityPost post;
  final String mediaUrl;
  final String? mediaType;
  final VoidCallback onDoubleTap;
  final bool showLikeAnimation;

  const _PostMedia({
    required this.post,
    required this.mediaUrl,
    required this.mediaType,
    required this.onDoubleTap,
    required this.showLikeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: onDoubleTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(12),
            ),
            child: _buildMediaContent(),
          ),
          if (showLikeAnimation)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: showLikeAnimation ? 1 : 0,
              child: Icon(Icons.favorite,
                  color: AppColors.error.withOpacity(0.9), size: 80),
            ),
        ],
      ),
    );
  }

  Widget _buildMediaContent() {
    if (post.isImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: mediaUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 250,
          placeholder: (context, url) => Container(
            height: 250,
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            height: 200,
            color: AppColors.lightGrey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image_outlined,
                    size: 48, color: AppColors.grey),
                const SizedBox(height: 8),
                Text('Failed to load image',
                    style: TextStyle(color: AppColors.grey)),
              ],
            ),
          ),
        ),
      );
    } else if (post.isVideo) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: mediaUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 250,
              placeholder: (context, url) => Container(
                height: 250,
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                height: 200,
                color: AppColors.lightGrey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.videocam_off, size: 48, color: AppColors.grey),
                    const SizedBox(height: 8),
                    Text('Failed to load video',
                        style: TextStyle(color: AppColors.grey)),
                  ],
                ),
              ),
            ),
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: Icon(
                  Icons.play_circle_fill,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        height: 150,
        color: AppColors.lightGrey,
        child: const Center(
          child: Icon(Icons.attach_file, size: 48, color: AppColors.grey),
        ),
      );
    }
  }
}

class _PostActions extends StatelessWidget {
  final CommunityPost post;
  final bool isLiked;
  final bool liking;
  final VoidCallback onLike;
  final VoidCallback onComment;

  const _PostActions({
    required this.post,
    required this.isLiked,
    required this.liking,
    required this.onLike,
    required this.onComment,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _PostActionButton(
                  icon: isLiked ? Icons.favorite : Icons.favorite_outline,
                  label: post.likes.toString(),
                  isActive: isLiked,
                  activeColor: AppColors.error,
                  onTap: onLike,
                  loading: liking,
                ),
                const SizedBox(width: 20),
                _PostActionButton(
                  icon: Icons.chat_bubble_outline,
                  label: post.comments.toString(),
                  onTap: onComment,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (post.likes > 0)
          Text('${post.likes} ${post.likes == 1 ? 'like' : 'likes'}',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                  fontSize: 12)),
      ],
    );
  }
}

class _PostActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;
  final Color activeColor;
  final bool loading;

  const _PostActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
    this.activeColor = AppColors.primary,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            if (loading)
              SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: activeColor))
            else
              Icon(icon,
                  color: isActive ? activeColor : AppColors.grey, size: 20),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      color: isActive ? activeColor : AppColors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w500)),
            ],
          ],
        ),
      ),
    );
  }
}

class _FollowButton extends StatefulWidget {
  final String userId;
  final CommunityService communityService;

  const _FollowButton({required this.userId, required this.communityService});

  @override
  State<_FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<_FollowButton> {
  bool _isFollowing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkIfFollowing();
  }

  void _checkIfFollowing() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.uid == widget.userId) return;

    try {
      final isFollowing =
          await widget.communityService.isFollowing(user.uid, widget.userId);
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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackbar('Please login to follow users');
      return;
    }

    if (user.uid == widget.userId) return;

    setState(() => _isLoading = true);

    try {
      await widget.communityService.toggleFollow(user.uid, widget.userId);
      if (mounted) {
        setState(() {
          _isFollowing = !_isFollowing;
        });
      }
      _showSnackbar(_isFollowing ? 'Followed! 👥' : 'Unfollowed');
    } catch (e) {
      _showSnackbar('Error: Please try again');
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
          behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.uid == widget.userId) {
      return const SizedBox.shrink();
    }

    return Container(
      child: Material(
        color: _isFollowing ? Colors.transparent : AppColors.primary,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: _isLoading ? null : _toggleFollow,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _isFollowing ? Colors.transparent : AppColors.primary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: _isFollowing ? AppColors.grey : Colors.transparent,
                  width: 1.5),
            ),
            child: _isLoading
                ? SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color:
                            _isFollowing ? AppColors.primary : AppColors.white))
                : Text(_isFollowing ? 'Following' : 'Follow',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color:
                            _isFollowing ? AppColors.grey : AppColors.white)),
          ),
        ),
      ),
    );
  }
}

class _PostShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CommunityCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              LoadingShimmer(
                  width: 40,
                  height: 40,
                  borderRadius: BorderRadius.circular(20)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LoadingShimmer(
                        width: 120,
                        height: 16,
                        borderRadius: BorderRadius.circular(8)),
                    const SizedBox(height: 6),
                    LoadingShimmer(
                        width: 80,
                        height: 12,
                        borderRadius: BorderRadius.circular(6)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LoadingShimmer(
              width: double.infinity,
              height: 14,
              borderRadius: BorderRadius.circular(7)),
          const SizedBox(height: 8),
          LoadingShimmer(
              width: 200, height: 14, borderRadius: BorderRadius.circular(7)),
          const SizedBox(height: 16),
          LoadingShimmer(
              width: double.infinity,
              height: 200,
              borderRadius: BorderRadius.circular(12)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  LoadingShimmer(
                      width: 60,
                      height: 24,
                      borderRadius: BorderRadius.circular(12)),
                  const SizedBox(width: 20),
                  LoadingShimmer(
                      width: 60,
                      height: 24,
                      borderRadius: BorderRadius.circular(12)),
                ],
              ),
              LoadingShimmer(
                  width: 24,
                  height: 24,
                  borderRadius: BorderRadius.circular(12)),
            ],
          ),
        ],
      ),
    );
  }
}
