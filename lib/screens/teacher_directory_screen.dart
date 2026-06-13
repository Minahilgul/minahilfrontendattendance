import 'package:flutter/material.dart';
import '../core/services/teacher_service.dart';
import '../widgets/base_scaffold.dart';

// ─────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────

enum TeacherStatus { verified, inactive, securityAlert }

class TeacherModel {
  final int id;
  final String initials;
  final Color avatarColor;
  final String name;
  final String department;
  final String role;
  final TeacherStatus status;
  final int activeClasses;
  final String? deviceInfo;
  final String? lastSeen;
  final String? securityMessage;
  final String? registeredInfo;
  final String? email;
  final String? phone;
  final String? deviceMacAddress; // ✅ ADD: MAC address field

  const TeacherModel({
    required this.id,
    required this.initials,
    required this.avatarColor,
    required this.name,
    required this.department,
    required this.role,
    required this.status,
    required this.activeClasses,
    this.deviceInfo,
    this.lastSeen,
    this.securityMessage,
    this.registeredInfo,
    this.email,
    this.phone,
    this.deviceMacAddress, // ✅ ADD
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    String name = json['username'] ?? 'Unknown';
    String initials = name
        .split(' ')
        .map((e) => e.isNotEmpty ? e[0] : '')
        .join()
        .toUpperCase();
    if (initials.length > 2) initials = initials.substring(0, 2);

    return TeacherModel(
      id: json['id'] ?? 0,
      initials: initials,
      avatarColor: const Color(0xFF1565C0),
      name: name,
      department: json['department'] ?? 'N/A',
      role: json['role'] ?? 'Teacher',
      status: TeacherStatus.verified,
      activeClasses: json['active_classes'] ?? 0,
      deviceInfo: json['device_info'],
      lastSeen: json['last_seen'],
      registeredInfo: json['created_at'],
      email: json['email'],
      phone: json['phone'],
      deviceMacAddress: json['device_mac_address'], // ✅ ADD
    );
  }
}

// ─────────────────────────────────────────────
// API SERVICE WRAPPERS
// ─────────────────────────────────────────────

// ✅ FIX: deviceMacAddress parameter added
Future<bool> addTeacher(
  String username,
  String email,
  String password,
  String phone,
  String deviceMacAddress,
) async {
  return await TeacherService.addTeacher(
    username: username,
    email: email,
    password: password,
    phone: phone,
    deviceMacAddress: deviceMacAddress, // ✅ FIX: pass actual parameter
  );
}

// ✅ FIX: deviceMacAddress parameter added
Future<bool> updateTeacher(
  int id,
  String username,
  String email,
  String phone,
  String deviceMacAddress,
) async {
  return await TeacherService.updateTeacher(
    id: id,
    username: username,
    email: email,
    phone: phone,
    deviceMacAddress: deviceMacAddress, // ✅ FIX: pass actual parameter
  );
}

Future<bool> deleteTeacher(int id) async {
  return await TeacherService.deleteTeacher(id);
}

// ─────────────────────────────────────────────
// STATUS BADGE WIDGET
// ─────────────────────────────────────────────

class StatusBadge extends StatelessWidget {
  final TeacherStatus status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case TeacherStatus.verified:
        return _badge('VERIFIED', const Color(0xFF2E7D32), const Color(0xFFE8F5E9));
      case TeacherStatus.inactive:
        return _badge('INACTIVE', const Color(0xFF757575), const Color(0xFFF5F5F5));
      case TeacherStatus.securityAlert:
        return _badge('⚠ SECURITY ALERT', const Color(0xFFC62828), const Color(0xFFFFEBEE));
    }
  }

  Widget _badge(String label, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(4)),
      child: Text(label,
          style: TextStyle(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5)),
    );
  }
}

// ─────────────────────────────────────────────
// ADD TEACHER DIALOG
// ─────────────────────────────────────────────

class AddTeacherDialog extends StatefulWidget {
  const AddTeacherDialog({super.key});
  @override
  State<AddTeacherDialog> createState() => _AddTeacherDialogState();
}

