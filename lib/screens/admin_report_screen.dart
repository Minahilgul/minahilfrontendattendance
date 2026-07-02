import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/base_scaffold.dart';
import '../core/services/admin_report_service.dart';
import '../core/theme/app_colors.dart';


// MODELS


enum StudentStatus { good, warning, critical, noData }

class StudentRecord {
  final int studentId;
  final String studentName;
  final String rollNo;
  final String className;
  final String teacherName;
  final int present;
  final int absent;
  final int total;
  final double pct;
  final StudentStatus status;

  const StudentRecord({
    required this.studentId,
    required this.studentName,
    required this.rollNo,
    required this.className,
    required this.teacherName,
    required this.present,
    required this.absent,
    required this.total,
    required this.pct,
    required this.status,
  });

  factory StudentRecord.fromMap(Map<String, dynamic> m) {
    StudentStatus status;
    switch (m['status']) {
      case 'critical': status = StudentStatus.critical; break;
      case 'warning':  status = StudentStatus.warning;  break;
      case 'no_data':  status = StudentStatus.noData;   break;
      default:         status = StudentStatus.good;
    }
    return StudentRecord(
      studentId:   m['student_id'] ?? 0,
      studentName: m['student_name'] ?? '',
      rollNo:      m['roll_no'] ?? '-',
      className:   m['class_name'] ?? '-',
      teacherName: m['teacher_name'] ?? 'Not Assigned',
      present:     m['present'] ?? 0,
      absent:      m['absent'] ?? 0,
      total:       m['total'] ?? 0,
      pct:         (m['pct'] as num?)?.toDouble() ?? 0.0,
      status:      status,
    );
  }
}


// HELPERS


Color _statusColor(StudentStatus s) {
  switch (s) {
    case StudentStatus.critical: return AppColors.danger;
    case StudentStatus.warning:  return AppColors.warning;
    case StudentStatus.good:     return AppColors.success;
    case StudentStatus.noData:   return AppColors.textLight;
  }
}

String _statusLabel(StudentStatus s) {
  switch (s) {
    case StudentStatus.critical: return 'CRITICAL';
    case StudentStatus.warning:  return 'WARNING';
    case StudentStatus.good:     return 'GOOD';
    case StudentStatus.noData:   return 'NO DATA';
  }
}

IconData _statusIcon(StudentStatus s) {
  switch (s) {
    case StudentStatus.critical: return Icons.warning_amber_rounded;
    case StudentStatus.warning:  return Icons.error_outline;
    case StudentStatus.good:     return Icons.check_circle_outline;
    case StudentStatus.noData:   return Icons.remove_circle_outline;
  }
}


// WIDGETS


class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final bool trendPositive;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.sub,
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
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textLight, letterSpacing: 0.6)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Row(children: [
              Icon(trendPositive ? Icons.arrow_upward : Icons.arrow_downward, size: 12,
                  color: trendPositive ? AppColors.success : AppColors.danger),
              const SizedBox(width: 3),
              Flexible(child: Text(sub, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                  color: trendPositive ? AppColors.success : AppColors.danger), overflow: TextOverflow.ellipsis)),
            ]),
          ],
        ),
      ),
    );
  }
}

class StudentListItem extends StatelessWidget {
  final StudentRecord record;
  const StudentListItem({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(record.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.4), width: 1.2),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar with initials
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
            child: Center(
              child: Text(
                record.studentName.isNotEmpty ? record.studentName[0].toUpperCase() : '?',
                style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + Roll No
                Row(children: [
                  Flexible(child: Text(record.studentName,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      overflow: TextOverflow.ellipsis)),
                  if (record.rollNo != '-') ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(4)),
                      child: Text('#${record.rollNo}', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                    ),
                  ]
                ]),
                const SizedBox(height: 3),
                // Class
                Row(children: [
                  Icon(Icons.class_outlined, size: 12, color: AppColors.textLight),
                  const SizedBox(width: 4),
                  Text(record.className, style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ]),
                const SizedBox(height: 2),
                // Teacher
                Row(children: [
                  Icon(Icons.person_outline, size: 12, color: AppColors.textLight),
                  const SizedBox(width: 4),
                  Flexible(child: Text(record.teacherName,
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis)),
                ]),
                const SizedBox(height: 8),
                // Present / Absent pills
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.check_circle, size: 12, color: AppColors.success),
                      const SizedBox(width: 4),
                      Text('${record.present} Present',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success)),
                    ]),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.cancel, size: 12, color: AppColors.danger),
                      const SizedBox(width: 4),
                      Text('${record.absent} Absent',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.danger)),
                    ]),
                  ),
                  const Spacer(),
                  Text('${record.pct.toStringAsFixed(1)}%',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color)),
                ]),
                if (record.total > 0) ...[
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: record.pct / 100,
                      minHeight: 5,
                      backgroundColor: color.withOpacity(0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Status badge
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(_statusLabel(record.status),
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.4)),
              ),
              const SizedBox(height: 4),
              Icon(_statusIcon(record.status), color: color, size: 16),
            ],
          ),
        ],
      ),
    );
  }
}

