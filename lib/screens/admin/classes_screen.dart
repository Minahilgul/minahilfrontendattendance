import 'package:flutter/material.dart';
import 'package:attendence_verification/core/services/auth_service.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/services/class_service.dart';
import '../../widgets/base_scaffold.dart';
import '../../core/theme/app_colors.dart';


// DATA MODEL


enum ClassStatus { active, inactive, scheduled }

class ClassItem {
  final int id;
  final String name;
  final String teacher;
  final int? teacherId;
  final int studentCount;
  final ClassStatus status;
  final bool isPendingTerm;
  final Color iconColor;

  const ClassItem({
    required this.id,
    required this.name,
    required this.teacher,
    this.teacherId,   
    required this.studentCount,
    required this.status,
    this.isPendingTerm = false,
    required this.iconColor,
  });

  factory ClassItem.fromJson(Map<String, dynamic> json) {
    return ClassItem(
      id: json['id']?? 0,
      name: json['class_name']?? '',
      
      teacher: json['teacher_name']?? json['name']?? '',
      teacherId: json['teacher_id'],
      studentCount: json['students_count']?? 0,
      status: json['status'] == 'active'
         ? ClassStatus.active
          : json['status'] == 'inactive'
             ? ClassStatus.inactive
              : ClassStatus.scheduled,
      iconColor: AppColors.primary,
    );
  }
}


// API SERVICE


List<ClassItem> allClasses = [];

Future<void> fetchClasses() async {
  final data = await ClassService.fetchClasses();
  allClasses = data.map((e) => ClassItem.fromJson(e)).toList();
}


// ManageClass.teacher_id directly instead of guessing it later.
Future<bool> createClass(String name, int? teacherId, String className, String students) async {
  return await ClassService.createClass(
    name: name,
    teacherId: teacherId,
    className: className,
    students: students,
  );
}

Future<bool> updateClass(int id, String name, int? teacherId, String className, String students) async {
  return await ClassService.updateClass(
    id: id,
    name: name,
    teacherId: teacherId,
    className: className,
    students: students,
  );
}

Future<bool> deleteClass(int id) async {
  return await ClassService.deleteClass(id);
}


// CLASSES SCREEN


class ClassesScreen extends StatefulWidget {
  const ClassesScreen({super.key});
  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = true;
  String _currentRole = 'admin';
  List<Map<String, dynamic>> _teachersList = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
    _loadRole();
    _loadTeachers();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  Future<void> _loadTeachers() async {
    final teachers = await ClassService.fetchTeachers();
    setState(() {
      _teachersList = teachers;
    });
  }

  Future<void> _loadRole() async {
    final storage = GetStorage();
    final role = storage.read<String>('role');
    if (role!= null && mounted) {
      setState(() {
        _currentRole = role;
      });
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await fetchClasses();
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<ClassItem> _getFilteredClasses(int tabIndex) {
    List<ClassItem> filtered;
    switch (tabIndex) {
      case 1:
        filtered = allClasses.where((c) => c.status == ClassStatus.active).toList();
        break;
      case 2:
        filtered = allClasses.where((c) => c.status == ClassStatus.inactive).toList();
        break;
      case 3:
        filtered = allClasses.where((c) => c.status == ClassStatus.scheduled).toList();
        break;
      default:
        filtered = allClasses;
    }
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((c) => c.name.toLowerCase().contains(_searchQuery) || c.teacher.toLowerCase().contains(_searchQuery)).toList();
    }
    return filtered;
  }

  void _showAddClassDialog() async {
    final result = await showDialog<bool>(
        context: context, builder: (context) => AddClassDialog(teachers: _teachersList));
    if (result == true) _loadData();
  }

  void _showEditClassDialog(ClassItem item) async {
    final result = await showDialog<bool>(
        context: context, builder: (context) => EditClassDialog(item: item, teachers: _teachersList));
    if (result == true) _loadData();
  }

  void _showDeleteClassDialog(ClassItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Class'),
        content: Text('Are you sure you want to delete ${item.name}?'),
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
      final success = await deleteClass(item.id);
      if (success) {
        await _loadData();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${item.name} deleted'), backgroundColor: AppColors.danger));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete'), backgroundColor: AppColors.danger));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Classes',
      role: _currentRole,

