import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'settings_screen.dart';
import '../widgets/base_scaffold.dart'; 
import '../core/services/session_service.dart';
// import '../core/helpers/device_mac_helper.dart';



class TeacherDashboardScreen extends StatefulWidget {
  final int userId; 
  final String role; 

  const TeacherDashboardScreen({
    super.key,
    required this.userId,
    required this.role, 
  });

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  int _selectedIndex = 0;
  int? activeSessionId;
  bool isLoading = false;

  int get teacherId => widget.userId; 
  final int classId = 5; 

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.class_rounded, label: 'Classes'),
    _NavItem(icon: Icons.bar_chart_rounded, label: 'Reports'),
    _NavItem(icon: Icons.settings_rounded, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Teacher Dashboard',
      role: widget.role,
      floatingActionButton: isLoading 
      ? const CircularProgressIndicator() 
      : FloatingActionButton(
          onPressed: () {},
      backgroundColor: const Color(0xFF0F9DF8),
       mini: true,
          child: const Icon(Icons.help_outline, color: Colors.white, size: 18),
        ),
    bottomNav: _buildBottomNavBar(),
      body: _buildBody(),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F9D58), Color(0xFF0A8F4C)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Teacher Dashboard',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Role: ${widget.role} | ID:${widget.userId}', style: TextStyle(color: Colors.white70, fontSize: 15)), // 👈 Miss Amina ki jagah ID dikha do
              if(activeSessionId!= null)...[
                const SizedBox(height: 8),
                Text('Active Session: $activeSessionId',
                    style: const TextStyle(color: Colors.yellow, fontSize: 12))
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.05,
        children: [
          _DashboardCardWidget(
            card: _DashboardCard(title: 'Start Session', icon: Icons.play_circle_fill, iconColor: Color(0xFF0F9D58)),
            onTap: startSession,
          ),
          _DashboardCardWidget(
            card: _DashboardCard(title: 'End Session', icon: Icons.stop_circle, iconColor: Colors.red),
            onTap: endSession,
          ),
          _DashboardCardWidget(
            card: _DashboardCard(title: 'Class Roster', icon: Icons.group_rounded, iconColor: Color(0xFF1565C0)),
            onTap: () {},
          ),
          _DashboardCardWidget(
            card: _DashboardCard(title: 'Reports', icon: Icons.bar_chart_rounded, iconColor: Color(0xFF7B1FA2)),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Future<void> startSession() async {
    setState(() => isLoading = true);
    try {
      Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      // ADD: Get device MAC address
    // final macAddress = await DeviceMacHelper.getMacAddress();
      final result = await SessionService.createSession(
        teacherId: teacherId,
        classId: classId,
        latitude: pos.latitude,
        longitude: pos.longitude,
        // deviceMacAddress: macAddress,   // ADD THIS
      );
      if (result['success']) {
        final id = result['data']['id'];
        setState(() => activeSessionId = id);
        _showSnack('Session start ho gayi! ID: $id');
      } else {
        _showSnack(result['message'] ?? 'Error');
      }
    } catch (e) {
      _showSnack('Error: $e');
    }
    setState(() => isLoading = false);
  }

  Future<void> endSession() async {
    if (activeSessionId == null) {
      _showSnack('Start Session First');
      return;
    }
    final result = await SessionService.endSession(activeSessionId!);
    if (result['success']) {
      setState(() => activeSessionId = null);
      _showSnack('Session Ended');
    } else {
      _showSnack(result['message'] ?? 'Error ending session');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: Offset(0, -2)),
      ]),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navItems.length, (index) {
              final item = _navItems[index];
              final isActive = _selectedIndex == index;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedIndex = index);
                  if(index == 3) { // Settings tab
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SettingsScreen()),
                    );
                  }
                },
                child: SizedBox(
                  width: 72,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item.icon, color: isActive? Color(0xFF0F9D58) : Color(0xFF9E9E9E)),
                      Text(item.label, style: TextStyle(color: isActive? Color(0xFF0F9D58) : Color(0xFF9E9E9E), fontSize: 11)),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _DashboardCardWidget extends StatelessWidget {
  final _DashboardCard card;
  final VoidCallback onTap;

  const _DashboardCardWidget({required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 12, offset: Offset(0, 3))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(color: card.iconColor, borderRadius: BorderRadius.circular(14)),
                  child: Icon(card.icon, color: Colors.white, size: 28),
                ),
                const SizedBox(height: 16),
                Text(card.title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF212121))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardCard {
  final String title;
  final IconData icon;
  final Color iconColor;
  const _DashboardCard({required this.title, required this.icon, required this.iconColor});
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}