import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/services/attendance_service.dart';
import '../../core/services/session_service.dart';
import '../../core/theme/app_colors.dart';

enum AttendanceStatus { none, present, late, absent }

class StudentModel {
  final String name;
  final String rollNo;
  final String initials;
  final Color avatarColor;
  final int studentId;
  AttendanceStatus status;

  StudentModel({
    required this.name,
    required this.rollNo,
    required this.initials,
    required this.avatarColor,
    required this.studentId,
    this.status = AttendanceStatus.none,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    final name = (json['username'] ?? json['name'] ?? 'Unknown').toString();
    String initials = name
        .split(' ')
        .where((e) => e.isNotEmpty)
        .map((e) => e[0])
        .take(2)
        .join()
        .toUpperCase();
    final id = json['id'] is int
        ? json['id'] as int
        : int.tryParse(json['id'].toString()) ?? 0;

    return StudentModel(
      name: name,
      rollNo: (json['roll_no'] ?? '').toString(),
      initials: initials.isEmpty ? 'ST' : initials,
      avatarColor: Colors.primaries[id.hashCode % Colors.primaries.length],
      studentId: id,
    );
  }
}

class MarkAttendanceScreen extends StatefulWidget {
  final int sessionId;

  const MarkAttendanceScreen({super.key, required this.sessionId});

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  List<StudentModel> _students = [];
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await SessionService.getStudents(widget.sessionId);

    if (result['success'] == true) {
      final list = List<Map<String, dynamic>>.from(result['data'] ?? []);
      setState(() {
        _students = list.map((e) => StudentModel.fromJson(e)).toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = result['message'] ?? 'Failed to load students for this session';
        _isLoading = false;
      });
    }
  }

  int get _markedCount =>
      _students.where((s) => s.status != AttendanceStatus.none).length;

  double get _progress =>
      _students.isEmpty ? 0 : _markedCount / _students.length;

  void _setStatus(int index, AttendanceStatus status) {
    setState(() {
      _students[index].status = status;
    });
  }

  void _autoFill() {
    setState(() {
      for (final s in _students) {
        if (s.status == AttendanceStatus.none) {
          s.status = AttendanceStatus.present;
        }
      }
    });
  }

  Future<void> _saveAttendance() async {
    if (_students.isEmpty) return;

    setState(() => _isSaving = true);
    try {
      Position pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      int successCount = 0;

      for (final student in _students) {
        if (student.status == AttendanceStatus.none) continue;

        final result = await AttendanceService.saveAttendance(
          sessionId: widget.sessionId,
          studentId: student.studentId,
          latitude: pos.latitude,
          longitude: pos.longitude,
          status: student.status.name, // present/late/absent
        );

        if (result['success'] == true) successCount++;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('$successCount / ${_students.length} students ki attendance save ho gayi')),
      );
      if (successCount > 0) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
    if (mounted) setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
        title: Text(
          'Mark Attendance',
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(Icons.check_circle_rounded,
                color: AppColors.success, size: 26),
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _buildError()
                : _students.isEmpty
                    ? _buildEmpty()
                    : Column(
                        children: [
                          Container(
                            color: AppColors.surface,
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        '$_markedCount / ${_students.length} Marked',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary)),
                                    Text('${(_progress * 100).round()}%',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primary)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: _progress,
                                    minHeight: 8,
                                    backgroundColor: AppColors.border,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.primary),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                GestureDetector(
                                  onTap: _autoFill,
                                  child: Container(
                                    width: double.infinity,
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                        color: AppColors.background,
                                        borderRadius:
                                            BorderRadius.circular(8)),
                                    child: Center(
                                      child: Text(
                                          'Mark remaining as present? Auto-fill',
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w500)),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                              itemCount: _students.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                return _StudentCard(
                                  student: _students[index],
                                  onStatusChanged: (status) =>
                                      _setStatus(index, status),
                                );
                              },
                            ),
                          ),
                          _BottomSaveSection(
                            studentsRemaining: _students
                                .where((s) => s.status == AttendanceStatus.none)
                                .length,
                            isSaving: _isSaving,
                            onSave: _saveAttendance,
                          ),
                        ],
                      ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: AppColors.danger),
          const SizedBox(height: 12),
          Text(_error!, style: TextStyle(color: AppColors.danger)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadStudents, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Text('No students found for this session.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
    );
  }
}

class _StudentCard extends StatelessWidget {
  final StudentModel student;
  final ValueChanged<AttendanceStatus> onStatusChanged;

  const _StudentCard({required this.student, required this.onStatusChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                  radius: 22,
                  backgroundColor: student.avatarColor,
                  child: Text(student.initials,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(student.name,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    if (student.rollNo.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text('Roll No: ${student.rollNo}',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _AttendanceButton(
                      label: 'Present',
                      isSelected: student.status == AttendanceStatus.present,
                      selectedColor: AppColors.success,
                      onTap: () => onStatusChanged(AttendanceStatus.present))),
              const SizedBox(width: 8),
              Expanded(
                  child: _AttendanceButton(
                      label: 'Late',
                      isSelected: student.status == AttendanceStatus.late,
                      selectedColor: AppColors.warning,
                      onTap: () => onStatusChanged(AttendanceStatus.late))),
              const SizedBox(width: 8),
              Expanded(
                  child: _AttendanceButton(
                      label: 'Absent',
                      isSelected: student.status == AttendanceStatus.absent,
                      selectedColor: AppColors.danger,
                      onTap: () => onStatusChanged(AttendanceStatus.absent))),
            ],
          ),
        ],
      ),
    );
  }
}

class _AttendanceButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _AttendanceButton(
      {required this.label,
      required this.isSelected,
      required this.selectedColor,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 40,
        decoration: BoxDecoration(
            color: isSelected ? selectedColor : AppColors.border,
            borderRadius: BorderRadius.circular(8)),
        child: Center(
            child: Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textSecondary))),
      ),
    );
  }
}

class _BottomSaveSection extends StatelessWidget {
  final int studentsRemaining;
  final bool isSaving;
  final VoidCallback onSave;

  const _BottomSaveSection(
      {required this.studentsRemaining,
      required this.isSaving,
      required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: isSaving ? null : onSave,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                icon: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save_rounded, size: 20),
                label: Text(isSaving ? 'Saving...' : 'Save Attendance',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 8),
            Text('$studentsRemaining STUDENTS REMAINING',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }
}