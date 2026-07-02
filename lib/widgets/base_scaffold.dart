import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../core/theme/app_colors.dart';

class BaseScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? bottomNav;
  final Widget? floatingActionButton;
  final String role;
  
  final Function(int)? onDrawerNavTap;
  
  final String? displayName;

  const BaseScaffold({
    super.key,
    required this.title,
    required this.body,
    required this.role,
    this.actions,
    this.bottomNav,
    this.floatingActionButton,
    this.onDrawerNavTap,
    this.displayName,
  });

  @override
  Widget build(BuildContext context) {
    // Drawer header label — use displayName if provided, else role label
    final String headerLabel = displayName?.isNotEmpty == true
        ? displayName!
        : role == 'admin'
            ? 'Administrator'
            : role == 'teacher'
                ? 'Teacher'
                : 'Student';

    
    String initials = '';
    if (displayName != null && displayName!.trim().isNotEmpty) {
      final parts = displayName!.trim().split(' ');
      initials = parts.length >= 2
          ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
          : parts[0][0].toUpperCase();
    }

    return Scaffold(
       backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.w800, fontSize: 20, color: Colors.white)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: actions,
      ),
      drawer: Drawer(
        backgroundColor: AppColors.surface,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [ AppColors.primary,
  AppColors.primaryDark,
                    ],
              ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white.withOpacity(0.25),
                    child: initials.isNotEmpty
                        ? Text(initials,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20))
                        : const Icon(Icons.admin_panel_settings,
                            color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  //  Shows actual name if displayName is passed, else role label
                  Text(headerLabel,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  // Sub-label: role badge below name
                  if (displayName?.isNotEmpty == true)
                    Text(
                      role == 'admin'
                          ? 'Administrator'
                          : role == 'teacher'
                              ? 'Teacher'
                              : 'Student',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.75), fontSize: 12),
                    ),
                ],
              ),
            ),

            //  Admin items 
            if (role == 'admin') ...[
              ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Dashboard'),
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed('/admin-dashboard');
                  }),
              ListTile(
                  leading: const Icon(Icons.people),
                  title: const Text('Teacher Directory'),
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed('/teacher-directory');
                  }),
              ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Student Directory'),
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed('/student-directory');
                  }),
              ListTile(
                  leading: const Icon(Icons.class_),
                  title: const Text('Manage Classes'),
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed('/classes');
                  }),
              ListTile(
                  leading: const Icon(Icons.pending_actions),
                  title: const Text('Pending Approvals'),
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed('/approvals');
                  }),
              ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('System Settings'),
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed('/settings');
                  }),
            ],

            // Teacher items 
            if (role == 'teacher') ...[
              ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Dashboard'),
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed('/teacher-dashboard');
                  }),
              ListTile(
                  leading: const Icon(Icons.class_),
                  title: const Text('My Classes'),
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed('/classes');
                  }),
              ListTile(
                  leading: const Icon(Icons.checklist),
                  title: const Text('Attendance'),
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed('/mark-attendance');
                  }),
              ListTile(
                leading: const Icon(Icons.person_outline,
                    color: AppColors.success),
                title: const Text('Student Directory'),
                onTap: () {
                  Navigator.pop(context);
                  Get.toNamed('/student-directory');
                },
              ),
            ],

            //  Student items
            if (role == 'student') ...[
              ListTile(
                leading: const Icon(Icons.home_rounded),
                title: const Text('Home'),
                onTap: () {
                  Navigator.pop(context);
                  onDrawerNavTap?.call(0);
                },
              ),
              ListTile(
                leading: const Icon(Icons.bar_chart_rounded),
                title: const Text('Reports'),
                onTap: () {
                  Navigator.pop(context);
                  onDrawerNavTap?.call(1);
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications_rounded),
                title: const Text('Notifications'),
                onTap: () {
                  Navigator.pop(context);
                  onDrawerNavTap?.call(2);
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_rounded),
                title: const Text('Profile'),
                onTap: () {
                  Navigator.pop(context);
                  onDrawerNavTap?.call(3);
                },
              ),
            ],

            const Divider(),

            // Profile / Reports / Alerts — admin & teacher only
            if (role != 'student') ...[
              ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Profile'),
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed('/admin-profile');
                  }),
              ListTile(
                  leading: const Icon(Icons.bar_chart),
                  title: const Text('Reports'),
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed('/reports');
                  }),
            ],

            // Logout — always shown
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.danger),
              title: const Text('Logout',
                  style: TextStyle(color: AppColors.danger)),
              onTap: () async {
                final storage = GetStorage();
                await storage.erase();
                if (context.mounted) {
                  Navigator.pop(context);
                  Get.offAllNamed('/login');
                }
              },
            ),
          ],
        ),
      ),
      body: body,
      bottomNavigationBar: bottomNav,
      floatingActionButton: floatingActionButton,
    );
  }
}