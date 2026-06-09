import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BaseScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? bottomNav;
  final Widget? floatingActionButton;
  final String role;

  const BaseScaffold({
    super.key,
    required this.title,
    required this.body,
    required this.role,
    this.actions,
    this.bottomNav,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: Colors.white)),
        backgroundColor: const Color(0xFF2979FF),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF2979FF), Color(0xFF00BFA5)]),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children:  [
                  CircleAvatar(radius: 28, child: Icon(Icons.admin_panel_settings)),
                  SizedBox(height: 12),
                  Text( role == 'admin' ? 'Administrator': 'Teacher', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            if (role == 'admin') ... [
               ListTile(leading: const Icon(Icons.home), title: const Text('Dashboard'), 
           
            onTap: () {
              Navigator.pop(context);
              context.push('/');
            }),
            ListTile(leading: const Icon(Icons.people), title: const Text('Teacher Directory'), onTap: () {
              Navigator.pop(context);
              context.push('/teachers');
            }),
            ListTile(leading: const Icon(Icons.pending_actions), title: const Text('Pending Approvals'), onTap: () {
              Navigator.pop(context);
              context.push('/pending');
            }),
            ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('System Settings'),
            onTap: () {
           Navigator.pop(context);
           context.push('/settings');
        }),
            ], 
      if(role == 'teacher') ...[
        ListTile(leading: const Icon(Icons.home), title: const Text('Dashboard'), onTap: () {
          Navigator.pop(context);
          context.push('/teacher-dashboard');
        }),
        ListTile(leading: const Icon(Icons.class_), title: const Text('My Classes'), onTap: () {
          Navigator.pop(context);
          context.push('/my-classes');
        }),
        ListTile(leading: const Icon(Icons.checklist), title: const Text('Attendance'), onTap: () {
          Navigator.pop(context);
          context.push('/attendance');
        }),
      ],
      
      const Divider(),
      ListTile(leading: const Icon(Icons.person), title: const Text('Profile'), onTap: () {
        Navigator.pop(context);
        context.push('/profile');
      }),
    ],
  ),
),
           
      body: body,
      bottomNavigationBar: bottomNav,
      floatingActionButton: floatingActionButton,
    );
  }
}