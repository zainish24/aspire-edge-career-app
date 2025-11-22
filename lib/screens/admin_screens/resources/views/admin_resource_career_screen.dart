import 'package:flutter/material.dart';
import 'package:aspire_edge/models/resource_model.dart';
import 'package:aspire_edge/routes/screen_export.dart';
import 'package:aspire_edge/services/resource_service.dart';
import 'package:aspire_edge/theme/app_theme.dart';
import 'admin_resource_detail_screen.dart'; // ADD THIS IMPORT

class AdminCareerResourcesScreen extends StatefulWidget {
  final String careerId;
  final String careerTitle;

  const AdminCareerResourcesScreen({
    super.key,
    required this.careerId,
    required this.careerTitle,
  });

  @override
  State<AdminCareerResourcesScreen> createState() =>
      _AdminCareerResourcesScreenState();
}

class _AdminCareerResourcesScreenState
    extends State<AdminCareerResourcesScreen> {
  final ResourceService _resourceService = ResourceService();
  List<ResourceModel> _resources = [];
  bool _loading = true;
  String _filterType = 'all';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadResources();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    // Handle scroll if needed for future features
  }

  Future<void> _loadResources() async {
    try {
      setState(() => _loading = true);
      final resources =
          await _resourceService.getResourcesByCareerId(widget.careerId);
      setState(() {
        _resources = resources;
        _loading = false;
      });
    } catch (e) {
      print("Error loading resources: $e");
      setState(() => _loading = false);
    }
  }

  void _navigateToAddEditResourceScreen({ResourceModel? resource}) {
    Navigator.of(context).pushNamed(
      adminAddEditResourceScreenRoute,
      arguments: {
        'careerId': widget.careerId,
        'careerTitle': widget.careerTitle,
        'resourceData': resource,
      },
    ).then((value) {
      if (value == true) {
        _loadResources();
      }
    });
  }

  void _navigateToDetailScreen(ResourceModel resource) {
    print("🔗 Navigating to detail screen for: ${resource.title}");
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminResourceDetailScreen(),
        settings: RouteSettings(
          arguments: {
            'resource': resource,
            'careerTitle': widget.careerTitle,
          },
        ),
      ),
    ).then((value) {
      if (value == true) {
        _loadResources(); // Refresh the list if needed
      }
    });
  }

  Future<void> _deleteResource(String resourceId) async {
    try {
      final confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            "Delete Resource",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          content: const Text(
            "Are you sure you want to delete this resource?",
            style: TextStyle(color: AppColors.darkGrey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                "Cancel",
                style: TextStyle(color: AppColors.darkGrey),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await _resourceService.deleteResource(resourceId);
        _showSuccessPopup("Resource deleted successfully");
        _loadResources();
      }
    } catch (e) {
      _showErrorPopup("Error deleting resource: $e");
    }
  }

  void _showErrorPopup(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccessPopup(String message) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primary,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Success!",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.darkGrey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text(
                  "OK",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.careerTitle,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: AppColors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: _loadResources,
            icon: Icon(Icons.refresh_rounded, color: AppColors.primary),
            tooltip: "Refresh",
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                // Header Banner
                _buildHeaderBanner(),

                const SizedBox(height: 8),

                // Main Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        // Statistics Section
                        _buildStatisticsSection(isSmallScreen),

                        const SizedBox(height: 16),

                        // Add Resource Button (Placed between statistics and search)
                        _buildAddResourceButton(),

                        const SizedBox(height: 16),

                        // Search Section
                        _buildSearchSection(),

                        const SizedBox(height: 16),

                        // Modern Filter Section
                        _buildModernFilterSection(),

                        const SizedBox(height: 20),

                        // Resources List
                        _buildResourcesListSection(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // Add Resource Button with same UI as resource list screen
  Widget _buildAddResourceButton() {
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
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              icon: Icons.add_circle_outline_rounded,
              title: "Add Resource",
              subtitle: "Create new resource",
              color: AppColors.primary,
              onTap: () => _navigateToAddEditResourceScreen(),
            ),
          ),
        ],
      ),
    );
  }

  // Action Button Widget (same as resource list screen)
  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderBanner() {
    final filteredResources = _applyFilters(_resources);

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
            AppColors.primaryDark,
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
                  "Resources for ${widget.careerTitle}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  "${filteredResources.length} resources available • ${_getUniqueTypesCount()} content types",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.library_books_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(bool isSmallScreen) {
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
      child: _resources.isEmpty
          ? _buildEmptyStats()
          : _buildStatsContent(isSmallScreen),
    );
  }

  Widget _buildStatsContent(bool isSmallScreen) {
    final filteredResources = _applyFilters(_resources);
    final totalResources = filteredResources.length;

    // Calculate counts for each type
    final blogCount =
        filteredResources.where((r) => r.type.toLowerCase() == 'blog').length;
    final videoCount =
        filteredResources.where((r) => r.type.toLowerCase() == 'video').length;
    final ebookCount =
        filteredResources.where((r) => r.type.toLowerCase() == 'ebook').length;
    final otherCount = totalResources - blogCount - videoCount - ebookCount;

    return Column(
      children: [
        // Header
        const Row(
          children: [
            Text(
              "Resources Overview",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Main Stats Row
        Row(
          children: [
            _buildStatCard(
              'Total Resources',
              totalResources.toString(),
              Icons.library_books_rounded,
              AppColors.primary,
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              'Content Types',
              _getUniqueTypesCount().toString(),
              Icons.category_rounded,
              AppColors.secondary,
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Type Breakdown Header
        const Row(
          children: [
            Text(
              'Content Type Breakdown',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.darkGrey,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Responsive Type Breakdown
        _buildResponsiveTypeGrid(
          blogCount: blogCount,
          videoCount: videoCount,
          ebookCount: ebookCount,
          otherCount: otherCount,
          isSmallScreen: isSmallScreen,
        ),
      ],
    );
  }

  Widget _buildResponsiveTypeGrid({
    required int blogCount,
    required int videoCount,
    required int ebookCount,
    required int otherCount,
    required bool isSmallScreen,
  }) {
    final types = [
      _TypeItem('Blog Posts', blogCount, AppColors.info, Icons.article_rounded),
      _TypeItem(
          'Videos', videoCount, AppColors.success, Icons.video_library_rounded),
      _TypeItem(
          'E-Books', ebookCount, AppColors.secondary, Icons.menu_book_rounded),
      if (otherCount > 0)
        _TypeItem('Other', otherCount, AppColors.darkGrey, Icons.link_rounded),
    ].where((item) => item.count > 0).toList();

    if (isSmallScreen) {
      // For small screens, use a vertical list
      return Column(
        children: types
            .map(
              (type) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildTypeListItem(type),
              ),
            )
            .toList(),
      );
    } else {
      // For larger screens, use a grid
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 3.5,
        children: types
            .map(
              (type) => _buildTypeStatItem(
                  type.title, type.count, type.color, type.icon),
            )
            .toList(),
      );
    }
  }

  Widget _buildTypeListItem(_TypeItem type) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: type.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: type.color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: type.color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(type.icon, color: type.color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  type.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
                Text(
                  '${type.count} resources',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.darkGrey,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: type.color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${type.count}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.darkGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeStatItem(
      String title, int count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
                Text(
                  '$count resources',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.darkGrey,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
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
        children: [
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Icon(Icons.search_rounded, color: AppColors.darkGrey, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: "Search resources by title, author, tags...",
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: AppColors.grey),
                    ),
                    style: const TextStyle(
                      color: AppColors.black,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                      });
                    },
                    icon: Icon(Icons.clear_rounded,
                        color: AppColors.darkGrey, size: 18),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernFilterSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppColors.primary.withOpacity(0.05),
                  AppColors.primary.withOpacity(0.02),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary,
                        AppColors.primaryDark,
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.category_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Filter Resources by Type',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkGrey,
                    fontSize: 16,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Modern Filter Options Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
            children: [
              _buildModernFilterOption(
                type: 'all',
                label: 'All',
                icon: Icons.all_inclusive_rounded,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primaryDark,
                  ],
                ),
              ),
              _buildModernFilterOption(
                type: 'blog',
                label: 'Blogs',
                icon: Icons.article_rounded,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.info,
                    Color(0xFF0EA5E9), // Darker blue for gradient
                  ],
                ),
              ),
              _buildModernFilterOption(
                type: 'video',
                label: 'Videos',
                icon: Icons.video_library_rounded,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.success,
                    Color(0xFF10B981), // Darker green for gradient
                  ],
                ),
              ),
              _buildModernFilterOption(
                type: 'ebook',
                label: 'E-Books',
                icon: Icons.menu_book_rounded,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.secondary,
                    AppColors.secondaryDark,
                  ],
                ),
              ),
            ],
          ),

          // Selected Filter Indicator
          const SizedBox(height: 16),
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _getTypeColor(_filterType).withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getTypeColor(_filterType).withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getTypeIcon(_filterType),
                  size: 16,
                  color: _getTypeColor(_filterType),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _filterType == 'all'
                        ? 'Showing all ${_applyFilters(_resources).length} resources'
                        : 'Showing ${_applyFilters(_resources).length} ${_formatType(_filterType).toLowerCase()} resources',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _getTypeColor(_filterType),
                    ),
                  ),
                ),
                if (_filterType != 'all' && _resources.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getTypeColor(_filterType),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${((_applyFilters(_resources).length / _resources.length) * 100).round()}%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
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

  // Modern Filter Option Widget
  Widget _buildModernFilterOption({
    required String type,
    required String label,
    required IconData icon,
    required Gradient gradient,
  }) {
    final isSelected = _filterType == type;
    final typeColor = _getTypeColor(type);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _filterType = type;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          decoration: BoxDecoration(
            gradient: isSelected ? gradient : null,
            color: isSelected ? null : Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  isSelected ? typeColor.withOpacity(0.3) : Colors.grey[200]!,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: typeColor.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon Container
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.2)
                      : typeColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(
                          color: Colors.white.withOpacity(0.3), width: 2)
                      : null,
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: isSelected ? Colors.white : typeColor,
                ),
              ),

              const SizedBox(height: 8),

              // Label
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.darkGrey,
                  letterSpacing: -0.1,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),

              // Selection Indicator
              if (isSelected)
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResourcesListSection() {
    final filteredResources = _applyFilters(_resources);

    if (filteredResources.isEmpty) {
      return _filterType == 'all' ? _buildEmptyList() : _buildNoMatches();
    }

    return Column(
      children: [
        // List Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "All Resources",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${filteredResources.length} resources",
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Resources List
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredResources.length,
          itemBuilder: (context, index) {
            return _buildResourceListItem(filteredResources[index]);
          },
        ),
      ],
    );
  }

  Widget _buildResourceListItem(ResourceModel resource) {
    final typeColor = _getTypeColor(resource.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _navigateToDetailScreen(resource),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title and type
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            resource.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (resource.author.isNotEmpty)
                            const SizedBox(height: 4),
                          if (resource.author.isNotEmpty)
                            Text(
                              "By ${resource.author}",
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.darkGrey,
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: typeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getTypeIcon(resource.type),
                            color: typeColor,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            resource.type.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              color: typeColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Tags
                if (resource.tags.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      ...resource.tags
                          .take(3)
                          .map((tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  tag,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ))
                          .toList(),
                      if (resource.tags.length > 3)
                        Text(
                          "+${resource.tags.length - 3} more",
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.darkGrey,
                          ),
                        ),
                    ],
                  ),

                if (resource.tags.isNotEmpty) const SizedBox(height: 12),

                // Footer with media type, date, and actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              resource.mediaType,
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _formatDate(resource.createdAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.darkGrey,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    PopupMenuButton(
                      icon: Icon(Icons.more_vert_rounded,
                          color: AppColors.darkGrey, size: 20),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_rounded, size: 18),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_rounded,
                                  color: Colors.red, size: 18),
                              SizedBox(width: 8),
                              Text('Delete',
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          _navigateToAddEditResourceScreen(resource: resource);
                        } else if (value == 'delete') {
                          _deleteResource(resource.resourceId);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<ResourceModel> _applyFilters(List<ResourceModel> resources) {
    List<ResourceModel> filtered = resources;

    // Apply type filter
    if (_filterType != 'all') {
      filtered = filtered
          .where((resource) =>
              resource.type.toLowerCase() == _filterType.toLowerCase())
          .toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((resource) {
        final title = resource.title.toLowerCase();
        final author = resource.author.toLowerCase();
        final type = resource.type.toLowerCase();
        final tags = resource.tags.map((tag) => tag.toLowerCase()).toList();
        final query = _searchQuery.toLowerCase();

        return title.contains(query) ||
            author.contains(query) ||
            type.contains(query) ||
            tags.any((tag) => tag.contains(query));
      }).toList();
    }

    return filtered;
  }

  // Helper methods
  int _getUniqueTypesCount() {
    final types = _resources.map((r) => r.type.toLowerCase()).toSet();
    return types.length;
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'blog':
        return AppColors.info;
      case 'video':
        return AppColors.success;
      case 'ebook':
        return AppColors.secondary;
      case 'pdf':
        return AppColors.warning;
      case 'document':
        return AppColors.info;
      default:
        return AppColors.primary;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'blog':
        return Icons.article_rounded;
      case 'video':
        return Icons.video_library_rounded;
      case 'ebook':
        return Icons.menu_book_rounded;
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'document':
        return Icons.description_rounded;
      default:
        return Icons.all_inclusive_rounded;
    }
  }

  String _formatType(String type) {
    return type == 'all' ? 'All' : type[0].toUpperCase() + type.substring(1);
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  // Empty states
  Widget _buildEmptyStats() {
    return Column(
      children: [
        const Row(
          children: [
            Text(
              "Resources Overview",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.lightGrey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Column(
            children: [
              Icon(Icons.library_books_outlined,
                  color: AppColors.grey, size: 40),
              SizedBox(height: 8),
              Text(
                'No resources data available',
                style: TextStyle(color: AppColors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyList() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.library_books_outlined,
              color: AppColors.primary,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "No Resources Available",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "There are no resources added for this career yet",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.darkGrey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _navigateToAddEditResourceScreen(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              "Add First Resource",
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoMatches() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              color: AppColors.primary,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "No Matching Resources",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "No resources found for \"${_formatType(_filterType)}\" type",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.darkGrey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _filterType = 'all';
                _searchController.clear();
                _searchQuery = '';
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              "Clear Filters",
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeItem {
  final String title;
  final int count;
  final Color color;
  final IconData icon;

  _TypeItem(this.title, this.count, this.color, this.icon);
}