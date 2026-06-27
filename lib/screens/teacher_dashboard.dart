import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'settings_screen.dart';
import '../widgets/base_scaffold.dart'; 
import '../core/services/session_service.dart';
import '../core/services/auth_service.dart';
import 'student_selection_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'session_report_screen.dart';
import 'attendance_report_screen.dart';
import '../core/services/confirmation_service.dart';



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

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.class_rounded, label: 'Classes'),
    _NavItem(icon: Icons.bar_chart_rounded, label: 'Reports'),
    _NavItem(icon: Icons.settings_rounded, label: 'Settings'),
  ];
  //confirmation 
  @override
  void initState() {
    super.initState();
    _checkActiveSession();
  }

  Future<void> _checkActiveSession() async {
    final result = await SessionService.getActiveSession(teacherId);
    print("ACTIVE SESSION CHECK: $result");
    if (result['success'] == true && result['active'] == true && result['data'] != null) {
      setState(() {
        activeSessionId = result['data']['id'];
      });
    }
  }

  //show response
  Future<void> _showResponseDirectory() async {
  if (activeSessionId == null) {
    _showSnack('Start a session first');
    return;
  }

  // Show loading
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  final result = await ConfirmationService.getDirectory(activeSessionId!);
  if (!mounted) return;
  Navigator.pop(context); // close loader

  if (result['success'] != true) {
    _showSnack(result['message'] ?? 'Failed to load directory');
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
            // Header
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: Color(0xFF00796B),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.how_to_reg_rounded, color: Colors.white),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text('Confirmation Directory',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Analytics row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _directoryChip('✅ YES', result['yes_count'] ?? 0, const Color(0xFF0F9D58)),
                  _directoryChip('❌ NO', result['no_count'] ?? 0, Colors.red),
                  _directoryChip('⏳ Pending', result['pending_count'] ?? 0, Colors.orange),
                ],
              ),
            ),
            // Verdict
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00796B).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    result['verdict'] ?? 'Awaiting responses',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00796B)),
                  ),
                ),
              ),
            ),
            const Divider(height: 1),
            // Student list
            Flexible(
              child: students.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('No students found',
                          style: TextStyle(color: Colors.grey)),
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
                            ? const Color(0xFF0F9D58)
                            : resp == 'no'
                                ? Colors.red
                                : Colors.orange;
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
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(s['student_name'] ?? '-',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13)),
                          subtitle: Text(
                              'Roll: ${s['roll_no'] ?? '-'}  •  ${s['responded_at']}',
                              style: const TextStyle(fontSize: 11)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(respIcon, color: respColor, size: 16),
                              const SizedBox(width: 4),
                              Text(resp.toUpperCase(),
                                  style: TextStyle(
                                      color: respColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12)),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            // Refresh button
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showResponseDirectory();
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Refresh'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF00796B),
                    side: const BorderSide(color: Color(0xFF00796B)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
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
      Text('$count',
          style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 22)),
      Text(label,
          style: TextStyle(color: color, fontSize: 11)),
    ],
  );
}

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
            card: _DashboardCard(title: 'My Profile', icon: Icons.group_rounded, iconColor: Color(0xFF1565C0)),
            onTap: () => context.push('/teacher-profile'),
          ),
           _DashboardCardWidget(
            card: _DashboardCard(title: 'Class Roaster', icon: Icons.group_rounded, iconColor: Color(0xFF1565C0)),
            onTap: () => context.push('/roster'),
          ),
          _DashboardCardWidget(
            card: _DashboardCard(title: 'Reports', icon: Icons.bar_chart_rounded, iconColor: Color(0xFF7B1FA2)),
            onTap: (){
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AttendanceReportScreen(),
      ),
    );
  }, //=> context.push('/teacher-reports'),
          ),
          _DashboardCardWidget(
  card: _DashboardCard(
    title: 'View Responses',
    icon: Icons.how_to_reg_rounded,
    iconColor: Color(0xFF00796B),
  ),
  onTap: _showResponseDirectory,
),
        ],
      ),
    );
  }
  Future<void> startSession() async {
  setState(() => isLoading = true);
  print("1. BUTTON TAPPED ✅"); 
  
  try {
    //Location service check
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    print("2. Location Service: $serviceEnabled");
    if (!serviceEnabled) {
      _showSnack('Location ON karo phone/PC se');
      await Geolocator.openLocationSettings();
      setState(() => isLoading = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    print("3. Permission: $permission");
    //  YE IMPORTANT HAI - Web ke liye
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      print("4. After request: $permission");
    }
    
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      _showSnack('Location Allow karo browser se');

      setState(() => isLoading = false);
      return;
    }

    print("5. Getting location..."); 
    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low, 
      timeLimit: Duration(seconds: 10), 
    );
    print("6. Location OK: ${pos.latitude}"); 

    final result = await SessionService.createSession(
      teacherId: teacherId,
      latitude: pos.latitude,
      longitude: pos.longitude,
    );

    print("7. API Result: $result"); // 👈 ye add karo

    if (result['success']) {
      final int id = result['data']['id'];
      setState(() => activeSessionId = id);

      if (!mounted) return;
      print("8. Navigating to StudentSelectionScreen..."); // 👈 ye add karo
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StudentSelectionScreen(sessionId: id),
        ),
      );
    } else {
      _showSnack(result['message'] ?? 'Failed to start session');
    }
  } catch (e) {
    print("ERROR: $e"); // 👈 ye add karo
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

  // Request Confirmation 
  Future<void> _requestConfirmation() async {
  if (activeSessionId == null) {
    _showSnack('Start a session first');
    return;
  }
  final result = await ConfirmationService.requestConfirmation(activeSessionId!);
  if (result['success'] == true) {
    _showSnack('Confirmation request sent to students');
  } else {
    _showSnack(result['message'] ?? 'Failed to send request');
  }
}

  Future<void> _showConfirmationResults() async {
    if (activeSessionId == null) return;
    final result = await ConfirmationService.getResults(activeSessionId!);
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirmation Results',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: result['requested'] == true
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _resultRow('✅ YES (Present)', result['yes_count'] ?? 0,
                      const Color(0xFF0F9D58)),
                  const SizedBox(height: 8),
                  _resultRow('❌ NO (Not Present)', result['no_count'] ?? 0,
                      Colors.red),
                  const Divider(height: 24),
                  Text(
                    '${result['total_responded']}/${result['total_students']} students responded',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: (result['yes_count'] ?? 0) >=
                              (result['no_count'] ?? 0)
                          ? const Color(0xFF0F9D58).withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      result['verdict'] ?? '-',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: (result['yes_count'] ?? 0) >=
                                (result['no_count'] ?? 0)
                            ? const Color(0xFF0F9D58)
                            : Colors.red,
                      ),
                    ),
                  ),
                ],
              )
            : const Text('No confirmation request sent yet.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showConfirmationResults();
            },
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _resultRow(String label, int count, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(color: color, fontWeight: FontWeight.w500)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text('$count',
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
        ),
      ],
    );
  }// END

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
                  if(index == 1) {
                    context.push('/classes');
                  } else if(index == 2) {
                    context.push('/teacher-reports');
                  } else if(index == 3) {
                    context.push('/settings');
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