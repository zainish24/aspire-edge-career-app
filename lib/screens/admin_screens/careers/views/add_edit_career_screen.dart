import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;

import 'package:aspire_edge/constants.dart';
import 'package:aspire_edge/components/custom_dialog.dart';
import 'package:aspire_edge/models/career_model.dart';
import 'package:aspire_edge/models/education_model.dart';
import 'package:aspire_edge/models/skill_model.dart';
import 'package:aspire_edge/routes/screen_export.dart';
import 'package:aspire_edge/services/career_service.dart';

class AdminCareerAddEditScreen extends StatefulWidget {
  final String? careerId;
  final CareerModel? careerData;

  const AdminCareerAddEditScreen({super.key, this.careerId, this.careerData});

  @override
  State<AdminCareerAddEditScreen> createState() =>
      _AdminCareerAddEditScreenState();
}

class _AdminCareerAddEditScreenState extends State<AdminCareerAddEditScreen> {
  final PageController _pageController = PageController();

  // Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _responsibilitiesController =
      TextEditingController();
  final TextEditingController _entryPositionsController =
      TextEditingController();
  final TextEditingController _seniorPositionsController =
      TextEditingController();
  final TextEditingController _streamsController = TextEditingController();
  final TextEditingController _cvTipsController = TextEditingController();
  final TextEditingController _questionsController = TextEditingController();
  final TextEditingController _bodyLanguageController = TextEditingController();
  final TextEditingController _mockInterviewVideosController =
      TextEditingController();

  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedImages = [];
  final List<String> _uploadedImageUrls = [];
  final List<XFile> _selectedVideos = [];
  final List<String> _uploadedVideoUrls = [];

  final CareerService _careerService = CareerService();

  // Selection data
  final List<Map<String, dynamic>> _industries = [];
  String? _selectedIndustryId;
  String? _selectedIndustryName;

  final List<EducationModel> _educations = [];
  final List<String> _selectedEducationIds = [];
  final List<String> _selectedEducationNames = [];

  // Skills data
  final List<SkillModel> _selectedSkills = [];
  final Map<String, String> _skillLevels = {};

  // Career attributes
  final Map<String, dynamic> _attributes = {
    'workEnvironment': <String>[],
    'jobOutlook': 'Medium',
    'experienceLevel': 'Entry-level',
    'workLifeBalance': 'Good',
    'stressLevel': 'Medium',
    'employmentType': <String>['Full-time'],
  };

  // UI State
  bool _isLoading = false;
  bool _isSaving = false;
  int _currentStep = 0;

  // Attribute options
  final Map<String, List<String>> _attributeOptions = {
    'Work Environment': [
      'Office',
      'Remote',
      'Hybrid',
      'Field',
      'Laboratory',
      'Factory'
    ],
    'Job Outlook': ['Very High', 'High', 'Medium', 'Low', 'Declining'],
    'Experience Level': [
      'Internship',
      'Entry-level',
      'Mid-level',
      'Senior',
      'Executive'
    ],
    'Work-Life Balance': ['Excellent', 'Good', 'Moderate', 'Poor', 'Demanding'],
    'Stress Level': ['Low', 'Medium', 'High', 'Very High'],
    'Skill Level': ['Beginner', 'Intermediate', 'Advanced', 'Expert'],
    'Employment Type': [
      'Full-time',
      'Part-time',
      'Contract',
      'Freelance',
      'Internship'
    ],
  };

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      await _loadIndustries();

