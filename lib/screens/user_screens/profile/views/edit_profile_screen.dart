// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:aspire_edge/components/custom_dialog.dart';
import 'package:aspire_edge/theme/app_theme.dart';
import 'package:aspire_edge/config_example.dart';

class EditProfileScreen extends StatefulWidget {
  final File? profileImage;
  final String? profilePic; // Add this to receive existing profile pic URL
  final String fullName;
  final String email;
  final String phone;
  final String? tier;

  const EditProfileScreen({
    super.key,
    this.profileImage,
    this.profilePic, // Add this parameter
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.tier,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  File? selectedImage;
  XFile? selectedXFile;
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  String? selectedTier;
  bool _saving = false;
  String? existingProfilePic; // Store the existing profile pic URL

  @override
  void initState() {
    super.initState();
    selectedImage = widget.profileImage;
    existingProfilePic = widget.profilePic; // Store the existing URL
    nameController = TextEditingController(text: widget.fullName);
    phoneController = TextEditingController(text: widget.phone);
    emailController = TextEditingController(text: widget.email);
    selectedTier = widget.tier;
  }

  bool _isWeb() => identical(0, 0.0);

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedXFile = pickedFile;
        if (!_isWeb()) {
          selectedImage = File(pickedFile.path);
        }
        // Clear existing profile pic when new image is selected
        existingProfilePic = null;
      });
    }
  }

  Future<String?> _uploadImageToCloudinary(dynamic imageFile) async {
    final String cloudName = CloudinaryConfig.cloudName;
    final String uploadPreset = CloudinaryConfig.uploadPreset;
    final uploadUrl = "https://api.cloudinary.com/v1_1/$cloudName/image/upload";

    try {
      FormData formData;

      if (_isWeb()) {
        formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(
            imageFile.path,
            filename: 'profile_image.jpg',
          ),
          'upload_preset': uploadPreset,
        });
      } else {
        formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(imageFile.path),
          'upload_preset': uploadPreset,
        });
      }

      final response = await Dio().post(uploadUrl, data: formData);
      if (response.statusCode == 200) {
        return response.data["secure_url"];
      }
    } catch (e) {
      debugPrint("Image upload error: $e");
      if (_isWeb()) {
        return await _uploadImageAlternative(imageFile);
      }
    }
    return null;
  }

  Future<String?> _uploadImageAlternative(XFile imageFile) async {
    try {
      final String cloudName = CloudinaryConfig.cloudName;
      final String uploadPreset = CloudinaryConfig.uploadPreset;
      final uploadUrl =
          "https://api.cloudinary.com/v1_1/$cloudName/image/upload";

      final bytes = await imageFile.readAsBytes();
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: 'profile_image.jpg'),
        'upload_preset': uploadPreset,
      });

      final response = await Dio().post(uploadUrl, data: formData);
      if (response.statusCode == 200) {
        return response.data["secure_url"];
      }
    } catch (e) {
      debugPrint("Alternative upload error: $e");
    }
    return null;
  }

  // Updated image provider to handle all cases
  ImageProvider<Object> _getImageProvider() {
    // First priority: Newly selected image (web)
    if (_isWeb() && selectedXFile != null) {
      return NetworkImage(selectedXFile!.path);
    }
    // Second priority: Newly selected image (mobile)
    else if (!_isWeb() && selectedImage != null) {
      return FileImage(selectedImage!);
    }
    // Third priority: Existing profile picture from Firestore
    else if (existingProfilePic != null && existingProfilePic!.isNotEmpty) {
      return NetworkImage(existingProfilePic!);
    }
    // Fallback: Default asset image
    else {
      return const AssetImage("assets/images/profile.png");
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      String? imageUrl;

      // Upload new image if selected
      if (_isWeb() && selectedXFile != null) {
        imageUrl = await _uploadImageToCloudinary(selectedXFile!);
      } else if (!_isWeb() && selectedImage != null) {
        imageUrl = await _uploadImageToCloudinary(selectedImage!);
      }

      final updatedData = {
        "name": nameController.text,
        "email": emailController.text,
        "phone": phoneController.text.isEmpty ? null : phoneController.text,
        "tier": selectedTier,
        if (imageUrl != null) "profilePic": imageUrl,
      };

      updatedData.removeWhere((key, value) => value == null);

      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .update(updatedData);

      final resultData = {
        "fullName": nameController.text,
        "email": emailController.text,
        "phone": phoneController.text.isEmpty ? null : phoneController.text,
        "tier": selectedTier,
        "profilePic":
            imageUrl ?? existingProfilePic, // Return existing if no new upload
      };

      if (!_isWeb()) {
        resultData["profileImage"] = selectedImage as String?;
      }

      Navigator.pop(context, resultData);
    } catch (e) {
      debugPrint("Error saving profile: $e");
      CustomDialog.show(context,
          message: "Failed to update profile", isError: true);
    } finally {
      setState(() => _saving = false);
    }
  }

  Widget _buildInputField(
      String label, IconData icon, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text, bool required = true}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.darkGrey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: required
                ? (value) => value == null || value.isEmpty
                    ? "Please enter $label"
                    : null
                : null,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[50],
              prefixIcon: Icon(icon, color: AppColors.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.error),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.error, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierDropdown() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Education Level",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.darkGrey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: selectedTier,
            items: const [
              DropdownMenuItem(
                  value: null, child: Text("Select Education Level")),
              DropdownMenuItem(value: "student", child: Text("Student")),
              DropdownMenuItem(value: "graduate", child: Text("Graduate")),
              DropdownMenuItem(
                  value: "professional", child: Text("Professional")),
            ],
            onChanged: (value) {
              setState(() {
                selectedTier = value;
              });
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[50],
              prefixIcon: Icon(Icons.school_rounded, color: AppColors.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.black),
        title: const Text(
          "Edit Profile",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: AppColors.black,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: _saving ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              icon: _saving
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.check_rounded, size: 18),
              label: Text(
                _saving ? "Saving..." : "Save",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Profile Image Section
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
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
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppColors.primary, width: 4),
                              ),
                              child: CircleAvatar(
                                radius: 58,
                                backgroundColor:
                                    AppColors.primary.withOpacity(0.1),
                                backgroundImage: _getImageProvider(),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 3),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_rounded,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Update Profile Photo",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Tap the camera icon to change your photo",
                          style: TextStyle(
                            color: AppColors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Form Section
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
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
                        const Text(
                          'Personal Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Update your account details',
                          style: TextStyle(
                            color: AppColors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildInputField(
                            "Full Name", Icons.person_rounded, nameController),
                        _buildInputField("Email Address", Icons.email_rounded,
                            emailController,
                            keyboardType: TextInputType.emailAddress),
                        _buildInputField("Phone Number", Icons.phone_rounded,
                            phoneController,
                            keyboardType: TextInputType.phone, required: false),
                        _buildTierDropdown(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
