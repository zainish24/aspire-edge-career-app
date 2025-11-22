import 'package:flutter/material.dart';
import 'package:aspire_edge/constants.dart';
import 'package:aspire_edge/models/user_model.dart';
import 'package:aspire_edge/routes/screen_export.dart';
import '/services/user_service.dart';
import 'components/user_card.dart';
import 'package:aspire_edge/components/custom_dialog.dart';

class AdminUserListScreen extends StatefulWidget {
  const AdminUserListScreen({super.key});

  @override
  State<AdminUserListScreen> createState() => _AdminUserListScreenState();
}

class _AdminUserListScreenState extends State<AdminUserListScreen> {
  final UserService _svc = UserService();
  String? currentUserRole;
  String _currentView =
      'students'; // 'students', 'graduates', 'professionals', 'admins'
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRole() async {
    final r = await _svc.getCurrentUserRole();
    setState(() => currentUserRole = r);
  }

  void _setView(String view) {
    setState(() => _currentView = view);
  }

  Stream<List<UserModel>> _getCurrentStream() {
    switch (_currentView) {
      case 'admins':
        return _svc.streamAdmins();
      case 'students':
        return _svc.streamStudents();
      case 'graduates':
        return _svc.streamGraduates();
      case 'professionals':
        return _svc.streamProfessionals();
      default:
        return _svc.streamStudents();
    }
  }

  String _getViewTitle() {
    switch (_currentView) {
      case 'admins':
        return 'Admins';
      case 'students':
        return 'Students';
      case 'graduates':
        return 'Graduates';
      case 'professionals':
        return 'Professionals';
      default:
        return 'Users';
    }
  }

  String _getViewSubtitle() {
    switch (_currentView) {
      case 'admins':
        return 'Manage system administrators';
      case 'students':
        return 'Active students and learners';
      case 'graduates':
        return 'Recent graduates and alumni';
      case 'professionals':
        return 'Working professionals';
      default:
        return 'User management';
    }
  }

  IconData _getViewIcon() {
    switch (_currentView) {
      case 'admins':
        return Icons.admin_panel_settings_rounded;
      case 'students':
        return Icons.school_rounded;
      case 'graduates':
        return Icons.celebration_rounded;
      case 'professionals':
        return Icons.work_rounded;
      default:
        return Icons.people_rounded;
    }
  }

  Color _getViewColor() {
    switch (_currentView) {
      case 'admins':
        return AppColors.primary;
      case 'students':
        return Colors.blue;
      case 'graduates':
        return Colors.green;
      case 'professionals':
        return Colors.orange;
      default:
        return AppColors.primary;
    }
  }

