import '../../core/theme/app_colors.dart';
import 'package:attendence_verification/widgets/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/services/student_service.dart';
import '../../widgets/base_scaffold.dart';


// DATA MODELS


class StudentModel {
  final dynamic id; // pending-students ids may not be plain ints server-side
  final String initials;
  final Color avatarColor;
  final String name;
  final String role;
  final String? email;
  final String? phone;
  final String? createdInfo;
  final String? className;
  final String? rollNo;
  final bool isPending;

  const StudentModel({
    required this.id,
    required this.initials,
    required this.avatarColor,
    required this.name,
    required this.role,
    this.email,
    this.phone,
    this.createdInfo,
    this.className,
    this.rollNo,
    this.isPending = false,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json, {bool isPending = false}) {
    // Pending-students rows use 'name'; regular students use 'username'
    String name = json['username'] ?? json['name'] ?? 'Unknown';
    String initials = name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').join().toUpperCase();
    if (initials.length > 2) initials = initials.substring(0, 2);

    return StudentModel(
      id: json['id'] ?? 0,
      initials: initials.isEmpty ? 'ST' : initials,
      avatarColor: AppColors.primary,
      name: name,
      role: json['role'] ?? 'Student',
      email: json['email'],
      phone: json['phone'],
      createdInfo: json['created_at'],
      className: json['class'],
      rollNo: json['roll_no'],
      isPending: isPending,
    );
  }
}

Future<Map<String, dynamic>> updateStudent(
  int id,
  String username,
  String email,
  String phone, {
  String? cls,
  String? rollNo,
}) async {
  return await StudentService.updateStudent(
    id: id,
    username: username,
    email: email,
    phone: phone,
    cls: cls,
    rollNo: rollNo,
  );
}

Future<bool> deleteStudent(int id) async {
  return await StudentService.deleteStudent(id);
}

class EditStudentDialog extends StatefulWidget {
  final StudentModel student;
  const EditStudentDialog({super.key, required this.student});

  @override
  State<EditStudentDialog> createState() => _EditStudentDialogState();
}

class _EditStudentDialogState extends State<EditStudentDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _rollNoCtrl;
  bool _isLoading = false;

  List<Map<String, dynamic>> _classes = [];
  bool _loadingClasses = true;
  String _selectedClass = '';

  @override
  void initState() {
    super.initState();
    _usernameCtrl = TextEditingController(text: widget.student.name);
    _emailCtrl = TextEditingController(text: widget.student.email ?? '');
    _phoneCtrl = TextEditingController(text: widget.student.phone ?? '');
    _rollNoCtrl = TextEditingController(text: widget.student.rollNo ?? '');
    _selectedClass = widget.student.className ?? '';
    _loadClasses();
  }

  List<String> get _classOptions {
    final set = <String>{};
    for (var c in _classes) {
      final name = (c['class_name'] ?? c['name'] ?? c['title'] ?? '').toString().trim();
      if (name.isNotEmpty) {
        set.add(name);
      }
    }
    if (_selectedClass.isNotEmpty && !set.contains(_selectedClass)) {
      set.add(_selectedClass);
    }
    return set.toList();
  }

  Future<void> _loadClasses() async {
    final list = await StudentService.fetchClasses();
    if (mounted) {
      setState(() {
        _classes = list;
        final options = _classOptions;
        if (_selectedClass.isEmpty && options.isNotEmpty) {
          _selectedClass = options.first;
        }
        _loadingClasses = false;
      });
    }
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _rollNoCtrl.dispose();
    super.dispose();
  }

