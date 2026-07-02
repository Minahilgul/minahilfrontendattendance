import 'package:flutter/material.dart';
import 'package:attendence_verification/core/services/auth_service.dart';
import '../core/services/teacher_service.dart';
import '../widgets/base_scaffold.dart';
import '../core/theme/app_colors.dart';



// DATA MODELS


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
  final String? deviceId;

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
    this.deviceId, 
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    String name = json['username']?? 'Unknown';
    String initials = name.split(' ').map((e) => e.isNotEmpty? e[0] : '').join().toUpperCase();
    if (initials.length > 2) initials = initials.substring(0, 2);

    return TeacherModel(
      id: json['id']?? 0,
      initials: initials,
      avatarColor: AppColors.primaryDark,
      name: name,
      department: json['department']?? 'N/A',
      role: json['role']?? 'Teacher',
      status: json['status'] == 1 ? TeacherStatus.verified : TeacherStatus.inactive,
      activeClasses: json['active_classes']?? 0,
      deviceInfo: json['device_info'],
      lastSeen: json['last_seen'],
      registeredInfo: json['created_at'],
      email: json['email'],
      phone: json['phone'],
      deviceId: json['device_id'], 
    );
  }
}


// API SERVICE WRAPPERS


//      Added deviceId param to match service signature.
//  Added optional named `status` param (0 = inactive, 1 = active).
Future<bool> addTeacher(
  String username,
  String email,
  String password,
  String phone,
  String deviceId, {
  int? status,
}) async {
  final result = await TeacherService.addTeacher(
    username: username,
    email: email,
    password: password,
    phone: phone,
    deviceId: deviceId,
    status: status,
  );
  return result['success'] == true;
}

//  TeacherService.updateTeacher now returns Map<String,dynamic> not bool.
//      Added deviceId param to match service signature.
//  Added optional named `status` param (0 = inactive, 1 = active).
Future<bool> updateTeacher(
  int id,
  String username,
  String email,
  String phone,
  String deviceId, {
  int? status,
}) async {
  final result = await TeacherService.updateTeacher(
    id: id,
    username: username,
    email: email,
    phone: phone,
    deviceId: deviceId,
    status: status,
  );
  return result['success'] == true;
}

Future<bool> deleteTeacher(int id) async {
  return await TeacherService.deleteTeacher(id);
}


// STATUS BADGE WIDGET


class StatusBadge extends StatelessWidget {
  final TeacherStatus status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case TeacherStatus.verified:
        return _badge('VERIFIED', AppColors.success, AppColors.success.withOpacity(0.12));
      case TeacherStatus.inactive:
        return _badge('INACTIVE', AppColors.textSecondary, AppColors.background);
      case TeacherStatus.securityAlert:
        return _badge('⚠ SECURITY ALERT', AppColors.danger, AppColors.danger.withOpacity(0.1));
    }
  }

  Widget _badge(String label, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
    );
  }
}


