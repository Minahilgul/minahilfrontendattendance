import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import '../settings_screen.dart';
import '../../widgets/base_scaffold.dart';
import '../../core/services/session_service.dart';
import '../../core/services/auth_service.dart';
import '../student_selection_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'session_report_screen.dart';
import 'mark_attendance.dart';
import '../attendance_report_screen.dart';
import '../../core/services/confirmation_service.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/dashboard_card.dart';

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

  // ✅ CHANGE 1: Classes & Settings removed → Profile & View Responses added
  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.home_rounded,        label: 'Home'),
    _NavItem(icon: Icons.bar_chart_rounded,   label: 'Reports'),
    _NavItem(icon: Icons.how_to_reg_rounded,  label: 'View Responses'),
    _NavItem(icon: Icons.person_rounded,      label: 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    _checkActiveSession();
  }

  Future<void> _checkActiveSession() async {
    final result = await SessionService.getActiveSession(teacherId);
    print("ACTIVE SESSION CHECK: $result");
    if (result['success'] == true &&
        result['active'] == true &&
        result['data'] != null) {
      setState(() {
        activeSessionId = result['data']['id'];
      });
    }
  }

  Future<void> _showResponseDirectory() async {
    if (activeSessionId == null) {
      _showSnack('Start a session first');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final result = await ConfirmationService.getDirectory(activeSessionId!);
    if (!mounted) return;
    Navigator.pop(context);

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
                      _showResponseDirectory();
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
    return BaseScaffold(
      title: 'Teacher Dashboard',
      role: widget.role,
      // ✅ CHANGE 2: FAB (? help button) removed — no floatingActionButton
      bottomNav: _buildBottomNavBar(),
      body: _buildBody(),
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
          DashboardCard(
            title: 'Start Session',
            iconData: Icons.play_circle_fill,
            type: DashboardCardType.success,
            onTap: startSession,
          ),
          DashboardCard(
            title: 'End Session',
            iconData: Icons.stop_circle,
            type: DashboardCardType.danger,
            onTap: _openEndSessionScreen,
          ),
          // ✅ CHANGE 3: Class Roaster card removed
          // ✅ CHANGE 4: Reports card replaced with Attendance card (Reports moved to drawer)
          DashboardCard(
            title: 'Attendance',
            iconData: Icons.checklist_rounded,
            type: DashboardCardType.primary,
            onTap: _openAttendance,
          ),
          DashboardCard(
            title: 'Add Student',
            iconData: Icons.person_add_alt_1_rounded,
            type: DashboardCardType.success,
            onTap: () => Get.toNamed('/student-directory'),
          ),
        ],
      ),
    );
  }

  // Opens Mark Attendance for whichever session is currently active.
  // Reuses the already-tracked activeSessionId if we have it, otherwise
  // asks the backend fresh — so this keeps working even if the teacher
  // navigated away mid-session (e.g. to mark a student who arrived late).
  Future<void> _openAttendance() async {
    int? sessionId = activeSessionId;

    if (sessionId == null) {
      final result = await SessionService.getActiveSession(teacherId);
      if (result['success'] == true &&
          result['active'] == true &&
          result['data'] != null) {
        sessionId = result['data']['id'] is int
            ? result['data']['id']
            : int.tryParse(result['data']['id'].toString());
        if (sessionId != null) {
          setState(() => activeSessionId = sessionId);
        }
      }
    }

    if (sessionId == null) {
      _showSnack('No active session. Start a session first.');
      return;
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MarkAttendanceScreen(sessionId: sessionId!),
      ),
    );
  }

  Future<void> startSession() async {
    setState(() => isLoading = true);
    print("1. BUTTON TAPPED ✅");

    try {
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
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        print("4. After request: $permission");
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showSnack('Location Allow karo browser se');
        setState(() => isLoading = false);
        return;
      }

      print("5. Getting location...");
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 10),
      );
      print("6. Location OK: ${pos.latitude}");

      final result = await SessionService.createSession(
        teacherId: teacherId,
        latitude: pos.latitude,
        longitude: pos.longitude,
      );

      print("7. API Result: $result");

      if (result['success']) {
        final int id = result['data']['id'];
        setState(() => activeSessionId = id);

        if (!mounted) return;
        print("8. Navigating to StudentSelectionScreen...");
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
      print("ERROR: $e");
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

  // ── UPDATED: "End Session" now opens a full page instead of a bottom sheet ──
  void _openEndSessionScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TeacherSessionsScreen(
          teacherId: teacherId,
          onSessionEnded: (sessionId) {
            if (activeSessionId == sessionId) {
              setState(() => activeSessionId = null);
            }
          },
        ),
      ),
    );
  }

  Future<void> _requestConfirmation() async {
    if (activeSessionId == null) {
      _showSnack('Start a session first');
      return;
    }
    final result =
        await ConfirmationService.requestConfirmation(activeSessionId!);
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
        title: const Text(
          'Confirmation Results',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: result['requested'] == true
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _resultRow('✅ YES (Present)', result['yes_count'] ?? 0,
                      AppColors.success),
                  const SizedBox(height: 8),
                  _resultRow('❌ NO (Not Present)', result['no_count'] ?? 0,
                      AppColors.danger),
                  const Divider(height: 24),
                  Text(
                    '${result['total_responded']}/${result['total_students']} students responded',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: (result['yes_count'] ?? 0) >=
                              (result['no_count'] ?? 0)
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.danger.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      result['verdict'] ?? '-',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: (result['yes_count'] ?? 0) >=
                                (result['no_count'] ?? 0)
                            ? AppColors.success
                            : AppColors.danger,
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
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
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
                  // ✅ CHANGE 1: Updated nav actions
                  // index 0 = Home (stay)
                  // index 1 = Reports
                  // index 2 = View Responses
                  // index 3 = Profile
                  if (index == 1) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AttendanceReportScreen(),
                      ),
                    );
                  } else if (index == 2) {
                    _showResponseDirectory();
                  } else if (index == 3) {
                    Get.toNamed('/teacher-profile');
                  }
                },
                child: SizedBox(
                  width: 72,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item.icon,
                        color: isActive
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                      Text(
                        item.label,
                        style: TextStyle(
                          color: isActive
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
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

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

// ── TEACHER SESSIONS SCREEN (was a bottom sheet, now a full page) ──
// Lists every session this teacher has created. If a session is active,
// an "End" button lets the teacher end it. Ended sessions show an "Ended" badge.
// Because this writes to the same attendance_sessions row/status that the
// admin's Reports & Audit screen reads, the admin's sessions list reflects
// this the next time it loads/refreshes.
class TeacherSessionsScreen extends StatefulWidget {
  final int teacherId;
  final void Function(int sessionId)? onSessionEnded;

  const TeacherSessionsScreen({
    super.key,
    required this.teacherId,
    this.onSessionEnded,
  });

  @override
  State<TeacherSessionsScreen> createState() => _TeacherSessionsScreenState();
}

class _TeacherSessionsScreenState extends State<TeacherSessionsScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _sessions = [];
  final Set<int> _endingIds = {};

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() => _loading = true);
    final result = await SessionService.getTeacherSessions(widget.teacherId);
    final list = List<Map<String, dynamic>>.from(result['data'] ?? []);
    if (mounted) setState(() { _sessions = list; _loading = false; });
  }

  Future<void> _endSession(int index) async {
    final session = _sessions[index];
    final int sessionId = session['id'] is int
        ? session['id']
        : int.tryParse(session['id'].toString()) ?? 0;

    setState(() => _endingIds.add(sessionId));
    final result = await SessionService.endSession(sessionId);

    if (!mounted) return;
    setState(() => _endingIds.remove(sessionId));

    if (result['success'] == true) {
      setState(() {
        _sessions[index] = {..._sessions[index], 'status': 'inactive'};
      });
      widget.onSessionEnded?.call(sessionId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Session ended'),
            backgroundColor: AppColors.success),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Failed to end session'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  String _formatTime(dynamic raw) {
    if (raw == null) return '-';
    try {
      final dt = DateTime.parse(raw.toString()).toLocal();
      final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final minute = dt.minute.toString().padLeft(2, '0');
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $period';
    } catch (e) {
      return '-';
    }
  }

  String _formatDate(dynamic raw) {
    if (raw == null) return '';
    try {
      final dt = DateTime.parse(raw.toString()).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('My Sessions', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSessions,
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _sessions.isEmpty
              ? Center(
                  child: Text('No sessions found',
                      style: TextStyle(color: AppColors.textLight)))
              : RefreshIndicator(
                  onRefresh: _loadSessions,
                  color: AppColors.primary,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _sessions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final s = _sessions[index];
                      final isActive = s['status'] == 'active';
                      final int sessionId = s['id'] is int
                          ? s['id']
                          : int.tryParse(s['id'].toString()) ?? 0;
                      final isEnding = _endingIds.contains(sessionId);

                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: (isActive
                                    ? AppColors.success
                                    : AppColors.textLight)
                                .withOpacity(0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s['class_name'] ??
                                        'Class ${s['class_id'] ?? '-'}',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(children: [
                                    Icon(Icons.access_time,
                                        size: 12, color: AppColors.textLight),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${_formatTime(s['start_time'])} - ${s['end_time'] != null ? _formatTime(s['end_time']) : 'Ongoing'}',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary),
                                    ),
                                  ]),
                                  const SizedBox(height: 2),
                                  Text(_formatDate(s['start_time']),
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: AppColors.textLight)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            isActive
                                ? SizedBox(
                                    height: 32,
                                    child: ElevatedButton(
                                      onPressed: isEnding
                                          ? null
                                          : () => _endSession(index),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.danger,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                      ),
                                      child: isEnding
                                          ? const SizedBox(
                                              width: 14,
                                              height: 14,
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.white),
                                            )
                                          : const Text('End',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight:
                                                      FontWeight.w700)),
                                    ),
                                  )
                                : Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.textLight
                                          .withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Ended',
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textLight),
                                    ),
                                  ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}