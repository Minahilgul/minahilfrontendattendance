import 'dart:async';
import 'package:attendence_verification/widgets/gradient_button.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../widgets/base_scaffold.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/class_service.dart';
import '../../core/services/teacher_report_service.dart';
import '../../core/theme/app_colors.dart';


Widget _responsive(BuildContext context, Widget child) {
  final width = MediaQuery.of(context).size.width;
  if (width < 800) return child;
  return Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 900),
      child: child,
    ),
  );
}

int? _asInt(dynamic v) => v is int ? v : int.tryParse('${v ?? ''}');

Color _pctColor(double pct) =>
    pct >= 75 ? AppColors.success : (pct >= 50 ? AppColors.warning : AppColors.danger);

// models

enum _Status { good, warning, critical, noData }

class _StudentRecord {
  final int studentId;
  final String studentName;
  final String rollNo;
  final String className;
  final int present;
  final int absent;
  final int total;
  final double pct;
  final _Status status;

  const _StudentRecord({
    required this.studentId,
    required this.studentName,
    required this.rollNo,
    required this.className,
    required this.present,
    required this.absent,
    required this.total,
    required this.pct,
    required this.status,
  });

  factory _StudentRecord.fromMap(Map<String, dynamic> m) {
    _Status status;
    switch (m['status']) {
      case 'critical':
        status = _Status.critical;
        break;
      case 'warning':
        status = _Status.warning;
        break;
      case 'no_data':
        status = _Status.noData;
        break;
      default:
        status = _Status.good;
    }
    return _StudentRecord(
      studentId: _asInt(m['student_id']) ?? 0,
      studentName: '${m['student_name'] ?? ''}',
      rollNo: '${m['roll_no'] ?? '-'}',
      className: '${m['class_name'] ?? '-'}',
      present: _asInt(m['present']) ?? 0,
      absent: _asInt(m['absent']) ?? 0,
      total: _asInt(m['total']) ?? 0,
      pct: (m['pct'] as num?)?.toDouble() ?? 0.0,
      status: status,
    );
  }
}

Color _statusColor(_Status s) {
  switch (s) {
    case _Status.critical:
      return AppColors.danger;
    case _Status.warning:
      return AppColors.warning;
    case _Status.good:
      return AppColors.success;
    case _Status.noData:
      return AppColors.textLight;
  }
}

String _statusLabel(_Status s) {
  switch (s) {
    case _Status.critical:
      return 'CRITICAL';
    case _Status.warning:
      return 'WARNING';
    case _Status.good:
      return 'GOOD';
    case _Status.noData:
      return 'NO DATA';
  }
}

IconData _statusIcon(_Status s) {
  switch (s) {
    case _Status.critical:
      return Icons.warning_amber_rounded;
    case _Status.warning:
      return Icons.error_outline;
    case _Status.good:
      return Icons.check_circle_outline;
    case _Status.noData:
      return Icons.remove_circle_outline;
  }
}

// widgets

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final bool trendPositive;

  const _StatCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.trendPositive,
  });

  @override
  Widget build(BuildContext context) {
    final c = trendPositive ? AppColors.success : AppColors.danger;
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
            Text(label.toUpperCase(),
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textLight, letterSpacing: 0.6)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Row(children: [
              Icon(trendPositive ? Icons.arrow_upward : Icons.arrow_downward, size: 12, color: c),
              const SizedBox(width: 3),
              Flexible(
                child: Text(sub,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: c),
                    overflow: TextOverflow.ellipsis),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class _StudentTile extends StatelessWidget {
  final _StudentRecord record;
  final VoidCallback? onTap;
  const _StudentTile({required this.record, this.onTap});

  Widget _pill(IconData icon, String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
        ]),
      );

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
                  Row(children: [
                    Flexible(
                      child: Text(record.studentName,
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          overflow: TextOverflow.ellipsis),
                    ),
                    if (record.rollNo != '-') ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(4)),
                        child: Text('#${record.rollNo}',
                            style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ]),
                  const SizedBox(height: 3),
                  Row(children: [
                    Icon(Icons.class_outlined, size: 12, color: AppColors.textLight),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(record.className,
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    _pill(Icons.check_circle, '${record.present} Present', AppColors.success),
                    const SizedBox(width: 8),
                    _pill(Icons.cancel, '${record.absent} Absent', AppColors.danger),
                    const Spacer(),
                    Text('${record.pct.toStringAsFixed(1)}%',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color)),
                  ]),
                  if (record.total > 0) ...[
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (record.pct / 100).clamp(0.0, 1.0),
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
            Column(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(_statusLabel(record.status),
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.4)),
              ),
              const SizedBox(height: 4),
              Icon(_statusIcon(record.status), color: color, size: 16),
            ]),
          ],
        ),
      ),
    );
  }
}

