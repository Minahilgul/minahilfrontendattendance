import 'package:flutter/material.dart';
import 'add_student_screen.dart';
import 'add_teacher_screen.dart';
import 'teacher_directory_screen.dart';
import 'view_attendance_screen.dart';
import 'classes_screen.dart';
import 'pending_approvals_screen.dart';
import 'admin_report_screen.dart';
import 'package:get/get.dart';
import '../widgets/base_scaffold.dart'; 
import '../widgets/dashboard_card.dart';
import '../core/theme/app_colors.dart';

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
                  DashboardCard(
                    title: 'Pending Approvals',
                    iconData: Icons.group_outlined,
                     type: DashboardCardType.warning,
                    onTap: () {
                      Get.toNamed('/approvals');
                    },
                  ),
                  DashboardCard(
                    title: 'Reports & Audit',
                    iconData: Icons.description_outlined,
                    type: DashboardCardType.purple,
                    onTap: () {
                      Get.toNamed('/reports');
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
