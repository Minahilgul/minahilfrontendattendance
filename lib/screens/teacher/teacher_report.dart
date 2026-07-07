import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/session_service.dart';
import '../../core/services/confirmation_service.dart';
import '../../widgets/base_scaffold.dart';

// Data Models 

enum TeacherAuditStatus { suspicious, verified, flagged }

class TeacherAuditLog {
  final String name;
  final String subject;
  final String course;
  final String time;
  final String detail;
  final TeacherAuditStatus status;

  const TeacherAuditLog({
    required this.name,
    required this.subject,
    required this.course,
    required this.time,
    required this.detail,
    required this.status,
  });
}

//  Screen

class TeacherReportScreen extends StatefulWidget {
  const TeacherReportScreen({super.key});

  @override
  State<TeacherReportScreen> createState() => _TeacherReportScreenState();
}

class _TeacherReportScreenState extends State<TeacherReportScreen> {
  int _navIndex = 1;

  String _selectedClass = 'All Classes';
  String _selectedFaculty = 'All Faculty';
  String _selectedPeriod = 'Last 7 Days';

  final List<String> _classes = ['All Classes', 'CS101', 'MAT102', 'PHY105'];
  final List<String> _faculty = ['All Faculty', 'Dr. Sarah Jenkins', 'Prof. Michael Chen'];
  final List<String> _periods = ['Last 7 Days', 'Last 30 Days', 'This Semester'];

  final List<TeacherAuditLog> _logs = const [
    TeacherAuditLog(
      name: 'Dr. Sara',
      subject: 'CS101',
      course: 'Computer Science Fundamentals',
      time: '10:30 AM',
      detail: 'Duplicate IP Detected',
      status: TeacherAuditStatus.suspicious,
    ),
    TeacherAuditLog(
      name: 'Madam Azleen',
      subject: 'MAT1025',
      course: 'Linear Algebra',
      time: '11:45 AM',
      detail: 'Biometric is Confirmed',
      status: TeacherAuditStatus.verified,
    ),
    TeacherAuditLog(
      name: 'Esha Gul (Student)',
      subject: 'PHY105',
      course: 'Quantum Physics',
      time: '01:15 PM',
      detail: 'GPS Location (500m)',
      status: TeacherAuditStatus.flagged,
    ),
  ];

  final List<FlSpot> _chartSpots = const [
    FlSpot(0, 72),
    FlSpot(1, 80),
    FlSpot(2, 78),
    FlSpot(3, 85),
    FlSpot(4, 83),
    FlSpot(5, 88),
    FlSpot(6, 88.4),
  ];

  final List<String> _chartDays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

