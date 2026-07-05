import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../core/theme/app_colors.dart';
import '../core/services/auth_service.dart';
import '../core/services/session_service.dart';
import '../core/services/confirmation_service.dart';

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

  Future<int?> _findActiveSessionId() async {
    final int? teacherId = AuthService.currentUser?['id'] is int
        ? AuthService.currentUser!['id'] as int
        : int.tryParse(AuthService.currentUser?['id']?.toString() ?? '');

    if (teacherId == null) return null;

    final result = await SessionService.getActiveSession(teacherId);
    if (result['success'] == true &&
        result['active'] == true &&
        result['data'] != null) {
      return result['data']['id'] is int
          ? result['data']['id']
          : int.tryParse(result['data']['id'].toString());
    }
    return null;
  }

  // Finds the teacher's currently active session, then shows the
  // confirmation directory (who said yes/no/pending) for it. Works from
  // any screen — the teacher doesn't need to be on the dashboard.
  Future<void> _showResponseDirectory(BuildContext context) async {
    Navigator.pop(context); // close drawer first

    final sessionId = await _findActiveSessionId();
    if (sessionId == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No active session. Start a session first.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final result = await ConfirmationService.getDirectory(sessionId);
    if (!context.mounted) return;
    Navigator.pop(context); // close loading spinner

    if (result['success'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Failed to load directory')),
      );
      return;
    }

    final List<dynamic> students = result['data'] ?? [];

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.how_to_reg_rounded, color: Colors.white),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Confirmation Directory',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 18),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _directoryChip('✅ YES', result['yes_count'] ?? 0, AppColors.success),
                    _directoryChip('❌ NO', result['no_count'] ?? 0, AppColors.danger),
                    _directoryChip('⏳ Pending', result['pending_count'] ?? 0, AppColors.warning),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      result['verdict'] ?? 'Awaiting responses',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: students.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'No students found',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: students.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, indent: 16),
                        itemBuilder: (_, i) {
                          final s = students[i];
                          final resp = s['response'] as String;
                          final respColor = resp == 'yes'
                              ? AppColors.success
                              : resp == 'no'
                                  ? AppColors.danger
                                  : AppColors.warning;
                          final respIcon = resp == 'yes'
                              ? Icons.check_circle_rounded
                              : resp == 'no'
                                  ? Icons.cancel_rounded
                                  : Icons.hourglass_empty_rounded;

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: respColor.withOpacity(0.12),
                              child: Text(
                                (s['student_name'] as String)
                                    .substring(0, 1)
                                    .toUpperCase(),
                                style: TextStyle(
                                  color: respColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              s['student_name'] ?? '-',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            subtitle: Text(
                              'Roll: ${s['roll_no'] ?? '-'}  •  ${s['responded_at']}',
                              style: const TextStyle(fontSize: 11),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(respIcon, color: respColor, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  resp.toUpperCase(),
                                  style: TextStyle(
                                    color: respColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showResponseDirectory(context);
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('Refresh'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _directoryChip(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        Text(label, style: TextStyle(color: color, fontSize: 11)),
      ],
    );
  }

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
                  leading: const Icon(Icons.bar_chart_rounded),
                  title: const Text('Reports'),
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed('/teacher-report');
                  }),
              ListTile(
                leading: const Icon(Icons.how_to_reg_rounded,
                    color: AppColors.success),
                title: const Text('View Responses'),
                // Same active-session lookup as Attendance: finds the
                // teacher's active session first, then shows the
                // confirmation directory for it.
                onTap: () => _showResponseDirectory(context),
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
              // Admin's own Reports & Audit Logs screen. Teacher already
              // has a dedicated "Reports" item above pointing at
              // '/teacher-report', so this one is admin-only to avoid
              // a duplicate/broken entry for teachers.
              if (role == 'admin')
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