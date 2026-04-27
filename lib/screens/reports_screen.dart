import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance Verification',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF1565C0),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      ),
      home: const ReportsAuditScreen(),
    );
  }
}

// ─────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────

enum AuditStatus { suspicious, verified, flagged }

class AuditLog {
  final String name;
  final String subject;
  final String time;
  final String detail;
  final AuditStatus status;

  const AuditLog({
    required this.name,
    required this.subject,
    required this.time,
    required this.detail,
    required this.status,
  });
}

final List<AuditLog> _auditLogs = [
  AuditLog(
    name: 'Dr. Sarah Jenkins',
    subject: 'CS101 • Computer Science Fundamentals',
    time: '10:30 AM',
    detail: 'Duplicate IP Detected',
    status: AuditStatus.suspicious,
  ),
  AuditLog(
    name: 'Prof. Michael Chen',
    subject: 'MAT1025 • Linear Algebra',
    time: '11:45 AM',
    detail: 'Biometric is Confirmed',
    status: AuditStatus.verified,
  ),
  AuditLog(
    name: 'James Wilson (Student)',
    subject: 'PHY105 • Quantum Physics',
    time: '01:15 PM',
    detail: 'GPS Location (500m)',
    status: AuditStatus.flagged,
  ),
];

// ─────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────

Color _statusColor(AuditStatus s) {
  switch (s) {
    case AuditStatus.suspicious:
      return const Color(0xFFE53935);
    case AuditStatus.verified:
      return const Color(0xFF2E7D32);
    case AuditStatus.flagged:
      return const Color(0xFFF57C00);
  }
}

String _statusLabel(AuditStatus s) {
  switch (s) {
    case AuditStatus.suspicious:
      return 'SUSPICIOUS';
    case AuditStatus.verified:
      return 'VERIFIED';
    case AuditStatus.flagged:
      return 'FLAGGED';
  }
}

IconData _statusIcon(AuditStatus s) {
  switch (s) {
    case AuditStatus.suspicious:
      return Icons.warning_amber_rounded;
    case AuditStatus.verified:
      return Icons.check_circle_outline;
    case AuditStatus.flagged:
      return Icons.flag_outlined;
  }
}

// ─────────────────────────────────────────────
// REUSABLE WIDGETS
// ─────────────────────────────────────────────

/// Dropdown filter chip
class FilterDropdown extends StatefulWidget {
  final String label;
  final List<String> options;

  const FilterDropdown({super.key, required this.label, required this.options});

  @override
  State<FilterDropdown> createState() => _FilterDropdownState();
}

class _FilterDropdownState extends State<FilterDropdown> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.label;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1565C0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selected,
          isDense: true,
          icon: const Icon(Icons.keyboard_arrow_down,
              color: Colors.white, size: 18),
          dropdownColor: const Color(0xFF1565C0),
          style: const TextStyle(
              color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
          items: [_selected, ...widget.options.where((o) => o != _selected)]
              .map((v) => DropdownMenuItem(
                    value: v,
                    child: Text(v,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 13)),
                  ))
              .toList(),
          onChanged: (v) => setState(() => _selected = v ?? _selected),
        ),
      ),
    );
  }
}

/// Stat card (Total Sessions / Flagged Logs)
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String trend;
  final bool trendPositive;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.trend,
    required this.trendPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFF9E9E9E),
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  trendPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 12,
                  color: trendPositive
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFFE53935),
                ),
                const SizedBox(width: 3),
                Text(
                  trend,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: trendPositive
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFE53935),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Audit log list item
class AuditLogItem extends StatelessWidget {
  final AuditLog log;

  const AuditLogItem({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(log.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(_statusIcon(log.status), color: color, size: 18),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  log.subject,
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF757575)),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time,
                        size: 11, color: Color(0xFFBDBDBD)),
                    const SizedBox(width: 4),
                    Text(log.time,
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFFBDBDBD))),
                    const SizedBox(width: 8),
                    const Icon(Icons.info_outline,
                        size: 11, color: Color(0xFFBDBDBD)),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        log.detail,
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFFBDBDBD)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Status badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _statusLabel(log.status),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Attendance line chart
class AttendanceLineChart extends StatelessWidget {
  const AttendanceLineChart({super.key});

