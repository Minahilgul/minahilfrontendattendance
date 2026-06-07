import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BaseScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? bottomNav;
  final Widget? floatingActionButton;

  const BaseScaffold({
    super.key,
    required this.title,
    required this.body,
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
                children: const [
                  CircleAvatar(radius: 28, child: Icon(Icons.admin_panel_settings)),
                  SizedBox(height: 12),
                  Text('Administrator', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            ListTile(leading: const Icon(Icons.home), title: const Text('Dashboard'), onTap: () {
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
            ListTile(leading: const Icon(Icons.bar_chart), title: const Text('Reports'), onTap: () {
              Navigator.pop(context);
              context.push('/reports');
            }),
            ListTile(
            leading: Icon(Icons.admin_panel_settings, color: Color(0xFF37474F)),
            title: Text('Role Management', style: TextStyle(fontWeight: FontWeight.w600)),
            onTap: () {
            Navigator.pop(context); // drawer close
            context.push('/roles'); // Role screen pe le jao
             },
             ),
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