// ADD TEACHER DIALOG


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
  final _imeiCtrl = TextEditingController(); //  added MAC controller
  bool _isActive = true; // NEW: Active/Inactive toggle, defaults to Active
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _phoneCtrl.dispose();
    _imeiCtrl.dispose(); //  dispose MAC controller
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    //  pass _imeiCtrl as 5th arg to match updated wrapper signature
    final success = await addTeacher(
      _usernameCtrl.text.trim(),
      _emailCtrl.text.trim(),
      _passwordCtrl.text.trim(),
      _phoneCtrl.text.trim(),
      _imeiCtrl.text.trim(),
      status: _isActive ? 1 : 0, 
    );
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (success) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Teacher added successfully!'), backgroundColor: AppColors.success));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Failed to add teacher. Please try again.'), backgroundColor: AppColors.danger));
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
                const Text('Add New Teacher', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('Fill in the details to add a new faculty member', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                const SizedBox(height: 20),
                _buildField('Username', _usernameCtrl, Icons.person_outline, validator: (v) => v!.isEmpty? 'Username required' : null),
                const SizedBox(height: 14),
                _buildField('Email', _emailCtrl, Icons.email_outlined, keyboardType: TextInputType.emailAddress, validator: (v) => v!.isEmpty? 'Email required' : null),
                const SizedBox(height: 14),
                _buildPasswordField(),
                const SizedBox(height: 14),
                _buildField('Phone Number', _phoneCtrl, Icons.phone_outlined, keyboardType: TextInputType.phone,
                validator: (v) =>
      v == null || v.trim().isEmpty
          ? 'Phone number required'
          : null,
                ),

                const SizedBox(height: 14),
                _buildField('Device ID / IMEI', _imeiCtrl, Icons.router_outlined,
                validator: (v) =>
      v == null || v.trim().isEmpty
          ? 'Device ID required'
          : null,
                ),
                const SizedBox(height: 14),

                // NEW: Active/Inactive status toggle — placed below last field, right corner
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      _isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _isActive ? AppColors.success : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: _isActive,
                      activeColor: AppColors.primaryDark,
                      onChanged: (val) => setState(() => _isActive = val),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading? null : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), side: BorderSide(color: AppColors.border), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        child: Text('Cancel', style: TextStyle(color: AppColors.textPrimary)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading? null : _onSave,
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDark, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        child: _isLoading? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Save'),
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

  Widget _buildField(String label, TextEditingController ctrl, IconData icon, {TextInputType keyboardType = TextInputType.text, String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, size: 20), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14), isDense: true),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordCtrl,
      obscureText: _obscurePassword,
      validator: (v) => v!.isEmpty? 'Password required' : null,
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: const Icon(Icons.lock_outline, size: 20),
        suffixIcon: IconButton(icon: Icon(_obscurePassword? Icons.visibility_off : Icons.visibility, size: 20), onPressed: () => setState(() => _obscurePassword =!_obscurePassword)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        isDense: true,
      ),
    );
  }
}


// EDIT TEACHER DIALOG 


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
  late TextEditingController _imeiCtrl; //  added MAC controller
  late bool _isActive; //  pre-filled from existing teacher status
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _usernameCtrl = TextEditingController(text: widget.teacher.name);
    _emailCtrl = TextEditingController(text: widget.teacher.email?? '');
    _phoneCtrl = TextEditingController(text: widget.teacher.phone?? '');
    //  prefill existing MAC address from teacher model
    _imeiCtrl = TextEditingController(text: widget.teacher.deviceId ?? '');
    //  prefill toggle from existing teacher status
    _isActive = widget.teacher.status == TeacherStatus.verified;
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _imeiCtrl.dispose(); //  dispose MAC controller
    super.dispose();
  }

  Future<void> _onUpdate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    //  pass _imeiCtrl as 5th arg to match updated wrapper signature
    final success = await updateTeacher(
      widget.teacher.id,
      _usernameCtrl.text.trim(),
      _emailCtrl.text.trim(),
      _phoneCtrl.text.trim(),
      _imeiCtrl.text.trim(),
      status: _isActive ? 1 : 0, 
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.teacher.name} updated successfully!'), backgroundColor: AppColors.success)
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Failed to update teacher'), backgroundColor: AppColors.danger)
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
            const Text('Edit Teacher', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('Update faculty details', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 20),
            _buildField('Username', _usernameCtrl, Icons.person_outline, validator: (v) => v!.isEmpty? 'Username required' : null),
            const SizedBox(height: 14),
            _buildField('Email', _emailCtrl, Icons.email_outlined, keyboardType: TextInputType.emailAddress, validator: (v) => v!.isEmpty? 'Email required' : null),
            const SizedBox(height: 14),
            _buildField('Phone Number', _phoneCtrl, Icons.phone_outlined, keyboardType: TextInputType.phone,
            validator: (v) =>
      v == null || v.trim().isEmpty
          ? 'Phone number required'
          : null,
            ),
            const SizedBox(height: 14),
            _buildField('Device ID / IMEI', _imeiCtrl, Icons.router_outlined,
            validator: (v) =>
      v == null || v.trim().isEmpty
          ? 'Device ID required'
          : null,
            ),
            const SizedBox(height: 14),

            // NEW: Active/Inactive status toggle — placed below last field, right corner
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  _isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _isActive ? AppColors.success : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: _isActive,
                  activeColor: AppColors.primaryDark,
                  onChanged: (val) => setState(() => _isActive = val),
                ),
              ],
            ),

            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), side: BorderSide(color: AppColors.border), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    child: Text('Cancel', style: TextStyle(color: AppColors.textPrimary)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading? null : _onUpdate,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDark, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    child: _isLoading? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Update'),
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

  Widget _buildField(String label, TextEditingController ctrl, IconData icon, {TextInputType keyboardType = TextInputType.text, String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, size: 20), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14), isDense: true),
    );
  }
}