  Future<void> _onUpdate() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Color(0xFFC62828),
        ),
      );
      return;
    }
    if (_selectedClass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select a class'),
            backgroundColor: Color(0xFFC62828)),
      );
      return;
    }
    setState(() => _isLoading = true);
    final result = await StudentService.updateStudent(
      id: widget.student.id,
      username: _usernameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      cls: _selectedClass,
      rollNo: _rollNoCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('${widget.student.name} updated successfully!'),
            backgroundColor: const Color(0xFF2E7D32)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(result['message'] ?? 'Failed to update student'),
            backgroundColor: const Color(0xFFC62828)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Edit Student',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('Update student details',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                const SizedBox(height: 20),
                _buildField('Username', _usernameCtrl, Icons.person_outline,
                    validator: (v) =>
                        v!.isEmpty ? 'Username required' : null),
                const SizedBox(height: 14),
                _buildField(
                    'Email', _emailCtrl, Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) =>
                        v!.isEmpty ? 'Email required' : null),
                const SizedBox(height: 14),
                _buildField(
                    'Phone Number', _phoneCtrl, Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Please enter the correct number';
                      }
                      if (!RegExp(r'^[0-9]{11}$').hasMatch(v.trim())) {
                        return 'Please enter the correct number';
                      }
                      return null;
                    }),
                const SizedBox(height: 14),

                //  class_name key use ho rahi hai — Add dialog se match
                Builder(builder: (context) {
                  final options = _classOptions;
                  final dropdownValue = options.contains(_selectedClass)
                      ? _selectedClass
                      : (options.isNotEmpty ? options.first : null);

                  return _loadingClasses
                      ? const Center(child: CircularProgressIndicator())
                      : DropdownButtonFormField<String>(
                          value: dropdownValue,
                          items: options.map((className) {
                            return DropdownMenuItem<String>(
                              value: className,
                              child: Text(className),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedClass = val ?? '';
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Class',
                            prefixIcon: const Icon(Icons.class_outlined,
                                size: 20),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 14),
                            isDense: true,
                          ),
                        );
                }),
                const SizedBox(height: 14),

                _buildField(
                    'Roll Number', _rollNoCtrl, Icons.format_list_numbered,
                    validator: (v) =>
                        v!.isEmpty ? 'Roll number required' : null),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: Colors.grey[400]!),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8))),
                        child: const Text('Cancel',
                            style: TextStyle(color: Colors.black87)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GradientButton(
                        onPressed: _isLoading ? null : _onUpdate,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8))),
                        child: _isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Text('Update'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          isDense: true),
    );
  }
}


class AddStudentDialog extends StatefulWidget {
  const AddStudentDialog({super.key});
  @override
  State<AddStudentDialog> createState() => _AddStudentDialogState();
}