class AttendanceLineChart extends StatelessWidget {
  final List<Map<String, dynamic>> chartData;
  const AttendanceLineChart({super.key, required this.chartData});

  @override
  Widget build(BuildContext context) {
    if (chartData.isEmpty) {
      return Center(child: Text('No data', style: TextStyle(color: AppColors.textLight, fontSize: 13)));
    }

    final spots = chartData.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), (e.value['pct'] as num?)?.toDouble() ?? 0.0))
        .toList();

    final labels = chartData.map((d) {
      final l = (d['label'] as String? ?? '');
      return l.length >= 3 ? l.substring(0, 3) : l;
    }).toList();

    return LineChart(LineChartData(
      minY: 0, maxY: 100,
      gridData: FlGridData(
        show: true, horizontalInterval: 25, drawVerticalLine: false,
        getDrawingHorizontalLine: (_) => const FlLine(color: Color(0xFFEEEEEE), strokeWidth: 1),
      ),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(sideTitles: SideTitles(
          showTitles: true, interval: 25, reservedSize: 28,
          getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: TextStyle(fontSize: 10, color: AppColors.textLight)),
        )),
        bottomTitles: AxisTitles(sideTitles: SideTitles(
          showTitles: true, reservedSize: 22,
          getTitlesWidget: (v, _) {
            final i = v.toInt();
            if (i < 0 || i >= labels.length) return const SizedBox();
            return Text(labels[i], style: TextStyle(fontSize: 9, color: AppColors.textLight));
          },
        )),
      ),
      lineBarsData: [LineChartBarData(
        spots: spots, isCurved: true, curveSmoothness: 0.35,
        color: AppColors.primary, barWidth: 2.5, isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: true, gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(0.15), AppColors.primary.withOpacity(0.0)],
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
        )),
      )],
      lineTouchData: LineTouchData(touchTooltipData: LineTouchTooltipData(
        getTooltipColor: (_) => AppColors.primary,
        getTooltipItems: (spots) => spots.map((s) => LineTooltipItem(
          '${s.y.toStringAsFixed(1)}%',
          const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
        )).toList(),
      )),
    ));
  }
}


// MAIN SCREEN


class ReportsAuditScreen extends StatefulWidget {
  const ReportsAuditScreen({super.key});

  @override
  State<ReportsAuditScreen> createState() => _ReportsAuditScreenState();
}

class _ReportsAuditScreenState extends State<ReportsAuditScreen> {
  // Filters
  int?   _selectedClassId;
  String _selectedClassName = 'All Classes';
  int?   _selectedTeacherId;
  String _selectedTeacherName = 'All Faculty';
  int    _selectedDays = 7;
  String _selectedDaysLabel = 'Last 7 Days';

  // Data
  List<Map<String, dynamic>> _classes  = [];
  List<Map<String, dynamic>> _teachers = [];
  Map<String, dynamic>       _stats    = {};
  List<Map<String, dynamic>> _chartData   = [];
  List<StudentRecord>        _students    = [];

  bool _loadingStats    = true;
  bool _loadingChart    = true;
  bool _loadingStudents = true;
  bool _showAllStudents = false;

  final Map<String, int> _daysOptions = {
    'Last 7 Days':   7,
    'Last 30 Days':  30,
    'Last 3 Months': 90,
  };

  @override
  void initState() { super.initState(); _loadAll(); }

  Future<void> _loadAll() async {
    await Future.wait([_loadClasses(), _loadTeachers()]);
    _loadStats();
    _loadChart();
    _loadStudents();
  }

  Future<void> _loadClasses() async {
    final c = await AdminReportService.getClasses();
    if (mounted) setState(() => _classes = c);
  }

  Future<void> _loadTeachers() async {
    final t = await AdminReportService.getTeachers();
    if (mounted) setState(() => _teachers = t);
  }

  Future<void> _loadStats() async {
    setState(() => _loadingStats = true);
    final s = await AdminReportService.getStats(
        classId: _selectedClassId, teacherId: _selectedTeacherId, days: _selectedDays);
    if (mounted) setState(() { _stats = s; _loadingStats = false; });
  }

