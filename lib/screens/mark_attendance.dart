import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../core/services/attendance_service.dart';
import '../core/theme/app_colors.dart';

void main() {
  runApp(const MarkAttendanceApp());
}

class MarkAttendanceApp extends StatelessWidget {
  const MarkAttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mark Attendance',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
      ),
      home: const MarkAttendanceScreen(),
    );
  }
}

enum AttendanceStatus { none, present, late, absent }

class StudentModel {
  final String name;
  final String id;
  final String initials;
  final Color avatarColor;
  final bool isNext;
  final int studentId; // DB ka ID add kiya
  AttendanceStatus status;

  StudentModel({
    required this.name,
    required this.id,
    required this.initials,
    required this.avatarColor,
    required this.studentId, // naya
    this.isNext = false,
    this.status = AttendanceStatus.none,
  });
}

class MarkAttendanceScreen extends StatefulWidget {
  const MarkAttendanceScreen({super.key});

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  final int sessionId = 1; // Teacher se mili session_id yahan set karo

  final List<StudentModel> _students = [
    StudentModel(
      name: 'Marcus Holloway',
      id: 'ID: 2026-C68',
      initials: 'MH',
      avatarColor: const Color(0xFF1565C0),
      studentId: 12, // DB user id
      status: AttendanceStatus.present,
    ),
    StudentModel(
      name: 'Sarah Jenkins',
      id: 'ID: 2026-C89',
      initials: 'SJ',
      avatarColor: const Color(0xFF6A1B9A),
      studentId: 13,
      status: AttendanceStatus.late,
    ),
    StudentModel(
      name: 'Alex Rivera',
      id: 'ID: 2026-353',
      initials: 'AR',
      avatarColor: const Color(0xFF00695C),
      studentId: 14,
      status: AttendanceStatus.absent,
    ),
    StudentModel(
      name: 'Elena Moretti',
      id: 'ID: 2026-118',
      initials: 'EM',
      avatarColor: const Color(0xFF37474F),
      studentId: 15,
      isNext: true,
      status: AttendanceStatus.none,
    ),
  ];

  int get _markedCount =>
      _students.where((s) => s.status != AttendanceStatus.none).length;

  double get _progress => _students.isEmpty ? 0 : _markedCount / _students.length;

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

  // NAYA FUNCTION: Save pe API call
  Future<void> _saveAttendance() async {
    try {
      Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      int successCount = 0;

      for (final student in _students) {
        if (student.status == AttendanceStatus.none) continue;

        final success = await AttendanceService.saveAttendance(
          sessionId: sessionId,
          studentId: student.studentId,
          latitude: pos.latitude,
          longitude: pos.longitude,
          status: student.status.name, // present/late/absent
        );

        if (success) successCount++;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$successCount students ki attendance save ho gayi')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CS101: Intro to UI Design',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            Text(
              'MONDAY, OCT 25 • 10:00 AM',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondary, letterSpacing: 0.3),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(Icons.check_circle_rounded, color: AppColors.success, size: 26),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('$_markedCount / ${_students.length} Marked',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      Text('${(_progress * 100).round()}%',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: _progress,
                      minHeight: 8,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _autoFill,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
                      child: Center(
                        child: Text('Mark remaining as present? Auto-fill',
                            style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w500)),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                itemCount: _students.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  return _StudentCard(
                    student: _students[index],
                    onStatusChanged: (status) => _setStatus(index, status),
                  );
                },
              ),
            ),
            _BottomSaveSection(
              studentsRemaining: _students.where((s) => s.status == AttendanceStatus.none).length,
              onSave: _saveAttendance, // YAHAN FUNCTION LAGAYA
            ),
          ],
        ),
      ),
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: Offset(0, 3))],
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 22, backgroundColor: student.avatarColor,
                  child: Text(student.initials, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(student.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      if (student.isNext)...[
                        const SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(4)),
                          child: Text('NEXT', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ]),
                    const SizedBox(height: 3),
                    Text(student.id, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _AttendanceButton(label: 'Present', isSelected: student.status == AttendanceStatus.present, selectedColor: AppColors.success, onTap: () => onStatusChanged(AttendanceStatus.present))),
              const SizedBox(width: 8),
              Expanded(child: _AttendanceButton(label: 'Late', isSelected: student.status == AttendanceStatus.late, selectedColor: AppColors.warning, onTap: () => onStatusChanged(AttendanceStatus.late))),
              const SizedBox(width: 8),
              Expanded(child: _AttendanceButton(label: 'Absent', isSelected: student.status == AttendanceStatus.absent, selectedColor: AppColors.danger, onTap: () => onStatusChanged(AttendanceStatus.absent))),
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

  const _AttendanceButton({required this.label, required this.isSelected, required this.selectedColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 180),
        height: 40,
        decoration: BoxDecoration(color: isSelected? selectedColor : AppColors.border, borderRadius: BorderRadius.circular(8)),
        child: Center(child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected? Colors.white : AppColors.textSecondary))),
      ),
    );
  }
}

class _BottomSaveSection extends StatelessWidget {
  final int studentsRemaining;
  final VoidCallback onSave;

  const _BottomSaveSection({required this.studentsRemaining, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: onSave, // YAHAN API CALL
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                icon: Icon(Icons.save_rounded, size: 20),
                label: Text('Save Attendance', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 8),
            Text('$studentsRemaining STUDENTS REMAINING', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }
}