  @override
  Widget build(BuildContext context) {
    // Weekly data Mon-Sun (~88% range with minor variance)
    final spots = [
      const FlSpot(0, 87),
      const FlSpot(1, 88),
      const FlSpot(2, 87.5),
      const FlSpot(3, 89),
      const FlSpot(4, 88.4),
      const FlSpot(5, 88),
      const FlSpot(6, 88.8),
    ];

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 100,
        gridData: FlGridData(
          show: true,
          horizontalInterval: 25,
          getDrawingHorizontalLine: (_) => FlLine(
            color: const Color(0xFFEEEEEE),
            strokeWidth: 1,
          ),
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 25,
              reservedSize: 28,
              getTitlesWidget: (value, _) => Text(
                value.toInt().toString(),
                style: const TextStyle(
                    fontSize: 10, color: Color(0xFFBDBDBD)),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              getTitlesWidget: (value, _) {
                const days = [
                  'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'
                ];
                final i = value.toInt();
                if (i < 0 || i >= days.length) return const SizedBox();
                return Text(
                  days[i],
                  style: const TextStyle(
                      fontSize: 9, color: Color(0xFFBDBDBD)),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: const Color(0xFF1565C0),
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1565C0).withOpacity(0.15),
                  const Color(0xFF1565C0).withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => const Color(0xFF1565C0),
            getTooltipItems: (spots) => spots
                .map((s) => LineTooltipItem(
                      '${s.y.toStringAsFixed(1)}%',
                      const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────

class ReportsAuditScreen extends StatefulWidget {
  const ReportsAuditScreen({super.key});

  @override
  State<ReportsAuditScreen> createState() => _ReportsAuditScreenState();
}

class _ReportsAuditScreenState extends State<ReportsAuditScreen> {
  int _selectedNavIndex = 1;

  final List<String> _navLabels = ['Home', 'Reports', 'Directory', 'Settings'];
  final List<IconData> _navIcons = [
    Icons.home_outlined,
    Icons.bar_chart_outlined,
    Icons.people_outline,
    Icons.settings_outlined,
  ];
  final List<IconData> _navIconsFilled = [
    Icons.home,
    Icons.bar_chart,
    Icons.people,
    Icons.settings,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── HEADER ──
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.assessment_outlined,
                          color: Color(0xFF1565C0), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Reports & Audit',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        Text(
                          'ADMIN DASHBOARD',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF9E9E9E),
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Icon(Icons.share_outlined,
                        color: Color(0xFF9E9E9E), size: 20),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── FILTER ROW ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    FilterDropdown(
                      label: 'All Classes',
                      options: ['Class 10', 'Class 11', 'Class 12'],
                    ),
                    FilterDropdown(
                      label: 'All Faculty',
                      options: [
                        'Dr. Sarah Jenkins',
                        'Prof. Michael Chen',
                        'James Wilson'
                      ],
                    ),
                    FilterDropdown(
                      label: 'Last 7 Days',
                      options: ['Last 30 Days', 'Last 3 Months', 'This Year'],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── ATTENDANCE TRENDS CARD ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Attendance Trends',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF1565C0),
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text('Details',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Metric
                      const Text(
                        'WEEKLY ATTENDANCE %',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF9E9E9E),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            '88.4%',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                Icon(Icons.arrow_upward,
                                    size: 13, color: Color(0xFF2E7D32)),
                                SizedBox(width: 2),
                                Text(
                                  '+2.4%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF2E7D32),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Line chart
                      SizedBox(
                        height: 140,
                        child: const AttendanceLineChart(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // ── STAT CARDS ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: const [
                    StatCard(
                      label: 'Total Sessions',
                      value: '1,240',
                      trend: '5% vs last week',
                      trendPositive: true,
                    ),
                    SizedBox(width: 12),
                    StatCard(
                      label: 'Flagged Logs',
                      value: '12',
                      trend: '2% improvement',
                      trendPositive: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── RECENT AUDIT LOGS ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Audit Logs',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF1565C0),
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('See All',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: _auditLogs
                      .map((log) => AuditLogItem(log: log))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),

      // ── FLOATING ACTION BUTTON ──
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.download_outlined),
      ),

      // ── BOTTOM NAV ──
      bottomNavigationBar: Container(
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
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_navLabels.length, (i) {
                final selected = _selectedNavIndex == i;
                return GestureDetector(
                  onTap: () => setState(() => _selectedNavIndex = i),
                  child: SizedBox(
                    width: 72,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          selected
                              ? _navIconsFilled[i]
                              : _navIcons[i],
                          size: 22,
                          color: selected
                              ? const Color(0xFF1565C0)
                              : const Color(0xFF9E9E9E),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _navLabels[i],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? const Color(0xFF1565C0)
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
      ),
    );
  }
}