class _AddStudentDialogState extends State<AddStudentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _rollNoCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  List<Map<String, dynamic>> _classes = [];
  bool _loadingClasses = true;
  String _selectedClass = '';

  bool _loadingRollNo = true;

  @override
  void initState() {
    super.initState();
    _loadClasses();
    _loadNextRollNo();
  }

  List<String> get _classOptions {
    final set = <String>{};
    for (var c in _classes) {
      final name = (c['class_name'] ?? c['name'] ?? c['title'] ?? '').toString().trim();
      if (name.isNotEmpty) {
        set.add(name);
      }
    }
    if (_selectedClass.isNotEmpty && !set.contains(_selectedClass)) {
      set.add(_selectedClass);
    }
    return set.toList();
  }

  Future<void> _loadClasses() async {
    final list = await StudentService.fetchClasses();
    if (mounted) {
      setState(() {
        _classes = list;
        final options = _classOptions;
        if (_selectedClass.isEmpty && options.isNotEmpty) {
          _selectedClass = options.first;
        }
        _loadingClasses = false;
      });
    }
  }

  // Auto-fill roll number field with the next available roll no (max+1, global)
  Future<void> _loadNextRollNo() async {
    final nextRollNo = await StudentService.fetchNextRollNo();
    if (mounted) {
      setState(() {
        if (nextRollNo != null) {
          _rollNoCtrl.text = nextRollNo;
        }
        _loadingRollNo = false;
      });
    }
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _phoneCtrl.dispose();
    _rollNoCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Color(0xFFC62828),
        ),
      );
      return;
    }
    if (_selectedClass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select a class'),
            backgroundColor: Color(0xFFC62828)),
      );
      return;
    }
    setState(() => _isLoading = true);
    final result = await StudentService.createStudent(
      username: _usernameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      cls: _selectedClass,
      rollNo: _rollNoCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (result['success'] == true) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(result['message'] ?? 'Student added successfully!'),
            backgroundColor: const Color(0xFF2E7D32)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(result['message'] ??
                'Failed to add student. Please try again.'),
            backgroundColor: const Color(0xFFC62828)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Add New Student',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('Fill in the details to add a new student',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                const SizedBox(height: 20),
                _buildField('Username', _usernameCtrl, Icons.person_outline,
                    validator: (v) =>
                        v!.isEmpty ? 'Username required' : null),
                const SizedBox(height: 14),
                _buildField(
                    'Email', _emailCtrl, Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) =>
                        v!.isEmpty ? 'Email required' : null),
                const SizedBox(height: 14),
                _buildPasswordField(),
                const SizedBox(height: 14),
                _buildField(
                    'Phone Number', _phoneCtrl, Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Please enter the correct number';
                      }
                      if (!RegExp(r'^[0-9]{11}$').hasMatch(v.trim())) {
                        return 'Please enter the correct number';
                      }
                      return null;
                    }),
                const SizedBox(height: 14),
                Builder(builder: (context) {
                  final options = _classOptions;
                  final dropdownValue = options.contains(_selectedClass)
                      ? _selectedClass
                      : (options.isNotEmpty ? options.first : null);

                  return _loadingClasses
                      ? const Center(child: CircularProgressIndicator())
                      : DropdownButtonFormField<String>(
                          value: dropdownValue,
                          items: options.map((className) {
                            return DropdownMenuItem<String>(
                              value: className,
                              child: Text(className),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedClass = val ?? '';
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Class',
                            prefixIcon: const Icon(Icons.class_outlined,
                                size: 20),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 14),
                            isDense: true,
                          ),
                        );
                }),
                const SizedBox(height: 14),

                // Roll Number — auto-filled (max existing + 1) and readonly,
                // taake duplicate/manual entry ka chance na rahe
                TextFormField(
                  controller: _rollNoCtrl,
                  readOnly: true,
                  validator: (v) =>
                      v!.isEmpty ? 'Roll number required' : null,
                  decoration: InputDecoration(
                    labelText: 'Roll Number',
                    hintText: _loadingRollNo ? 'Loading...' : null,
                    prefixIcon:
                        const Icon(Icons.format_list_numbered, size: 20),
                    suffixIcon: _loadingRollNo
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2),
                            ),
                          )
                        : null,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                    isDense: true,
                    filled: true,
                    fillColor: const Color(0xFFF0F2F5),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: Colors.grey[400]!),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8))),
                        child: const Text('Cancel',
                            style: TextStyle(color: Colors.black87)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GradientButton(
                        onPressed: _isLoading ? null : _onSave,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8))),
                        child: _isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          isDense: true),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordCtrl,
      obscureText: _obscurePassword,
      validator: (v) => v!.isEmpty ? 'Password required' : null,
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: const Icon(Icons.lock_outline, size: 20),
        suffixIcon: IconButton(
            icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off
                    : Icons.visibility,
                size: 20),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword)),
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        isDense: true,
      ),
    );
  }
}


class StudentCard extends StatelessWidget {
  final StudentModel student;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const StudentCard({
    super.key,
    required this.student,
    this.onEdit,
    this.onDelete,
    this.onApprove,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    // Teachers (or anyone without approve/reject rights) get no action menu
    // at all on pending rows — view-only.
    final bool showPendingMenu = onApprove != null || onReject != null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 0.5),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
                radius: 22,
                backgroundColor: student.avatarColor,
                child: Text(student.initials,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(student.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1A2E))),
                      ),
                      if (student.isPending) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('Pending',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFEF6C00))),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  if (student.email != null)
                    Text(student.email!,
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[600])),
                  if (student.phone != null && student.phone!.isNotEmpty)
                    Text('Phone: ${student.phone}',
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[600])),
                  if (student.className != null || student.rollNo != null)
                    Text(
                        'Class: ${student.className ?? 'N/A'} | Roll No: ${student.rollNo ?? 'N/A'}',
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[600])),
                  const SizedBox(height: 4),
                  Text('Role: ${student.role}',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary)),
                ],
              ),
            ),
            student.isPending
                ? (showPendingMenu
                    ? PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert,
                            color: Colors.grey[400], size: 20),
                        padding: EdgeInsets.zero,
                        onSelected: (value) {
                          if (value == 'approve') onApprove?.call();
                          if (value == 'reject') onReject?.call();
                        },
                        itemBuilder: (context) => [
                          if (onApprove != null)
                            const PopupMenuItem(
                                value: 'approve',
                                child: Row(children: [
                                  Icon(Icons.check_circle_outline,
                                      size: 18, color: Color(0xFF2E7D32)),
                                  SizedBox(width: 8),
                                  Text('Approve',
                                      style:
                                          TextStyle(color: Color(0xFF2E7D32)))
                                ])),
                          if (onReject != null)
                            const PopupMenuItem(
                                value: 'reject',
                                child: Row(children: [
                                  Icon(Icons.cancel_outlined,
                                      size: 18, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Reject',
                                      style: TextStyle(color: Colors.red))
                                ])),
                        ],
                      )
                    // View-only: no menu at all for this role
                    : const SizedBox(width: 20))
                : PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert,
                        color: Colors.grey[400], size: 20),
                    padding: EdgeInsets.zero,
                    onSelected: (value) {
                      if (value == 'edit') onEdit?.call();
                      if (value == 'delete') onDelete?.call();
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                          value: 'edit',
                          child: Row(children: [
                            Icon(Icons.edit_outlined, size: 18),
                            SizedBox(width: 8),
                            Text('Edit')
                          ])),
                      const PopupMenuItem(
                          value: 'delete',
                          child: Row(children: [
                            Icon(Icons.delete_outline,
                                size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete',
                                style: TextStyle(color: Colors.red))
                          ])),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}


