import 'package:attendence_verification/widgets/gradient_button.dart';
import 'package:flutter/material.dart';
import '../../core/services/student_report_service.dart';
import '../../core/services/student_report_export_service.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/base_scaffold.dart';

class StudentReportScreen extends StatefulWidget {
  final bool isEmbedded;
  const StudentReportScreen({super.key, this.isEmbedded = false});

  @override
  State<StudentReportScreen> createState() => _StudentReportScreenState();
}

class _StudentReportScreenState extends State<StudentReportScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _data;

  String? _startDate;
  String? _endDate;
  String _statusFilter = 'All';
  int? _selectedClassId;
  String _selectedClassName = 'All Subjects';
  List<Map<String, dynamic>> _availableSubjects = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await StudentReportService.getMyReport(
        startDate: _startDate,
        endDate: _endDate,
        status: _statusFilter,
        classId: _selectedClassId,
      );
      if (mounted) {
        setState(() {
          _data = result;
          
          if (_availableSubjects.isEmpty) {
            final recs = result['records'] as List<dynamic>? ?? [];
            final Set<int> seen = {};
            for (var r in recs) {
              final cid = r['class_id'];
              if (cid != null && !seen.contains(cid)) {
                seen.add(cid);
                final cname = r['class_name'] ?? 'Unknown';
                final subj = r['subject'] != null ? ' (${r['subject']})' : '';
                _availableSubjects.add({
                  'id': cid,
                  'name': '$cname$subj',
                });
              }
            }
          }

          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(
              start: DateTime.parse(_startDate!),
              end: DateTime.parse(_endDate!),
            )
          : null,
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start.toString().split(' ')[0];
        _endDate = picked.end.toString().split(' ')[0];
      });
      _load();
    }
  }

  void _clearDateRange() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
    _load();
  }

  void _showDownloadOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('Download PDF'),
              onTap: () => _runDownload(() => StudentReportExportService.downloadMyPdf(
                    startDate: _startDate,
                    endDate: _endDate,
                    status: _statusFilter,
                    classId: _selectedClassId,
                  )),
            ),
            ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.green),
              title: const Text('Download Excel'),
              onTap: () => _runDownload(() => StudentReportExportService.downloadMyExcel(
                    startDate: _startDate,
                    endDate: _endDate,
                    status: _statusFilter,
                    classId: _selectedClassId,
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _runDownload(Future<void> Function() action) async {
    Navigator.pop(context);
    try {
      await action();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Downloaded successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bodyContent = Container(
      color: AppColors.background,
      child: RefreshIndicator(
        onRefresh: _load,
        color: AppColors.primary,
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : _error != null
                ? _buildError()
                : _buildBody(),
      ),
    );

    if (widget.isEmbedded) {
      return Scaffold(
        backgroundColor: AppColors.background,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _loading ? null : _showDownloadOptions,
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.download_rounded, color: Colors.white, size: 20),
          label: const Text('Download Report', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        body: bodyContent,
      );
    }

    return BaseScaffold(
      title: 'My Attendance Report',
      role: 'student',
      actions: [
        IconButton(
          icon: const Icon(Icons.download_outlined, color: Colors.white, size: 20),
          onPressed: _loading ? null : _showDownloadOptions,
        ),
      ],
      body: bodyContent,
    );
  }

  Widget _buildError() {
    return ListView(
      children: [
        const SizedBox(height: 120),
        const Icon(Icons.error_outline_rounded, size: 52, color: AppColors.danger),
        const SizedBox(height: 12),
        Center(child: Text(_error!, style: const TextStyle(color: AppColors.textSecondary))),
        const SizedBox(height: 20),
        Center(
          child: GradientButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: _load,
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    final details = _data?['student_details'] as Map<String, dynamic>? ?? {};
    final summary = _data?['summary'] as Map<String, dynamic>? ?? {};
    final records = _data?['records'] as List<dynamic>? ?? [];

    final totalClasses = summary['total_classes'] ?? 0;
    final presentCount = summary['present_count'] ?? 0;
    final absentCount = summary['absent_count'] ?? 0;
    final lateCount = summary['late_count'] ?? 0;
    final pct = (summary['attendance_percentage'] as num?)?.toDouble() ?? 0.0;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        // Student header card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(details['full_name'] ?? 'Student',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                'Roll #${details['roll_number'] ?? '-'}  •  ${details['class'] ?? '-'}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                'Teacher: ${details['teacher_name'] ?? 'Not Assigned'}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Filters
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _chip(_selectedClassName, onTap: _showSubjectPicker),
              const SizedBox(width: 8),
              _chip(_statusFilter == 'All' ? 'All Status' : _statusFilter, onTap: _showStatusSheet),
              const SizedBox(width: 8),
              _chip(
                _startDate != null && _endDate != null
                    ? '${_startDate!.substring(5)} to ${_endDate!.substring(5)}'
                    : 'Date Range',
                onTap: _pickDateRange,
              ),
              if (_startDate != null) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _clearDateRange,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: AppColors.danger, shape: BoxShape.circle),
                    child: const Icon(Icons.clear, color: Colors.white, size: 14),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Stats row
        Row(
          children: [
            _statBox('Total', '$totalClasses', AppColors.primary),
            const SizedBox(width: 8),
            _statBox('Present', '$presentCount', AppColors.success),
            const SizedBox(width: 8),
            _statBox('Absent', '$absentCount', AppColors.danger),
            const SizedBox(width: 8),
            _statBox('Late', '$lateCount', AppColors.warning),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Overall Attendance Rate',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              Text(
                '${pct.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: pct >= 75 ? AppColors.success : (pct >= 50 ? AppColors.warning : AppColors.danger),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // History
        const Text('Attendance History',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 10),

        if (records.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const Column(
              children: [
                Icon(Icons.calendar_today_outlined, size: 40, color: AppColors.textLight),
                SizedBox(height: 10),
                Text('No attendance records found', style: TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          )
        else
          ...records.map((r) => _historyTile(r)),
      ],
    );
  }

  Widget _statBox(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _historyTile(Map<String, dynamic> r) {
    final status = (r['status'] ?? '-').toString();
    final isPresent = status.toLowerCase() == 'present';
    final isLate = status.toLowerCase() == 'late';
    final color = isPresent ? AppColors.success : (isLate ? AppColors.warning : AppColors.danger);
    final bg = isPresent
        ? const Color(0xFFDCFCE7)
        : isLate
            ? const Color(0xFFFEF3C7)
            : const Color(0xFFFEE2E2);
    final icon = isPresent ? '✓' : (isLate ? '⏱' : '✗');

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
                Text(r['subject'] ?? 'Class',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 3),
                Text('📅 ${r['date'] ?? '-'}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                if ((r['remarks'] ?? '-') != '-') ...[
                  const SizedBox(height: 2),
                  Text(r['remarks'], style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
            child: Text(
              '$icon $status',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: Colors.white),
          ],
        ),
      ),
    );
  }

  void _showSubjectPicker() => showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          const Text('Select Subject', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  title: const Text('All Subjects', style: TextStyle(color: AppColors.textPrimary)),
                  trailing: _selectedClassId == null ? const Icon(Icons.check, color: AppColors.primary) : null,
                  onTap: () {
                    setState(() { _selectedClassId = null; _selectedClassName = 'All Subjects'; });
                    Navigator.pop(context);
                    _load();
                  },
                ),
                ..._availableSubjects.map((s) => ListTile(
                  title: Text(s['name'] ?? 'Unknown', style: const TextStyle(color: AppColors.textPrimary)),
                  trailing: _selectedClassId == s['id'] ? const Icon(Icons.check, color: AppColors.primary) : null,
                  onTap: () {
                    setState(() { _selectedClassId = s['id']; _selectedClassName = s['name'] ?? 'Unknown'; });
                    Navigator.pop(context);
                    _load();
                  },
                )).toList(),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  void _showStatusSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 8),
          for (final s in ['All', 'present', 'absent', 'late'])
            ListTile(
              title: Text(s == 'All' ? 'All Status' : s.toUpperCase(), style: const TextStyle(color: AppColors.textPrimary)),
              trailing: _statusFilter == s ? const Icon(Icons.check_rounded, color: AppColors.primary) : null,
              onTap: () { setState(() => _statusFilter = s); Navigator.pop(context); _load(); },
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}