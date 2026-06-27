import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../widgets/base_scaffold.dart';
import '../core/services/student_profile_service.dart';
import '../core/services/confirmation_service.dart';
import '../core/services/auth_service.dart';

// Constants
const String _baseUrl    = 'http://localhost:8000/api';
const Color _kGreen      = Color(0xFF0F9D58);
const Color _kGreenLight = Color(0xFF00BFA5);
const Color _kBg         = Color(0xFFF5F7FA);

// Model
class AttendanceRecord {
  final String subject;
  final String date;
  final String status;

  const AttendanceRecord({
    required this.subject,
    required this.date,
    required this.status,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> j) => AttendanceRecord(
        subject: j['class_name'] ?? 'Class ${j['class_id']}',
        date:    j['attendance_date'] ?? '',
        status:  j['status'] ?? 'absent',
      );
}

// Dummy Notifications
const List<Map<String, String>> _kNotifications = [
  {
    'icon': '📡',
    'title': 'Attendance Session Started',
    'body': 'Your teacher has started a new attendance session.',
    'time': 'Just now',
    'type': 'session',
  },
  {
    'icon': '✅',
    'title': 'Attendance Marked',
    'body': 'Your attendance was recorded successfully.',
    'time': '2 hours ago',
    'type': 'confirm',
  },
  {
    'icon': '⚠️',
    'title': 'Low Attendance Warning',
    'body': 'Your attendance in one class has dropped below 75%.',
    'time': 'Yesterday',
    'type': 'alert',
  },
  {
    'icon': '💬',
    'title': 'Message from Teacher',
    'body': 'Mid-term exam schedule has been updated.',
    'time': '2 days ago',
    'type': 'message',
  },
];

// Main Widget
class StudentDashboardScreen extends StatefulWidget {
  final int    userId;
  final String role;
  final String name;

  const StudentDashboardScreen({
    super.key,
    required this.userId,
    required this.role,
    required this.name,
  });

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  int _selectedIndex = 0;

  Map<String, dynamic>? _studentInfo;
  List<AttendanceRecord> _allRecords = [];
  bool _loading = true;
  String? _error;

  // ── Confirmation polling ──
  Timer? _confirmationPoller;
  int get studentId => widget.userId;

  @override
  void initState() {
    super.initState();
    _loadData();
    _startPolling();
  }

  @override
  void dispose() {
    _confirmationPoller?.cancel();
    super.dispose();
  }

  // ── Polling methods ──────────────────────────
  void _startPolling() {
    _confirmationPoller = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _checkForConfirmation(),
    );
  }

  Future<void> _checkForConfirmation() async {
    final token = await AuthService.getToken();
    print("TOKEN: $token");
    print("POLLING... studentId: $studentId");
    final result = await ConfirmationService.getPending(studentId);
    print("POLL RESULT: $result");
    if (result['pending'] == true && mounted) {
      _confirmationPoller?.cancel();
      await _showConfirmationDialog(
        result['request_id'],
        result['session_id'],
      );
      _startPolling();
    }
  }