      floatingActionButton: FloatingActionButton(
        onPressed: _showAddClassDialog,
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: Container(
        color: AppColors.background,
        child: Column(
          children: [
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search by class or teacher',
                  hintStyle: const TextStyle(fontSize: 14, color: AppColors.textLight),
                  prefixIcon: const Icon(Icons.search, color: AppColors.textLight, size: 20),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                ),
              ),
            ),
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TabBar(
                controller: _tabController,
                onTap: (_) => setState(() {}),
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicator: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                padding: EdgeInsets.zero,
                labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                tabs: const [_TabChip(label: 'All Classes'), _TabChip(label: 'Active'), _TabChip(label: 'Inactive'), _TabChip(label: 'Scheduled')],
              ),
            ),
            Expanded(
              child: _isLoading
                 ? const Center(child: CircularProgressIndicator())
                  : AnimatedBuilder(
                      animation: _tabController,
                      builder: (context, _) {
                        final classes = _getFilteredClasses(_tabController.index);
                        if (classes.isEmpty) {
                          return const Center(child: Text('No classes found', style: TextStyle(color: AppColors.textLight, fontSize: 14)));
                        }
                        return ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: classes.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) => ClassCard(
                            item: classes[index],
                            onEdit: () => _showEditClassDialog(classes[index]),
                            onDelete: () => _showDeleteClassDialog(classes[index]),
                          ),
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

class _TabChip extends StatelessWidget {
  final String label;
  const _TabChip({required this.label});
  @override
  Widget build(BuildContext context) {
    return Tab(child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), child: Text(label)));
  }
}

class ClassCard extends StatelessWidget {
  final ClassItem item;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ClassCard({super.key, required this.item, this.onEdit, this.onDelete});

  Color get _statusColor {
    switch (item.status) {
      case ClassStatus.active:
        return AppColors.success;
      case ClassStatus.inactive:
        return AppColors.textLight;
      case ClassStatus.scheduled:
        return AppColors.primary;
    }
  }

  String get _statusLabel {
    switch (item.status) {
      case ClassStatus.active:
        return 'ACTIVE';
      case ClassStatus.inactive:
        return 'INACTIVE';
      case ClassStatus.scheduled:
        return 'SCHEDULED';
    }
  }

  IconData _getIconForClass(String name) {
    if (name.contains('Calculus') || name.contains('Math')) return Icons.calculate_outlined;
    if (name.contains('Psychology')) return Icons.psychology_outlined;
    if (name.contains('Chemistry')) return Icons.science_outlined;
    if (name.contains('Media') || name.contains('Art')) return Icons.palette_outlined;
    if (name.contains('History')) return Icons.history_edu_outlined;
    if (name.contains('Physical')) return Icons.sports_soccer_outlined;
    return Icons.class_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: AppColors.textPrimary.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 44, height: 44, decoration: BoxDecoration(color: item.iconColor.withOpacity(0.15), borderRadius: BorderRadius.circular(10)), child: Icon(_getIconForClass(item.name), color: item.iconColor, size: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    _StatusBadge(label: _statusLabel, color: _statusColor),
                    if (item.isPendingTerm)...[const SizedBox(width: 6), _StatusBadge(label: 'Pending Term', color: AppColors.warning, isOutlined: true)],
                  ]),
                  const SizedBox(height: 6),
                  Text(item.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 3),
                  Text('• ${item.teacher}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  Row(children: [const Icon(Icons.people_outline, size: 15, color: AppColors.textLight), const SizedBox(width: 4), Text('${item.studentCount} Students', style: const TextStyle(fontSize: 12, color: AppColors.textLight))]),
                ],
              ),
            ),
            const SizedBox(width: 4),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textLight),
              padding: EdgeInsets.zero,
              onSelected: (value) {
                if (value == 'edit') onEdit?.call();
                if (value == 'delete') onDelete?.call();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 18), SizedBox(width: 8), Text('Edit')])),
                const PopupMenuItem(value: 'view', child: Row(children: [Icon(Icons.visibility_outlined, size: 18), SizedBox(width: 8), Text('View Details')])),
                const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 18, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final bool isOutlined;
  const _StatusBadge({required this.label, required this.color, this.isOutlined = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: isOutlined? Colors.transparent : color.withOpacity(0.12), border: isOutlined? Border.all(color: color, width: 1) : null, borderRadius: BorderRadius.circular(4)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isOutlined)...[Container(width: 5, height: 5, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(width: 4)],
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color, letterSpacing: 0.3)),
        ],
      ),
    );
  }
}

class AddClassDialog extends StatefulWidget {
  final List<Map<String, dynamic>> teachers;
  const AddClassDialog({super.key, required this.teachers});
  @override
  State<AddClassDialog> createState() => _AddClassDialogState();
}

