import 'package:flutter/material.dart';
import '../core/services/session_service.dart';

class AttendanceMarkingScreen extends StatefulWidget {
  final int sessionId;
  final List<Map<String, dynamic>> selectedStudents;

  const AttendanceMarkingScreen({
    super.key,
    required this.sessionId,
    required this.selectedStudents,
  });

  @override
  State<AttendanceMarkingScreen> createState() =>
      _AttendanceMarkingScreenState();
}

class _AttendanceMarkingScreenState extends State<AttendanceMarkingScreen> {
  // student id → status (present/absent/leave)
  late Map<int, String> attendanceMap;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    // Sab students pehle 'present' set karo default
    attendanceMap = {
      for (var s in widget.selectedStudents)
        s['id'] as int: 'present'
    };
  }

  Future<void> _saveAttendance() async {
    setState(() => isSaving = true);

    final result = await SessionService.markAttendance(
      sessionId: widget.sessionId,
      attendance: attendanceMap,
    );

    setState(() => isSaving = false);

    if (result['success']) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Attendance save ho gayi!'),
          backgroundColor: Color(0xFF0F9D58),
        ),
      );
      // Dashboard pe wapas
      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Error saving attendance'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F9D58),
        foregroundColor: Colors.white,
        title: const Text(
          'Attendance Mark Karo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // ── Banner ─────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFFE8F5E9),
            child: Text(
              'Session ID: ${widget.sessionId}  •  ${widget.selectedStudents.length} Students',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF2E7D32),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // ── Legend ─────────────────────────────────────────────
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _legendBadge('P', 'Present', const Color(0xFF0F9D58)),
                const SizedBox(width: 8),
                _legendBadge('A', 'Absent', Colors.red),
                const SizedBox(width: 8),
                _legendBadge('L', 'Leave', Colors.orange),
              ],
            ),
          ),

          // ── Student list ────────────────────────────────────────
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              itemCount: widget.selectedStudents.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final s = widget.selectedStudents[index];
                final id = s['id'] as int;
                final name = s['username'] ?? 'Unknown';
                final rollNo = s['roll_no'] ?? '';
                final status = attendanceMap[id] ?? 'present';

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF2979FF),
                      child: Text(
                        name[0].toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    subtitle: rollNo.isNotEmpty
                        ? Text('Roll No: $rollNo',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey))
                        : null,
                    // ── P / A / L buttons ───────────────────────
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _statusButton(
                          label: 'P',
                          color: const Color(0xFF0F9D58),
                          isSelected: status == 'present',
                          onTap: () => setState(
                              () => attendanceMap[id] = 'present'),
                        ),
                        const SizedBox(width: 6),
                        _statusButton(
                          label: 'A',
                          color: Colors.red,
                          isSelected: status == 'absent',
                          onTap: () => setState(
                              () => attendanceMap[id] = 'absent'),
                        ),
                        const SizedBox(width: 6),
                        _statusButton(
                          label: 'L',
                          color: Colors.orange,
                          isSelected: status == 'leave',
                          onTap: () =>
                              setState(() => attendanceMap[id] = 'leave'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Save button ─────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSaving ? null : _saveAttendance,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F9D58),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Attendance Save Karo',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusButton({
    required String label,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _legendBadge(String label, String text, Color color) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(6)),
          child: Center(
            child: Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 4),
        Text(text,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}