  Future<void> _showConfirmationDialog(int requestId, int sessionId) async {
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
                color: const Color(0xFF0288D1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.how_to_vote_rounded, color: Color(0xFF0288D1)),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text('Teacher Confirmation',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Is your teacher physically present in the classroom right now?',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Your response is confidential.',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          // NO
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.close_rounded, size: 18),
            label: const Text('NO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            onPressed: () async {
              await _submitResponse(requestId, 'no');
              if (mounted) Navigator.pop(context);
            },
          ),
          // YES
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F9D58),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.check_rounded, size: 18),
            label: const Text('YES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            onPressed: () async {
              await _submitResponse(requestId, 'yes');
              if (mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _submitResponse(int requestId, String response) async {
    final result = await ConfirmationService.submitResponse(
      requestId: requestId,
      studentId: studentId,
      response: response,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['success'] == true
              ? 'Response submitted: ${response.toUpperCase()} ✓'
              : result['message'] ?? 'Failed to submit'),
          backgroundColor:
              result['success'] == true ? const Color(0xFF0F9D58) : Colors.red,
        ),
      );
    }
  }

  // ── Data loading ─────────────────────────────
  Future<String?> _getToken() async {
    final storage = GetStorage();
    return storage.read<String>('token');
  }

  Future<void> _loadData() async {
    setState(() { _loading = true; _error = null; });
    try {
      final token = await _getToken();
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final profileRes = await http.get(
        Uri.parse('$_baseUrl/students/${widget.userId}'),
        headers: headers,
      );

      Map<String, dynamic>? info;
      if (profileRes.statusCode == 200) {
        final body = jsonDecode(profileRes.body);
        info = body['data'] ?? body;
      }

      List<AttendanceRecord> records = [];
      if (info != null && info['attendances'] != null) {
        final list = info['attendances'] as List;
        records = list.map((e) => AttendanceRecord.fromJson(e)).toList();
      }

      setState(() {
        _studentInfo = info;
        _allRecords  = records;
        _loading     = false;
      });
    } catch (e) {
      setState(() { _loading = false; _error = e.toString(); });
    }
  }

  // ── Bottom Nav ───────────────────────────────
  Widget _buildBottomNav() {
    final items = const [
      {'icon': Icons.home_rounded,          'label': 'Home'},
      {'icon': Icons.bar_chart_rounded,     'label': 'Reports'},
      {'icon': Icons.notifications_rounded, 'label': 'Alerts'},
      {'icon': Icons.person_rounded,        'label': 'Profile'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final active = _selectedIndex == i;
              return GestureDetector(
                onTap: () => setState(() => _selectedIndex = i),
                child: SizedBox(
                  width: 72,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(items[i]['icon'] as IconData,
                              color: active ? _kGreen : const Color(0xFF9E9E9E)),
                          if (i == 2)
                            Positioned(
                              right: -4, top: -4,
                              child: Container(
                                width: 10, height: 10,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        items[i]['label'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          color: active ? _kGreen : const Color(0xFF9E9E9E),
                          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
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

  // ── Body ─────────────────────────────────────
  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: _kGreen),
            SizedBox(height: 16),
            Text('Loading your data…', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text('Could not load data', style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(backgroundColor: _kGreen),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    switch (_selectedIndex) {
      case 0: return _HomePage(name: widget.name, userId: widget.userId, role: widget.role, records: _allRecords);
      case 1: return _ReportsPage(records: _allRecords, onRefresh: _loadData);
      case 2: return _NotificationsPage();
      case 3: return _ProfilePage(name: widget.name, userId: widget.userId, role: widget.role, studentInfo: _studentInfo);
      default: return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: ['Student Dashboard', 'My Reports', 'Notifications', 'My Profile'][_selectedIndex],
      role: widget.role,
      bottomNav: _buildBottomNav(),
      onDrawerNavTap: (index) => setState(() => _selectedIndex = index),
      body: _buildBody(),
    );
  }
}


// ════════════════════════════════════════════
// PAGE 1 — HOME
// ════════════════════════════════════════════

class _HomePage extends StatelessWidget {
  final String name;
  final int userId;
  final String role;
  final List<AttendanceRecord> records;

  const _HomePage({
    required this.name,
    required this.userId,
    required this.role,
    required this.records,
  });

  @override
  Widget build(BuildContext context) {
    final today    = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final todayRecord = records.where((r) => r.date == todayStr).toList();
    final todayStatus = todayRecord.isNotEmpty ? todayRecord.first.status : 'not_marked';

    final present = records.where((r) => r.status == 'present').length;
    final absent  = records.where((r) => r.status == 'absent').length;
    final late    = records.where((r) => r.status == 'late').length;
    final total   = records.length;
    final pct     = total > 0 ? ((present / total) * 100).round() : 0;

    return Container(
      color: _kBg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_kGreen, _kGreenLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: _kGreen.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome, $name! 👋',
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Student Portal • Attendance Verification System',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _BannerStat(
                          label: "Today's Status",
                          value: todayStatus == 'present' ? '✅ Present'
                               : todayStatus == 'absent'  ? '❌ Absent'
                               : todayStatus == 'late'    ? '⏱ Late'
                               : '⏳ Not Marked',
                        ),
                      ),
                      Container(width: 1, height: 40, color: Colors.white30),
                      Expanded(child: _BannerStat(label: 'Overall', value: '$pct%', center: true)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Listening indicator (confirmation polling)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF0288D1).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF0288D1).withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.sensors_rounded, color: Color(0xFF0288D1), size: 18),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Listening for teacher confirmation requests…',
                      style: TextStyle(
                          color: Color(0xFF0288D1),
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.3, end: 1.0),
                    duration: const Duration(seconds: 1),
                    builder: (_, val, __) => Opacity(
                      opacity: val,
                      child: const Icon(Icons.circle, size: 8, color: Color(0xFF0288D1)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _SectionCard(
              icon: Icons.info_outline,
              title: 'ACCOUNT DETAILS',
              child: Column(children: [
                _InfoRow(label: 'User ID', value: '#$userId'),
                _InfoRow(label: 'Role',    value: role.toUpperCase()),
                _InfoRow(label: 'Status',  value: 'Active', valueColor: _kGreen),
              ]),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              icon: Icons.calendar_month_rounded,
              title: 'THIS MONTH',
              child: Row(children: [
                _StatBox(label: 'Present', value: present, color: _kGreen,                bg: const Color(0xFFE6F4EA)),
                const SizedBox(width: 10),
                _StatBox(label: 'Late',    value: late,    color: const Color(0xFFF59E0B), bg: const Color(0xFFFFF8E1)),
                const SizedBox(width: 10),
                _StatBox(label: 'Absent',  value: absent,  color: Colors.red,              bg: const Color(0xFFFFEBEE)),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}


// ════════════════════════════════════════════
// PAGE 2 — REPORTS
// ════════════════════════════════════════════

class _ReportsPage extends StatefulWidget {
  final List<AttendanceRecord> records;
  final VoidCallback onRefresh;

  const _ReportsPage({required this.records, required this.onRefresh});

  @override
  State<_ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<_ReportsPage> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final records = widget.records;
    final present = records.where((r) => r.status == 'present').length;
    final total   = records.length;
    final pct     = total > 0 ? ((present / total) * 100).round() : 0;

    final subjects = ['All', ...records.map((r) => r.subject).toSet().toList()];
    final filtered = _filter == 'All' ? records : records.where((r) => r.subject == _filter).toList();

    return Container(
      color: _kBg,
      child: RefreshIndicator(
        onRefresh: () async => widget.onRefresh(),
        color: _kGreen,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 3))],
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 80, height: 80,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: pct / 100,
                            strokeWidth: 8,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation(pct >= 75 ? _kGreen : Colors.red),
                          ),
                          Text('$pct%', style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w800,
                            color: pct >= 75 ? _kGreen : Colors.red,
                          )),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Overall Attendance',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1C1B1F))),
                          const SizedBox(height: 4),
                          Text('$present present out of $total classes',
                              style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          if (pct < 75) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(8)),
                              child: const Text('⚠ Below 75% threshold',
                                  style: TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: subjects.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final s      = subjects[i];
                    final active = _filter == s;
                    return GestureDetector(
                      onTap: () => setState(() => _filter = s),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: active ? _kGreen : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: active ? _kGreen : Colors.grey.shade300),
                        ),
                        child: Text(s,
                            style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600,
                              color: active ? Colors.white : Colors.grey.shade600,
                            )),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              if (filtered.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Column(
                      children: [
                        Icon(Icons.history_edu_rounded, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text('No attendance records yet', style: TextStyle(color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
                )
              else
                ...filtered.map((r) => _AttendanceTile(record: r)),
            ],
          ),
        ),
      ),
    );
  }
}


// ════════════════════════════════════════════
// PAGE 3 — NOTIFICATIONS
// ════════════════════════════════════════════

class _NotificationsPage extends StatefulWidget {
  @override
  State<_NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<_NotificationsPage> {
  final List<bool> _read = List.filled(_kNotifications.length, false);

  @override
  Widget build(BuildContext context) {
    final unread = _read.where((r) => !r).length;

    return Container(
      color: _kBg,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  const Text('Notifications', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  if (unread > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                      child: Text('$unread', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                    ),
                  ],
                ]),
                if (unread > 0)
                  GestureDetector(
                    onTap: () => setState(() { for (int i = 0; i < _read.length; i++) _read[i] = true; }),
                    child: const Text('Mark all read',
                        style: TextStyle(color: _kGreen, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: _kNotifications.length,
              itemBuilder: (_, i) {
                final n = _kNotifications[i];
                return GestureDetector(
                  onTap: () => setState(() => _read[i] = true),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _read[i] ? Colors.white : const Color(0xFFE8F0FE),
                      borderRadius: BorderRadius.circular(14),
                      border: Border(left: BorderSide(color: _read[i] ? Colors.transparent : _kGreen, width: 4)),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 42, height: 42,
                          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                          child: Center(child: Text(n['icon']!, style: const TextStyle(fontSize: 20))),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(n['title']!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: _read[i] ? FontWeight.w600 : FontWeight.w800,
                                    color: const Color(0xFF1C1B1F),
                                  )),
                              const SizedBox(height: 3),
                              Text(n['body']!, style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.4)),
                              const SizedBox(height: 6),
                              Text(n['time']!, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                        ),
                        if (!_read[i])
                          Container(
                            width: 8, height: 8,
                            margin: const EdgeInsets.only(top: 4),
                            decoration: const BoxDecoration(color: _kGreen, shape: BoxShape.circle),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


// ════════════════════════════════════════════
// PAGE 4 — PROFILE
// ════════════════════════════════════════════

class _ProfilePage extends StatefulWidget {
  final String name;
  final int userId;
  final String role;
  final Map<String, dynamic>? studentInfo;

  const _ProfilePage({required this.name, required this.userId, required this.role, this.studentInfo});

  @override
  State<_ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<_ProfilePage> {
  final _service = StudentProfileService();

  void _showSnackbar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red : _kGreen,
      behavior: SnackBarBehavior.floating,
    ));
  }

  Future<void> _openChangePassword() async {
    final formKey   = GlobalKey<FormState>();
    final currentPw = TextEditingController();
    final newPw     = TextEditingController();
    final confirmPw = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        bool showCurrent = false, showNew = false, showConfirm = false;
        bool loading = false;

        return StatefulBuilder(
          builder: (ctx, setS) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(children: [
                      const Icon(Icons.lock_outline, color: _kGreen),
                      const SizedBox(width: 8),
                      const Text('Change Password',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    _dialogPwField('Current Password', currentPw, showCurrent,
                        () => setS(() => showCurrent = !showCurrent),
                        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null),
                    const SizedBox(height: 12),
                    _dialogPwField('New Password', newPw, showNew,
                        () => setS(() => showNew = !showNew),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          if (v.length < 8) return 'Min 8 characters';
                          return null;
                        }),
                    const SizedBox(height: 12),
                    _dialogPwField('Confirm Password', confirmPw, showConfirm,
                        () => setS(() => showConfirm = !showConfirm),
                        validator: (v) =>
                            v != newPw.text ? 'Passwords do not match' : null),
                    const SizedBox(height: 20),
                    Row(children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: loading
                              ? null
                              : () async {
                                  if (!formKey.currentState!.validate()) return;
                                  setS(() => loading = true);
                                  try {
                                    await _service.changePassword(
                                      currentPassword: currentPw.text,
                                      newPassword: newPw.text,
                                      confirmPassword: confirmPw.text,
                                    );
                                    if (ctx.mounted) Navigator.pop(ctx);
                                    if (mounted) {
                                      _showSnackbar('Password changed successfully');
                                    }
                                  } catch (e) {
                                    if (ctx.mounted) setS(() => loading = false);
                                    if (mounted) _showSnackbar(e.toString(), isError: true);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _kGreen,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: loading
                              ? const SizedBox(
                                  width: 20, height: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Text('Update',
                                  style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    currentPw.dispose();
    newPw.dispose();
    confirmPw.dispose();
  }

  Widget _dialogPwField(
    String label,
    TextEditingController ctrl,
    bool show,
    VoidCallback toggle, {
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      obscureText: !show,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline, color: _kGreen),
        suffixIcon: IconButton(
          icon: Icon(show ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
          onPressed: toggle,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kGreen, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _service.logout();
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final info      = widget.studentInfo;
    final email     = info?['email'] ?? '—';
    final phone     = info?['phone'] ?? '—';
    final className = info?['class_name']?.toString() ?? info?['class']?.toString() ?? '—';
    final rollNo    = info?['roll_no'] ?? info?['roll_number'] ?? '—';
    final parts     = widget.name.trim().split(' ');
    final initials  = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : widget.name.substring(0, 2).toUpperCase();

    return Container(
      color: _kBg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            Container(
              width: 80, height: 80,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [_kGreen, _kGreenLight]),
              ),
              child: Center(
                child: Text(initials,
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(height: 12),
            Text(widget.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1C1B1F))),
            Text(rollNo != '—' ? rollNo : 'Student',
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFE6F4EA), borderRadius: BorderRadius.circular(10)),
              child: const Text('● Active',
                  style: TextStyle(color: _kGreen, fontSize: 12, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 24),

            // Personal Info
            _SectionCard(
              icon: Icons.person_outline,
              title: 'PERSONAL INFO',
              child: Column(children: [
                _InfoRow(label: 'Full Name', value: widget.name),
                _InfoRow(label: 'Email',     value: email),
                _InfoRow(label: 'Phone',     value: phone),
                _InfoRow(label: 'Class',     value: className),
                _InfoRow(label: 'Roll No',   value: rollNo),
                _InfoRow(label: 'Role',      value: widget.role.toUpperCase()),
                _InfoRow(label: 'Status',    value: 'Active', valueColor: _kGreen),
              ]),
            ),
            const SizedBox(height: 16),

            // Actions Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: _kGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.lock_outline, color: _kGreen, size: 22),
                    ),
                    title: const Text('Change Password',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text('Update your password',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: _openChangePassword,
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.logout, color: Colors.red, size: 22),
                    ),
                    title: const Text('Logout',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.red)),
                    subtitle: const Text('Sign out from this device',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: _logout,
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ════════════════════════════════════════════
// SHARED SMALL WIDGETS
// ════════════════════════════════════════════

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({required this.icon, required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: _kGreen, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54, letterSpacing: 0.8)),
              ),
              if (trailing != null) trailing!,
            ]),
            const Divider(height: 20),
            child,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? const Color(0xFF1C1B1F))),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final Color bg;

  const _StatBox({required this.label, required this.value, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Column(children: [
          Text('$value', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ]),
      ),
    );
  }
}

class _BannerStat extends StatelessWidget {
  final String label;
  final String value;
  final bool center;

  const _BannerStat({required this.label, required this.value, this.center = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _AttendanceTile extends StatelessWidget {
  final AttendanceRecord record;

  const _AttendanceTile({required this.record});

  @override
  Widget build(BuildContext context) {
    final isPresent = record.status == 'present';
    final isLate    = record.status == 'late';
    final color = isPresent ? _kGreen : isLate ? const Color(0xFFF59E0B) : Colors.red;
    final bg    = isPresent ? const Color(0xFFE6F4EA) : isLate ? const Color(0xFFFFF8E1) : const Color(0xFFFFEBEE);
    final icon  = isPresent ? '✓' : isLate ? '⏱' : '✗';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record.subject,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1C1B1F))),
                const SizedBox(height: 3),
                Text('📅 ${record.date}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
            child: Text(
              '$icon ${record.status[0].toUpperCase()}${record.status.substring(1)}',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
            ),
          ),
        ],
      ),
    );
  }
}