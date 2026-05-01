import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ReportsAuditApp());
}

class ReportsAuditApp extends StatelessWidget {
  const ReportsAuditApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reports & Audit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2962FF),
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
      ),
      home: const ReportsAuditScreen(),
    );
  }
}

// ─── Data Models ──────────────────────────────────────────────────────────────

enum AuditStatus { suspicious, verified, flagged }

class AuditLog {
  final String name;
  final String subject;
  final String course;
  final String time;
  final String detail;
  final AuditStatus status;

  const AuditLog({
    required this.name,
    required this.subject,
    required this.course,
    required this.time,
    required this.detail,
    required this.status,
  });
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class ReportsAuditScreen extends StatefulWidget {
  const ReportsAuditScreen({super.key});

  @override
  State<ReportsAuditScreen> createState() => _ReportsAuditScreenState();
}

class _ReportsAuditScreenState extends State<ReportsAuditScreen> {
  int _navIndex = 1;

  String _selectedClass = 'All Classes';
  String _selectedFaculty = 'All Faculty';
  String _selectedPeriod = 'Last 7 Days';

  final List<String> _classes = ['All Classes', 'CS101', 'MAT102', 'PHY105'];
  final List<String> _faculty = ['All Faculty', 'Dr. Sarah Jenkins', 'Prof. Michael Chen'];
  final List<String> _periods = ['Last 7 Days', 'Last 30 Days', 'This Semester'];

  final List<AuditLog> _logs = const [
    AuditLog(
      name: 'Dr. Sara',
      subject: 'CS101',
      course: 'Computer Science Fundamentals',
      time: '10:30 AM',
      detail: 'Duplicate IP Detected',
      status: AuditStatus.suspicious,
    ),
    AuditLog(
      name: 'Madam Azleen',
      subject: 'MAT1025',
      course: 'Linear Algebra',
      time: '11:45 AM',
      detail: 'Biometric is Confirmed',
      status: AuditStatus.verified,
    ),
    AuditLog(
      name: 'Esha Gul (Student)',
      subject: 'PHY105',
      course: 'Quantum Physics',
      time: '01:15 PM',
      detail: 'GPS Location (500m)',
      status: AuditStatus.flagged,
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

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.bar_chart_rounded, label: 'Reports'),
    _NavItem(icon: Icons.folder_rounded, label: 'Directory'),
    _NavItem(icon: Icons.settings_rounded, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(10),
          child: CircleAvatar(
            backgroundColor: const Color(0xFFE3E8FF),
            child: const Icon(Icons.bar_chart_rounded,
                color: Color(0xFF2962FF), size: 18),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Reports & Audit',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF212121),
              ),
            ),
            Text(
              'ADMIN DASHBOARD',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF9E9E9E),
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black54),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
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
                          children: const [
                            Text(
                              'Attendance Trends',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF212121),
                              ),
                            ),
                            Text(
                              'Details',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF2962FF),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'WEEKLY ATTENDANCE %',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF9E9E9E),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            Text(
                              '88.4%',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF212121),
                              ),
                            ),
                            SizedBox(width: 10),
                            _TrendBadge(label: '+2.4%', positive: true),
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
                  // Audit logs heade
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Recent Audit Logs',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF212121),
                        ),
                      ),
                      Text(
                        'See All',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF2962FF),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF2962FF),
        foregroundColor: Colors.white,
        elevation: 3,
        child: const Icon(Icons.description_rounded),
      ),
      bottomNavigationBar: _buildBottomNav(),
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
                onTap: () => setState(() => _navIndex = i),
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
                            ? const Color(0xFF2962FF)
                            : const Color(0xFF9E9E9E),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _navItems[i].label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              isActive ? FontWeight.w600 : FontWeight.w400,
                          color: isActive
                              ? const Color(0xFF2962FF)
                              : const Color(0xFF9E9E9E),
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

// ─── Line Chart ───────────────────────────────────────────────────────────────

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
                style: const TextStyle(
                  fontSize: 9,
                  color: Color(0xFFBDBDBD),
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
                  style: const TextStyle(
                    fontSize: 9,
                    color: Color(0xFFBDBDBD),
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
            color: const Color(0xFF2962FF),
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF2962FF).withOpacity(0.15),
                  const Color(0xFF2962FF).withOpacity(0.01),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Dropdown Filter ──────────────────────────────────────────────────────────

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
        color: const Color(0xFF2962FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Colors.white, size: 18),
          dropdownColor: const Color(0xFF2962FF),
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

// ─── Stat Card ────────────────────────────────────────────────────────────────

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
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF9E9E9E),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                positive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                size: 12,
                color: positive ? const Color(0xFF43A047) : const Color(0xFFE53935),
              ),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  trend,
                  style: TextStyle(
                    fontSize: 11,
                    color: positive
                        ? const Color(0xFF43A047)
                        : const Color(0xFFE53935),
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

// ─── Trend Badge ──────────────────────────────────────────────────────────────

class _TrendBadge extends StatelessWidget {
  final String label;
  final bool positive;

  const _TrendBadge({required this.label, required this.positive});

  @override
  Widget build(BuildContext context) {
    final color =
        positive ? const Color(0xFF43A047) : const Color(0xFFE53935);
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

// ─── Audit Log Card ───────────────────────────────────────────────────────────

class _AuditLogCard extends StatelessWidget {
  final AuditLog log;
  const _AuditLogCard({required this.log});

  @override
  Widget build(BuildContext context) {
    Color iconBg;
    IconData iconData;
    Color statusColor;
    String statusLabel;

    switch (log.status) {
      case AuditStatus.suspicious:
        iconBg = const Color(0xFFFFEBEE);
        iconData = Icons.warning_rounded;
        statusColor = const Color(0xFFE53935);
        statusLabel = 'SUSPICIOUS';
        break;
      case AuditStatus.verified:
        iconBg = const Color(0xFFE8F5E9);
        iconData = Icons.check_circle_rounded;
        statusColor = const Color(0xFF43A047);
        statusLabel = 'VERIFIED';
        break;
      case AuditStatus.flagged:
        iconBg = const Color(0xFFFFF3E0);
        iconData = Icons.flag_rounded;
        statusColor = const Color(0xFFFFA726);
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
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF212121),
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
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF757575),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded,
                        size: 11, color: Color(0xFFBDBDBD)),
                    const SizedBox(width: 4),
                    Text(
                      log.time,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFFBDBDBD),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.info_outline_rounded,
                        size: 11, color: Color(0xFFBDBDBD)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        log.detail,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFFBDBDBD),
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

// ─── Reusable White Card ──────────────────────────────────────────────────────

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

// ─── Nav Item ─────────────────────────────────────────────────────────────────

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}