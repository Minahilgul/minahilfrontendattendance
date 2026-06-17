import 'package:flutter/material.dart';
import '../core/services/session_service.dart';

class StudentSelectionScreen extends StatefulWidget {
  final int sessionId;

  const StudentSelectionScreen({
    super.key,
    required this.sessionId,
  });

  @override
  State<StudentSelectionScreen> createState() => _StudentSelectionScreenState();
}

class _StudentSelectionScreenState extends State<StudentSelectionScreen> {
  List<Map<String, dynamic>> students = [];
  Set<int> selectedIds = {};
  bool isLoading = true;
  bool isSaving = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() { isLoading = true; error = null; });

    final result = await SessionService.getStudents();

    if (result['success']) {
      setState(() {
        students = List<Map<String, dynamic>>.from(result['data']);
        isLoading = false;
      });
    } else {
      setState(() {
        error = result['message'];
        isLoading = false;
      });
    }
  }

  Future<void> _saveStudents() async {
    if (selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kam az kam ek student select karo')),
      );
      return;
    }

    setState(() => isSaving = true);

    final result = await SessionService.saveSessionStudents(
      sessionId: widget.sessionId,
      studentIds: selectedIds.toList(),
    );

    setState(() => isSaving = false);

    if (result['success']) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${selectedIds.length} students save ho gaye!'),
          backgroundColor: const Color(0xFF0F9D58),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Error'),
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
        title: const Text('Students Select Karo',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (!isLoading && students.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  if (selectedIds.length == students.length) {
                    selectedIds.clear();
                  } else {
                    selectedIds = students.map((s) => s['id'] as int).toSet();
                  }
                });
              },
              child: Text(
                selectedIds.length == students.length ? 'Deselect All' : 'Select All',
                style: const TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Session ID banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFFE8F5E9),
            child: Text(
              'Session ID: ${widget.sessionId}',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF2E7D32),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Student list
          Expanded(child: _buildList()),

          // Bottom bar
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF0F9D58)),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text(error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadStudents,
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F9D58)),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (students.isEmpty) {
      return const Center(
        child: Text('Koi student nahi mila.',
            style: TextStyle(color: Colors.grey, fontSize: 16)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: students.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final s = students[index];
        final id = s['id'] as int;
        final name = s['username'] ?? 'Unknown';
        final rollNo = s['roll_no'] ?? '';
        final isSelected = selectedIds.contains(id);

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                selectedIds.remove(id);
              } else {
                selectedIds.add(id);
              }
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFE8F5E9) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? const Color(0xFF0F9D58) : Colors.transparent,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              // Avatar
              leading: CircleAvatar(
                backgroundColor: isSelected
                    ? const Color(0xFF0F9D58)
                    : const Color(0xFFE0E0E0),
                child: Text(
                  name[0].toUpperCase(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Name
              title: Text(name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15)),
              // Roll no
              subtitle: rollNo.isNotEmpty
                  ? Text('Roll No: $rollNo',
                      style:
                          const TextStyle(fontSize: 12, color: Colors.grey))
                  : null,
              // Checkbox on right
              trailing: Checkbox(
                value: isSelected,
                activeColor: const Color(0xFF0F9D58),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      selectedIds.add(id);
                    } else {
                      selectedIds.remove(id);
                    }
                  });
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    return Container(
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${selectedIds.length} selected',
              style: const TextStyle(
                color: Color(0xFF0F9D58),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: isSaving ? null : _saveStudents,
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
                  : const Text('Session Banao',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}