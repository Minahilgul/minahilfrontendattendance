import 'package:flutter/material.dart';

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
          seedColor: const Color(0xFF2962FF),
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
      ),
      home: const MarkAttendanceScreen(),
    );
  }
}

// ─── Data Model ───────────────────────────────────────────────────────────────

enum AttendanceStatus { none, present, late, absent }

class StudentModel {
  final String name;
  final String id;
  final String initials;
  final Color avatarColor;
  final bool isNext;
  AttendanceStatus status;

  StudentModel({
    required this.name,
    required this.id,
    required this.initials,
    required this.avatarColor,
    this.isNext = false,
    this.status = AttendanceStatus.none,
  });
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class MarkAttendanceScreen extends StatefulWidget {
  const MarkAttendanceScreen({super.key});

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  final List<StudentModel> _students = [
    StudentModel(
      name: 'Marcus Holloway',
      id: 'ID: 2026-C68',
      initials: 'MH',
      avatarColor: const Color(0xFF1565C0),
      status: AttendanceStatus.present,
    ),
    StudentModel(
      name: 'Sarah Jenkins',
      id: 'ID: 2026-C89',
      initials: 'SJ',
      avatarColor: const Color(0xFF6A1B9A),
      status: AttendanceStatus.late,
    ),
    StudentModel(
      name: 'Alex Rivera',
      id: 'ID: 2026-353',
      initials: 'AR',
      avatarColor: const Color(0xFF00695C),
      status: AttendanceStatus.absent,
    ),
    StudentModel(
      name: 'Elena Moretti',
      id: 'ID: 2026-118',
      initials: 'EM',
      avatarColor: const Color(0xFF37474F),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'CS101: Intro to UI Design',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            Text(
              'MONDAY, OCT 25 • 10:00 AM',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFF9E9E9E),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.check_circle_rounded,
                color: Color(0xFF43A047), size: 26),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$_markedCount / ${_students.length} Marked',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF424242),
                        ),
                      ),
                      Text(
                        '${(_progress * 100).round()}%',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2962FF),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: _progress,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFE3E8FF),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF2962FF)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _autoFill,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'Mark remaining as present? Auto-fill',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF2962FF),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Student list
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
            // Bottom section
            _BottomSaveSection(
              studentsRemaining:
                  _students.where((s) => s.status == AttendanceStatus.none).length,
              onSave: () {
                debugPrint('Attendance Saved');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Attendance Saved')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Student Card ─────────────────────────────────────────────────────────────

class _StudentCard extends StatelessWidget {
  final StudentModel student;
  final ValueChanged<AttendanceStatus> onStatusChanged;

  const _StudentCard({
    required this.student,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 22,
                backgroundColor: student.avatarColor,
                child: Text(
                  student.initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Name & ID
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          student.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF212121),
                          ),
                        ),
                        if (student.isNext) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2962FF),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'NEXT',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      student.id,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9E9E9E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Attendance buttons
          Row(
            children: [
              Expanded(
                child: _AttendanceButton(
                  label: 'Present',
                  isSelected: student.status == AttendanceStatus.present,
                  selectedColor: const Color(0xFF43A047),
                  onTap: () => onStatusChanged(AttendanceStatus.present),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _AttendanceButton(
                  label: 'Late',
                  isSelected: student.status == AttendanceStatus.late,
                  selectedColor: const Color(0xFFFFA726),
                  onTap: () => onStatusChanged(AttendanceStatus.late),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _AttendanceButton(
                  label: 'Absent',
                  isSelected: student.status == AttendanceStatus.absent,
                  selectedColor: const Color(0xFFE53935),
                  onTap: () => onStatusChanged(AttendanceStatus.absent),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Attendance Button ────────────────────────────────────────────────────────

class _AttendanceButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _AttendanceButton({
    required this.label,
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF9E9E9E),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Bottom Save Section ──────────────────────────────────────────────────────

class _BottomSaveSection extends StatelessWidget {
  final int studentsRemaining;
  final VoidCallback onSave;

  const _BottomSaveSection({
    required this.studentsRemaining,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2962FF),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.save_rounded, size: 20),
                label: const Text(
                  'Save Attendance',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$studentsRemaining STUDENTS REMAINING',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF9E9E9E),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}