import 'package:flutter/material.dart';
import 'package:aspire_edge/constants.dart';
import 'package:aspire_edge/components/custom_dialog.dart';
import 'package:aspire_edge/models/skill_model.dart';
import 'package:aspire_edge/services/career_service.dart';

class AdminSkillManagementScreen extends StatefulWidget {
  final String? industryId;
  final String? industryName;
  final List<String>? educationIds;
  final Function(List<SkillModel>)? onSkillsSelected;

  const AdminSkillManagementScreen({
    super.key,
    this.industryId,
    this.industryName,
    this.educationIds,
    this.onSkillsSelected,
    required String educationId,
    required String educationName,
  });

  @override
  State<AdminSkillManagementScreen> createState() =>
      _AdminSkillManagementScreenState();
}

class _AdminSkillManagementScreenState
    extends State<AdminSkillManagementScreen> {
  final CareerService _careerService = CareerService();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  List<SkillModel> _allSkills = [];
  List<SkillModel> _filteredSkills = [];
  List<SkillModel> _selectedSkills = [];
  bool _loading = false;
  bool _showAddForm = false;
  SkillModel? _editingSkill;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      // Load skills based on filters
      if (widget.industryId != null) {
        _allSkills = await _careerService.getSkillsByIndustryAndEducation(
          industryId: widget.industryId!,
          educationIds: widget.educationIds ?? [],
        );
      } else {
        _allSkills = await _careerService.getAllSkills();
      }

      _filteredSkills = _allSkills;
      setState(() {});
    } catch (e) {
      CustomDialog.show(context,
          message: "Error loading skills: $e", isError: true);
    } finally {
      setState(() => _loading = false);
    }
  }

  void _filterSkills() {
    final searchTerm = _searchController.text.toLowerCase();
    setState(() {
      _filteredSkills = _allSkills.where((skill) {
        final matchesSearch = searchTerm.isEmpty ||
            skill.name.toLowerCase().contains(searchTerm) ||
            skill.description.toLowerCase().contains(searchTerm);
        return matchesSearch;
      }).toList();
    });
  }

  void _startAddSkill() {
    _editingSkill = null;
    _nameController.clear();
    _descriptionController.clear();
    setState(() => _showAddForm = true);
  }

  void _startEditSkill(SkillModel skill) {
    _editingSkill = skill;
    _nameController.text = skill.name;
    _descriptionController.text = skill.description;
    setState(() => _showAddForm = true);
  }

  Future<void> _saveSkill() async {
    if (_nameController.text.trim().isEmpty) {
      CustomDialog.show(context,
          message: "Please enter skill name", isError: true);
      return;
    }

    setState(() => _loading = true);
    try {
      if (_editingSkill == null) {
        // Add new skill
        await _careerService.createSkillWithCategory(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          industryId: widget.industryId ?? '',
          industryName: widget.industryName ?? '',
          educationIds: widget.educationIds ?? [],
        );
      } else {
        // Update existing skill
        final updatedSkill = SkillModel(
          id: _editingSkill!.id,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          industryId: widget.industryId ?? _editingSkill!.industryId,
          industryName: widget.industryName ?? _editingSkill!.industryName,
          educationIds: widget.educationIds ?? _editingSkill!.educationIds,
          createdAt: _editingSkill!.createdAt,
          updatedAt: _editingSkill!.updatedAt,
        );
        await _careerService.updateSkill(updatedSkill);
      }

      _nameController.clear();
      _descriptionController.clear();
      setState(() {
        _showAddForm = false;
        _editingSkill = null;
      });

      CustomDialog.show(context,
          message: _editingSkill == null
              ? "Skill added successfully!"
              : "Skill updated successfully!",
          isError: false);

      await _loadData();
    } catch (e) {
      CustomDialog.show(context,
          message: "Error saving skill: $e", isError: true);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _deleteSkill(String skillId, String skillName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
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
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_rounded,
                  color: AppColors.error,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Delete Skill?",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Are you sure you want to delete \"$skillName\"?",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.darkGrey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.darkGrey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        "Delete",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      setState(() => _loading = true);
      try {
        await _careerService.deleteSkill(skillId);
        CustomDialog.show(context,
            message: "Skill deleted successfully!", isError: false);
        await _loadData();
      } catch (e) {
        CustomDialog.show(context,
            message: "Error deleting skill: $e", isError: true);
      } finally {
        setState(() => _loading = false);
      }
    }
  }

  void _toggleSkillSelection(SkillModel skill) {
    setState(() {
      if (_selectedSkills.contains(skill)) {
        _selectedSkills.remove(skill);
      } else {
        _selectedSkills.add(skill);
      }
    });
  }

  void _confirmSelection() {
    if (widget.onSkillsSelected != null) {
      widget.onSkillsSelected!(_selectedSkills);
    }
    Navigator.pop(context, _selectedSkills);
  }

  Widget _buildSkillCard(SkillModel skill) {
    final isSelected = _selectedSkills.contains(skill);
    final isSelectable = widget.onSkillsSelected != null;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 20,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: 2,
        ),
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
        child: isMobile
            ? _buildMobileSkillCard(skill, isSelected, isSelectable)
            : _buildDesktopSkillCard(skill, isSelected, isSelectable),
      ),
    );
  }

  Widget _buildMobileSkillCard(
      SkillModel skill, bool isSelected, bool isSelectable) {
    return ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child:
            Icon(Icons.psychology_rounded, color: AppColors.primary, size: 20),
      ),
      title: Text(
        skill.name,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isSelected ? AppColors.primary : AppColors.black,
          fontSize: 15,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (skill.description.isNotEmpty)
            Text(
              skill.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: isSelected ? AppColors.primary : Colors.grey[600],
              ),
            ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: isSelected,
            onChanged: (value) => _toggleSkillSelection(skill),
            activeColor: AppColors.primary,
          ),
          _buildEditDeleteButtons(skill, true),
        ],
      ),
      onTap: () => _toggleSkillSelection(skill),
    );
  }

  Widget _buildDesktopSkillCard(
      SkillModel skill, bool isSelected, bool isSelectable) {
    return ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child:
            Icon(Icons.psychology_rounded, color: AppColors.primary, size: 20),
      ),
      title: Text(
        skill.name,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isSelected ? AppColors.primary : AppColors.black,
          fontSize: 15,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (skill.description.isNotEmpty)
            Text(
              skill.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: isSelected ? AppColors.primary : Colors.grey[600],
              ),
            ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: isSelected,
            onChanged: (value) => _toggleSkillSelection(skill),
            activeColor: AppColors.primary,
          ),
          _buildEditDeleteButtons(skill, false),
        ],
      ),
      onTap: () => _toggleSkillSelection(skill),
    );
  }

  // New method to build edit/delete buttons
  Widget _buildEditDeleteButtons(SkillModel skill, bool isMobile) {
    if (isMobile) {
      return PopupMenuButton<String>(
        icon: Icon(Icons.more_vert_rounded, color: AppColors.darkGrey),
        onSelected: (value) {
          if (value == 'edit') {
            _startEditSkill(skill);
          } else if (value == 'delete') {
            _deleteSkill(skill.id, skill.name);
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit_rounded, color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Text('Edit'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete_rounded, color: AppColors.error, size: 18),
                const SizedBox(width: 8),
                Text('Delete'),
              ],
            ),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  Icon(Icons.edit_rounded, color: AppColors.primary, size: 18),
            ),
            onPressed: () => _startEditSkill(skill),
          ),
          IconButton(
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  Icon(Icons.delete_rounded, color: AppColors.error, size: 18),
            ),
            onPressed: () => _deleteSkill(skill.id, skill.name),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.industryName != null
              ? "Skills - ${widget.industryName}"
              : "Manage Skills",
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: AppColors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_selectedSkills.isNotEmpty) // REMOVED the onSkillsSelected check
            Padding(
              padding: EdgeInsets.only(right: isMobile ? 12 : 16),
              child: isMobile
                  ? IconButton(
                      onPressed: _confirmSelection,
                      icon: Badge(
                        label: Text(_selectedSkills.length.toString()),
                        child:
                            Icon(Icons.check_rounded, color: AppColors.primary),
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: _confirmSelection,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: Text('Select (${_selectedSkills.length})'),
                    ),
            ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Fixed Header Section (non-scrollable)
            _buildHeaderSection(isMobile),

            // Scrollable Content Section
            Expanded(
              child: _buildContentSection(isMobile, isTablet),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(bool isMobile) {
    return Column(
      children: [
        // Header Banner
        Container(
          width: double.infinity,
          margin: EdgeInsets.all(isMobile ? 16 : 20),
          padding: EdgeInsets.all(isMobile ? 16 : 20),
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
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: isMobile ? _buildMobileHeader() : _buildDesktopHeader(),
        ),

        // Search and Add Button
        Container(
          margin: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 20,
            vertical: 8,
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: isMobile ? 44 : 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: isMobile ? 12 : 16),
                      Icon(Icons.search_rounded,
                          color: AppColors.darkGrey, size: isMobile ? 18 : 20),
                      SizedBox(width: isMobile ? 8 : 12),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) => _filterSkills(),
                          decoration: InputDecoration(
                            hintText: "Search skills...",
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              color: AppColors.grey,
                              fontSize: isMobile ? 14 : null,
                            ),
                          ),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          onPressed: () {
                            _searchController.clear();
                            _filterSkills();
                          },
                          icon: Icon(Icons.clear_rounded,
                              color: AppColors.darkGrey,
                              size: isMobile ? 16 : 18),
                        ),
                    ],
                  ),
                ),
              ),
              if (!_showAddForm) ...[
                SizedBox(width: isMobile ? 8 : 12),
                Container(
                  width: isMobile ? 44 : 50,
                  height: isMobile ? 44 : 50,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: _startAddSkill,
                    icon: Icon(Icons.add_rounded,
                        color: Colors.white, size: isMobile ? 18 : 20),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContentSection(bool isMobile, bool isTablet) {
    return CustomScrollView(
      slivers: [
        // Add/Edit Form
        if (_showAddForm)
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 20,
                vertical: 8,
              ),
              child: _buildSkillForm(isMobile, isTablet),
            ),
          ),

        // Skills List or Loading
        if (_loading)
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Loading skills..."),
                ],
              ),
            ),
          )
        else if (_filteredSkills.isEmpty)
          SliverFillRemaining(
            child: _buildEmptyState(isMobile),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildSkillCard(_filteredSkills[index]),
              childCount: _filteredSkills.length,
            ),
          ),
      ],
    );
  }

  Widget _buildMobileHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.industryName != null
              ? "Skills - ${widget.industryName}"
              : "Manage Skills",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "${_allSkills.length} skills",
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.industryName != null
                    ? "Skills for ${widget.industryName}"
                    : "Manage Skills",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Manage ${_allSkills.length} skills",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.psychology_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ],
    );
  }

  Widget _buildSkillForm(bool isMobile, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: isMobile ? 36 : 40,
                height: isMobile ? 36 : 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.psychology_rounded,
                  color: AppColors.primary,
                  size: isMobile ? 18 : 20,
                ),
              ),
              SizedBox(width: isMobile ? 8 : 12),
              Expanded(
                child: Text(
                  _editingSkill == null ? "Add New Skill" : "Edit Skill",
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 20),
          _buildFormField(
            controller: _nameController,
            label: "Skill Name *",
            hint: "Enter skill name",
            icon: Icons.psychology_rounded,
            isMobile: isMobile,
          ),
          SizedBox(height: isMobile ? 12 : 16),
          _buildFormField(
            controller: _descriptionController,
            label: "Description",
            hint: "Enter skill description",
            icon: Icons.description_rounded,
            maxLines: 2,
            isMobile: isMobile,
          ),
          SizedBox(height: isMobile ? 16 : 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _showAddForm = false;
                      _editingSkill = null;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.darkGrey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 14),
                  ),
                  child: Text(
                    "Cancel",
                    style: TextStyle(fontSize: isMobile ? 14 : null),
                  ),
                ),
              ),
              SizedBox(width: isMobile ? 8 : 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveSkill,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 14),
                  ),
                  child: Text(
                    "Save Skill",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: isMobile ? 14 : null,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    required bool isMobile,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.black,
            fontSize: isMobile ? 13 : 14,
          ),
        ),
        SizedBox(height: isMobile ? 6 : 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(
                icon,
                color: AppColors.primary,
                size: isMobile ? 18 : 20,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 16,
                vertical: isMobile ? 12 : 16,
              ),
              hintStyle: TextStyle(fontSize: isMobile ? 14 : null),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isMobile) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 20 : 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: isMobile ? 80 : 100,
            height: isMobile ? 80 : 100,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.psychology_rounded,
              size: isMobile ? 36 : 48,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: isMobile ? 16 : 20),
          Text(
            "No Skills Found",
            style: TextStyle(
              fontSize: isMobile ? 18 : 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: isMobile ? 8 : 12),
          Text(
            "Try adjusting your filters or add a new skill",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: isMobile ? 13 : null,
            ),
          ),
          SizedBox(height: isMobile ? 20 : 24),
          ElevatedButton(
            onPressed: _startAddSkill,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 20 : 24,
                vertical: isMobile ? 10 : 12,
              ),
            ),
            child: Text(
              "Add New Skill",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: isMobile ? 14 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