class _TrendChart extends StatelessWidget {
  final List<Map<String, dynamic>> chartData;
  const _TrendChart({required this.chartData});

  @override
  Widget build(BuildContext context) {
    if (chartData.isEmpty) {
      return Center(child: Text('No data', style: TextStyle(color: AppColors.textLight, fontSize: 13)));
    }

    final spots = chartData
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), (e.value['pct'] as num?)?.toDouble() ?? 0.0))
        .toList();
    final labels = chartData.map((d) => '${d['label'] ?? ''}').toList();
    final double labelInterval = labels.length > 7 ? (labels.length / 6).ceilToDouble() : 1.0;

    return LineChart(LineChartData(
      minX: 0,
      maxX: (spots.length - 1).toDouble(),
      minY: 0,
      maxY: 100,
      gridData: FlGridData(
        show: true,
        horizontalInterval: 25,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (_) => const FlLine(color: Color(0xFFEEEEEE), strokeWidth: 1),
      ),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 25,
            reservedSize: 28,
            getTitlesWidget: (v, _) =>
                Text(v.toInt().toString(), style: TextStyle(fontSize: 10, color: AppColors.textLight)),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 22,
            interval: labelInterval,
            getTitlesWidget: (v, _) {
              if (v != v.roundToDouble()) return const SizedBox();
              final i = v.toInt();
              if (i < 0 || i >= labels.length) return const SizedBox();
              return Text(labels[i],
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.textLight));
            },
          ),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.35,
          color: AppColors.primary,
          barWidth: 2.5,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [AppColors.primary.withOpacity(0.15), AppColors.primary.withOpacity(0.0)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => AppColors.primary,
          getTooltipItems: (spots) => spots
              .map((s) => LineTooltipItem(
                    '${s.y.toStringAsFixed(1)}%',
                    const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                  ))
              .toList(),
        ),
      ),
    ));
  }
}

// screen

class TeacherReportScreen extends StatefulWidget {
  const TeacherReportScreen({super.key});

  @override
  State<TeacherReportScreen> createState() => _TeacherReportScreenState();
}

enum _Tab { students, sessions, classes }

class _TeacherReportScreenState extends State<TeacherReportScreen> {
  _Tab _activeTab = _Tab.students;

  // summaries
  List<Map<String, dynamic>> _sessionsSummary = [];
  List<Map<String, dynamic>> _classesSummary = [];
  bool _loadingSummaries = false;

  // filters
  int? _selectedClassId;
  String _selectedClassName = 'All Classes';
  int _selectedDays = 30;
  String _selectedDaysLabel = 'This Month';

  // advanced filters
  bool _showAdvancedFilters = false;
  String? _filterStudentName;
  String? _filterStatus;
  String? _filterDate;
  String? _filterStartDate;
  String? _filterEndDate;
  int? _filterSessionId;
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _sessionCtrl = TextEditingController();

  // data
  List<Map<String, dynamic>> _classes = [];
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _chartData = [];
  List<_StudentRecord> _students = [];

