import 'package:flutter/material.dart';
import 'package:attendence_verification/core/services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/services/class_service.dart';
import '../widgets/base_scaffold.dart';

// ─────────────────────────────────────────────
// DATA MODEL
// ─────────────────────────────────────────────

enum ClassStatus { active, inactive, scheduled }

class ClassItem {
  final int id;
  final String name;
  final String teacher;
  final int studentCount;
  final ClassStatus status;
  final bool isPendingTerm;
  final Color iconColor;

  const ClassItem({
    required this.id,
    required this.name,
    required this.teacher,
    required this.studentCount,
    required this.status,
    this.isPendingTerm = false,
    required this.iconColor,
  });

  
  factory ClassItem.fromJson(Map<String, dynamic> json) {
    return ClassItem(
      id: json['id']?? 0,
<<<<<<< HEAD
      name: json['class_name']?? '',
      teacher: json['name']?? '',
=======
      name: json['name']?? '',
      teacher: json['class_name']?? '',
>>>>>>> af416199e6087c9de125e478054a03f0373937c4
      studentCount: json['students_count']?? 0,
      status: json['status'] == 'active'? ClassStatus.active :
              json['status'] == 'inactive'? ClassStatus.inactive :
              ClassStatus.scheduled,
      iconColor: const Color(0xFF2196F3),
    );
  }
}

// ─────────────────────────────────────────────
// API SERVICE - API SE DATA LOAD HOGA VIA CLASS SERVICE
// ─────────────────────────────────────────────

List<ClassItem> allClasses = []; 

Future<void> fetchClasses() async {
  final data = await ClassService.fetchClasses();
  allClasses = data.map((e) => ClassItem.fromJson(e)).toList();
}

Future<bool> createClass(String name, String className, String students) async {
  return await ClassService.createClass(
    name: name,
    className: className,
    students: students,
  );
}

Future<bool> updateClass(int id, String name, String className, String students) async {
  return await ClassService.updateClass(
    id: id,
    name: name,
    className: className,
    students: students,
  );
}

Future<bool> deleteClass(int id) async {
  return await ClassService.deleteClass(id);
}

// ─────────────────────────────────────────────
// CLASSES SCREEN
// ─────────────────────────────────────────────

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData(); 
    _loadRole();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  Future<void> _loadRole() async {
    const storage = FlutterSecureStorage();
    final role = await storage.read(key: 'role');
    if (role != null && mounted) {
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
    final result = await showDialog<bool>(context: context, builder: (context) => const AddClassDialog());
    if (result == true) _loadData(); // 👈 Refresh
  }

  void _showEditClassDialog(ClassItem item) async {
    final result = await showDialog<bool>(context: context, builder: (context) => EditClassDialog(item: item));
    if (result == true) _loadData(); // 👈 Refresh
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
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE53935)),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await deleteClass(item.id);
      if (success) {
        await _loadData(); // 👈 Refresh
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${item.name} deleted'), backgroundColor: const Color(0xFFC62828)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete'), backgroundColor: Color(0xFFC62828)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Classes',
      role: _currentRole,
      actions: [
        IconButton(icon: const Icon(Icons.add, color: Colors.white, size: 26), onPressed: _showAddClassDialog),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddClassDialog,
        backgroundColor: const Color(0xFF2196F3),
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: Container(
        color: const Color(0xFFF5F5F5),
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Search by class or teacher',
                  hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF9E9E9E), size: 20),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF2196F3), width: 1.5)),
                ),
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TabBar(
                controller: _tabController,
                onTap: (_) => setState(() {}),
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicator: BoxDecoration(color: const Color(0xFF2196F3), borderRadius: BorderRadius.circular(20)),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black54,
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
                    return const Center(child: Text('No classes found', style: TextStyle(color: Colors.black38, fontSize: 14)));
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
      case ClassStatus.active: return const Color(0xFF4CAF50);
      case ClassStatus.inactive: return const Color(0xFF9E9E9E);
      case ClassStatus.scheduled: return const Color(0xFF2196F3);
    }
  }

  String get _statusLabel {
    switch (item.status) {
      case ClassStatus.active: return 'ACTIVE';
      case ClassStatus.inactive: return 'INACTIVE';
      case ClassStatus.scheduled: return 'SCHEDULED';
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]),
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
                    if (item.isPendingTerm)...[const SizedBox(width: 6), _StatusBadge(label: 'Pending Term', color: const Color(0xFFFF9800), isOutlined: true)],
                  ]),
                  const SizedBox(height: 6),
                  Text(item.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87)),
                  const SizedBox(height: 3),
                  Text('• ${item.teacher}', style: const TextStyle(fontSize: 13, color: Colors.black54)),
                  const SizedBox(height: 6),
                  Row(children: [const Icon(Icons.people_outline, size: 15, color: Colors.black45), const SizedBox(width: 4), Text('${item.studentCount} Students', style: const TextStyle(fontSize: 12, color: Colors.black45))]),
                ],
              ),
            ),
            const SizedBox(width: 4),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 20, color: Colors.black45),
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
  const AddClassDialog({super.key});
  @override
  State<AddClassDialog> createState() => _AddClassDialogState();
}