class _AddTeacherDialogState extends State<AddTeacherDialog> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _macCtrl = TextEditingController(); // ✅ MAC controller
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _phoneCtrl.dispose();
    _macCtrl.dispose(); // ✅ dispose
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    // ✅ FIX: pass _macCtrl.text as 5th argument
    final success = await addTeacher(
      _usernameCtrl.text.trim(),
      _emailCtrl.text.trim(),
      _passwordCtrl.text.trim(),
      _phoneCtrl.text.trim(),
      _macCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (success) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Teacher added successfully!'),
          backgroundColor: Color(0xFF2E7D32)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to add teacher. Please try again.'),
          backgroundColor: Color(0xFFC62828)));
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
                const Text('Add New Teacher',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('Fill in the details to add a new faculty member',
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
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 14),
                // ✅ ADD: MAC address field in form
                _buildField(
                    'Device MAC Address', _macCtrl, Icons.router_outlined),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                            _isLoading ? null : () => Navigator.of(context).pop(),
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
                            backgroundColor: const Color(0xFF1565C0),
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        isDense: true,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// EDIT TEACHER DIALOG
// ─────────────────────────────────────────────

class EditTeacherDialog extends StatefulWidget {
  final TeacherModel teacher;
  const EditTeacherDialog({super.key, required this.teacher});

  @override
  State<EditTeacherDialog> createState() => _EditTeacherDialogState();
}

class _EditTeacherDialogState extends State<EditTeacherDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _macCtrl; // ✅ MAC controller
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _usernameCtrl = TextEditingController(text: widget.teacher.name);
    _emailCtrl = TextEditingController(text: widget.teacher.email ?? '');
    _phoneCtrl = TextEditingController(text: widget.teacher.phone ?? '');
    // ✅ Prefill existing MAC address
    _macCtrl = TextEditingController(
        text: widget.teacher.deviceMacAddress ?? '');
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _macCtrl.dispose(); // ✅ dispose
    super.dispose();
  }

  Future<void> _onUpdate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    // ✅ FIX: pass _macCtrl.text as 5th argument
    final success = await updateTeacher(
      widget.teacher.id,
      _usernameCtrl.text.trim(),
      _emailCtrl.text.trim(),
      _phoneCtrl.text.trim(),
      _macCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${widget.teacher.name} updated successfully!'),
          backgroundColor: const Color(0xFF2E7D32)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to update teacher'),
          backgroundColor: Color(0xFFC62828)));
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
                const Text('Edit Teacher',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('Update faculty details',
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
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 14),
                // ✅ ADD: MAC address field in edit form
                _buildField(
                    'Device MAC Address', _macCtrl, Icons.router_outlined),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                            _isLoading ? null : () => Navigator.of(context).pop(),
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
                            backgroundColor: const Color(0xFF1565C0),
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          isDense: true),
    );
  }
}

// ─────────────────────────────────────────────
// TEACHER CARD WIDGET
// ─────────────────────────────────────────────

class TeacherCard extends StatelessWidget {
  final TeacherModel teacher;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TeacherCard(
      {super.key, required this.teacher, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isAlert = teacher.status == TeacherStatus.securityAlert;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isAlert
            ? Border.all(color: const Color(0xFFEF9A9A), width: 1.5)
            : Border.all(color: const Color(0xFFE0E0E0), width: 0.5),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                    radius: 22,
                    backgroundColor: teacher.avatarColor,
                    child: Text(teacher.initials,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14))),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StatusBadge(status: teacher.status),
                      const SizedBox(height: 4),
                      Text(teacher.name,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A2E))),
                      Text('${teacher.department} • ${teacher.role}',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600])),
                      const SizedBox(height: 8),
                      // Active classes + device info row
                      Row(children: [
                        Icon(Icons.class_outlined,
                            size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text('${teacher.activeClasses} Active Classes',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600])),
                        if (teacher.deviceInfo != null) ...[
                          const SizedBox(width: 12),
                          Icon(Icons.smartphone,
                              size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(teacher.deviceInfo!,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600])),
                        ],
                        if (teacher.registeredInfo != null) ...[
                          const SizedBox(width: 12),
                          Icon(Icons.check_circle_outline,
                              size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(teacher.registeredInfo!,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600])),
                        ],
                      ]),
                      // ✅ FIX: MAC address shown on its own row, correct syntax
                      if (teacher.deviceMacAddress != null &&
                          teacher.deviceMacAddress!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(children: [
                          Icon(Icons.router_outlined,
                              size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text('MAC: ${teacher.deviceMacAddress}',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600])),
                        ]),
                      ],
                      if (teacher.lastSeen != null) ...[
                        const SizedBox(height: 4),
                        Text('LAST SEEN ${teacher.lastSeen}',
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[400],
                                letterSpacing: 0.3)),
                      ],
                    ],
                  ),
                ),
                PopupMenuButton<String>(
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
          if (isAlert) ...[
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                  color: const Color(0xFFFFF8F8),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFCDD2))),
              child: Row(children: [
                const Icon(Icons.warning_amber_rounded,
                    color: Color(0xFFE53935), size: 16),
                const SizedBox(width: 8),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      const Text('NEW LOGIN DETECTED',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFE53935),
                              letterSpacing: 0.3)),
                      Text('Unknown Windows PC • Austin, TX',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey[700])),
                    ])),
              ]),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Row(children: [
                Expanded(
                    child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: Color(0xFFE53935)),
                            foregroundColor: const Color(0xFFE53935),
                            padding:
                                const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8))),
                        child: const Text('LOCK ACCOUNT',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700)))),
                const SizedBox(width: 10),
                Expanded(
                    child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1565C0),
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8))),
                        child: const Text('VERIFY ID',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700)))),
              ]),
            ),
          ],
          if (teacher.status == TeacherStatus.verified)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF1565C0),
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Text('VIEW LOGS',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 14)
                    ])),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────

