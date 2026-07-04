import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../widgets/base_scaffold.dart';
import '../../core/services/admin_report_service.dart';
import '../../core/theme/app_colors.dart';


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
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.sub,
    required this.trendPositive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
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
      ),
    );
  }
}

class StudentListItem extends StatelessWidget {
  final StudentRecord record;
  final VoidCallback? onTap;
  const StudentListItem({super.key, required this.record, this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(record.status);
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
    ));
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

  // Advanced filters state
  bool _showAdvancedFilters = false;
  String? _filterStudentName;
  String? _filterStatus;
  String? _filterDate;
  String? _filterStartDate;
  String? _filterEndDate;
  int? _filterSessionId;

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
      classId: _selectedClassId,
      teacherId: _selectedTeacherId,
      days: _selectedDays,
      date: _filterDate,
      startDate: _filterStartDate,
      endDate: _filterEndDate,
      status: _filterStatus,
      sessionId: _filterSessionId,
      studentName: _filterStudentName,
    );
    if (mounted) setState(() { _stats = s; _loadingStats = false; });
  }

  Future<void> _loadChart() async {
    setState(() => _loadingChart = true);
    final d = await AdminReportService.getChartData(
      classId: _selectedClassId,
      teacherId: _selectedTeacherId,
      days: _selectedDays,
      date: _filterDate,
      startDate: _filterStartDate,
      endDate: _filterEndDate,
      status: _filterStatus,
      sessionId: _filterSessionId,
      studentName: _filterStudentName,
    );
    if (mounted) setState(() { _chartData = d; _loadingChart = false; });
  }

  Future<void> _loadStudents() async {
    setState(() => _loadingStudents = true);
    final list = await AdminReportService.getStudentsList(
      classId: _selectedClassId,
      teacherId: _selectedTeacherId,
      days: _selectedDays,
      date: _filterDate,
      startDate: _filterStartDate,
      endDate: _filterEndDate,
      status: _filterStatus,
      sessionId: _filterSessionId,
      studentName: _filterStudentName,
    );
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

  // ── NEW: open the sessions list bottom sheet ──
  void _showSessionsList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => const SessionsListSheet(),
    );
  }

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
                      _filterChipAdvanced('Advanced Filters', _showAdvancedFilters, () {
                        setState(() {
                          _showAdvancedFilters = !_showAdvancedFilters;
                        });
                      }),
                    ],
                  ),
                ),

                if (_showAdvancedFilters) _buildAdvancedFiltersCard(),

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
                              sub: _selectedDaysLabel, trendPositive: true, onTap: _showSessionsList),
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
                      _selectedTeacherName != 'All Faculty'
                          ? '$_selectedTeacherName Students'
                          : (_selectedClassName == 'All Classes' ? 'All Students' : '$_selectedClassName Students'),
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

  Widget _filterChipAdvanced(String label, bool isSelected, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary, width: 1),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(
          isSelected ? Icons.filter_alt_off : Icons.filter_alt,
          color: isSelected ? Colors.white : AppColors.primary,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.primary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ]),
    ),
  );

  Widget _buildAdvancedFiltersCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Advanced Filters',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Student Name',
                      hintText: 'Search student...',
                      prefixIcon: const Icon(Icons.search, size: 18),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _filterStudentName = val.isEmpty ? null : val;
                      });
                      _onFilterChanged();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Session ID',
                      hintText: 'Enter session ID',
                      prefixIcon: const Icon(Icons.pin, size: 18),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _filterSessionId = int.tryParse(val);
                      });
                      _onFilterChanged();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _filterStatus,
                    decoration: InputDecoration(
                      labelText: 'Status',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('All Statuses')),
                      DropdownMenuItem(value: 'present', child: Text('Present')),
                      DropdownMenuItem(value: 'absent', child: Text('Absent')),
                      DropdownMenuItem(value: 'late', child: Text('Late')),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _filterStatus = val;
                      });
                      _onFilterChanged();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selectFilterDate,
                    icon: Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                    label: Text(
                      _filterDate ?? 'Select Date',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selectFilterDateRange,
                    icon: Icon(Icons.date_range, size: 16, color: AppColors.primary),
                    label: Text(
                      _filterStartDate != null && _filterEndDate != null
                          ? '${_filterStartDate!.substring(5)} to ${_filterEndDate!.substring(5)}'
                          : 'Select Date Range',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _resetFilters,
                  icon: const Icon(Icons.clear_all, size: 16, color: Colors.white),
                  label: const Text('Reset', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectFilterDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _filterDate = picked.toString().split(' ')[0];
        _filterStartDate = null;
        _filterEndDate = null;
      });
      _onFilterChanged();
    }
  }

  Future<void> _selectFilterDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
      initialDateRange: _filterStartDate != null && _filterEndDate != null
          ? DateTimeRange(
              start: DateTime.parse(_filterStartDate!),
              end: DateTime.parse(_filterEndDate!),
            )
          : null,
    );
    if (picked != null) {
      setState(() {
        _filterStartDate = picked.start.toString().split(' ')[0];
        _filterEndDate = picked.end.toString().split(' ')[0];
        _filterDate = null;
      });
      _onFilterChanged();
    }
  }

  void _resetFilters() {
    setState(() {
      _filterStudentName = null;
      _filterStatus = null;
      _filterDate = null;
      _filterStartDate = null;
      _filterEndDate = null;
      _filterSessionId = null;
      _selectedClassId = null;
      _selectedClassName = 'All Classes';
      _selectedTeacherId = null;
      _selectedTeacherName = 'All Faculty';
    });
    _onFilterChanged();
  }

  Widget _shimmerCard() => Expanded(
    child: Container(
      height: 90,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))),
    ),
  );

  // Summary: existing StudentListItem cards (with present/absent pills)
  Widget _buildSummaryCards() => Column(
    children: _students.map((s) => StudentListItem(
      record: s,
      onTap: () => _openStudentReport(context, s),
    )).toList(),
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
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _openStudentReport(context, s),
              child: Padding(
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
      Text('No records found', style: TextStyle(color: AppColors.textLight, fontSize: 14)),
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
          onTap: () {
            setState(() {
              _selectedTeacherId = null;
              _selectedTeacherName = 'All Faculty';
            });
            Navigator.pop(context);
            _onFilterChanged();
          },
        ),
        Expanded(
          child: ListView(
            shrinkWrap: true,
            children: _teachers.map((t) {
              final id = t['id'];
              final name = t['name'] ?? t['username'] ?? '';
              final isSelected = _selectedTeacherId == id;
              return ListTile(
                title: Text(name),
                trailing: isSelected ? Icon(Icons.check, color: AppColors.primary) : null,
                onTap: () {
                  setState(() {
                    _selectedTeacherId = id;
                    _selectedTeacherName = name;
                  });
                  Navigator.pop(context);
                  _onFilterChanged();
                },
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    ),
  );

  void _openStudentReport(BuildContext context, StudentRecord s) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) => StudentReportModal(student: s, onUpdateNeeded: _onFilterChanged),
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: FadeTransition(
            opacity: anim1,
            child: child,
          ),
        );
      },
    );
  }

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

