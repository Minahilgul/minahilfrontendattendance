import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import '../core/services/student_service.dart';
import '../widgets/base_scaffold.dart';


// DATA MODELS


class StudentModel {
  final int id;
  final String initials;
  final Color avatarColor;
  final String name;
  final String role;
  final String? email;
  final String? phone;
  final String? createdInfo;
  final String? className;
  final String? rollNo;

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
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    String name = json['username'] ?? 'Unknown';
    String initials = name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').join().toUpperCase();
    if (initials.length > 2) initials = initials.substring(0, 2);

    return StudentModel(
      id: json['id'] ?? 0,
      initials: initials.isEmpty ? 'ST' : initials,
      avatarColor: const Color(0xFF0F9D58),
      name: name,
      role: json['role'] ?? 'Student',
      email: json['email'],
      phone: json['phone'],
      createdInfo: json['created_at'],
      className: json['class'],
      rollNo: json['roll_no'],
    );
  }
}

Future<bool> updateStudent(
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


// ADD STUDENT DIALOG


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

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    final list = await StudentService.fetchClasses();
    if (mounted) {
      setState(() {
        _classes = list;
        final matches = list.any(
          (c) => c['class_name']?.toString() == _selectedClass,
        );
        if (!matches && list.isNotEmpty) {
          _selectedClass = list[0]['class_name']?.toString() ?? '';
        }
        _loadingClasses = false;
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
                    validator: (v) =>
                        v!.isEmpty ? 'Phone number required' : null),
                const SizedBox(height: 14),
                _loadingClasses
                    ? const Center(child: CircularProgressIndicator())
                    : DropdownButtonFormField<String>(
                        value:
                            _selectedClass.isEmpty ? null : _selectedClass,
                        items: _classes.map((c) {
                          final className =
                              c['class_name']?.toString() ?? '';
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
                      ),
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
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _onSave,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F9D58),
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


// EDIT STUDENT DIALOG


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

  Future<void> _loadClasses() async {
    final list = await StudentService.fetchClasses();
    if (mounted) {
      setState(() {
        _classes = list;

        //  use 'class_name' key (same as AddStudentDialog)
        final matches = list.any(
          (c) => c['class_name']?.toString() == _selectedClass,
        );
        if (!matches && _selectedClass.isEmpty && list.isNotEmpty) {
          _selectedClass = list[0]['class_name']?.toString() ?? '';
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
    final success = await updateStudent(
      widget.student.id,
      _usernameCtrl.text.trim(),
      _emailCtrl.text.trim(),
      _phoneCtrl.text.trim(),
      cls: _selectedClass,
      rollNo: _rollNoCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('${widget.student.name} updated successfully!'),
            backgroundColor: const Color(0xFF2E7D32)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to update student'),
            backgroundColor: Color(0xFFC62828)),
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
                    validator: (v) =>
                        v!.isEmpty ? 'Phone number required' : null),
                const SizedBox(height: 14),

                //  class_name key use ho rahi hai — Add dialog se match
                _loadingClasses
                    ? const Center(child: CircularProgressIndicator())
                    : DropdownButtonFormField<String>(
                        value:
                            _selectedClass.isEmpty ? null : _selectedClass,
                        items: _classes.map((c) {
                          final className =
                              c['class_name']?.toString() ?? ''; 
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
                      ),
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
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _onUpdate,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F9D58),
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


// STUDENT CARD WIDGET


class StudentCard extends StatelessWidget {
  final StudentModel student;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const StudentCard(
      {super.key, required this.student, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
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
                  Text(student.name,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E))),
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
                          color: Color(0xFF0F9D58))),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.grey[400], size: 20),
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
                      Icon(Icons.delete_outline, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red))
                    ])),
              ],
            ),
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

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _fetchStudents();
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

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchStudents() async {
    setState(() => _isLoading = true);
    try {
      final list = await StudentService.fetchStudents();
      setState(() {
        _allStudents = list.map((e) => StudentModel.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Fetch Error: $e');
      setState(() => _isLoading = false);
    }
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
          ElevatedButton(
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
      final success = await deleteStudent(student.id);
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

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Student Directory',
      role: _currentRole,
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddStudentDialog,
        backgroundColor: const Color(0xFF0F9D58),
        foregroundColor: Colors.white,
        elevation: 4,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredStudents.isEmpty
                      ? Center(
                          child: Text('No students found',
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
                              onEdit: () async {
                                final result = await showDialog<bool>(
                                    context: context,
                                    builder: (_) =>
                                        EditStudentDialog(student: s));
                                if (result == true) _fetchStudents();
                              },
                              onDelete: () => _showDeleteDialog(s),
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