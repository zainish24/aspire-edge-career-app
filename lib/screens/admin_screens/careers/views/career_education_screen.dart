import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:aspire_edge/models/education_model.dart';
import '/../constants.dart';
import '/../services/career_service.dart';

class AdminCareerEducationScreen extends StatefulWidget {
  const AdminCareerEducationScreen({super.key});

  @override
  State<AdminCareerEducationScreen> createState() =>
      _AdminCareerEducationScreenState();
}

class _AdminCareerEducationScreenState
    extends State<AdminCareerEducationScreen> {
  // Controllers for ALL fields
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _institutionTypeController = TextEditingController();
  final TextEditingController _costRangeController = TextEditingController();
  final TextEditingController _admissionRequirementsController = TextEditingController();
  final TextEditingController _careerOutcomesController = TextEditingController();
  final TextEditingController _averageSalaryController = TextEditingController();
  final TextEditingController _accreditationController = TextEditingController();
  final TextEditingController _prerequisitesController = TextEditingController();
  
  String? _selectedIndustryId;
  String? _selectedIndustryName;
  bool _loading = false;
  String? _editingId;
  String _searchQuery = '';
  
  final List<String> _educationLevels = [
    'Certificate',
    'Diploma',
    'Associate Degree',
    'Bachelor',
    'Master',
    'PhD',
    'Professional Certification'
  ];
  String? _selectedEducationLevel;

  final List<String> _workEnvironments = [
    'Full-time',
    'Part-time',
    'Online',
    'Hybrid',
    'Evening Classes',
    'Weekend Classes'
  ];
  final List<String> _selectedWorkEnvironments = [];

  final CareerService _careerService = CareerService();
  
  List<EducationModel> _educations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEducations();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _institutionTypeController.dispose();
    _costRangeController.dispose();
    _admissionRequirementsController.dispose();
    _careerOutcomesController.dispose();
    _averageSalaryController.dispose();
    _accreditationController.dispose();
    _prerequisitesController.dispose();
    super.dispose();
  }

  Future<void> _fetchEducations() async {
    try {
      final snapshot = await _careerService.educationsRef
          .orderBy("createdAt", descending: true)
          .get();
      
      setState(() {
        _educations = snapshot.docs.map((doc) => doc.data()).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching educations: $e');
      setState(() => _isLoading = false);
      _showErrorPopup("Error loading educations: ${e.toString()}");
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
                child: Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primary,
                  size: 32,
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
                onPressed: () {
                  Navigator.pop(ctx);
                  _clearForm();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
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

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _durationController.clear();
    _institutionTypeController.clear();
    _costRangeController.clear();
    _admissionRequirementsController.clear();
    _careerOutcomesController.clear();
    _averageSalaryController.clear();
    _accreditationController.clear();
    _prerequisitesController.clear();
    _selectedIndustryId = null;
    _selectedIndustryName = null;
    _selectedEducationLevel = null;
    _selectedWorkEnvironments.clear();
    _editingId = null;
  }

  Future<List<Map<String, dynamic>>> _loadIndustries() async {
    try {
      return await _careerService.getAllIndustries();
    } catch (e) {
      _showErrorPopup("Error loading industries: ${e.toString()}");
      return [];
    }
  }

  // Industry Selection
  void _showIndustrySelectionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: _loadIndustries(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text("Loading industries..."),
                    ],
                  ),
                ),
              );
            }

            if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.business_rounded, size: 48, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      "No industries found",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Please add industries first",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Close"),
                    ),
                  ],
                ),
              );
            }

            final industries = snapshot.data!;

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.business_rounded, color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            "Select Industry",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  
                  // List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: industries.length,
                      itemBuilder: (context, index) {
                        return _buildIndustryListItem(industries[index]);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildIndustryListItem(Map<String, dynamic> industry) {
    final name = industry["name"] ?? "Unnamed Industry";
    final description = industry["description"] ?? "";
    final isSelected = _selectedIndustryId == industry["id"];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.business_rounded, color: AppColors.primary, size: 20),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        subtitle: description.isNotEmpty ? Text(
          description,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12, color: AppColors.darkGrey),
        ) : null,
        trailing: isSelected
            ? Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, color: Colors.white, size: 16),
              )
            : null,
        onTap: () {
          setState(() {
            _selectedIndustryId = industry["id"];
            _selectedIndustryName = name;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  // Education Level Selection
  void _showEducationLevelSelection() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.school_rounded, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Select Education Level",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              
              // List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _educationLevels.length,
                  itemBuilder: (context, index) {
                    return _buildEducationLevelItem(_educationLevels[index]);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEducationLevelItem(String level) {
    final isSelected = _selectedEducationLevel == level;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.school_rounded, color: AppColors.primary, size: 20),
        ),
        title: Text(
          level,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        trailing: isSelected
            ? Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, color: Colors.white, size: 16),
              )
            : null,
        onTap: () {
          setState(() {
            _selectedEducationLevel = level;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  // Work Environment Selection
  void _showWorkEnvironmentSelection() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.work_rounded, color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            "Select Work Environments",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  
                  // List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _workEnvironments.length,
                      itemBuilder: (context, index) {
                        final environment = _workEnvironments[index];
                        return _buildWorkEnvironmentItem(environment, setState);
                      },
                    ),
                  ),
                  
                  // Done Button
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(color: Colors.grey[200]!),
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Done",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWorkEnvironmentItem(String environment, StateSetter setState) {
    final isSelected = _selectedWorkEnvironments.contains(environment);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.grey[300]!,
        ),
      ),
      child: CheckboxListTile(
        value: isSelected,
        onChanged: (value) {
          setState(() {
            if (value == true) {
              _selectedWorkEnvironments.add(environment);
            } else {
              _selectedWorkEnvironments.remove(environment);
            }
          });
        },
        title: Text(
          environment,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        secondary: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.work_rounded, color: AppColors.primary, size: 20),
        ),
        controlAffinity: ListTileControlAffinity.trailing,
      ),
    );
  }

  // MAIN EDUCATION DIALOG
  void _showEducationDialog({EducationModel? education}) {
    if (education != null) {
      _editingId = education.id;
      _titleController.text = education.title;
      _descriptionController.text = education.description;
      _durationController.text = education.duration;
      _institutionTypeController.text = education.institutionType;
      _costRangeController.text = education.costRange ?? '';
      _admissionRequirementsController.text = education.admissionRequirements ?? '';
      _careerOutcomesController.text = education.careerOutcomes ?? '';
      _averageSalaryController.text = education.averageSalary ?? '';
      _accreditationController.text = education.accreditation ?? '';
      _prerequisitesController.text = education.prerequisites.join(', ');
      _selectedEducationLevel = education.educationLevel;
      _selectedIndustryId = education.industryId;
      _selectedIndustryName = education.industryName;
      _selectedWorkEnvironments.clear();
      _selectedWorkEnvironments.addAll(education.workEnvironments);
    } else {
      _clearForm();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EducationFormDialog(
        editingId: _editingId,
        titleController: _titleController,
        descriptionController: _descriptionController,
        durationController: _durationController,
        institutionTypeController: _institutionTypeController,
        costRangeController: _costRangeController,
        admissionRequirementsController: _admissionRequirementsController,
        careerOutcomesController: _careerOutcomesController,
        averageSalaryController: _averageSalaryController,
        accreditationController: _accreditationController,
        prerequisitesController: _prerequisitesController,
        selectedEducationLevel: _selectedEducationLevel,
        selectedIndustryName: _selectedIndustryName,
        selectedWorkEnvironments: _selectedWorkEnvironments,
        onEducationLevelTap: _showEducationLevelSelection,
        onIndustryTap: _showIndustrySelectionSheet,
        onWorkEnvironmentTap: _showWorkEnvironmentSelection,
        onSave: _saveEducation,
        loading: _loading,
      ),
    );
  }

  Future<void> _saveEducation() async {
    if (_titleController.text.trim().isEmpty || 
        _selectedIndustryId == null || 
        _selectedEducationLevel == null) {
      _showErrorPopup("Please fill all required fields (Title, Industry, Education Level)");
      return;
    }
      
    setState(() => _loading = true);

    try {
      final educationData = {
        "title": _titleController.text.trim(),
        "description": _descriptionController.text.trim(),
        "duration": _durationController.text.trim(),
        "institutionType": _institutionTypeController.text.trim(),
        "educationLevel": _selectedEducationLevel,
        "costRange": _costRangeController.text.trim(),
        "admissionRequirements": _admissionRequirementsController.text.trim(),
        "careerOutcomes": _careerOutcomesController.text.trim(),
        "averageSalary": _averageSalaryController.text.trim(),
        "accreditation": _accreditationController.text.trim(),
        "prerequisites": _prerequisitesController.text.trim().split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        "workEnvironments": _selectedWorkEnvironments,
        "industryId": _selectedIndustryId,
        "industryName": _selectedIndustryName,
        "createdAt": _editingId == null ? FieldValue.serverTimestamp() : null,
        "updatedAt": FieldValue.serverTimestamp(),
      };

      if (_editingId == null) {
        await _careerService.addEducation(EducationModel.fromMap(educationData, id: ''));
        _showSuccessPopup("Education added successfully");
      } else {
        final existingEducation = _educations.firstWhere((edu) => edu.id == _editingId);
        educationData['createdAt'] = existingEducation.createdAt;
        
        await _careerService.updateEducation(EducationModel.fromMap(educationData, id: _editingId!));
        _showSuccessPopup("Education updated successfully");
      }

      await _fetchEducations();
      if (mounted) Navigator.pop(context);
      
    } catch (e) {
      print("Error saving education: $e");
      _showErrorPopup("Error: ${e.toString()}");
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _confirmDelete(String id, String title) async {
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
                "Delete Education?",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Are you sure you want to delete \"$title\"? This action cannot be undone.",
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
                      onPressed: () => Navigator.pop(ctx),
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
                      onPressed: () async {
                        Navigator.pop(ctx);
                        try {
                          await _careerService.deleteEducation(id);
                          _showSuccessPopup("\"$title\" has been successfully deleted.");
                          await _fetchEducations();
                        } catch (e) {
                          _showErrorPopup('Failed to delete education: $e');
                        }
                      },
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
  }

  Widget _buildEducationListItem(EducationModel education) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
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
        child: ListTile(
          contentPadding: const EdgeInsets.all(20),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.school_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          title: Text(
            education.title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.black,
              fontSize: 16,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.business_rounded, size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    education.industryName,
                    style: TextStyle(fontSize: 12, color: AppColors.darkGrey),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.star_rounded, size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    education.educationLevel,
                    style: TextStyle(fontSize: 12, color: AppColors.darkGrey),
                  ),
                ],
              ),
              if (education.description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  education.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: AppColors.darkGrey),
                ),
              ],
              if (education.duration.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  "Duration: ${education.duration}",
                  style: TextStyle(fontSize: 12, color: AppColors.darkGrey),
                ),
              ],
            ],
          ),
          trailing: Row(
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
                  child: Icon(Icons.edit_rounded, color: AppColors.primary, size: 18),
                ),
                onPressed: () => _showEducationDialog(education: education),
              ),
              IconButton(
                icon: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.delete_rounded, color: AppColors.error, size: 18),
                ),
                onPressed: () => _confirmDelete(education.id, education.title),
              ),
            ],
          ),
        ),
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
              Icons.school_outlined,
              color: AppColors.primary,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _searchQuery.isEmpty ? "No Education Paths Found" : "No Results Found",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _searchQuery.isEmpty 
                ? "Start by adding your first education path"
                : "No education paths found for \"$_searchQuery\"",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.darkGrey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          if (_searchQuery.isEmpty)
            ElevatedButton(
              onPressed: () => _showEducationDialog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                "Add First Education",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            ElevatedButton(
              onPressed: () {
                setState(() {
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
                "Clear Search",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderBanner() {
    final filteredEducations = _getFilteredEducations();
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
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
                  "Education Management",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Manage ${filteredEducations.length} education paths",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${filteredEducations.length} paths",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddEducationButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: () => _showEducationDialog(),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          elevation: 2,
          shadowColor: AppColors.primary.withOpacity(0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, size: 20),
            const SizedBox(width: 8),
            const Text(
              "Add New Education",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
        children: [
          Row(
            children: [
              Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                "Search Education Paths",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: "Search by title, industry, or level...",
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
                        _searchQuery = '';
                      });
                    },
                    icon: Icon(Icons.clear_rounded, color: AppColors.darkGrey, size: 18),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<EducationModel> _getFilteredEducations() {
    if (_searchQuery.isEmpty) {
      return _educations;
    }
    
    return _educations.where((education) {
      final title = education.title.toLowerCase();
      final industryName = education.industryName.toLowerCase();
      final educationLevel = education.educationLevel.toLowerCase();
      final description = education.description.toLowerCase();
      
      return title.contains(_searchQuery.toLowerCase()) ||
          industryName.contains(_searchQuery.toLowerCase()) ||
          educationLevel.contains(_searchQuery.toLowerCase()) ||
          description.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredEducations = _getFilteredEducations();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Manage Education Paths",
          style: TextStyle(
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            onPressed: _fetchEducations,
            icon: Icon(Icons.refresh_rounded, color: AppColors.primary),
            tooltip: "Refresh",
          ),
        ],
      ),
      
      
      
      
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text(
                    "Loading Education Paths...",
                    style: TextStyle(
                      color: AppColors.darkGrey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Header Banner
                _buildHeaderBanner(),
                
                // Add Education Button
                _buildAddEducationButton(),
                
                // Search Section
                _buildSearchSection(),
                
                // Education List
                Expanded(
                  child: filteredEducations.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 20),
                          itemCount: filteredEducations.length,
                          itemBuilder: (context, index) {
                            final education = filteredEducations[index];
                            return _buildEducationListItem(education);
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

// SEPARATE WIDGET FOR EDUCATION FORM DIALOG
class EducationFormDialog extends StatelessWidget {
  final String? editingId;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController durationController;
  final TextEditingController institutionTypeController;
  final TextEditingController costRangeController;
  final TextEditingController admissionRequirementsController;
  final TextEditingController careerOutcomesController;
  final TextEditingController averageSalaryController;
  final TextEditingController accreditationController;
  final TextEditingController prerequisitesController;
  final String? selectedEducationLevel;
  final String? selectedIndustryName;
  final List<String> selectedWorkEnvironments;
  final VoidCallback onEducationLevelTap;
  final VoidCallback onIndustryTap;
  final VoidCallback onWorkEnvironmentTap;
  final VoidCallback onSave;
  final bool loading;

  const EducationFormDialog({
    super.key,
    required this.editingId,
    required this.titleController,
    required this.descriptionController,
    required this.durationController,
    required this.institutionTypeController,
    required this.costRangeController,
    required this.admissionRequirementsController,
    required this.careerOutcomesController,
    required this.averageSalaryController,
    required this.accreditationController,
    required this.prerequisitesController,
    required this.selectedEducationLevel,
    required this.selectedIndustryName,
    required this.selectedWorkEnvironments,
    required this.onEducationLevelTap,
    required this.onIndustryTap,
    required this.onWorkEnvironmentTap,
    required this.onSave,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    final isFormValid = titleController.text.trim().isNotEmpty &&
        selectedIndustryName != null &&
        selectedEducationLevel != null;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.school_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      editingId == null ? "Add New Education" : "Edit Education",
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Basic Information Section
              _buildSectionHeader("Basic Information", Icons.info_rounded),
              _buildSelectionField(
                label: "Education Level*",
                value: selectedEducationLevel,
                icon: Icons.school_rounded,
                onTap: onEducationLevelTap,
              ),
              const SizedBox(height: 16),
              _buildSelectionField(
                label: "Industry*",
                value: selectedIndustryName,
                icon: Icons.business_rounded,
                onTap: onIndustryTap,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: titleController,
                label: "Education Title*",
                hint: "Enter education title",
                icon: Icons.title_rounded,
                isRequired: true,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: descriptionController,
                label: "Description",
                hint: "Enter education description",
                icon: Icons.description_rounded,
                maxLines: 3,
              ),
              
              // Program Details Section
              _buildSectionHeader("Program Details", Icons.school_rounded),
              _buildTextField(
                controller: durationController,
                label: "Duration",
                hint: "e.g., 4 years, 2 semesters",
                icon: Icons.access_time_rounded,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: institutionTypeController,
                label: "Institution Type",
                hint: "e.g., University, College, Online",
                icon: Icons.business_center_rounded,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: costRangeController,
                label: "Cost Range",
                hint: "e.g., \$8,000 - \$15,000 per year",
                icon: Icons.attach_money_rounded,
              ),
              const SizedBox(height: 16),
              _buildSelectionField(
                label: "Work Environments",
                value: selectedWorkEnvironments.isNotEmpty 
                    ? "${selectedWorkEnvironments.length} selected"
                    : "Select work environments",
                icon: Icons.work_rounded,
                onTap: onWorkEnvironmentTap,
              ),
        
              // Admission & Career Section
              _buildSectionHeader("Admission & Career", Icons.work_outline_rounded),
              _buildTextField(
                controller: admissionRequirementsController,
                label: "Admission Requirements",
                hint: "List admission requirements",
                icon: Icons.assignment_rounded,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: careerOutcomesController,
                label: "Career Outcomes",
                hint: "Describe potential career outcomes",
                icon: Icons.work_outline_rounded,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: averageSalaryController,
                label: "Average Salary",
                hint: "e.g., \$60,000 - \$120,000",
                icon: Icons.monetization_on_rounded,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: accreditationController,
                label: "Accreditation",
                hint: "Accreditation details",
                icon: Icons.verified_rounded,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: prerequisitesController,
                label: "Prerequisites",
                hint: "Comma separated prerequisites",
                icon: Icons.list_rounded,
              ),
              
              const SizedBox(height: 32),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.darkGrey,
                        side: const BorderSide(color: AppColors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: !isFormValid || loading ? null : onSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              editingId == null ? "Add Education" : "Save Changes",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
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
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
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
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionField({
    required String label,
    required String? value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.black,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[300]!,
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value ?? label,
                    style: TextStyle(
                      color: value != null ? AppColors.black : AppColors.darkGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(Icons.arrow_drop_down_rounded, color: AppColors.darkGrey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isRequired = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.black,
                fontSize: 14,
              ),
            ),
            if (isRequired)
              const Text(
                " *",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
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
              prefixIcon: Icon(icon, color: AppColors.primary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}