class TeacherDirectoryScreen extends StatefulWidget {
  final int userId;
  final String role;

  const TeacherDirectoryScreen({
    super.key,
    required this.userId,
    required this.role,
  });

  @override
  State<TeacherDirectoryScreen> createState() =>
      _TeacherDirectoryScreenState();
}

class _TeacherDirectoryScreenState extends State<TeacherDirectoryScreen> {
  int _selectedTab = 0;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  List<TeacherModel> _allTeachers = [];
  bool _isLoading = true;

  final List<String> _tabs = ['All Faculty', 'Registered', 'Security Alerts'];

  @override
  void initState() {
    super.initState();
    _fetchTeachers();
  }

  Future<void> _fetchTeachers() async {
    setState(() => _isLoading = true);
    try {
      final list = await TeacherService.fetchTeachers();
      setState(() {
        _allTeachers =
            list.map((e) => TeacherModel.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Fetch Error: $e');
      setState(() => _isLoading = false);
    }
  }

  List<TeacherModel> get _filteredTeachers {
    List<TeacherModel> list = _allTeachers;
    if (_selectedTab == 1) {
      list = list
          .where((t) =>
              t.status == TeacherStatus.verified ||
              t.registeredInfo != null)
          .toList();
    } else if (_selectedTab == 2) {
      list = list
          .where((t) => t.status == TeacherStatus.securityAlert)
          .toList();
    }
    if (_searchQuery.isNotEmpty) {
      list = list
          .where((t) =>
              t.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              t.department
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
          .toList();
    }
    return list;
  }

  void _openAddTeacherDialog() async {
    final result = await showDialog<bool>(
        context: context, builder: (_) => const AddTeacherDialog());
    if (result == true) _fetchTeachers();
  }

  void _showDeleteDialog(TeacherModel teacher) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Teacher'),
        content:
            Text('Are you sure you want to delete ${teacher.name}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935)),
            child: const Text('Delete',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await deleteTeacher(teacher.id);
      if (success) {
        setState(() {
          _allTeachers.removeWhere((t) => t.id == teacher.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('${teacher.name} deleted'),
            backgroundColor: const Color(0xFFC62828)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Failed to delete'),
            backgroundColor: Color(0xFFC62828)));
      }
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Teacher Directory',
      role: 'admin',
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
              color: const Color(0xFF1565C0),
              borderRadius: BorderRadius.circular(10)),
          child: IconButton(
              icon: const Icon(Icons.add, color: Colors.white, size: 20),
              onPressed: _openAddTeacherDialog,
              padding: EdgeInsets.zero),
        ),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddTeacherDialog,
        backgroundColor: const Color(0xFF1565C0),
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
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Manage faculty and security',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500])),
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
                          hintText: 'Search by name or department',
                          hintStyle: TextStyle(
                              color: Colors.grey[400], fontSize: 13),
                          prefixIcon: Icon(Icons.search,
                              color: Colors.grey[400], size: 20),
                          suffixIcon: Icon(Icons.tune,
                              color: Colors.grey[400], size: 18),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                      children:
                          List.generate(_tabs.length, (i) {
                    final selected = _selectedTab == i;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedTab = i),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFF1565C0)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(_tabs[i],
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? Colors.white
                                    : Colors.grey[600])),
                      ),
                    );
                  })),
                  const SizedBox(height: 4),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding:
                          const EdgeInsets.symmetric(vertical: 12),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    'ACTIVE STAFF (${_filteredTeachers.length})',
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.grey[500],
                                        letterSpacing: 0.5)),
                                const Text('Sort by: Recent',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF1565C0))),
                              ]),
                        ),
                        const SizedBox(height: 4),
                        ..._filteredTeachers.map((t) => TeacherCard(
                              teacher: t,
                              onEdit: () async {
                                final result =
                                    await showDialog<bool>(
                                        context: context,
                                        builder: (_) =>
                                            EditTeacherDialog(teacher: t));
                                if (result == true) _fetchTeachers();
                              },
                              onDelete: () => _showDeleteDialog(t),
                            )),
                        Container(
                          margin:
                              const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                              color: const Color(0xFF1565C0),
                              borderRadius: BorderRadius.circular(12)),
                          child: Row(children: [
                            const Icon(Icons.sync,
                                color: Colors.white, size: 18),
                            const SizedBox(width: 10),
                            Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: const [
                                  Text('Security Sync',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13)),
                                  Text('Last synced 5 mins ago',
                                      style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 11)),
                                ]),
                            const Spacer(),
                            const Text('Details',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          ]),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}