// FILTER CHIP (small helper for the Active/Pending toggle, with optional badge)


class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int? badgeCount;
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : const Color(0xFFF0F2F5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: selected ? Colors.white : Colors.grey[700],
              ),
            ),
            if (badgeCount != null && badgeCount! > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: selected ? Colors.white : AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badgeCount',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: selected ? AppColors.primary : Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


// MAIN DIRECTORY SCREEN

class StudentDirectoryScreen extends StatefulWidget {
  const StudentDirectoryScreen({super.key});

  @override
  State<StudentDirectoryScreen> createState() =>
      _StudentDirectoryScreenState();
}

class _StudentDirectoryScreenState extends State<StudentDirectoryScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  List<StudentModel> _allStudents = [];
  bool _isLoading = true;
  String _currentRole = 'teacher';

  // which tab is active — pending students are shown with no class filtering
  String _statusFilter = 'active'; // 'active' | 'pending'
  bool _isBulkApproving = false;

  // live badge count for the Pending chip
  int _pendingCount = 0;

  bool get _isAdmin => _currentRole == 'admin';

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _fetchStudents();
    _loadPendingCount();
  }

  Future<void> _loadUserRole() async {
    final storage = GetStorage();
    final role = storage.read<String>('role');
    if (role != null && mounted) {
      setState(() {
        _currentRole = role;
      });
    }
  }

  Future<void> _loadPendingCount() async {
    final count = await StudentService.fetchPendingCount();
    if (mounted) setState(() => _pendingCount = count);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchStudents() async {
    setState(() => _isLoading = true);
    try {
      if (_statusFilter == 'pending') {
        final list = await StudentService.fetchPendingStudents();
        setState(() {
          _allStudents = list
              .map((e) => StudentModel.fromJson(
                  Map<String, dynamic>.from(e), isPending: true))
              .toList();
          _isLoading = false;
        });
      } else {
        final list = await StudentService.fetchStudents();
        setState(() {
          _allStudents = list.map((e) => StudentModel.fromJson(e)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Fetch Error: $e');
      setState(() => _isLoading = false);
    }
  }

  void _onFilterChanged(String status) {
    if (_statusFilter == status) return;
    setState(() {
      _statusFilter = status;
      _searchCtrl.clear();
      _searchQuery = '';
    });
    _fetchStudents();
  }

  List<StudentModel> get _filteredStudents {
    List<StudentModel> list = _allStudents;
    if (_searchQuery.isNotEmpty) {
      list = list
          .where((s) =>
              s.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    return list;
  }

  void _openAddStudentDialog() async {
    final result = await showDialog<bool>(
        context: context, builder: (_) => const AddStudentDialog());
    if (result == true) _fetchStudents();
  }

  void _showDeleteDialog(StudentModel student) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Student'),
        content: Text('Are you sure you want to delete ${student.name}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          GradientButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935)),
            child:
                const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await deleteStudent(student.id as int);
      if (success) {
        setState(() {
          _allStudents.removeWhere((s) => s.id == student.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('${student.name} deleted'),
            backgroundColor: const Color(0xFFC62828)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Failed to delete'),
            backgroundColor: Color(0xFFC62828)));
      }
    }
  }

  // Approve/Reject/ApproveAll below are only ever wired up to UI controls
  // for admins (see build()), but they also guard on _isAdmin defensively.

  Future<void> _approveStudent(StudentModel student) async {
    if (!_isAdmin) return;
    final success = await StudentService.approveStudent(student.id.toString());
    if (!mounted) return;
    if (success) {
      setState(() => _allStudents.removeWhere((s) => s.id == student.id));
      _loadPendingCount();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${student.name} approved'),
          backgroundColor: const Color(0xFF2E7D32)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to approve'),
          backgroundColor: Color(0xFFC62828)));
    }
  }

  void _showRejectDialog(StudentModel student) async {
    if (!_isAdmin) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reject Student'),
        content:
            Text('Are you sure you want to reject ${student.name}\'s request?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          GradientButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935)),
            child:
                const Text('Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await StudentService.rejectStudent(student.id.toString());
      if (!mounted) return;
      if (success) {
        setState(() => _allStudents.removeWhere((s) => s.id == student.id));
        _loadPendingCount();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('${student.name} rejected'),
            backgroundColor: const Color(0xFFC62828)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Failed to reject'),
            backgroundColor: Color(0xFFC62828)));
      }
    }
  }

  Future<void> _approveAll() async {
    if (!_isAdmin) return;
    if (_filteredStudents.isEmpty) return;
    setState(() => _isBulkApproving = true);
    final ids = _filteredStudents.map((s) => s.id.toString()).toList();
    final success = await StudentService.approveAllStudents(ids);
    if (!mounted) return;
    setState(() => _isBulkApproving = false);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${ids.length} students approved'),
          backgroundColor: const Color(0xFF2E7D32)));
      _fetchStudents();
      _loadPendingCount();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to approve all'),
          backgroundColor: Color(0xFFC62828)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPendingTab = _statusFilter == 'pending';

    return BaseScaffold(
      title: 'Student Directory',
      role: _currentRole,
      floatingActionButton: isPendingTab
          ? null
          : FloatingActionButton(
              onPressed: _openAddStudentDialog,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.add),
            ),
      body: Container(
        color: const Color(0xFFF5F7FA),
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Manage students and accounts',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey[500])),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _FilterChip(
                          label: 'Active',
                          selected: !isPendingTab,
                          onTap: () => _onFilterChanged('active'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _FilterChip(
                          label: 'Pending',
                          selected: isPendingTab,
                          onTap: () => _onFilterChanged('pending'),
                          badgeCount: _pendingCount,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                        color: const Color(0xFFF0F2F5),
                        borderRadius: BorderRadius.circular(10)),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) =>
                          setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                          hintText: 'Search by name',
                          hintStyle: TextStyle(
                              color: Colors.grey[400], fontSize: 13),
                          prefixIcon: Icon(Icons.search,
                              color: Colors.grey[400], size: 20),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12)),
                    ),
                  ),
                  // Only admins get the bulk-approve control; teachers get a
                  // plain read-only pending list with no approve/reject UI.
                  if (isPendingTab && _isAdmin) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: (_isBulkApproving || _filteredStudents.isEmpty)
                            ? null
                            : _approveAll,
                        icon: _isBulkApproving
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.done_all, size: 18),
                        label: Text(_isBulkApproving
                            ? 'Approving...'
                            : 'Approve All (${_filteredStudents.length})'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2E7D32),
                          side: const BorderSide(color: Color(0xFF2E7D32)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredStudents.isEmpty
                      ? Center(
                          child: Text(
                              isPendingTab
                                  ? 'No pending students'
                                  : 'No students found',
                              style: TextStyle(
                                  color: Colors.grey[500], fontSize: 15)))
                      : ListView.builder(
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                          itemCount: _filteredStudents.length,
                          itemBuilder: (context, index) {
                            final s = _filteredStudents[index];
                            return StudentCard(
                              student: s,
                              onEdit: s.isPending
                                  ? null
                                  : () async {
                                      final result = await showDialog<bool>(
                                          context: context,
                                          builder: (_) =>
                                              EditStudentDialog(student: s));
                                      if (result == true) _fetchStudents();
                                    },
                              onDelete: s.isPending
                                  ? null
                                  : () => _showDeleteDialog(s),
                              // Approve/Reject only wired up for admins —
                              // teachers see the pending list read-only.
                              onApprove: (s.isPending && _isAdmin)
                                  ? () => _approveStudent(s)
                                  : null,
                              onReject: (s.isPending && _isAdmin)
                                  ? () => _showRejectDialog(s)
                                  : null,
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