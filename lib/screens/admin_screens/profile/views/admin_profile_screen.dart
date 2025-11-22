import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'admin_edit_profile_screen.dart';
import 'package:aspire_edge/routes/route_constants.dart';
import 'package:aspire_edge/models/user_model.dart';
import 'package:aspire_edge/theme/app_theme.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen(
      {super.key, required String userId, required String userName});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  File? profileImage;
  String fullName = "";
  String email = "";
  String? phone;
  String? tier;
  String role = "";
  String? profilePic;
  DateTime? createdAt;
  bool isActive = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .get();

        if (snapshot.exists) {
          final userModel = UserModel.fromDoc(snapshot);
          setState(() {
            fullName = userModel.name;
            email = userModel.email;
            phone = userModel.phone;
            tier = userModel.tier;
            role = userModel.role;
            profilePic = userModel.profilePic;
            createdAt = userModel.createdAt;
            isActive = userModel.isActive;
            _loading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading user data: $e");
      setState(() => _loading = false);
    }
  }



  Widget _buildActionTile(String title, String subtitle, IconData icon,
      Color color, VoidCallback onTap) {
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
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.darkGrey,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.grey,
            fontSize: 12,
          ),
        ),
        trailing: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: AppColors.primary,
          ),
        ),
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
          "Profile Overview",
          style:  TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: AppColors.black,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final updatedData = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AdminEditProfileScreen(
                    profileImage: profileImage,
                    fullName: fullName,
                    email: email,
                    phone: phone ?? "",
                    tier: tier,
                  ),
                ),
              );
              if (updatedData != null) {
                setState(() {
                  profileImage = updatedData["profileImage"];
                  fullName = updatedData["fullName"];
                  email = updatedData["email"];
                  phone = updatedData["phone"];
                  tier = updatedData["tier"];
                  profilePic = updatedData["profilePic"] ?? profilePic;
                });
              }
            },
            icon: const Icon(Icons.edit_rounded, color: AppColors.primary),
          )
        ],
      ),
      body: _loading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
                      backgroundColor: AppColors.primary.withOpacity(0.2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Loading Profile...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.darkGrey,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile Header Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.8),
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
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 4),
                              ),
                              child: CircleAvatar(
                                radius: 48,
                                backgroundColor: Colors.white.withOpacity(0.2),
                                backgroundImage: profileImage != null
                                    ? FileImage(profileImage!)
                                    : (profilePic != null &&
                                                profilePic!.isNotEmpty
                                            ? NetworkImage(profilePic!)
                                            : const AssetImage(
                                                "assets/images/profile.png"))
                                        as ImageProvider,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () async {
                                  final updatedData = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AdminEditProfileScreen(
                                        profileImage: profileImage,
                                        fullName: fullName,
                                        email: email,
                                        phone: phone ?? "",
                                        tier: tier,
                                      ),
                                    ),
                                  );
                                  if (updatedData != null) {
                                    setState(() {
                                      profileImage =
                                          updatedData["profileImage"];
                                      fullName = updatedData["fullName"];
                                      email = updatedData["email"];
                                      phone = updatedData["phone"];
                                      tier = updatedData["tier"];
                                      profilePic = updatedData["profilePic"] ??
                                          profilePic;
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: AppColors.primary, width: 2),
                                  ),
                                  child: Icon(
                                    Icons.camera_alt_rounded,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          fullName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                role.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Actions Card
                  Container(
                    padding: const EdgeInsets.all(20),
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
                          'Account Settings',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildActionTile(
                          "Edit Profile",
                          "Update your personal information",
                          Icons.person_rounded,
                          AppColors.primary,
                          () async {
                            final updatedData = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AdminEditProfileScreen(
                                  profileImage: profileImage,
                                  fullName: fullName,
                                  email: email,
                                  phone: phone ?? "",
                                  tier: tier,
                                ),
                              ),
                            );
                            if (updatedData != null) {
                              setState(() {
                                profileImage = updatedData["profileImage"];
                                fullName = updatedData["fullName"];
                                email = updatedData["email"];
                                phone = updatedData["phone"];
                                tier = updatedData["tier"];
                                profilePic =
                                    updatedData["profilePic"] ?? profilePic;
                              });
                            }
                          },
                        ),
                        _buildActionTile(
                          "Change Password",
                          "Secure your account with new password",
                          Icons.lock_rounded,
                          AppColors.secondary,
                          () {
                            Navigator.pushNamed(
                                context, chooseVerificationMethodScreenRoute);
                          },
                        ),
                        _buildActionTile(
                          "Notification Settings",
                          "Manage your notification preferences",
                          Icons.notifications_rounded,
                          AppColors.info,
                          () {},
                        ),
                        _buildActionTile(
                          "Privacy & Security",
                          "Control your privacy settings",
                          Icons.security_rounded,
                          AppColors.warning,
                          () {},
                        ),
                        _buildActionTile(
                          "Help & Support",
                          "Get help and contact support",
                          Icons.help_rounded,
                          AppColors.success,
                          () {},
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