class _AddClassDialogState extends State<AddClassDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _classController = TextEditingController();
  String? _selectedTeacherId;
  bool _isLoading = false;

  @override
  void dispose() {
    _classController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate() || _selectedTeacherId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select teacher'), backgroundColor: AppColors.danger)
      );
      return;
    }
    setState(() => _isLoading = true);

    final teacher = widget.teachers.firstWhere(
      (t) => t['id']?.toString() == _selectedTeacherId,
      orElse: () => <String, dynamic>{'username': 'Unknown'},
    );
    final teacherName = teacher['username']?.toString() ?? 'Unknown';
    final teacherIdInt = int.tryParse(_selectedTeacherId!);

    
    // display name.
    final success = await createClass(teacherName, teacherIdInt, _classController.text.trim(), "0");
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (success) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Class created successfully!'), backgroundColor: AppColors.success));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to create class. Please try again.'), backgroundColor: AppColors.danger));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add Class', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: _selectedTeacherId,
                decoration: InputDecoration(
                  labelText: 'Teacher Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
                items: widget.teachers.map((teacher) {
                  final String teacherIdStr = teacher['id']?.toString() ?? '';
                  final String teacherName = teacher['username']?.toString() ?? 'Unknown';
                  return DropdownMenuItem<String>(
                    value: teacherIdStr,
                    child: Text(teacherName, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedTeacherId = value),
                validator: (v) => v == null? 'Teacher Name is required' : null,
              ),
              const SizedBox(height: 14),

              _DialogTextField(
                controller: _classController,
                label: 'Class Name',
                hint: 'Enter class name',
                validator: (v) => (v == null || v.isEmpty)? 'Class Name is required' : null,
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: _isLoading? null : () => Navigator.of(context).pop(), style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('Cancel', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: _isLoading? null : _onSave, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0), child: _isLoading? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Save', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditClassDialog extends StatefulWidget {
  final ClassItem item;
  final List<Map<String, dynamic>> teachers;
  const EditClassDialog({super.key, required this.item, required this.teachers});

  @override
  State<EditClassDialog> createState() => _EditClassDialogState();
}

class _EditClassDialogState extends State<EditClassDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _classController;
  String? _selectedTeacherId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _classController = TextEditingController(text: widget.item.name);
    
    _selectedTeacherId = widget.item.teacherId?.toString();
  }

  @override
  void dispose() {
    _classController.dispose();
    super.dispose();
  }

  Future<void> _onUpdate() async {
    if (!_formKey.currentState!.validate() || _selectedTeacherId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select teacher'), backgroundColor: AppColors.danger)
      );
      return;
    }
    setState(() => _isLoading = true);

    final teacher = widget.teachers.firstWhere(
      (t) => t['id']?.toString() == _selectedTeacherId,
      orElse: () => <String, dynamic>{'username': 'Unknown'},
    );
    final teacherName = teacher['username']?.toString() ?? 'Unknown';
    final teacherIdInt = int.tryParse(_selectedTeacherId!);

    final success = await updateClass(widget.item.id, teacherName, teacherIdInt, _classController.text.trim(), "0");
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (success) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Class updated successfully!'), backgroundColor: AppColors.success));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update class'), backgroundColor: AppColors.danger));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Edit Class', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: _selectedTeacherId,
                decoration: InputDecoration(
                  labelText: 'Teacher Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
                items: widget.teachers.map((teacher) {
                  final String teacherIdStr = teacher['id']?.toString() ?? '';
                  final String teacherName = teacher['username']?.toString() ?? 'Unknown';
                  return DropdownMenuItem<String>(
                    value: teacherIdStr,
                    child: Text(teacherName, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedTeacherId = value),
                validator: (v) => v == null? 'Teacher Name is required' : null,
              ),
              const SizedBox(height: 14),

              _DialogTextField(
                controller: _classController,
                label: 'Class Name',
                hint: 'Enter class name',
                validator: (v) => (v == null || v.isEmpty)? 'Class Name is required' : null,
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: _isLoading? null : () => Navigator.of(context).pop(), style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('Cancel', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: _isLoading? null : _onUpdate, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0), child: _isLoading? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Update', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _DialogTextField({required this.controller, required this.label, required this.hint, this.keyboardType = TextInputType.text, this.validator});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 14, color: Color(0xFFBDBD)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            filled: true,
            fillColor: const Color(0xFFFA),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.danger)),
          ),
        ),
      ],
    );
  }
}