// ── TEACHER LIST COMPONENT ──
class TeacherList extends StatelessWidget {
  final List<Map<String, dynamic>> teachers;
  final int? selectedTeacherId;
  final Function(int? id, String name) onTeacherSelected;

  const TeacherList({
    super.key,
    required this.teachers,
    required this.selectedTeacherId,
    required this.onTeacherSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Faculty Members',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 82,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: teachers.length + 1,
            itemBuilder: (context, index) {
              final isAllFaculty = index == 0;
              final teacher = isAllFaculty ? null : teachers[index - 1];
              final id = isAllFaculty ? null : (teacher!['id'] as int?);
              final name = isAllFaculty ? 'All Faculty' : (teacher!['name'] as String? ?? 'Unknown');
              
              final isSelected = selectedTeacherId == id;
              final cardColor = isSelected ? AppColors.primary : Colors.white;
              final textColor = isSelected ? Colors.white : AppColors.textPrimary;
              final avatarBg = isSelected ? Colors.white.withOpacity(0.2) : AppColors.primary.withOpacity(0.12);

              return GestureDetector(
                onTap: () => onTeacherSelected(id, name),
                child: Container(
                  width: 104,
                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      )
                    ],
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: avatarBg,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            isAllFaculty ? 'ALL' : (name.isNotEmpty ? name[0].toUpperCase() : '?'),
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        name,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── STUDENT REPORT MODAL ──
class StudentReportModal extends StatefulWidget {
  final StudentRecord student;
  final VoidCallback? onUpdateNeeded;

  const StudentReportModal({super.key, required this.student, this.onUpdateNeeded});

  @override
  State<StudentReportModal> createState() => _StudentReportModalState();
}

class _StudentReportModalState extends State<StudentReportModal> with SingleTickerProviderStateMixin {
  bool _loading = true;
  bool _hasError = false;
  Map<String, dynamic>? _reportData;
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _scaleAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );
    _animController.forward();
    _loadReport();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadReport() async {
    setState(() {
      _loading = true;
      _hasError = false;
    });
    try {
      final data = await AdminReportService.getStudentReport(widget.student.studentId);
      if (data.isNotEmpty && data.containsKey('student_details')) {
        setState(() {
          _reportData = data;
          _loading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.82),
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Student Attendance Report',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Content
              Expanded(
                child: _buildBody(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5),
            ),
            const SizedBox(height: 14),
            Text(
              'Loading attendance records...',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 44, color: AppColors.danger),
            const SizedBox(height: 12),
            Text(
              'Failed to load report',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Could not retrieve details from the server.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textLight, fontSize: 11),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 36,
              child: ElevatedButton(
                onPressed: _loadReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Try Again', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      );
    }

    final details = _reportData?['student_details'] as Map<String, dynamic>? ?? {};
    final summary = _reportData?['summary'] as Map<String, dynamic>? ?? {};
    final records = _reportData?['records'] as List<dynamic>? ?? [];

    final fullName = details['full_name'] ?? widget.student.studentName;
    final rollNo = details['roll_number'] ?? widget.student.rollNo;
    final className = details['class'] ?? widget.student.className;
    final teacherName = details['teacher_name'] ?? widget.student.teacherName;

    final totalClasses = summary['total_classes'] ?? 0;
    final presentCount = summary['present_count'] ?? 0;
    final absentCount = summary['absent_count'] ?? 0;
    final lateCount = summary['late_count'] ?? 0;
    final pct = (summary['attendance_percentage'] as num?)?.toDouble() ?? 0.0;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Student details card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _detailRow('Full Name', fullName, Icons.person_outline),
                const SizedBox(height: 6),
                _detailRow('Roll Number', rollNo, Icons.tag),
                const SizedBox(height: 6),
                _detailRow('Class', className, Icons.class_outlined),
                const SizedBox(height: 6),
                _detailRow('Teacher Name', teacherName, Icons.assignment_ind_outlined),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Attendance Summary
          Text(
            'Attendance Summary',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          
          // Stats Row
          Row(
            children: [
              _summaryBox('Total Classes', '$totalClasses', AppColors.primary),
              const SizedBox(width: 6),
              _summaryBox('Present', '$presentCount', AppColors.success),
              const SizedBox(width: 6),
              _summaryBox('Absent', '$absentCount', AppColors.danger),
              const SizedBox(width: 6),
              _summaryBox('Late', '$lateCount', AppColors.warning),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Overall Attendance Rate',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${pct.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: pct >= 75 ? AppColors.success : (pct >= 50 ? AppColors.warning : AppColors.danger),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Full History Table
          Text(
            'Attendance History Logs',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          if (records.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 28, color: AppColors.textLight),
                  const SizedBox(height: 8),
                  Text(
                    'No attendance record available',
                    style: TextStyle(color: AppColors.textLight, fontSize: 12),
                  ),
                ],
              ),
            )
          else
            _buildRecordsTable(records),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(fontSize: 11, color: AppColors.textPrimary, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Widget _summaryBox(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.18)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordsTable(List<dynamic> records) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(2.2),
            1: FlexColumnWidth(2.0),
            2: FlexColumnWidth(2.0),
            3: FlexColumnWidth(2.3),
            4: FlexColumnWidth(1.2),
          },
          border: TableBorder.symmetric(
            inside: BorderSide(color: AppColors.border, width: 0.8),
          ),
          children: [
            // Table Header
            TableRow(
              decoration: BoxDecoration(color: AppColors.background),
              children: [
                _tableHeaderCell('Date'),
                _tableHeaderCell('Status'),
                _tableHeaderCell('Subject'),
                _tableHeaderCell('Remarks'),
                _tableHeaderCell('Edit'),
              ],
            ),
            // Table Rows
            ...records.map((r) {
              final date = r['date'] ?? '-';
              final status = r['status'] ?? '-';
              final subject = r['subject'] ?? '-';
              final remarks = r['remarks'] ?? '-';
              final int? attendanceId = r['id'] as int?;

              Color statusColor;
              if (status.toString().toLowerCase() == 'present') {
                statusColor = AppColors.success;
              } else if (status.toString().toLowerCase() == 'late') {
                statusColor = AppColors.warning;
              } else {
                statusColor = AppColors.danger;
              }

              return TableRow(
                children: [
                  _tableCell(date, alignment: Alignment.centerLeft),
                  _tableStatusCell(status, statusColor),
                  _tableCell(subject),
                  _tableCell(remarks),
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: IconButton(
                      icon: Icon(Icons.edit, size: 14, color: AppColors.primary),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: attendanceId == null ? null : () => _editAttendanceRecord(attendanceId, status),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _tableHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _tableCell(String text, {Alignment alignment = Alignment.centerLeft}) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _tableStatusCell(String status, Color color) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          status,
          style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Future<void> _editAttendanceRecord(int attendanceId, String currentStatus) async {
    String? newStatus = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(
            'Edit Attendance Status',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () { Navigator.pop(context, 'Present'); },
              child: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
                  SizedBox(width: 8),
                  Text('Present'),
                ],
              ),
            ),
            SimpleDialogOption(
              onPressed: () { Navigator.pop(context, 'Late'); },
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 18),
                  SizedBox(width: 8),
                  Text('Late'),
                ],
              ),
            ),
            SimpleDialogOption(
              onPressed: () { Navigator.pop(context, 'Absent'); },
              child: const Row(
                children: [
                  Icon(Icons.cancel_rounded, color: AppColors.danger, size: 18),
                  SizedBox(width: 8),
                  Text('Absent'),
                ],
              ),
            ),
          ],
        );
      },
    );

    if (newStatus != null && newStatus.toLowerCase() != currentStatus.toLowerCase()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final result = await AdminReportService.updateAttendance(attendanceId, newStatus);

      Navigator.pop(context); // Close loading spinner

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Attendance updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        _loadReport();
        widget.onUpdateNeeded?.call();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to update attendance'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }
}

// ── SESSIONS LIST BOTTOM SHEET (NEW) ──
// Shows all sessions with their timing and active/inactive status.
// A switch lets the admin toggle a session's status on the fly.
class SessionsListSheet extends StatefulWidget {
  const SessionsListSheet({super.key});

  @override
  State<SessionsListSheet> createState() => _SessionsListSheetState();
}

class _SessionsListSheetState extends State<SessionsListSheet> {
  bool _loading = true;
  List<Map<String, dynamic>> _sessions = [];

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() => _loading = true);
    final list = await AdminReportService.getSessions();
    if (mounted) setState(() { _sessions = list; _loading = false; });
  }

  Future<void> _toggleStatus(int index) async {
    final id = _sessions[index]['id'] as int;
    final result = await AdminReportService.toggleSessionStatus(id);
    if (result['success'] == true) {
      setState(() {
        _sessions[index] = {
          ..._sessions[index],
          'status': result['status'],
          'end_time': result['end_time'], // NEW: keep displayed time in sync with the toggle
        };
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Failed to update session status'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text('All Sessions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Expanded(
              child: _loading
                  ? Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : _sessions.isEmpty
                      ? Center(child: Text('No sessions found', style: TextStyle(color: AppColors.textLight)))
                      : ListView.separated(
                          controller: scrollController,
                          itemCount: _sessions.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final s = _sessions[index];
                            final isActive = s['status'] == 'active';
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: (isActive ? AppColors.success : AppColors.textLight).withOpacity(0.4),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          s['teacher_name'] ?? 'Unknown',
                                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                        ),
                                        const SizedBox(height: 2),
                                        Row(children: [
                                          Icon(Icons.class_outlined, size: 12, color: AppColors.textLight),
                                          const SizedBox(width: 4),
                                          Text(
                                            s['class_name'] ?? 'Unknown',
                                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                                          ),
                                        ]),
                                        const SizedBox(height: 4),
                                        Row(children: [
                                          Icon(Icons.access_time, size: 12, color: AppColors.textLight),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${s['start_time'] ?? '-'} - ${s['end_time'] ?? 'Ongoing'}',
                                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                          ),
                                        ]),
                                        const SizedBox(height: 2),
                                        Text(s['date'] ?? '', style: TextStyle(fontSize: 10, color: AppColors.textLight)),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        isActive ? 'Active' : 'Inactive',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: isActive ? AppColors.success : AppColors.textLight,
                                        ),
                                      ),
                                      Switch(
                                        value: isActive,
                                        activeColor: AppColors.success,
                                        onChanged: (_) => _toggleStatus(index),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}