class _AddClassDialogState extends State<AddClassDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _classController = TextEditingController();
<<<<<<< HEAD
  
=======
  final TextEditingController _studentsController = TextEditingController();
>>>>>>> af416199e6087c9de125e478054a03f0373937c4
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _classController.dispose();
<<<<<<< HEAD
    
=======
    _studentsController.dispose();
>>>>>>> af416199e6087c9de125e478054a03f0373937c4
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
<<<<<<< HEAD
    final success = await createClass(_nameController.text.trim(), _classController.text.trim(), "0");
=======
    final success = await createClass(_nameController.text.trim(), _classController.text.trim(), _studentsController.text.trim());
>>>>>>> af416199e6087c9de125e478054a03f0373937c4
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (success) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Class created successfully!'), backgroundColor: Color(0xFF4CAF50)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to create class. Please try again.'), backgroundColor: Color(0xFFF44336)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add Class', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87)),
              const SizedBox(height: 20),
              _DialogTextField(controller: _nameController, label: 'Name', hint: 'Enter teacher name', validator: (v) => (v == null || v.isEmpty)? 'Name is required' : null),
              const SizedBox(height: 14),
              _DialogTextField(controller: _classController, label: 'Class', hint: 'Enter class name', validator: (v) => (v == null || v.isEmpty)? 'Class is required' : null),
              const SizedBox(height: 14),
<<<<<<< HEAD
             
=======
              _DialogTextField(controller: _studentsController, label: 'Roll No', hint: 'Enter number of students', keyboardType: TextInputType.number, validator: (v) {if (v == null || v.isEmpty) return 'Students is required'; if (int.tryParse(v) == null) return 'Enter a valid number'; return null;}),
              const SizedBox(height: 24),
>>>>>>> af416199e6087c9de125e478054a03f0373937c4
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: _isLoading? null : () => Navigator.of(context).pop(), style: TextButton.styleFrom(foregroundColor: Colors.black54, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('Cancel', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: _isLoading? null : _onSave, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2196F3), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0), child: _isLoading? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Save', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
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
  const EditClassDialog({super.key, required this.item});

  @override
  State<EditClassDialog> createState() => _EditClassDialogState();
}

class _EditClassDialogState extends State<EditClassDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _classController;
<<<<<<< HEAD
  
=======
  late TextEditingController _studentsController;
>>>>>>> af416199e6087c9de125e478054a03f0373937c4
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.teacher);
    _classController = TextEditingController(text: widget.item.name);
<<<<<<< HEAD
   Count.toString());
=======
    _studentsController = TextEditingController(text: widget.item.studentCount.toString());
>>>>>>> af416199e6087c9de125e478054a03f0373937c4
  }

  @override
  void dispose() {
    _nameController.dispose();
    _classController.dispose();
<<<<<<< HEAD
  
=======
    _studentsController.dispose();
>>>>>>> af416199e6087c9de125e478054a03f0373937c4
    super.dispose();
  }

  Future<void> _onUpdate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
<<<<<<< HEAD
    final success = await updateClass(widget.item.id, _nameController.text.trim(), _classController.text.trim(), "0");
=======
    final success = await updateClass(widget.item.id, _nameController.text.trim(), _classController.text.trim(), _studentsController.text.trim());
>>>>>>> af416199e6087c9de125e478054a03f0373937c4
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (success) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Class updated successfully!'), backgroundColor: Color(0xFF4CAF50)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update class'), backgroundColor: Color(0xFFF44336)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Edit Class', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87)),
              const SizedBox(height: 20),
              _DialogTextField(controller: _nameController, label: 'Teacher Name', hint: 'Enter teacher name', validator: (v) => (v == null || v.isEmpty)? 'Name is required' : null),
              const SizedBox(height: 14),
              _DialogTextField(controller: _classController, label: 'Class Name', hint: 'Enter class name', validator: (v) => (v == null || v.isEmpty)? 'Class is required' : null),
              const SizedBox(height: 14),
<<<<<<< HEAD
              
=======
              _DialogTextField(controller: _studentsController, label: 'Students Count', hint: 'Enter number of students', keyboardType: TextInputType.number, validator: (v) {if (v == null || v.isEmpty) return 'Students is required'; if (int.tryParse(v) == null) return 'Enter a valid number'; return null;}),
              const SizedBox(height: 24),
>>>>>>> af416199e6087c9de125e478054a03f0373937c4
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: _isLoading? null : () => Navigator.of(context).pop(), style: TextButton.styleFrom(foregroundColor: Colors.black54, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('Cancel', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: _isLoading? null : _onUpdate, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2196F3), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0), child: _isLoading? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Update', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
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
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black54)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 14, color: Color(0xFFBDBD)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            filled: true,
            fillColor: const Color(0xFFFA),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF2196F3), width: 1.5)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFF44336))),
          ),
        ),
      ],
    );
  }
}