// TEACHER CARD WIDGET


class TeacherCard extends StatelessWidget {
  final TeacherModel teacher;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onApprove;

  const TeacherCard({super.key, required this.teacher, this.onEdit, this.onDelete, this.onApprove});

  @override
  Widget build(BuildContext context) {
    final isAlert = teacher.status == TeacherStatus.securityAlert;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: isAlert? Border.all(color: AppColors.danger.withOpacity(0.5), width: 1.5) : Border.all(color: AppColors.border, width: 0.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(radius: 22, backgroundColor: teacher.avatarColor, child: Text(teacher.initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14))),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StatusBadge(status: teacher.status),
                      const SizedBox(height: 4),
                      Text(teacher.name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      Text('${teacher.department} • ${teacher.role}', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      Row(children: [
                        Icon(Icons.class_outlined, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text('${teacher.activeClasses} Active Classes', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        if (teacher.deviceInfo!= null)...[const SizedBox(width: 12), Icon(Icons.smartphone, size: 14, color: AppColors.textSecondary), const SizedBox(width: 4), Text(teacher.deviceInfo!, style: TextStyle(fontSize: 12, color: AppColors.textSecondary))],
                        if (teacher.registeredInfo!= null)...[const SizedBox(width: 12), Icon(Icons.check_circle_outline, size: 14, color: AppColors.textSecondary), const SizedBox(width: 4), Text(teacher.registeredInfo!, style: TextStyle(fontSize: 12, color: AppColors.textSecondary))],
                      ]),
                      if (teacher.lastSeen!= null)...[const SizedBox(height: 4), Text('LAST SEEN ${teacher.lastSeen}', style: TextStyle(fontSize: 10, color: AppColors.textLight, letterSpacing: 0.3))],
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: AppColors.textLight, size: 20),
                  padding: EdgeInsets.zero,
                  onSelected: (value) {
                    if (value == 'edit') onEdit?.call();
                    if (value == 'delete') onDelete?.call();
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 18), SizedBox(width: 8), Text('Edit')])),
                    PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 18, color: AppColors.danger), const SizedBox(width: 8), Text('Delete', style: TextStyle(color: AppColors.danger))])),
                  ],
                ),
              ],
            ),
          ),
          if (isAlert)...[
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.03), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.danger.withOpacity(0.3))),
              child: Row(children: [
                Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('NEW LOGIN DETECTED', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.danger, letterSpacing: 0.3)),
                  Text('Unknown Windows PC • Austin, TX', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ])),
              ]),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Row(children: [
                Expanded(child: OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(side: BorderSide(color: AppColors.danger), foregroundColor: AppColors.danger, padding: const EdgeInsets.symmetric(vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('LOCK ACCOUNT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)))),
                const SizedBox(width: 10),
                Expanded(child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDark, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('VERIFY ID', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)))),
              ]),
            ),
          ],
          if (teacher.status == TeacherStatus.verified)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(onPressed: () {}, style: TextButton.styleFrom(foregroundColor: AppColors.primaryDark, padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap), child: const Row(mainAxisSize: MainAxisSize.min, children: [Text('VIEW LOGS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)), SizedBox(width: 4), Icon(Icons.arrow_forward, size: 14)])),
              ),
            ),
          if (teacher.status == TeacherStatus.inactive)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: onApprove,
                  icon: const Icon(Icons.check, size: 14, color: Colors.white),
                  label: const Text('APPROVE TEACHER', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}


// MAIN SCREEN - SIRF CONSTRUCTOR UPDATE KIYA


class TeacherDirectoryScreen extends StatefulWidget {
  final int userId; 
  final String role; 

  const TeacherDirectoryScreen({
    super.key,
    required this.userId, 
    required this.role, 
  });

  @override
  State<TeacherDirectoryScreen> createState() => _TeacherDirectoryScreenState();
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
        _allTeachers = list.map((e) => TeacherModel.fromJson(e)).toList();
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
      list = list.where((t) => t.status == TeacherStatus.verified || t.registeredInfo!= null).toList();
    } else if (_selectedTab == 2) {
      list = list.where((t) => t.status == TeacherStatus.securityAlert).toList();
    }
    if (_searchQuery.isNotEmpty) {
      list = list.where((t) => t.name.toLowerCase().contains(_searchQuery.toLowerCase()) || t.department.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    return list;
  }

  void _openAddTeacherDialog() async {
    final result = await showDialog<bool>(context: context, builder: (_) => const AddTeacherDialog());
    if (result == true) _fetchTeachers();
  }

  void _showDeleteDialog(TeacherModel teacher) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Teacher'),
        content: Text('Are you sure you want to delete ${teacher.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${teacher.name} deleted'), backgroundColor: AppColors.danger));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Failed to delete'), backgroundColor: AppColors.danger));
      }
    }
  }

  void _showApproveDialog(TeacherModel teacher) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Approve Teacher'),
        content: Text('Are you sure you want to approve and activate the account of ${teacher.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('Approve', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await TeacherService.approveTeacher(teacher.id);
      if (success) {
        _fetchTeachers();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${teacher.name} approved successfully'), backgroundColor: AppColors.success));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Failed to approve teacher'), backgroundColor: AppColors.danger));
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
      actions: [],
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddTeacherDialog,
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add),
      ),
      body: Container(
        color: AppColors.background,
        child: Column(
          children: [
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Manage faculty and security', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  Container(
                    height: 44,
                    decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(hintText: 'Search by name or department', hintStyle: TextStyle(color: AppColors.textLight, fontSize: 13), prefixIcon: Icon(Icons.search, color: AppColors.textLight, size: 20), suffixIcon: Icon(Icons.tune, color: AppColors.textLight, size: 18), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(children: List.generate(_tabs.length, (i) {
                    final selected = _selectedTab == i;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedTab = i),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(color: selected? AppColors.primaryDark : Colors.transparent, borderRadius: BorderRadius.circular(20)),
                        child: Text(_tabs[i], style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected? Colors.white : AppColors.textSecondary)),
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
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text('ACTIVE STAFF (${_filteredTeachers.length})', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.5)),
                            Text('Sort by: Recent', style: TextStyle(fontSize: 11, color: AppColors.primaryDark)),
                          ]),
                        ),
                        const SizedBox(height: 4),
                      ..._filteredTeachers.map((t) => TeacherCard(
                              teacher: t,
                              onEdit: () async {
                                final result = await showDialog<bool>(context: context, builder: (_) => EditTeacherDialog(teacher: t));
                                if (result == true) _fetchTeachers();
                              },
                              onDelete: () => _showDeleteDialog(t),
                              onApprove: () => _showApproveDialog(t),
                            )),
                        Container(
                          margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(color: AppColors.primaryDark, borderRadius: BorderRadius.circular(12)),
                          child: Row(children: [
                            const Icon(Icons.sync, color: Colors.white, size: 18),
                            const SizedBox(width: 10),
                            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('Security Sync', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                              Text('Last synced 5 mins ago', style: TextStyle(color: Colors.white70, fontSize: 11)),
                            ]),
                            const Spacer(),
                            const Text('Details', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
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