  // NEW: Add Admin Action Button (similar to quiz screen)
  Widget _buildAddAdminAction() {
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
              icon: Icons.person_add_rounded,
              title: "Add Admin",
              subtitle: "Register new administrator",
              color: AppColors.primary,
              onTap: () => Navigator.pushNamed(context, adminUserAddScreenRoute),
            ),
          ),
        ],
      ),
    );
  }

  // NEW: Action Button Builder (similar to quiz screen)
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
    return StreamBuilder<List<UserModel>>(
      stream: _getCurrentStream(),
      builder: (context, snapshot) {
        final userCount = snapshot.data?.length ?? 0;

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getViewColor(),
                _getViewColor().withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _getViewColor().withOpacity(0.3),
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
                      _getViewTitle(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getViewSubtitle(),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "$userCount Users",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
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
                child: Icon(
                  _getViewIcon(),
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildViewSelector() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'User Categories',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildViewButton(
                  title: 'Students',
                  icon: Icons.school_rounded,
                  isActive: _currentView == 'students',
                  color: Colors.blue,
                  onTap: () => _setView('students'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildViewButton(
                  title: 'Graduates',
                  icon: Icons.celebration_rounded,
                  isActive: _currentView == 'graduates',
                  color: Colors.green,
                  onTap: () => _setView('graduates'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildViewButton(
                  title: 'Professionals',
                  icon: Icons.work_rounded,
                  isActive: _currentView == 'professionals',
                  color: Colors.orange,
                  onTap: () => _setView('professionals'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildViewButton(
                  title: 'Admins',
                  icon: Icons.admin_panel_settings_rounded,
                  isActive: _currentView == 'admins',
                  color: AppColors.primary,
                  onTap: () => _setView('admins'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildViewButton({
    required String title,
    required IconData icon,
    required bool isActive,
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
            color: isActive ? color : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? color : Colors.grey[300]!,
              width: isActive ? 2 : 1,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isActive ? Colors.white : color,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : color,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
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
                      hintText: "Search users by name, email, or role...",
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

  Widget _buildUserStats() {
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
      child: StreamBuilder<List<UserModel>>(
        stream: _getCurrentStream(),
        builder: (context, snapshot) {
          final users = snapshot.data ?? [];
          final activeUsers = users.where((user) => user.isActive).length;

          return Row(
            children: [
              _buildStatItem(
                'Total Users',
                users.length.toString(),
                Icons.people_rounded,
                _getViewColor(),
              ),
              const SizedBox(width: 12),
              _buildStatItem(
                'Active',
                activeUsers.toString(),
                Icons.check_circle_rounded,
                AppColors.success,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatItem(
      String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.darkGrey,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
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
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _getViewColor().withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getViewIcon(),
              color: _getViewColor(),
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _searchQuery.isEmpty
                ? "No ${_getViewTitle()} Available"
                : "No Users Found",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? "There are no ${_getViewTitle().toLowerCase()} in the system"
                : "Try adjusting your search terms",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.darkGrey,
              fontSize: 14,
            ),
          ),
        ],
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
              valueColor: AlwaysStoppedAnimation<Color>(_getViewColor()),
              backgroundColor: _getViewColor().withOpacity(0.2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Loading ${_getViewTitle()}...',
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

  List<UserModel> _filterUsers(List<UserModel> users) {
    if (_searchQuery.isEmpty) {
      return users;
    }
    return users.where((user) {
      return user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.role.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final canAddAdmin = currentUserRole == 'admin' && _currentView == 'admins';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "User Management",
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: AppColors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {});
            },
            icon: Icon(Icons.refresh_rounded, color: AppColors.primary),
            tooltip: "Refresh",
          ),
        ],
      ),
      // REMOVED: Floating Action Button
      body: Column(
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
                  // View Selector
                  _buildViewSelector(),

                  const SizedBox(height: 16),

                  // NEW: Add Admin Action Button (shown only when appropriate)
                  if (canAddAdmin) _buildAddAdminAction(),

                  const SizedBox(height: 16),

                  // User Statistics
                  _buildUserStats(),

                  const SizedBox(height: 16),

                  // Search Section
                  _buildSearchSection(),

                  const SizedBox(height: 20),

                  // User List
                  StreamBuilder<List<UserModel>>(
                    stream: _getCurrentStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildLoadingState();
                      }

                      if (snapshot.hasError) {
                        return Container(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                color: AppColors.error,
                                size: 60,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Error Loading Users',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.black,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final users = snapshot.data ?? [];
                      final filteredUsers = _filterUsers(users);

                      if (filteredUsers.isEmpty) {
                        return _buildEmptyState();
                      }

                      return Column(
                        children: [
                          // List Header
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _getViewTitle(),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.black,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _getViewColor().withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "${filteredUsers.length} users",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _getViewColor(),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // User List
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredUsers.length,
                            itemBuilder: (context, index) {
                              final user = filteredUsers[index];
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
                                child: UserCard(
                                  user: user,
                                  onView: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AdminUserDetailScreen(),
                                        settings: RouteSettings(
                                          arguments: {
                                            'user': user,
                                            'isCurrentAdminView':
                                                _currentView == 'admins',
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                  onEdit: (_currentView == 'admins' &&
                                          currentUserRole == 'admin')
                                      ? () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  AdminUserEditScreen(),
                                              settings: RouteSettings(
                                                arguments:
                                                    user, // Pass user directly
                                              ),
                                            ),
                                          )
                                      : null,
                                  onDelete: _currentView == 'admins'
                                      ? () async {
                                          await _svc.logoutUser(user.userId);
                                          CustomDialog.show(context,
                                              message: "User logged out",
                                              isError: false);
                                        }
                                      : null,
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}