  Future<void> _loadChart() async {
    setState(() => _loadingChart = true);
    final d = await AdminReportService.getChartData(
        classId: _selectedClassId, teacherId: _selectedTeacherId, days: _selectedDays);
    if (mounted) setState(() { _chartData = d; _loadingChart = false; });
  }

  Future<void> _loadStudents() async {
    setState(() => _loadingStudents = true);
    final list = await AdminReportService.getStudentsList(
        classId: _selectedClassId, teacherId: _selectedTeacherId, days: _selectedDays);
    if (mounted) setState(() {
      _students = list.map((m) => StudentRecord.fromMap(m)).toList();
      _loadingStudents = false;
    });
  }

  void _onFilterChanged() {
    setState(() => _showAllStudents = false);
    _loadStats();
    _loadChart();
    _loadStudents();
  }

  String get _attendancePct {
    final v = (_stats['attendance_pct'] as num?)?.toDouble() ?? 0.0;
    return '${v.toStringAsFixed(1)}%';
  }
  String get _trendLabel {
    final t = (_stats['trend'] as num?)?.toDouble() ?? 0.0;
    return t >= 0 ? '+${t.toStringAsFixed(1)}%' : '${t.toStringAsFixed(1)}%';
  }
  bool get _trendPositive => ((_stats['trend'] as num?)?.toDouble() ?? 0.0) >= 0;

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Reports & Audit',
      role: 'admin',
      actions: [
        IconButton(icon: const Icon(Icons.share_outlined, color: Colors.white, size: 20), onPressed: () {}),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.download_outlined),
      ),
      body: Container(
        color: AppColors.background,
        child: RefreshIndicator(
          onRefresh: _loadAll,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── FILTERS ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Wrap(
                    spacing: 8, runSpacing: 8,
                    children: [
                      _filterChip(_selectedClassName, _showClassPicker),
                      _filterChip(_selectedTeacherName, _showTeacherPicker),
                      _filterChip(_selectedDaysLabel, _showDaysPicker),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── CHART ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('Attendance Trends', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(foregroundColor: AppColors.primary, padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                            child: const Text('Details', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          ),
                        ]),
                        const SizedBox(height: 4),
                        Text('ATTENDANCE %', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textLight, letterSpacing: 0.5)),
                        const SizedBox(height: 4),
                        _loadingStats
                            ? SizedBox(height: 40, child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))))
                            : Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                Text(_attendancePct, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                                const SizedBox(width: 8),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(children: [
                                    Icon(_trendPositive ? Icons.arrow_upward : Icons.arrow_downward, size: 13,
                                        color: _trendPositive ? AppColors.success : AppColors.danger),
                                    const SizedBox(width: 2),
                                    Text(_trendLabel, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                                        color: _trendPositive ? AppColors.success : AppColors.danger)),
                                  ]),
                                ),
                              ]),
                        const SizedBox(height: 12),
                        SizedBox(height: 140, child: _loadingChart
                            ? Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2))
                            : AttendanceLineChart(chartData: _chartData)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // ── STAT CARDS ROW 1: Sessions + Students ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _loadingStats
                      ? Row(children: [_shimmerCard(), const SizedBox(width: 12), _shimmerCard()])
                      : Row(children: [
                          StatCard(label: 'Total Sessions', value: '${_stats['total_sessions'] ?? 0}',
                              sub: _selectedDaysLabel, trendPositive: true),
                          const SizedBox(width: 12),
                          StatCard(label: 'Total Students', value: '${_stats['total_students'] ?? 0}',
                              sub: _selectedClassName, trendPositive: true),
                        ]),
                ),

                const SizedBox(height: 10),

                // ── STAT CARDS ROW 2: Present + Absent ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _loadingStudents
                      ? Row(children: [_shimmerCard(), const SizedBox(width: 12), _shimmerCard()])
                      : Row(children: [
                          StatCard(
                            label: 'Present Students',
                            value: '${_students.fold(0, (sum, s) => sum + s.present)}',
                            sub: 'Total present students',
                            trendPositive: true,
                          ),
                          const SizedBox(width: 12),
                          StatCard(
                            label: 'Absent Students',
                            value: '${_students.fold(0, (sum, s) => sum + s.absent)}',
                            sub: 'Total absent students',
                            trendPositive: false,
                          ),
                        ]),
                ),

                const SizedBox(height: 16),

                //  STUDENTS LIST 
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(
                      _selectedClassName == 'All Classes' ? 'All Students' : '$_selectedClassName Students',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _showAllStudents = !_showAllStudents),
                      style: TextButton.styleFrom(foregroundColor: AppColors.primary, padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                      child: Text(_showAllStudents ? 'Hide' : 'See All', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ]),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _loadingStudents
                      ? Center(child: Padding(padding: const EdgeInsets.all(32), child: CircularProgressIndicator(color: AppColors.primary)))
                      : _students.isEmpty
                          ? _emptyState()
                          : _showAllStudents
                              ? _buildDetailList()
                              : _buildSummaryCards(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //  Helpers 

  Widget _filterChip(String label, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(width: 4),
        const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 18),
      ]),
    ),
  );

  Widget _shimmerCard() => Expanded(
    child: Container(
      height: 90,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))),
    ),
  );

  // Summary: existing StudentListItem cards (with present/absent pills)
  Widget _buildSummaryCards() => Column(
    children: _students.map((s) => StudentListItem(record: s)).toList(),
  );

  // Detail: simple rows — name + Present/Absent badge at end
  Widget _buildDetailList() => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
    ),
    child: Column(
      children: _students.asMap().entries.map((entry) {
        final i = entry.key;
        final s = entry.value;
        // A student is "present" if they have more present than absent
        final isPresent = s.total == 0 ? null : s.present >= s.absent;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Number
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text('${i + 1}',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name + class
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.studentName,
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text('${s.className}  •  Roll# ${s.rollNo}',
                            style: TextStyle(fontSize: 11, color: AppColors.textLight)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Present / Absent badge
                  if (isPresent == null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.textLight.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.remove_circle_outline, size: 14, color: AppColors.textLight),
                        const SizedBox(width: 4),
                        Text('No Data', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textLight)),
                      ]),
                    )
                  else if (isPresent)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.check_circle, size: 14, color: AppColors.success),
                        const SizedBox(width: 4),
                        Text('Present', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success)),
                      ]),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.cancel, size: 14, color: AppColors.danger),
                        const SizedBox(width: 4),
                        Text('Absent', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.danger)),
                      ]),
                    ),
                ],
              ),
            ),
            if (i < _students.length - 1)
              const Divider(height: 1, indent: 54, endIndent: 16),
          ],
        );
      }).toList(),
    ),
  );

  Widget _emptyState() => Container(
    padding: const EdgeInsets.all(32),
    alignment: Alignment.center,
    child: Column(children: [
      Icon(Icons.people_outline, size: 40, color: AppColors.textLight),
      const SizedBox(height: 12),
      Text('No students found', style: TextStyle(color: AppColors.textLight, fontSize: 14)),
    ]),
  );

  //  Bottom Sheet Pickers 

  void _showClassPicker() => showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (_) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        const Text('Select Class', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        const Divider(),
        ListTile(
          title: const Text('All Classes'),
          trailing: _selectedClassId == null ? Icon(Icons.check, color: AppColors.primary) : null,
          onTap: () { setState(() { _selectedClassId = null; _selectedClassName = 'All Classes'; }); Navigator.pop(context); _onFilterChanged(); },
        ),
        ..._classes.map((c) => ListTile(
          title: Text(c['class_name'] ?? ''),
          trailing: _selectedClassId == c['id'] ? Icon(Icons.check, color: AppColors.primary) : null,
          onTap: () { setState(() { _selectedClassId = c['id']; _selectedClassName = c['class_name'] ?? ''; }); Navigator.pop(context); _onFilterChanged(); },
        )),
        const SizedBox(height: 16),
      ],
    ),
  );

  void _showTeacherPicker() => showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (_) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        const Text('Select Faculty', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        const Divider(),
        ListTile(
          title: const Text('All Faculty'),
          trailing: _selectedTeacherId == null ? Icon(Icons.check, color: AppColors.primary) : null,
          onTap: () { setState(() { _selectedTeacherId = null; _selectedTeacherName = 'All Faculty'; }); Navigator.pop(context); _onFilterChanged(); },
        ),
        ..._teachers.map((t) => ListTile(
          title: Text(t['name'] ?? ''),
          trailing: _selectedTeacherId == t['id'] ? Icon(Icons.check, color: AppColors.primary) : null,
          onTap: () { setState(() { _selectedTeacherId = t['id']; _selectedTeacherName = t['name'] ?? ''; }); Navigator.pop(context); _onFilterChanged(); },
        )),
        const SizedBox(height: 16),
      ],
    ),
  );

  void _showDaysPicker() => showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (_) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        const Text('Select Period', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        const Divider(),
        ..._daysOptions.entries.map((e) => ListTile(
          title: Text(e.key),
          trailing: _selectedDaysLabel == e.key ? Icon(Icons.check, color: AppColors.primary) : null,
          onTap: () { setState(() { _selectedDays = e.value; _selectedDaysLabel = e.key; }); Navigator.pop(context); _onFilterChanged(); },
        )),
        const SizedBox(height: 16),
      ],
    ),
  );
}