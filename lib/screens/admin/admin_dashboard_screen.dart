import 'dart:async';
import 'package:flutter/material.dart';
import 'add_student_screen.dart';
import 'add_teacher_screen.dart';
import '../teacher_directory_screen.dart';
import '../view_attendance_screen.dart';
import 'classes_screen.dart';
import 'pending_approvals_screen.dart';
import 'admin_report_screen.dart';
import 'package:get/get.dart';
import '../../widgets/base_scaffold.dart'; 
import '../../widgets/dashboard_card.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/confirmation_service.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminDashboard();
  }
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
 
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  Timer? _confirmationPoller;

  @override
  void initState() {
    super.initState();
    _startConfirmationPoller();
  }

  @override
  void dispose() {
    _confirmationPoller?.cancel();
    super.dispose();
  }

  void _startConfirmationPoller() {
    _confirmationPoller?.cancel();
    final int? adminId = AuthService.currentUser?['id'] is int
        ? AuthService.currentUser!['id'] as int
        : int.tryParse(AuthService.currentUser?['id']?.toString() ?? '');
    
    if (adminId == null) return;

    _confirmationPoller = Timer.periodic(
      const Duration(seconds: 15),
      (timer) async {
        if (!mounted) return;
        final result = await ConfirmationService.getPending(adminId);
        if (result['success'] == true && result['pending'] == true && mounted) {
          _confirmationPoller?.cancel(); // pause polling
          await _showConfirmationDialog(
            result['request_id'] is int ? result['request_id'] : int.parse(result['request_id'].toString()),
            result['session_id'] is int ? result['session_id'] : int.parse(result['session_id'].toString()),
            result['message'] ?? 'Please confirm if the teacher is present.',
            adminId,
          );
          _startConfirmationPoller(); // resume polling
        }
      },
    );
  }

  Future<void> _showConfirmationDialog(int requestId, int sessionId, String message, int adminId) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.shield_outlined, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text('Admin Attendance Verification',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Your response will set the attendance presence verdict.',
              style: TextStyle(fontSize: 11, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          // NO
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger.withOpacity(0.1),
              foregroundColor: AppColors.danger,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.close_rounded, size: 18),
            label: const Text('NO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            onPressed: () async {
              await _submitResponse(requestId, 'no', adminId);
              if (mounted) Navigator.pop(context);
            },
          ),
          // YES
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.check_rounded, size: 18),
            label: const Text('YES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            onPressed: () async {
              await _submitResponse(requestId, 'yes', adminId);
              if (mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _submitResponse(int requestId, String response, int adminId) async {
    final result = await ConfirmationService.submitResponse(
      requestId: requestId,
      studentId: adminId,
      response: response,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['success'] == true
              ? 'Response submitted: ${response.toUpperCase()} ✓'
              : result['message'] ?? 'Failed to submit'),
          backgroundColor: result['success'] == true ? AppColors.success : AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Attendance Verification', 
      role: 'admin',
      
      bottomNav: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
  unselectedItemColor: AppColors.textSecondary,
  backgroundColor: AppColors.surface,
  showUnselectedLabels: true,
  elevation: 8,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          switch (index) {
            case 0:
              break;
            case 1:
              Get.toNamed('/classes');
              break;
            case 2:
              Get.toNamed('/reports');
              break;
            case 3:
              Get.toNamed('/admin-profile');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.class_), label: 'Manage Classes'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'View Reports'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      
        
          
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  DashboardCard(
                    title: 'Manage Classes',
                    iconData: Icons.grid_view_rounded,
                    type: DashboardCardType.primary,
                    onTap: () {
                      Get.toNamed('/classes');
                    },
                  ),
                  DashboardCard(
                    title: 'Teacher Directory',
                    iconData: Icons.shield_outlined,
                    type: DashboardCardType.success,
                    onTap: () {
                      Get.toNamed('/teacher-directory');
                    },
                  ),
                  // ── UPDATED: "Pending Approvals" replaced with "Student Directory" ──
                  DashboardCard(
                    title: 'Student Directory',
                    iconData: Icons.people_alt_outlined,
                    type: DashboardCardType.warning,
                    onTap: () {
                      Get.toNamed('/student-directory');
                    },
                  ),
                  // ── UPDATED: "Reports & Audit" replaced with "Pending Approvals" ──
                  // Reports & Audit is still reachable via the bottom navigation bar
                  // ("View Reports"), so it doesn't need its own dashboard card too.
                  DashboardCard(
                    title: 'Pending Approvals',
                    iconData: Icons.pending_actions_outlined,
                    type: DashboardCardType.purple,
                    onTap: () {
                      Get.toNamed('/approvals');
                    },
                  ),
                ],
              ),
            ),
    );
  }
}