  //  Bottom nav now matches Teacher Dashboard's nav exactly
  // (Home / Reports / View Responses / Profile) instead of the
  // admin-style Home/Classes/Settings labels.
  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.bar_chart_rounded, label: 'Reports'),
    _NavItem(icon: Icons.how_to_reg_rounded, label: 'View Responses'),
    _NavItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  // Finds the teacher's currently active session, then shows the
  // confirmation directory (who said yes/no/pending) for it. Same
  // logic as TeacherDashboardScreen so "View Responses" behaves
  // identically from either screen.
  Future<void> _showResponseDirectory() async {
    final int? teacherId = AuthService.currentUser?['id'] is int
        ? AuthService.currentUser!['id'] as int
        : int.tryParse(AuthService.currentUser?['id']?.toString() ?? '');

    if (teacherId == null) {
      _showSnack('Unable to identify teacher.');
      return;
    }

    final sessionResult = await SessionService.getActiveSession(teacherId);
    final int? sessionId = sessionResult['success'] == true &&
            sessionResult['active'] == true &&
            sessionResult['data'] != null
        ? (sessionResult['data']['id'] is int
            ? sessionResult['data']['id']
            : int.tryParse(sessionResult['data']['id'].toString()))
        : null;

    if (sessionId == null) {
      _showSnack('No active session. Start a session first.');
      return;
    }

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final result = await ConfirmationService.getDirectory(sessionId);
    if (!mounted) return;
    Navigator.pop(context); // close loading spinner

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

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Reports & Audit',
      role: 'teacher',
      bottomNav: _buildBottomNav(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 3,
        child: const Icon(Icons.description_rounded),
      ),
      body: Container(
        color: AppColors.background,
        child: SafeArea(
          child: Column(
            children: [
              // Sub-header (was the custom AppBar) — kept so the
              // "TEACHER DASHBOARD" label and share action are still
              // visible, now that BaseScaffold owns the real AppBar.
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.12),
                      child: Icon(Icons.bar_chart_rounded,
                          color: AppColors.primary, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reports & Audit',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'TEACHER DASHBOARD',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textLight,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.share_outlined, color: Colors.black54),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              // Filters row
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: _DropdownFilter(
                        value: _selectedClass,
                        items: _classes,
                        onChanged: (v) => setState(() => _selectedClass = v!),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _DropdownFilter(
                        value: _selectedFaculty,
                        items: _faculty,
                        onChanged: (v) => setState(() => _selectedFaculty = v!),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _DropdownFilter(
                        value: _selectedPeriod,
                        items: _periods,
                        onChanged: (v) => setState(() => _selectedPeriod = v!),
                      ),
                    ),
                  ],
                ),
              ),
              // Scrollable body
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Attendance Trends card
                    _WhiteCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Attendance Trends',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'Details',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'WEEKLY ATTENDANCE %',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textLight,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '88.4%',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const _TrendBadge(label: '+2.4%', positive: true),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 120,
                            child: _AttendanceLineChart(
                              spots: _chartSpots,
                              days: _chartDays,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Stats row
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            label: 'TOTAL SESSIONS',
                            value: '1,240',
                            trend: '+12% vs last week',
                            positive: true,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _StatCard(
                            label: 'FLAGGED LOGS',
                            value: '12',
                            trend: '-2% improvement',
                            positive: false,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Audit logs header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Audit Logs',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'See All',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ..._logs.map((log) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _AuditLogCard(log: log),
                        )),
                    const SizedBox(height: 72),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
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
            children: List.generate(_navItems.length, (i) {
              final isActive = _navIndex == i;
              return GestureDetector(
                onTap: () {
                  setState(() => _navIndex = i);
                  // index 0 = Home, 1 = Reports (current screen),
                  // 2 = View Responses, 3 = Profile — matches Teacher
                  // Dashboard's bottom nav exactly.
                  if (i == 0) {
                    Get.toNamed('/teacher-dashboard');
                  } else if (i == 2) {
                    _showResponseDirectory();
                  } else if (i == 3) {
                    Get.toNamed('/teacher-profile');
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 72,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _navItems[i].icon,
                        size: 24,
                        color: isActive
                            ? AppColors.primary
                            : AppColors.textLight,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _navItems[i].label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              isActive ? FontWeight.w600 : FontWeight.w400,
                          color: isActive
                              ? AppColors.primary
                              : AppColors.textLight,
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

// Line Chart 

class _AttendanceLineChart extends StatelessWidget {
  final List<FlSpot> spots;
  final List<String> days;

  const _AttendanceLineChart({required this.spots, required this.days});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 25,
          getDrawingHorizontalLine: (value) => FlLine(
            color: const Color(0xFFEEEEEE),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 25,
              reservedSize: 28,
              getTitlesWidget: (value, meta) => Text(
                '${value.toInt()}',
                style: TextStyle(
                  fontSize: 9,
                  color: AppColors.textLight,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 20,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= days.length) return const SizedBox();
                return Text(
                  days[idx],
                  style: TextStyle(
                    fontSize: 9,
                    color: AppColors.textLight,
                  ),
                );
              },
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primary,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withOpacity(0.15),
                  AppColors.primary.withOpacity(0.01),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//  Dropdown Filter 

class _DropdownFilter extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownFilter({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Colors.white, size: 18),
          dropdownColor: AppColors.primary,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          items: items
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        )),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// Stat Card

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String trend;
  final bool positive;

  const _StatCard({
    required this.label,
    required this.value,
    required this.trend,
    required this.positive,
  });

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textLight,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                positive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                size: 12,
                color: positive ? AppColors.success : AppColors.danger,
              ),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  trend,
                  style: TextStyle(
                    fontSize: 11,
                    color: positive
                        ? AppColors.success
                        : AppColors.danger,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Trend Badge 

class _TrendBadge extends StatelessWidget {
  final String label;
  final bool positive;

  const _TrendBadge({required this.label, required this.positive});

  @override
  Widget build(BuildContext context) {
    final color =
        positive ? AppColors.success : AppColors.danger;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

// Audit Log Card 

class _AuditLogCard extends StatelessWidget {
  final TeacherAuditLog log;
  const _AuditLogCard({required this.log});

  @override
  Widget build(BuildContext context) {
    Color iconBg;
    IconData iconData;
    Color statusColor;
    String statusLabel;

    switch (log.status) {
      case TeacherAuditStatus.suspicious:
        iconBg = AppColors.danger.withOpacity(0.1);
        iconData = Icons.warning_rounded;
        statusColor = AppColors.danger;
        statusLabel = 'SUSPICIOUS';
        break;
      case TeacherAuditStatus.verified:
        iconBg = AppColors.success.withOpacity(0.1);
        iconData = Icons.check_circle_rounded;
        statusColor = AppColors.success;
        statusLabel = 'VERIFIED';
        break;
      case TeacherAuditStatus.flagged:
        iconBg = AppColors.warning.withOpacity(0.1);
        iconData = Icons.flag_rounded;
        statusColor = AppColors.warning;
        statusLabel = 'FLAGGED';
        break;
    }

    return _WhiteCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconData, color: statusColor, size: 22),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        log.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${log.subject} • ${log.course}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded,
                        size: 11, color: AppColors.textLight),
                    const SizedBox(width: 4),
                    Text(
                      log.time,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(Icons.info_outline_rounded,
                        size: 11, color: AppColors.textLight),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        log.detail,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textLight,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Reusable White Card 

class _WhiteCard extends StatelessWidget {
  final Widget child;
  const _WhiteCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}

//  Nav Item 

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}