  bool _loadingStats = true;
  bool _loadingChart = true;
  bool _loadingStudents = true;
  bool _showAllStudents = false;
  String? _error;
  int _reqId = 0;
  Timer? _debounce;

  final Map<String, int> _daysOptions = const {
    'Today': 1,
    'This Month': 30,
    'Last 3 Months': 90,
  };

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _nameCtrl.dispose();
    _sessionCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    await _loadClasses();
    _onFilterChanged();
  }

  Future<void> _loadClasses() async {
    try {
      final list = await ClassService.fetchClasses();
      final myId = _asInt(AuthService.currentUser?['id']);
      final mine = list.where((c) {
        if (myId == null || !c.containsKey('teacher_id')) return true;
        return _asInt(c['teacher_id']) == myId;
      }).toList();
      if (mounted) setState(() => _classes = mine);
    } catch (e) {
      print('Error loading classes: $e');
    }
  }

  void _onFilterChanged() {
    final req = ++_reqId;
    setState(() {
      _showAllStudents = false;
      _error = null;
    });
    _loadStats(req);
    _loadChart(req);
    _loadStudents(req);
    _loadSummaries(req);
  }

  void _onFilterTyped() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), _onFilterChanged);
  }

  String _errText(Object e) => e.toString().replaceFirst('Exception: ', '');

  Future<void> _loadStats(int req) async {
    setState(() => _loadingStats = true);
    try {
      final s = await TeacherReportService.getMyStats(
        classId: _selectedClassId,
        date: _filterDate,
        startDate: _filterStartDate,
        endDate: _filterEndDate,
        days: _selectedDays,
        status: _filterStatus,
        sessionId: _filterSessionId,
        studentName: _filterStudentName,
      );
      if (!mounted || req != _reqId) return;
      setState(() {
        _stats = s;
        _loadingStats = false;
      });
    } catch (e) {
      if (!mounted || req != _reqId) return;
      setState(() {
        _stats = {};
        _loadingStats = false;
        _error = _errText(e);
      });
    }
  }

  Future<void> _loadChart(int req) async {
    setState(() => _loadingChart = true);
    try {
      final d = await TeacherReportService.getChartData(
        classId: _selectedClassId,
        date: _filterDate,
        startDate: _filterStartDate,
        endDate: _filterEndDate,
        days: _selectedDays,
        status: _filterStatus,
        sessionId: _filterSessionId,
        studentName: _filterStudentName,
      );
      if (!mounted || req != _reqId) return;
      setState(() {
        _chartData = d;
        _loadingChart = false;
      });
    } catch (e) {
      if (!mounted || req != _reqId) return;
      setState(() {
        _chartData = [];
        _loadingChart = false;
        _error = _errText(e);
      });
    }
  }

  Future<void> _loadStudents(int req) async {
    setState(() => _loadingStudents = true);
    try {
      final list = await TeacherReportService.getMyStudents(
        classId: _selectedClassId,
        studentName: _filterStudentName,
        date: _filterDate,
        startDate: _filterStartDate,
        endDate: _filterEndDate,
        days: _selectedDays,
        status: _filterStatus,
        sessionId: _filterSessionId,
      );
      if (!mounted || req != _reqId) return;
      setState(() {
        _students = list.map((m) => _StudentRecord.fromMap(m)).toList();
        _loadingStudents = false;
      });
    } catch (e) {
      if (!mounted || req != _reqId) return;
      setState(() {
        _students = [];
        _loadingStudents = false;
        _error = _errText(e);
      });
    }
  }

  Future<void> _loadSummaries(int req) async {
    setState(() => _loadingSummaries = true);
    try {
      final s = await TeacherReportService.getSessionsSummary(
        classId: _selectedClassId,
        days: _selectedDays,
        date: _filterDate,
        startDate: _filterStartDate,
        endDate: _filterEndDate,
        status: _filterStatus,
      );
      final c = await TeacherReportService.getClassesSummary(
        days: _selectedDays,
        date: _filterDate,
        startDate: _filterStartDate,
        endDate: _filterEndDate,
      );
      if (!mounted || req != _reqId) return;
      setState(() {
        _sessionsSummary = s;
        _classesSummary = c;
        _loadingSummaries = false;
      });
    } catch (e) {
      if (!mounted || req != _reqId) return;
      setState(() {
        _sessionsSummary = [];
        _classesSummary = [];
        _loadingSummaries = false;
        _error = _errText(e);
      });
    }
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
      title: 'Reports',
      role: 'teacher',
      showBackButton: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
          tooltip: 'Refresh',
          onPressed: () => _loadAll(),
        ),
      ],
      body: Container(
        color: AppColors.background,
        child: RefreshIndicator(
          onRefresh: _loadAll,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 80),
            child: _responsive(
              context,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _filterChip(_selectedClassName, _showClassPicker),
                        _filterChip(_selectedDaysLabel, _showDaysPicker),
                        _filterChipAdvanced('Advanced Filters', _showAdvancedFilters,
                            () => setState(() => _showAdvancedFilters = !_showAdvancedFilters)),
                      ],
                    ),
                  ),
                  if (_showAdvancedFilters) _buildAdvancedFiltersCard(),
                  if (_error != null) _buildErrorBanner(),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(children: [
                        _tabChip('By Student', _Tab.students),
                        const SizedBox(width: 8),
                        _tabChip('By Session', _Tab.sessions),
                        const SizedBox(width: 8),
                        _tabChip('By Class', _Tab.classes),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_activeTab == _Tab.students)
                    ..._buildStudentsTab()
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildSummaryTabContent(),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildStudentsTab() {
    final presentTotal = _students.fold<int>(0, (sum, s) => sum + s.present);
    final absentTotal = _students.fold<int>(0, (sum, s) => sum + s.absent);

    return [
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
              Text('Attendance Trends',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text('ATTENDANCE %',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textLight, letterSpacing: 0.5)),
              const SizedBox(height: 4),
              _loadingStats
                  ? SizedBox(
                      height: 40,
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                        ),
                      ),
                    )
                  : Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text(_attendancePct,
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(children: [
                          Icon(_trendPositive ? Icons.arrow_upward : Icons.arrow_downward,
                              size: 13, color: _trendPositive ? AppColors.success : AppColors.danger),
                          const SizedBox(width: 2),
                          Text(_trendLabel,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _trendPositive ? AppColors.success : AppColors.danger)),
                        ]),
                      ),
                    ]),
              const SizedBox(height: 12),
              SizedBox(
                height: 140,
                child: _loadingChart
                    ? Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2))
                    : _TrendChart(chartData: _chartData),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 14),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _loadingStats
            ? Row(children: [_shimmerCard(), const SizedBox(width: 12), _shimmerCard()])
            : Row(children: [
                _StatCard(
                    label: 'Total Sessions',
                    value: '${_stats['total_sessions'] ?? 0}',
                    sub: _selectedDaysLabel,
                    trendPositive: true),
                const SizedBox(width: 12),
                _StatCard(
                    label: 'Total Students',
                    value: '${_stats['total_students'] ?? 0}',
                    sub: _selectedClassName,
                    trendPositive: true),
              ]),
      ),
      const SizedBox(height: 10),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _loadingStudents
            ? Row(children: [_shimmerCard(), const SizedBox(width: 12), _shimmerCard()])
            : Row(children: [
                _StatCard(
                    label: 'Present Students',
                    value: '$presentTotal',
                    sub: 'Total present students',
                    trendPositive: true),
                const SizedBox(width: 12),
                _StatCard(
                    label: 'Absent Students',
                    value: '$absentTotal',
                    sub: 'Total absent students',
                    trendPositive: false),
              ]),
      ),
      const SizedBox(height: 16),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Flexible(
            child: Text(
              _selectedClassName == 'All Classes' ? 'My Students' : '$_selectedClassName Students',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: () => setState(() => _showAllStudents = !_showAllStudents),
            style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            child: Text(_showAllStudents ? 'Hide' : 'See All',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ]),
      ),
      const SizedBox(height: 10),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _loadingStudents
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            : _students.isEmpty
                ? _emptyState('No records found')
                : (_showAllStudents ? _buildDetailList() : _buildSummaryCards()),
      ),
    ];
  }

  // helpers

  Widget _buildErrorBanner() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.danger.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.danger.withOpacity(0.3)),
          ),
          child: Row(children: [
            Icon(Icons.error_outline, size: 18, color: AppColors.danger),
            const SizedBox(width: 8),
            Expanded(
              child: Text(_error ?? '', style: TextStyle(fontSize: 12, color: AppColors.danger)),
            ),
            TextButton(onPressed: _onFilterChanged, child: const Text('Retry')),
          ]),
        ),
      );

  Widget _filterChip(String label, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Flexible(
              child: Text(label,
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis),
            ),
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
            Icon(isSelected ? Icons.filter_alt_off : Icons.filter_alt,
                color: isSelected ? Colors.white : AppColors.primary, size: 16),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ]),
        ),
      );

  Widget _buildAdvancedFiltersCard() {
    final btnStyle = OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: BorderSide(color: Colors.grey.shade300),
    );
    final fieldPad = const EdgeInsets.symmetric(horizontal: 12, vertical: 8);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Advanced Filters',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Student Name',
                    hintText: 'Search student...',
                    prefixIcon: const Icon(Icons.search, size: 18),
                    contentPadding: fieldPad,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onChanged: (val) {
                    _filterStudentName = val.trim().isEmpty ? null : val.trim();
                    _onFilterTyped();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _sessionCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Session ID',
                    hintText: 'Enter session ID',
                    prefixIcon: const Icon(Icons.pin, size: 18),
                    contentPadding: fieldPad,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onChanged: (val) {
                    _filterSessionId = int.tryParse(val.trim());
                    _onFilterTyped();
                  },
                ),
              ),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  key: ValueKey('status-${_filterStatus ?? 'all'}'),
                  value: _filterStatus,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    contentPadding: fieldPad,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All Statuses')),
                    DropdownMenuItem(value: 'present', child: Text('Present')),
                    DropdownMenuItem(value: 'absent', child: Text('Absent')),
                    DropdownMenuItem(value: 'late', child: Text('Late')),
                  ],
                  onChanged: (val) {
                    setState(() => _filterStatus = val);
                    _onFilterChanged();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _selectFilterDate,
                  icon: Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                  label: Text(_filterDate ?? 'Select Date',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
                      overflow: TextOverflow.ellipsis),
                  style: btnStyle,
                ),
              ),
            ]),
            const SizedBox(height: 12),
            Row(children: [
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
                  style: btnStyle,
                ),
              ),
              const SizedBox(width: 12),
              GradientButton.icon(
                onPressed: _resetFilters,
                icon: const Icon(Icons.clear_all, size: 16, color: Colors.white),
                label: const Text('Reset', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ]),
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
          ? DateTimeRange(start: DateTime.parse(_filterStartDate!), end: DateTime.parse(_filterEndDate!))
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
    _debounce?.cancel();
    _nameCtrl.clear();
    _sessionCtrl.clear();
    setState(() {
      _filterStudentName = null;
      _filterStatus = null;
      _filterDate = null;
      _filterStartDate = null;
      _filterEndDate = null;
      _filterSessionId = null;
      _selectedClassId = null;
      _selectedClassName = 'All Classes';
    });
    _onFilterChanged();
  }

  Widget _shimmerCard() => Expanded(
        child: Container(
          height: 90,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
            ),
          ),
        ),
      );

  Widget _buildSummaryCards() => Column(
        children: _students
            .map((s) => _StudentTile(record: s, onTap: () => _openStudentReport(s)))
            .toList(),
      );

  Widget _badge(IconData icon, String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
        ]),
      );

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
            final bool? isPresent = s.total == 0 ? null : s.present >= s.absent;
            return Column(children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _openStudentReport(s),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(6)),
                      child: Center(
                        child: Text('${i + 1}',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                      ),
                    ),
                    const SizedBox(width: 12),
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
                    if (isPresent == null)
                      _badge(Icons.remove_circle_outline, 'No Data', AppColors.textLight)
                    else if (isPresent)
                      _badge(Icons.check_circle, 'Present', AppColors.success)
                    else
                      _badge(Icons.cancel, 'Absent', AppColors.danger),
                  ]),
                ),
              ),
              if (i < _students.length - 1) const Divider(height: 1, indent: 54, endIndent: 16),
            ]);
          }).toList(),
        ),
      );

  Widget _emptyState(String text) => Container(
        padding: const EdgeInsets.all(32),
        alignment: Alignment.center,
        child: Column(children: [
          Icon(Icons.people_outline, size: 40, color: AppColors.textLight),
          const SizedBox(height: 12),
          Text(text, style: TextStyle(color: AppColors.textLight, fontSize: 14)),
        ]),
      );

  // pickers

  void _showClassPicker() => showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        builder: (_) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              const Text('Select Class', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              const Divider(),
              ListTile(
                title: const Text('All Classes'),
                trailing: _selectedClassId == null ? Icon(Icons.check, color: AppColors.primary) : null,
                onTap: () {
                  setState(() {
                    _selectedClassId = null;
                    _selectedClassName = 'All Classes';
                  });
                  Navigator.pop(context);
                  _onFilterChanged();
                },
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: _classes.map((c) {
                    final id = _asInt(c['id']);
                    final className = '${c['class_name'] ?? c['name'] ?? 'Class ${c['id']}'}';
                    final subject = '${c['subject'] ?? ''}'.trim();
                    final displayName = subject.isNotEmpty ? '$className ($subject)' : className;
                    return ListTile(
                      title: Text(displayName),
                      trailing: _selectedClassId == id ? Icon(Icons.check, color: AppColors.primary) : null,
                      onTap: () {
                        setState(() {
                          _selectedClassId = id;
                          _selectedClassName = displayName;
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
        ),
      );

  void _showDaysPicker() => showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        builder: (_) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              const Text('Select Period', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              const Divider(),
              ..._daysOptions.entries.map((e) => ListTile(
                    title: Text(e.key),
                    trailing: _selectedDaysLabel == e.key ? Icon(Icons.check, color: AppColors.primary) : null,
                    onTap: () {
                      setState(() {
                        _selectedDays = e.value;
                        _selectedDaysLabel = e.key;
                      });
                      Navigator.pop(context);
                      _onFilterChanged();
                    },
                  )),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );

  void _openStudentReport(_StudentRecord s) {
    showDialog(context: context, builder: (_) => _StudentReportModal(student: s));
  }

  Widget _tabChip(String label, _Tab tab) {
    final active = _activeTab == tab;
    return ChoiceChip(
      label: Text(label,
          style: TextStyle(
              color: active ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
      selected: active,
      selectedColor: AppColors.primary,
      backgroundColor: Colors.white,
      checkmarkColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: active ? AppColors.primary : Colors.grey.shade300),
      ),
      onSelected: (val) {
        if (val) setState(() => _activeTab = tab);
      },
    );
  }

  // summary tabs

  Widget _buildSummaryTabContent() {
    if (_loadingSummaries) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }
    return _activeTab == _Tab.sessions ? _buildSessionsList() : _buildClassesList();
  }

  BoxDecoration get _cardDeco => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
        border: Border.all(color: Colors.grey.shade200),
      );

  Widget _buildSessionsList() {
    if (_sessionsSummary.isEmpty) return _emptyState('No sessions records found');
    return Column(
      children: _sessionsSummary.map((s) {
        final double pct = (s['attendance_pct'] as num?)?.toDouble() ?? 0.0;
        final verdict = '${s['verdict'] ?? 'No verification'}';
        Color verdictColor = Colors.grey;
        if (verdict == 'Teacher Present') verdictColor = AppColors.success;
        if (verdict == 'Teacher NOT Present') verdictColor = AppColors.danger;
        if (verdict == 'Awaiting responses') verdictColor = AppColors.warning;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: _cardDeco,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Session #${s['session_id'] ?? '-'}',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: verdictColor.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                  child: Text(verdict.toUpperCase(),
                      style: TextStyle(fontSize: 10, color: verdictColor, fontWeight: FontWeight.w800)),
                ),
              ]),
              const SizedBox(height: 6),
              Row(children: [
                Icon(Icons.class_outlined, size: 14, color: AppColors.textLight),
                const SizedBox(width: 4),
                Flexible(
                  child: Text('${s['class_name'] ?? '-'}',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                      overflow: TextOverflow.ellipsis),
                ),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Icon(Icons.access_time, size: 14, color: AppColors.textLight),
                const SizedBox(width: 4),
                Text('${s['date_time'] ?? '-'}', style: TextStyle(fontSize: 11, color: AppColors.textLight)),
              ]),
              const Divider(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Flexible(
                  child: Text(
                    'Present: ${s['present_count'] ?? 0} | Late: ${s['late_count'] ?? 0} | Absent: ${s['absent_count'] ?? 0}',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                  ),
                ),
                Text('$pct%', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _pctColor(pct))),
              ]),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (pct / 100).clamp(0.0, 1.0),
                  backgroundColor: Colors.grey.shade100,
                  valueColor: AlwaysStoppedAnimation<Color>(_pctColor(pct)),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildClassesList() {
    if (_classesSummary.isEmpty) return _emptyState('No classes records found');
    return Column(
      children: _classesSummary.map((c) {
        final double pct = (c['attendance_pct'] as num?)?.toDouble() ?? 0.0;
        final isActive = c['status'] == 'active';
        final subject = '${c['subject'] ?? ''}'.trim();
        final title = subject.isNotEmpty ? '${c['class_name']} ($subject)' : '${c['class_name'] ?? '-'}';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: _cardDeco,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(
                  child: Text(title,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: (isActive ? AppColors.success : AppColors.textLight).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('${c['status'] ?? ''}'.toUpperCase(),
                      style: TextStyle(
                          fontSize: 8,
                          color: isActive ? AppColors.success : AppColors.textLight,
                          fontWeight: FontWeight.w800)),
                ),
              ]),
              const Divider(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Total Sessions: ${c['total_sessions'] ?? 0}',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('Enrolled Students: ${c['total_students'] ?? 0}',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ]),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('$pct%', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _pctColor(pct))),
                  const SizedBox(height: 2),
                  Text('Avg Attendance',
                      style: TextStyle(fontSize: 9, color: AppColors.textLight, fontWeight: FontWeight.w600)),
                ]),
              ]),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// read-only student report dialog (teachers cannot edit attendance or export from here)

class _StudentReportModal extends StatefulWidget {
  final _StudentRecord student;
  const _StudentReportModal({required this.student});

  @override
  State<_StudentReportModal> createState() => _StudentReportModalState();
}

class _StudentReportModalState extends State<_StudentReportModal> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _reportData;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await TeacherReportService.getStudentReport(widget.student.studentId);
      if (!mounted) return;
      if (data.isNotEmpty && data.containsKey('student_details')) {
        setState(() {
          _reportData = data;
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Could not retrieve details from the server.';
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 560,
          maxHeight: MediaQuery.of(context).size.height * 0.82,
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(
                  child: Text('Student Attendance Report',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ]),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Flexible(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5)),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.error_outline_rounded, size: 44, color: AppColors.danger),
          const SizedBox(height: 12),
          Text('Failed to load report',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: AppColors.textLight, fontSize: 11)),
          const SizedBox(height: 16),
          SizedBox(
            height: 36,
            child: GradientButton(
              onPressed: _loadReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Try Again',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
        ]),
      );
    }

    final details = _reportData?['student_details'] as Map<String, dynamic>? ?? {};
    final summary = _reportData?['summary'] as Map<String, dynamic>? ?? {};
    final records = _reportData?['records'] as List<dynamic>? ?? [];

    final fullName = '${details['full_name'] ?? widget.student.studentName}';
    final rollNo = '${details['roll_number'] ?? widget.student.rollNo}';
    final className = '${details['class'] ?? widget.student.className}';

    final pct = (summary['attendance_percentage'] as num?)?.toDouble() ?? 0.0;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(children: [
              _detailRow('Full Name', fullName, Icons.person_outline),
              const SizedBox(height: 6),
              _detailRow('Roll Number', rollNo, Icons.tag),
              const SizedBox(height: 6),
              _detailRow('Class', className, Icons.class_outlined),
            ]),
          ),
          const SizedBox(height: 18),
          Text('Attendance Summary',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Row(children: [
            _summaryBox('Total Classes', '${summary['total_classes'] ?? 0}', AppColors.primary),
            const SizedBox(width: 6),
            _summaryBox('Present', '${summary['present_count'] ?? 0}', AppColors.success),
            const SizedBox(width: 6),
            _summaryBox('Absent', '${summary['absent_count'] ?? 0}', AppColors.danger),
            const SizedBox(width: 6),
            _summaryBox('Late', '${summary['late_count'] ?? 0}', AppColors.warning),
          ]),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Overall Attendance Rate',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              Text('${pct.toStringAsFixed(1)}%',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _pctColor(pct))),
            ]),
          ),
          const SizedBox(height: 18),
          Text('Attendance History Logs',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
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
              child: Column(children: [
                Icon(Icons.calendar_today_outlined, size: 28, color: AppColors.textLight),
                const SizedBox(height: 8),
                Text('No attendance record available', style: TextStyle(color: AppColors.textLight, fontSize: 12)),
              ]),
            )
          else
            _buildRecordsTable(records),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, IconData icon) => Row(children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text('$label: ', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
        Expanded(
          child: Text(value,
              textAlign: TextAlign.end,
              style: TextStyle(fontSize: 11, color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        ),
      ]);

  Widget _summaryBox(String label, String value, Color color) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.18)),
          ),
          child: Column(children: [
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 2),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          ]),
        ),
      );

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
            2: FlexColumnWidth(2.2),
            3: FlexColumnWidth(2.4),
          },
          border: TableBorder.symmetric(inside: BorderSide(color: AppColors.border, width: 0.8)),
          children: [
            TableRow(
              decoration: BoxDecoration(color: AppColors.background),
              children: [
                _headerCell('Date'),
                _headerCell('Status'),
                _headerCell('Subject'),
                _headerCell('Remarks'),
              ],
            ),
            ...records.map((r) {
              final status = '${r['status'] ?? '-'}';
              final lower = status.toLowerCase();
              final statusColor = lower == 'present'
                  ? AppColors.success
                  : (lower == 'late' ? AppColors.warning : AppColors.danger);
              return TableRow(children: [
                _cell('${r['date'] ?? '-'}'),
                _statusCell(status, statusColor),
                _cell('${r['subject'] ?? '-'}'),
                _cell('${r['remarks'] ?? '-'}'),
              ]);
            }),
          ],
        ),
      ),
    );
  }

  Widget _headerCell(String text) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      );

  Widget _cell(String text) => Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Text(text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
      );

  Widget _statusCell(String status, Color color) => Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
          child: Text(status, style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w700)),
        ),
      );
}