      if (widget.careerData != null) {
        _loadExistingData();
      }
    } catch (e) {
      debugPrint('Error initializing data: $e');
      _showError('Failed to load initial data');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _loadExistingData() {
    final data = widget.careerData!;

    _titleController.text = data.title;
    _descController.text = data.description ?? '';
    _salaryController.text = data.salaryRange ?? '';
    _uploadedImageUrls.addAll(data.images);

    _selectedIndustryId = data.industryId;
    _selectedIndustryName = data.industryName;

    _selectedEducationIds.addAll(data.educationPathIds);
    _selectedEducationNames.addAll(data.educationPathNames);

    // Load skills
    _loadExistingSkills(data);

    // Load attributes
    _attributes['workEnvironment'] = List<String>.from(data.workEnvironment);
    _attributes['jobOutlook'] = data.jobOutlook;
    _attributes['experienceLevel'] = data.experienceLevel;
    _attributes['workLifeBalance'] = data.workLifeBalance;
    _attributes['stressLevel'] = data.stressLevel;

    // Load career details
    _responsibilitiesController.text = data.responsibilities.join('\n');
    _entryPositionsController.text = data.entryLevelPositions.join(', ');
    _seniorPositionsController.text = data.seniorPositions.join(', ');

    // Load guidance tools
    _streamsController.text = data.recommendedStreams.join(', ');
    _cvTipsController.text = data.cvDoDonts.join('\n');
    _questionsController.text = data.commonInterviewQuestions.join('\n');
    _bodyLanguageController.text = data.bodyLanguageTips.join('\n');
    _mockInterviewVideosController.text = data.mockInterviewVideos.join('\n');
  }

  Future<void> _loadExistingSkills(CareerModel data) async {
    try {
      final skills = await _careerService.getSkillsByIds(data.skillIds);
      setState(() {
        _selectedSkills.clear();
        _selectedSkills.addAll(skills);
        _skillLevels.addAll(data.skillLevels);
      });
    } catch (e) {
      debugPrint('Error loading existing skills: $e');
    }
  }

  Future<void> _loadIndustries() async {
    try {
      final industries = await _careerService.getAllIndustries();
      if (mounted) {
        setState(() {
          _industries.clear();
          _industries.addAll(industries);
        });
      }
    } catch (e) {
      debugPrint('Error loading industries: $e');
      rethrow;
    }
  }

  Future<void> _loadEducations(String industryId) async {
    try {
      final educations =
          await _careerService.getEducationsByIndustry(industryId);
      if (mounted) {
        setState(() {
          _educations.clear();
          _educations.addAll(educations);
        });
      }
    } catch (e) {
      debugPrint('Error loading educations: $e');
      rethrow;
    }
  }

  // Skills Management
  void _openSkillManagement() async {
    if (_selectedIndustryId == null) {
      _showError('Please select an industry first');
      return;
    }

    final selectedSkills = await Navigator.push<List<SkillModel>>(
      context,
      MaterialPageRoute(
        builder: (context) => AdminSkillManagementScreen(
          industryId: _selectedIndustryId,
          industryName: _selectedIndustryName,
          educationIds: _selectedEducationIds,
          onSkillsSelected:
              null, // CHANGED THIS LINE - set to null for management mode
          educationId: '',
          educationName: '',
        ),
      ),
    );

    if (selectedSkills != null && mounted) {
      setState(() {
        _selectedSkills.clear();
        _selectedSkills.addAll(selectedSkills);

        // Set default skill levels for new skills
        for (final skill in selectedSkills) {
          _skillLevels.putIfAbsent(skill.id, () => 'Intermediate');
        }
      });
    }
  }

  // Image and Video Handling - FIXED VERSIONS
  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1200,
      );

      if (mounted) {
        setState(() {
          // Prevent duplicates
          for (final image in images) {
            if (!_selectedImages
                .any((existing) => existing.path == image.path)) {
              _selectedImages.add(image);
            }
          }
        });
      }
    } catch (e) {
      _showError('Failed to pick images: ${e.toString()}');
    }
  }

  Future<void> _pickVideos() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video != null && mounted) {
        setState(() {
          // Prevent duplicates
          if (!_selectedVideos.any((existing) => existing.path == video.path)) {
            _selectedVideos.add(video);
          }
        });
      }
    } catch (e) {
      _showError('Failed to pick video: ${e.toString()}');
    }
  }

  Future<void> _pickMockInterviewVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video != null && mounted) {
        setState(() {
          // Prevent duplicates
          if (!_selectedVideos.any((existing) => existing.path == video.path)) {
            _selectedVideos.add(video);
          }
        });
      }
    } catch (e) {
      _showError('Failed to pick video: ${e.toString()}');
    }
  }

  Future<String?> _uploadFile(XFile file, {bool isVideo = false}) async {
    const String cloudName = "dflrecddn";
    const String uploadPreset = "Ecommerce";
    final Uri uri =
        Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/upload");

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..fields['resource_type'] = isVideo ? 'video' : 'image';

    final bytes = await file.readAsBytes();
    final filename = path.basename(file.path);

    request.files.add(http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: filename,
    ));

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final body = await response.stream.bytesToString();
        final jsonMap = jsonDecode(body) as Map<String, dynamic>;
        return jsonMap['secure_url']?.toString();
      }
    } catch (e) {
      debugPrint('Upload error: $e');
    }
    return null;
  }

  void _removeImage(int index, bool isUploaded) {
    if (mounted) {
      setState(() {
        if (isUploaded) {
          _uploadedImageUrls.removeAt(index);
        } else {
          _selectedImages.removeAt(index);
        }
      });
    }
  }

  void _removeVideo(int index, bool isUploaded) {
    if (mounted) {
      setState(() {
        if (isUploaded) {
          _uploadedVideoUrls.removeAt(index);
        } else {
          _selectedVideos.removeAt(index);
        }
      });
    }
  }

  // Selection Dialogs - FIXED VERSIONS
  void _showIndustryDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Industry',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SizedBox(
                  width: double.maxFinite,
                  height: 400,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _industries.length,
                    itemBuilder: (context, index) {
                      final industry = _industries[index];
                      return ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            // ignore: deprecated_member_use
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.business_rounded,
                              color: AppColors.primary, size: 20),
                        ),
                        title: Text(industry['name']),
                        subtitle: industry['description'] != null
                            ? Text(industry['description'] as String)
                            : null,
                        trailing: _selectedIndustryId == industry['id']
                            ? Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.check,
                                    color: Colors.white, size: 16),
                              )
                            : null,
                        onTap: () => _selectIndustry(industry),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
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

  void _selectIndustry(Map<String, dynamic> industry) async {
    Navigator.pop(context);

    if (mounted) {
      setState(() {
        _selectedIndustryId = industry['id'] as String?;
        _selectedIndustryName = industry['name'] as String?;
        _selectedEducationIds.clear();
        _selectedEducationNames.clear();
        _selectedSkills.clear();
        _skillLevels.clear();
      });
    }

    await _loadEducations(_selectedIndustryId!);
  }

  void _showEducationDialog() {
    if (_selectedIndustryId == null) {
      _showError('Please select an industry first');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Select Education Paths',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.maxFinite,
                    height: 400,
                    child: _educations.isEmpty
                        ? const Center(
                            child: Text('No education paths available'))
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: _educations.length,
                            itemBuilder: (context, index) {
                              final education = _educations[index];
                              final isSelected =
                                  _selectedEducationIds.contains(education.id);

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary.withOpacity(0.1)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : Colors.grey[300]!,
                                  ),
                                ),
                                child: CheckboxListTile(
                                  title: Text(
                                    education.title,
                                    style: TextStyle(
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  subtitle: Text(education.description),
                                  value: isSelected,
                                  onChanged: (value) {
                                    setDialogState(() {
                                      if (value == true) {
                                        _selectedEducationIds.add(education.id);
                                        _selectedEducationNames
                                            .add(education.title);
                                      } else {
                                        _selectedEducationIds
                                            .remove(education.id);
                                        _selectedEducationNames
                                            .remove(education.title);
                                      }
                                    });
                                  },
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  activeColor: AppColors.primary,
                                  checkColor: Colors.white,
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {}); // Refresh the main UI
                            Navigator.pop(context);
                          },
                          child: const Text('Confirm'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAttributeDialog(String attribute, bool isMultiSelect) {
    final options = _attributeOptions[attribute] ?? [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Select $attribute',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SizedBox(
                      width: double.maxFinite,
                      height: 300,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          final option = options[index];
                          final isSelected = isMultiSelect
                              ? (_attributes[_camelCase(attribute)] as List)
                                  .contains(option)
                              : _attributes[_camelCase(attribute)] == option;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withOpacity(0.1)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.grey[300]!,
                              ),
                            ),
                            child: CheckboxListTile(
                              title: Text(option),
                              value: isSelected,
                              onChanged: (value) {
                                setDialogState(() {
                                  if (isMultiSelect) {
                                    final list =
                                        _attributes[_camelCase(attribute)]
                                            as List<String>;
                                    if (value == true) {
                                      list.add(option);
                                    } else {
                                      list.remove(option);
                                    }
                                  } else {
                                    _attributes[_camelCase(attribute)] = option;
                                  }
                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                              activeColor: AppColors.primary,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {}); // Refresh main UI
                            Navigator.pop(context);
                          },
                          child: const Text('Done'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _camelCase(String input) {
    final words = input.toLowerCase().split(' ');
    if (words.length == 1) return words[0];
    return words[0] +
        words.sublist(1).map((w) => w[0].toUpperCase() + w.substring(1)).join();
  }

  // Save Career with proper navigation
  Future<void> _saveCareer() async {
    // Validate required fields
    if (_titleController.text.trim().isEmpty) {
      _showError('Career title is required');
      return;
    }

    if (_selectedIndustryId == null) {
      _showError('Please select an industry');
      return;
    }

    if (_selectedEducationIds.isEmpty) {
      _showError('Please select at least one education path');
      return;
    }

    if (mounted) {
      setState(() => _isSaving = true);
    }

    try {
      // Upload new images
      final List<String> allImageUrls = [..._uploadedImageUrls];
      for (final image in _selectedImages) {
        final url = await _uploadFile(image);
        if (url != null) {
          allImageUrls.add(url);
        }
      }

      // Upload new videos
      final List<String> allVideoUrls = [..._uploadedVideoUrls];
      for (final video in _selectedVideos) {
        final url = await _uploadFile(video, isVideo: true);
        if (url != null) {
          allVideoUrls.add(url);
        }
      }

      // Parse text fields
      final responsibilities = _responsibilitiesController.text
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .toList();

      final entryPositions = _entryPositionsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final seniorPositions = _seniorPositionsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final recommendedStreams = _streamsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final cvDoDonts = _cvTipsController.text
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .toList();

      final commonQuestions = _questionsController.text
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .toList();

      final bodyLanguageTips = _bodyLanguageController.text
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .toList();

      final mockVideos = [
        ...allVideoUrls,
        ..._mockInterviewVideosController.text
            .split('\n')
            .where((line) => line.trim().isNotEmpty)
            .toList(),
      ];

      // Create career model
      final career = CareerModel(
        careerId:
            widget.careerId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        industryId: _selectedIndustryId!,
        industryName: _selectedIndustryName!,
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        skillIds: _selectedSkills.map((skill) => skill.id).toList(),
        skillNames: _selectedSkills.map((skill) => skill.name).toList(),
        salaryRange: _salaryController.text.trim().isEmpty
            ? null
            : _salaryController.text.trim(),
        educationPathIds: _selectedEducationIds,
        educationPathNames: _selectedEducationNames,
        images: allImageUrls,
        createdAt: widget.careerData?.createdAt ?? Timestamp.now(),
        updatedAt: Timestamp.now(),

        // Career attributes
        jobOutlook: _attributes['jobOutlook'] as String,
        workEnvironment:
            (_attributes['workEnvironment'] as List<String>).toList(),
        experienceLevel: _attributes['experienceLevel'] as String,
        responsibilities: responsibilities,
        workLifeBalance: _attributes['workLifeBalance'] as String,
        stressLevel: _attributes['stressLevel'] as String,
        entryLevelPositions: entryPositions,
        seniorPositions: seniorPositions,
        skillLevels: _skillLevels,

        // Career guidance
        streamSelector: {'recommendedStreams': recommendedStreams},
        cvTips: {'doDonts': cvDoDonts},
        interviewPrep: {
          'commonQuestions': commonQuestions,
          'bodyLanguageTips': bodyLanguageTips,
          'mockVideos': mockVideos,
        },
      );

      // Save to Firestore
      if (widget.careerId == null) {
        await _careerService.addCareer(career);
        _showSuccessAndNavigate('Career created successfully!');
      } else {
        await _careerService.updateCareer(career);
        _showSuccessAndNavigate('Career updated successfully!');
      }
    } catch (e) {
      debugPrint('Error saving career: $e');
      _showError('Failed to save career: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showSuccessAndNavigate(String message) {
    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Success'),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context, true); // Navigate back to career list
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showError(String message) {
    CustomDialog.show(context, message: message, isError: true);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _salaryController.dispose();
    _responsibilitiesController.dispose();
    _entryPositionsController.dispose();
    _seniorPositionsController.dispose();
    _streamsController.dispose();
    _cvTipsController.dispose();
    _questionsController.dispose();
    _bodyLanguageController.dispose();
    _mockInterviewVideosController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // UI Components
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: _isLoading ? _buildLoading() : _buildContent(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        widget.careerId != null ? 'Edit Career' : 'Create New Career',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 20,
          color: AppColors.black,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.black),
      actions: [
        if (_isSaving)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading...'),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // Progress Header
        _buildProgressHeader(),

        // Stepper
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // Stepper Header
                _buildStepperHeader(),

                // Content
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildBasicInfoStep(),
                      _buildIndustryEducationStep(),
                      _buildSkillsAttributesStep(),
                      _buildCareerDetailsStep(),
                    ],
                  ),
                ),

                // Navigation
                _buildNavigationButtons(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.all(20),
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
                  widget.careerId != null
                      ? 'Editing Career'
                      : 'Creating New Career',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getStepDescription(_currentStep),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: (_currentStep + 1) / 4,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
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
            child: Icon(
              _getStepIcon(_currentStep),
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepperHeader() {
    final steps = ['Basic', 'Industry', 'Skills', 'Details'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: steps.asMap().entries.map((entry) {
          final index = entry.key;
          final label = entry.value;
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;

          return Expanded(
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primary
                        : isCompleted
                            ? Colors.green
                            : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 18)
                      : Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isActive ? Colors.white : Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive ? AppColors.primary : Colors.grey[600],
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Basic Information', Icons.info_rounded),
          _buildTextField(
            controller: _titleController,
            label: 'Career Title *',
            hint: 'e.g., Software Engineer',
            icon: Icons.work_rounded,
            validator: (value) => value?.isEmpty == true ? 'Required' : null,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _descController,
            label: 'Description',
            hint: 'Describe this career path...',
            icon: Icons.description_rounded,
            maxLines: 4,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _salaryController,
            label: 'Salary Range',
            hint: 'e.g., \$60,000 - \$120,000',
            icon: Icons.attach_money_rounded,
          ),
          const SizedBox(height: 32),
          _buildSectionTitle('Media', Icons.photo_library_rounded),
          const SizedBox(height: 16),
          _buildMediaGrid(),
        ],
      ),
    );
  }

  Widget _buildIndustryEducationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Industry & Education', Icons.business_rounded),
          _buildSelectionCard(
            title: 'Industry *',
            value: _selectedIndustryName,
            icon: Icons.business_center_rounded,
            onTap: _showIndustryDialog,
          ),
          const SizedBox(height: 20),
          _buildSelectionCard(
            title: 'Education Paths *',
            value: _selectedEducationNames.isEmpty
                ? null
                : _selectedEducationNames.length == 1
                    ? _selectedEducationNames.first
                    : '${_selectedEducationNames.length} paths selected',
            icon: Icons.school_rounded,
            onTap: _showEducationDialog,
          ),
          if (_selectedEducationNames.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedEducationNames
                  .map((name) => Chip(
                        label: Text(
                          name,
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        deleteIconColor: AppColors.primary,
                        onDeleted: () {
                          final index = _selectedEducationNames.indexOf(name);
                          setState(() {
                            _selectedEducationNames.removeAt(index);
                            _selectedEducationIds.removeAt(index);
                          });
                        },
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSkillsAttributesStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Skills & Attributes', Icons.psychology_rounded),
          _buildSelectionCard(
            title: 'Required Skills',
            value: _selectedSkills.isEmpty
                ? null
                : '${_selectedSkills.length} selected',
            icon: Icons.psychology_rounded,
            onTap: _openSkillManagement,
          ),
          if (_selectedSkills.isNotEmpty) ...[
            const SizedBox(height: 20),
            ..._selectedSkills.map((skill) => _buildSkillLevelRow(skill)),
          ],
          const SizedBox(height: 32),
          _buildSectionTitle('Career Attributes', Icons.tune_rounded),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildAttributeChip('Work Environment', true),
              _buildAttributeChip('Job Outlook', false),
              _buildAttributeChip('Experience Level', false),
              _buildAttributeChip('Work-Life Balance', false),
              _buildAttributeChip('Stress Level', false),
              _buildAttributeChip('Employment Type', true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkillLevelRow(SkillModel skill) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.psychology_rounded,
                color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  skill.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (skill.description.isNotEmpty)
                  Text(
                    skill.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          DropdownButton<String>(
            value: _skillLevels[skill.id] ?? 'Intermediate',
            items: const [
              DropdownMenuItem(value: 'Beginner', child: Text('Beginner')),
              DropdownMenuItem(
                  value: 'Intermediate', child: Text('Intermediate')),
              DropdownMenuItem(value: 'Advanced', child: Text('Advanced')),
              DropdownMenuItem(value: 'Expert', child: Text('Expert')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _skillLevels[skill.id] = value;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCareerDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Career Details', Icons.details_rounded),

          _buildTextField(
            controller: _responsibilitiesController,
            label: 'Key Responsibilities',
            hint: 'One responsibility per line...',
            icon: Icons.checklist_rounded,
            maxLines: 4,
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _entryPositionsController,
                  label: 'Entry Level Positions',
                  hint: 'Junior, Assistant...',
                  icon: Icons.arrow_upward_rounded,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _seniorPositionsController,
                  label: 'Senior Positions',
                  hint: 'Senior, Manager...',
                  icon: Icons.leaderboard_rounded,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),
          _buildSectionTitle('Career Guidance', Icons.lightbulb_rounded),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _streamsController,
            label: 'Recommended Streams',
            hint: 'Science, Commerce, Arts...',
            icon: Icons.school_rounded,
          ),

          const SizedBox(height: 20),

          _buildTextField(
            controller: _cvTipsController,
            label: 'CV Tips',
            hint: 'One tip per line...',
            icon: Icons.article_rounded,
            maxLines: 3,
          ),

          const SizedBox(height: 20),

          _buildTextField(
            controller: _questionsController,
            label: 'Interview Questions',
            hint: 'One question per line...',
            icon: Icons.question_answer_rounded,
            maxLines: 3,
          ),

          const SizedBox(height: 20),

          _buildTextField(
            controller: _bodyLanguageController,
            label: 'Body Language Tips',
            hint: 'One tip per line...',
            icon: Icons.people_rounded,
            maxLines: 3,
          ),

          const SizedBox(height: 20),

          // Mock Interview Videos Section - FIXED
          _buildMockInterviewVideosSection(),
        ],
      ),
    );
  }

  Widget _buildMockInterviewVideosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Mock Interview Videos',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  fontSize: 14,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: _pickMockInterviewVideo,
              icon: Icon(Icons.video_library_rounded),
              label: Text('Browse Video'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          child: TextFormField(
            controller: _mockInterviewVideosController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText:
                  'Paste video URLs here (one per line)\nOr use browse button to upload videos',
              prefixIcon: Icon(Icons.link_rounded, color: AppColors.primary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'You can either upload video files using browse button or paste direct video URLs',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),

        // Show selected videos
        if (_selectedVideos.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Selected Videos:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedVideos.asMap().entries.map((entry) {
              final index = entry.key;
              final video = entry.value;
              return Chip(
                label: Text(
                  _getFileName(video.path),
                  style: TextStyle(fontSize: 12),
                ),
                backgroundColor: AppColors.primary.withOpacity(0.1),
                deleteIconColor: AppColors.primary,
                onDeleted: () {
                  setState(() {
                    _selectedVideos.removeAt(index);
                  });
                },
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
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
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextFormField(
            controller: controller,
            validator: validator,
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

  Widget _buildSelectionCard({
    required String title,
    required String? value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: value != null ? Text(value) : null,
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildAttributeChip(String attribute, bool isMultiSelect) {
    final currentValue = _attributes[_camelCase(attribute)];
    final displayValue = isMultiSelect
        ? (currentValue is List && currentValue.isNotEmpty)
            ? '${currentValue.length} selected'
            : 'Select'
        : currentValue.toString();

    return InkWell(
      onTap: () => _showAttributeDialog(attribute, isMultiSelect),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
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
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.tune_rounded,
                      color: AppColors.primary, size: 16),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    attribute,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              displayValue,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaGrid() {
    final allImages = [
      ..._uploadedImageUrls,
      ..._selectedImages.map((e) => e.path)
    ];
    final allVideos = [
      ..._uploadedVideoUrls,
      ..._selectedVideos.map((e) => e.path)
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMediaButton(
                'Add Images',
                Icons.add_photo_alternate_rounded,
                _pickImages,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMediaButton(
                'Add Videos',
                Icons.video_library_rounded,
                _pickVideos,
              ),
            ),
          ],
        ),
        if (allImages.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text(
            'Selected Images',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: allImages.length,
            itemBuilder: (context, index) {
              final isUploaded = index < _uploadedImageUrls.length;
              final imagePath = allImages[index];
              return _buildMediaThumbnail(
                imagePath,
                true,
                () => _removeImage(index, isUploaded),
              );
            },
          ),
        ],
        if (allVideos.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text(
            'Selected Videos',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: allVideos.length,
            itemBuilder: (context, index) {
              final isUploaded = index < _uploadedVideoUrls.length;
              final videoPath = allVideos[index];
              return _buildMediaThumbnail(
                videoPath,
                false,
                () => _removeVideo(index, isUploaded),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildMediaButton(String text, IconData icon, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // FIXED: Image display for web
  Widget _buildMediaThumbnail(
      String path, bool isImage, VoidCallback onRemove) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: isImage
                ? path.startsWith('http')
                    ? Image.network(
                        path,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(Icons.broken_image_rounded,
                                color: Colors.grey[400]),
                          );
                        },
                      )
                    : kIsWeb
                        ? FutureBuilder<Uint8List>(
                            future: _fileToUint8List(path),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Image.memory(
                                  snapshot.data!,
                                  fit: BoxFit.cover,
                                );
                              } else {
                                return Center(
                                  child: Icon(Icons.photo_rounded,
                                      color: Colors.grey[400]),
                                );
                              }
                            },
                          )
                        : Image.file(File(path), fit: BoxFit.cover)
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_circle_fill_rounded,
                            color: AppColors.primary, size: 32),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            _getFileName(path),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded,
                  color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }

  // Helper function to convert file to Uint8List for web
  Future<Uint8List> _fileToUint8List(String filePath) async {
    if (kIsWeb) {
      final file = XFile(filePath);
      return await file.readAsBytes();
    }
    final file = File(filePath);
    return await file.readAsBytes();
  }

  String _getFileName(String path) {
    final fileName = path.split('/').last;
    // Truncate long file names
    if (fileName.length > 15) {
      return '${fileName.substring(0, 12)}...';
    }
    return fileName;
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _goToPreviousStep,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.darkGrey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Back'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: _currentStep > 0 ? 1 : 2,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _goToNextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(_currentStep == 3 ? 'Save Career' : 'Continue'),
            ),
          ),
        ],
      ),
    );
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToNextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _saveCareer();
    }
  }

  String _getStepDescription(int step) {
    switch (step) {
      case 0:
        return 'Add basic career information and media';
      case 1:
        return 'Select industry and education requirements';
      case 2:
        return 'Define skills and career attributes';
      case 3:
        return 'Add career progression and guidance tools';
      default:
        return 'Complete career setup';
    }
  }

  IconData _getStepIcon(int step) {
    switch (step) {
      case 0:
        return Icons.info_rounded;
      case 1:
        return Icons.business_rounded;
      case 2:
        return Icons.psychology_rounded;
      case 3:
        return Icons.details_rounded;
      default:
        return Icons.work_rounded;
    }
  }
}
