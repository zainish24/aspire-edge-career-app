import 'package:flutter/material.dart';
import 'package:aspire_edge/components/primary_button.dart';
import 'package:aspire_edge/routes/screen_export.dart';
import 'package:aspire_edge/models/career_model.dart';
import 'package:aspire_edge/services/career_service.dart';
import 'package:aspire_edge/theme/app_theme.dart';

class CareerBankScreen extends StatefulWidget {
  const CareerBankScreen({super.key});

  @override
  State<CareerBankScreen> createState() => _CareerBankScreenState();
}

class _CareerBankScreenState extends State<CareerBankScreen>
    with SingleTickerProviderStateMixin {
  final CareerService _careerService = CareerService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool showFilter = false;
  bool loading = false;
  bool _isNavigating = false;
  bool _isLoading = true; // Added for enhanced loading

  // Animation controllers - EXACTLY like ProfileScreen
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<Offset> _logoSlideAnimation;

  // Search + Results
  String searchQuery = "";
  List<CareerModel> searchResults = [];
  List<CareerModel> recentCareers = [];
  List<CareerModel> allCareers = [];

  // Applied Filters
  List<String> appliedIndustries = [];
  List<String> appliedSkills = [];
  List<String> appliedEducation = [];
  String appliedSalary = "Any";

  // Temporary Filters
  List<String> tempIndustries = [];
  List<String> tempSkills = [];
  List<String> tempEducation = [];
  String tempSalary = "Any";

  // Dynamic data from Firestore
  List<String> industries = [];
  List<String> skills = [];
  List<String> educationPaths = [];
  final List<String> salaryRanges = ["<50k", "50k-100k", "100k-200k", "200k+"];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _searchController.addListener(_onSearchChanged);
    _loadInitialData();
    _scrollController.addListener(() {
      FocusScope.of(context).unfocus();
    });
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
      final careers = await _careerService.getAllCareers();
      allCareers = careers;
      searchResults = careers;

      final industriesData = await _careerService.getAllIndustries();
      final industrySet =
          industriesData.map((e) => e['name'] as String).toSet();

      final skillSet = <String>{};
      final educationSet = <String>{};

      for (var career in careers) {
        if (career.industryName.isNotEmpty)
          industrySet.add(career.industryName);
        skillSet.addAll(career.skillNames);
        educationSet.addAll(career.educationPathNames);
      }

      recentCareers = careers.take(5).toList();

      setState(() {
        industries = industrySet.toList()..sort();
        skills = skillSet.toList()..sort();
        educationPaths = educationSet.toList()..sort();
        _isLoading = false; // Data loaded, hide loading
      });
    } catch (e) {
      print('Error loading initial data: $e');
      setState(() => _isLoading = false);
    }
  }

  // Enhanced Loading State EXACTLY like ProfileScreen
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
                        'Loading Career Bank...',
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
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
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

  void _onSearchChanged() {
    setState(() => searchQuery = _searchController.text.trim());
    _searchCareers();
  }

  Future<void> _searchCareers() async {
    setState(() => loading = true);

    if (searchQuery.isEmpty &&
        appliedIndustries.isEmpty &&
        appliedSkills.isEmpty &&
        appliedEducation.isEmpty &&
        appliedSalary == "Any") {
      setState(() {
        searchResults = allCareers;
        loading = false;
      });
      return;
    }

    List<CareerModel> results = allCareers;

    if (searchQuery.isNotEmpty) {
      results = results.where((career) {
        final query = searchQuery.toLowerCase();
        return career.title.toLowerCase().contains(query) ||
            career.industryName.toLowerCase().contains(query) ||
            (career.description?.toLowerCase().contains(query) ?? false) ||
            career.skillNames
                .any((skill) => skill.toLowerCase().contains(query)) ||
            career.educationPathNames
                .any((edu) => edu.toLowerCase().contains(query));
      }).toList();
    }

    if (appliedIndustries.isNotEmpty) {
      results = results
          .where((career) => appliedIndustries.contains(career.industryName))
          .toList();
    }

    if (appliedSkills.isNotEmpty) {
      results = results
          .where((career) =>
              appliedSkills.every((skill) => career.skillNames.contains(skill)))
          .toList();
    }

    if (appliedEducation.isNotEmpty) {
      results = results
          .where((career) => appliedEducation
              .every((edu) => career.educationPathNames.contains(edu)))
          .toList();
    }

    if (appliedSalary != "Any") {
      results = results.where((career) {
        if (career.salaryRange == null) return false;
        switch (appliedSalary) {
          case "<50k":
            return career.salaryRange!.contains("<50") ||
                career.salaryRange!.toLowerCase().contains("under 50");
          case "50k-100k":
            return career.salaryRange!.contains("50") &&
                career.salaryRange!.contains("100");
          case "100k-200k":
            return career.salaryRange!.contains("100") &&
                career.salaryRange!.contains("200");
          case "200k+":
            return career.salaryRange!.contains("200") ||
                career.salaryRange!.toLowerCase().contains("over 200");
          default:
            return true;
        }
      }).toList();
    }

    setState(() {
      searchResults = results;
      loading = false;
    });
  }

  void removeFilter(String type, String value) {
    setState(() {
      if (type == "industry") appliedIndustries.remove(value);
      if (type == "skill") appliedSkills.remove(value);
      if (type == "education") appliedEducation.remove(value);
      if (type == "salary") appliedSalary = "Any";
    });
    _searchCareers();
  }

  void removeTempFilter(String type, String value) {
    setState(() {
      if (type == "industry") tempIndustries.remove(value);
      if (type == "skill") tempSkills.remove(value);
      if (type == "education") tempEducation.remove(value);
      if (type == "salary") tempSalary = "Any";
    });
  }

  void _navigateToCareerDetail(CareerModel career) {
    setState(() => _isNavigating = true);

    if (!recentCareers.any((c) => c.careerId == career.careerId)) {
      setState(() {
        recentCareers.insert(0, career);
        if (recentCareers.length > 5) {
          recentCareers = recentCareers.take(5).toList();
        }
      });
    }

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                CareerDetailsScreen(careerId: career.careerId),
          ),
        ).then((_) {
          if (mounted) setState(() => _isNavigating = false);
        });
      }
    });
  }

  Widget _buildHeaderBanner() {
    final filteredCareers = _getFilteredCareers();

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
                const Text(
                  "Career Exploration Hub",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Discover ${filteredCareers.length} career paths matching your interests",
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
              Icons.work_history_rounded,
              color: Colors.white,
              size: 30,
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
                        searchQuery = value;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: "Search careers by title, industry, skills...",
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: AppColors.grey),
                    ),
                    style: const TextStyle(
                      color: AppColors.black,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (searchQuery.isNotEmpty)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        searchQuery = '';
                      });
                    },
                    icon: Icon(Icons.clear_rounded,
                        color: AppColors.darkGrey, size: 18),
                  ),
                const SizedBox(width: 8),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: showFilter ? AppColors.primary : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.filter_list_rounded,
                      color: showFilter ? Colors.white : AppColors.primary,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        tempIndustries = List.from(appliedIndustries);
                        tempSkills = List.from(appliedSkills);
                        tempEducation = List.from(appliedEducation);
                        tempSalary = appliedSalary;
                        showFilter = !showFilter;
                      });
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
                        Color(0xFF6366F1),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Filter Careers',
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

          // Industry Filter
          _buildFilterSection(
            title: "Industry",
            icon: Icons.business_center_rounded,
            selectedItems: tempIndustries,
            allItems: industries,
            onTap: () => _pickMultipleOptions(
              "Select Industry",
              industries,
              tempIndustries,
              (v) => setState(() => tempIndustries = v),
            ),
            color: AppColors.info,
          ),

          const SizedBox(height: 16),

          // Skills Filter
          _buildFilterSection(
            title: "Skills",
            icon: Icons.psychology_rounded,
            selectedItems: tempSkills,
            allItems: skills,
            onTap: () => _pickMultipleOptions(
              "Select Skills",
              skills,
              tempSkills,
              (v) => setState(() => tempSkills = v),
            ),
            color: AppColors.success,
          ),

          const SizedBox(height: 16),

          // Education Filter
          _buildFilterSection(
            title: "Education",
            icon: Icons.school_rounded,
            selectedItems: tempEducation,
            allItems: educationPaths,
            onTap: () => _pickMultipleOptions(
              "Select Education",
              educationPaths,
              tempEducation,
              (v) => setState(() => tempEducation = v),
            ),
            color: AppColors.secondary,
          ),

          const SizedBox(height: 16),

          // Salary Filter
          _buildFilterSection(
            title: "Salary Range",
            icon: Icons.attach_money_rounded,
            selectedItems: [if (tempSalary != "Any") tempSalary],
            allItems: salaryRanges,
            onTap: () => _pickSingleOption(
              "Select Salary Range",
              ["Any", ...salaryRanges],
              tempSalary,
              (v) => setState(() => tempSalary = v == "Any" ? "Any" : v),
            ),
            color: AppColors.primary,
          ),

          const SizedBox(height: 16),

          // Selected Filters
          if (tempIndustries.isNotEmpty ||
              tempSkills.isNotEmpty ||
              tempEducation.isNotEmpty ||
              tempSalary != "Any")
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected Filters:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...tempIndustries
                          .map((e) => _buildTempFilterChip("industry", e)),
                      ...tempSkills
                          .map((e) => _buildTempFilterChip("skill", e)),
                      ...tempEducation
                          .map((e) => _buildTempFilterChip("education", e)),
                      if (tempSalary != "Any")
                        _buildTempFilterChip("salary", tempSalary),
                    ],
                  ),
                ],
              ),
            ),

          const SizedBox(height: 20),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  isOutlined: true,
                  label: "Apply Filters",
                  onPressed: () {
                    setState(() {
                      appliedIndustries = List.from(tempIndustries);
                      appliedSkills = List.from(tempSkills);
                      appliedEducation = List.from(tempEducation);
                      appliedSalary = tempSalary;
                      showFilter = false;
                    });
                    _searchCareers();
                  },
                ),
              ),
              const SizedBox(width: 12),
              if (tempIndustries.isNotEmpty ||
                  tempSkills.isNotEmpty ||
                  tempEducation.isNotEmpty ||
                  tempSalary != "Any")
                TextButton(
                  onPressed: () {
                    setState(() {
                      tempIndustries.clear();
                      tempSkills.clear();
                      tempEducation.clear();
                      tempSalary = "Any";
                    });
                  },
                  child: Text(
                    "Clear All",
                    style: TextStyle(
                      color: AppColors.error,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required IconData icon,
    required List<String> selectedItems,
    required List<String> allItems,
    required VoidCallback onTap,
    required Color color,
  }) {
    final displayText = selectedItems.isEmpty
        ? 'All $title'
        : selectedItems.length == 1
            ? selectedItems.first
            : '${selectedItems.length} selected';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
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
                    const SizedBox(height: 4),
                    Text(
                      displayText,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.darkGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: color, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTempFilterChip(String type, String value) {
    return Chip(
      label: Text(value),
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: AppColors.primary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      deleteIcon: Icon(Icons.close, size: 14, color: AppColors.primary),
      onDeleted: () => removeTempFilter(type, value),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildAppliedFilterChip(String type, String value) {
    return Chip(
      label: Text(value),
      backgroundColor: AppColors.primary.withOpacity(0.1),
      labelStyle: TextStyle(
        color: AppColors.primary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      deleteIcon: Icon(Icons.close, size: 14, color: AppColors.primary),
      onDeleted: () => removeFilter(type, value),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildCareerCard(CareerModel career) {
    final imageUrl = career.images.isNotEmpty ? career.images.first : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _navigateToCareerDetail(career),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Career Image
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.primary.withOpacity(0.1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholderImage();
                            },
                          )
                        : _buildPlaceholderImage(),
                  ),
                ),

                const SizedBox(width: 16),

                // Career Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  career.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.black,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    career.industryName,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: AppColors.primary,
                            size: 16,
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Skills
                      if (career.skillNames.isNotEmpty)
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: career.skillNames
                              .take(2)
                              .map((skill) => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      skill,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),

                      if (career.skillNames.isNotEmpty)
                        const SizedBox(height: 8),

                      // Footer with salary and growth
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.trending_up_rounded,
                                  size: 14, color: AppColors.success),
                              const SizedBox(width: 4),
                              Text(
                                "Growing Field",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          if (career.salaryRange != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                career.salaryRange!,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.work_rounded,
        color: AppColors.primary,
        size: 24,
      ),
    );
  }

  Widget _buildRecentCareers() {
    if (recentCareers.isEmpty || showFilter) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Recently Viewed",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              TextButton(
                onPressed: () => setState(() => recentCareers.clear()),
                child: Text(
                  "Clear All",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: recentCareers.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final career = recentCareers[index];
              return _buildRecentCareerCard(career);
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildRecentCareerCard(CareerModel career) {
    final imageUrl = career.images.isNotEmpty ? career.images.first : '';

    return Container(
      width: 280,
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
          onTap: () => _navigateToCareerDetail(career),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.primary.withOpacity(0.1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholderImage();
                            },
                          )
                        : _buildPlaceholderImage(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        career.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        career.industryName,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.darkGrey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      if (career.salaryRange != null)
                        Text(
                          career.salaryRange!,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              backgroundColor: AppColors.primary.withOpacity(0.2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Loading Careers...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.darkGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.work_outline_rounded,
              color: AppColors.primary,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            searchQuery.isNotEmpty ? "No Results Found" : "No Careers Found",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            searchQuery.isEmpty
                ? "Start exploring career opportunities to find your perfect path"
                : "No careers found for your search criteria",
            style: const TextStyle(
              color: AppColors.darkGrey,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (searchQuery.isNotEmpty ||
              appliedIndustries.isNotEmpty ||
              appliedSkills.isNotEmpty ||
              appliedEducation.isNotEmpty ||
              appliedSalary != "Any")
            PrimaryButton(
              isOutlined: true,
              label: "Clear All Filters",
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  appliedIndustries.clear();
                  appliedSkills.clear();
                  appliedEducation.clear();
                  appliedSalary = "Any";
                });
                _searchCareers();
              },
            ),
        ],
      ),
    );
  }

  List<CareerModel> _getFilteredCareers() {
    return searchResults;
  }

  @override
  Widget build(BuildContext context) {
    final filteredCareers = _getFilteredCareers();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Career Bank",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: AppColors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? _buildEnhancedLoadingState()
          : AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Stack(
                      children: [
                        Column(
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
                                    // Search Section
                                    _buildSearchSection(),

                                    const SizedBox(height: 16),

                                    // Modern Filter Section
                                    if (showFilter) _buildModernFilterSection(),

                                    if (showFilter) const SizedBox(height: 20),

                                    // Applied Filters
                                    if (appliedIndustries.isNotEmpty ||
                                        appliedSkills.isNotEmpty ||
                                        appliedEducation.isNotEmpty ||
                                        appliedSalary != "Any")
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "Active Filters:",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.darkGrey,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 8,
                                              children: [
                                                ...appliedIndustries.map((e) =>
                                                    _buildAppliedFilterChip("industry", e)),
                                                ...appliedSkills.map((e) =>
                                                    _buildAppliedFilterChip("skill", e)),
                                                ...appliedEducation.map((e) =>
                                                    _buildAppliedFilterChip("education", e)),
                                                if (appliedSalary != "Any")
                                                  _buildAppliedFilterChip(
                                                      "salary", appliedSalary),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                    // Recent Careers
                                    if (!showFilter) _buildRecentCareers(),

                                    // Careers List
                                    if (loading)
                                      _buildLoadingState()
                                    else if (filteredCareers.isEmpty)
                                      _buildEmptyState()
                                    else
                                      Column(
                                        children: [
                                          // List Header
                                          Padding(
                                            padding:
                                                const EdgeInsets.symmetric(horizontal: 8),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                const Text(
                                                  "All Careers",
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppColors.black,
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 12, vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.primary.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Text(
                                                    "${filteredCareers.length} careers",
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

                                          // Career List
                                          ListView.builder(
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemCount: filteredCareers.length,
                                            itemBuilder: (context, index) =>
                                                _buildCareerCard(filteredCareers[index]),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_isNavigating)
                          Container(
                            color: Colors.black.withOpacity(0.3),
                            child: Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  // Keep the existing _pickMultipleOptions and _pickSingleOption methods
  Future<void> _pickMultipleOptions(String title, List<String> options,
      List<String> selected, Function(List<String>) onConfirm) async {
    final tempSelected = [...selected];

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: AppColors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: options
                      .map(
                        (e) => CheckboxListTile(
                          value: tempSelected.contains(e),
                          title: Text(e),
                          onChanged: (val) {
                            setState(() {
                              val!
                                  ? tempSelected.add(e)
                                  : tempSelected.remove(e);
                            });
                          },
                          activeColor: AppColors.primary,
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                isOutlined: true,
                label: "Apply",
                onPressed: () {
                  onConfirm(tempSelected);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickSingleOption(String title, List<String> options,
      String selected, Function(String) onConfirm) async {
    String tempSelected = selected;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: AppColors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListView(
                shrinkWrap: true,
                children: options
                    .map(
                      (e) => RadioListTile<String>(
                        value: e,
                        groupValue: tempSelected,
                        title: Text(e),
                        onChanged: (val) => setState(() => tempSelected = val!),
                        activeColor: AppColors.primary,
                        contentPadding: EdgeInsets.zero,
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                isOutlined: true,
                label: "Apply",
                onPressed: () {
                  onConfirm(tempSelected);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}