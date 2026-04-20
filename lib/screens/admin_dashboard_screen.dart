import 'package:flutter/material.dart';
import 'add_student_screen.dart';
import 'add_teacher_screen.dart'; 
import 'profile_screen.dart' as profile;
import 'view_attendance_screen.dart';

class AdminDashboardScreen extends StatefulWidget{
  const AdminDashboardScreen({super.key});


@override
State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();}


class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;

 final List<Widget> screens = [
  const AdminDashboardScreen(),
  const AddTeacherScreen(),
  const ViewAttendanceScreen(),
  const profile.ProfileScreen(),
];


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF2F4F7),
      ),
      home: const AdminDashboard(),
    );
  }
}

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header with gradient
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFF2979FF), // Blue
                  Color(0xFF00BFA5), // Teal/Green
                ],
              ),
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 24,
              bottom: 28,
              left: 24,
              right: 24,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Welcome back, Administrator',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),

          // Grid of dashboard cards
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: const [
                  DashboardCard(
                    title: 'Manage Classes',
                    iconData: Icons.grid_view_rounded,
                    iconBgColor: Color(0xFF2979FF),
                  ),
                  DashboardCard(
                    title: 'Teacher Directory',
                    iconData: Icons.shield_outlined,
                    iconBgColor: Color(0xFF00BFA5),
                  ),
                  DashboardCard(
                    title: 'Pending Approvals',
                    iconData: Icons.group_outlined,
                    iconBgColor: Color(0xFF00BFA5),
                  ),
                  DashboardCard(
                    title: 'Reports & Audit',
                    iconData: Icons.description_outlined,
                    iconBgColor: Color(0xFF9C27B0),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // Floating help button
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF37474F),
        mini: true,
        child: const Icon(Icons.question_mark, color: Colors.white, size: 18),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final IconData iconData;
  final Color iconBgColor;

  const DashboardCard({
    super.key,
    required this.title,
    required this.iconData,
    required this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon container
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

              // Title
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}