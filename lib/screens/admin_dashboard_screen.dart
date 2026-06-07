import 'package:flutter/material.dart';
import 'add_student_screen.dart';
import 'add_teacher_screen.dart';
import 'teacher_directory_screen.dart';
import 'profile_screen.dart' as profile;
import 'view_attendance_screen.dart';
import 'classes_screen.dart';
import 'pending_approvals_screen.dart';
import 'reports_screen.dart';
import 'package:go_router/go_router.dart';
import '../widgets/base_scaffold.dart'; 

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
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF37474F),
        mini: true,
        child: const Icon(Icons.help_outline, color: Colors.white, size: 18),
      ),
      bottomNav: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          switch (index) {
            case 0:
              break;
            case 1:
              context.push('/classes');
              break;
            case 2:
              context.push('/reports');
              break;
            case 3:
              context.push('/profile');
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
      body: Column(
        children: [
          Expanded(
            child: Padding(
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
                    iconBgColor: const Color(0xFF2979FF),
                    onTap: () {
                      context.push('/classes');
                    },
                  ),
                  DashboardCard(
                    title: 'Teacher Directory',
                    iconData: Icons.shield_outlined,
                    iconBgColor: const Color(0xFF00BFA5),
                    onTap: () {
                      context.push('/teachers');
                    },
                  ),
                  DashboardCard(
                    title: 'Pending Approvals',
                    iconData: Icons.group_outlined,
                    iconBgColor: Color(0xFF00BFA5),
                    onTap: () {
                      context.push('/pending');
                    },
                  ),
                  DashboardCard(
                    title: 'Reports & Audit',
                    iconData: Icons.description_outlined,
                    iconBgColor: Color(0xFF9C27B0),
                    onTap: () {
                      context.push('/reports');
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

class DashboardCard extends StatelessWidget {
  final String title;
  final IconData iconData;
  final Color iconBgColor;
  final VoidCallback? onTap;

  const DashboardCard({
    super.key,
    required this.title,
    required this.iconData,
    required this.iconBgColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  iconData,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}