import 'package:flutter/material.dart';
import '../core/services/auth_service.dart';
import '../core/services/student_service.dart';
import '../core/theme/app_colors.dart';

class AddStudentScreen extends StatefulWidget {
  final String? teacherId;
  const AddStudentScreen({super.key, this.teacherId});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  //  SAFE teacherId (NO 'null' STRING EVER)
  String? get teacherIdValue {
    final user = AuthService.currentUser;

    if (widget.teacherId != null && widget.teacherId!.isNotEmpty) {
      return widget.teacherId;
    }

    if (user?['role'] == 'admin') {
      return null; // admin allowed
    }

    return user?['id']?.toString();
  }

  final _nameController = TextEditingController();
  final _rollController = TextEditingController();

  String _selectedClass = '';
  String _selectedStatus = 'Active';

  @override
  void dispose() {
    _nameController.dispose();
    _rollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Student"),
        backgroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.person_add),
                label: const Text("Add New Student"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                onPressed: () => _showAddStudentPopup(context),
              ),
            ),
          ),

          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: StudentService.fetchApprovedStudents(
                teacherIdValue ?? '0',
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final data = snapshot.data ?? {};
                final students = data['students'] ?? [];

                if (students.isEmpty) {
                  return const Center(
                    child: Text('Abhi koi approved student nahi hai'),
                  );
                }

                return ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        title: Text(student['name'] ?? ''),
                        subtitle: Text(
                          'Class: ${student['class']} | Roll: ${student['roll_no']} | Status: ${student['student_status']}',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddStudentPopup(BuildContext context) {
    _nameController.clear();
    _rollController.clear();
    _selectedClass = '';
    _selectedStatus = 'Active';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStatePopup) {
            return FutureBuilder<List<Map<String, dynamic>>>(
              future: StudentService.fetchClasses(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const AlertDialog(
                    content: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snap.hasError) {
                  return AlertDialog(
                    title: const Text('Error'),
                    content: Text('Classes load nahi hui: ${snap.error}'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  );
                }

                final classes = snap.data ?? [];

                if (_selectedClass.isEmpty && classes.isNotEmpty) {
                  _selectedClass =
                      classes[0]['name']?.toString() ?? '';
                }

                return AlertDialog(
                  title: const Text('Add Student'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),

                        DropdownButtonFormField<String>(
                          value: _selectedClass.isEmpty
                              ? null
                              : _selectedClass,
                          items: classes.map((c) {
                            return DropdownMenuItem<String>(
                              value: c['name']?.toString() ?? '',
                              child: Text(c['name']?.toString() ?? ''),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setStatePopup(() {
                              _selectedClass = val ?? '';
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'Class',
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 12),

                        TextField(
                          controller: _rollController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Roll No',
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 12),

                        DropdownButtonFormField<String>(
                          value: _selectedStatus,
                          items: const [
                            'Active',
                            'Inactive',
                            'Struck Out',
                            'On Leave'
                          ]
                              .map(
                                (s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            setStatePopup(() {
                              _selectedStatus = val ?? 'Active';
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: _submitForApproval,
                      child: const Text('Save'),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _submitForApproval() async {
    if (_nameController.text.trim().isEmpty ||
        _rollController.text.trim().isEmpty ||
        _selectedClass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sab fields bharo')),
      );
      return;
    }

    Navigator.pop(context);

    final result = await StudentService.submitForApproval(
      name: _nameController.text.trim(),
      cls: _selectedClass,
      roll: _rollController.text.trim(),
      status: _selectedStatus,

      //  never send "null" string
      teacherId: teacherIdValue ?? '',
    );

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student sent for approval')),
      );
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${result['message']}')),
      );
    }
  }
}