import 'package:attendence_verification/widgets/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import 'package:attendence_verification/core/services/class_service.dart';
import 'package:attendence_verification/core/theme/app_colors.dart';
import 'package:attendence_verification/widgets/base_scaffold.dart';

/// ===============================================================
/// DATA MODEL
/// ===============================================================

enum ClassStatus {
  active,
  inactive,
}

class ClassItem {
  final int id;
  final String name;
  final String teacher;
  final int? teacherId;
  final String subject;
  final int studentCount;
  final ClassStatus status;
  final bool isPendingTerm;
  final Color iconColor;

  const ClassItem({
    required this.id,
    required this.name,
    required this.teacher,
    this.teacherId,
    this.subject = '',
    required this.studentCount,
    required this.status,
    this.isPendingTerm = false,
    required this.iconColor,
  });

  factory ClassItem.fromJson(Map<String, dynamic> json) {
    final statusString =
        json['status']?.toString().toLowerCase() ?? 'inactive';

    final ClassStatus status =
        statusString == 'active' ? ClassStatus.active : ClassStatus.inactive;

    return ClassItem(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['class_name']?.toString() ??
          json['name']?.toString() ??
          '',
      teacher: json['teacher_name']?.toString() ??
          json['teacher']?.toString() ??
          json['name']?.toString() ??
          '',
      teacherId: int.tryParse(json['teacher_id']?.toString() ?? ''),
      subject: json['subject']?.toString() ?? '',
      studentCount:
          int.tryParse(json['students_count']?.toString() ?? '0') ?? 0,
      status: status,
      isPendingTerm: json['is_pending_term'] == true,
      iconColor: AppColors.primary,
    );
  }
}

/// ===============================================================
/// GLOBAL DATA
/// ===============================================================

List<ClassItem> allClasses = [];

/// ===============================================================
/// API FUNCTIONS
/// ===============================================================

Future<void> fetchClasses() async {
  final data = await ClassService.fetchClasses();

  allClasses = data
      .map<ClassItem>(
        (e) => ClassItem.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
      .toList();
}

Future<bool> createClass(
  String name,
  int? teacherId,
  String className,
  String students,
  String subject,
  String status,
) async {
  return await ClassService.createClass(
    name: name,
    teacherId: teacherId,
    className: className,
    students: students,
    subject: subject,
    status: status,
  );
}

Future<bool> updateClass(
  int id,
  String name,
  int? teacherId,
  String className,
  String students,
  String subject,
  String status,
) async {
  return await ClassService.updateClass(
    id: id,
    name: name,
    teacherId: teacherId,
    className: className,
    students: students,
    subject: subject,
    status: status,
  );
}

Future<bool> deleteClass(int id) async {
  return await ClassService.deleteClass(id);
}

/// ===============================================================
/// CLASSES SCREEN
/// ===============================================================

class ClassesScreen extends StatefulWidget {
  const ClassesScreen({super.key});

  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  bool _isLoading = true;
  String _currentRole = 'admin';

  List<Map<String, dynamic>> _teachersList = [];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 3,
      vsync: this,
    );

    _loadData();
    _loadRole();
    _loadTeachers();

    _searchController.addListener(() {
      if (!mounted) return;

      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  Future<void> _loadTeachers() async {
    try {
      final teachers = await ClassService.fetchTeachers();

      if (!mounted) return;

      setState(() {
        _teachersList = teachers;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _teachersList = [];
      });
    }
  }

  Future<void> _loadRole() async {
    final storage = GetStorage();
    final role = storage.read<String>('role');

    if (role != null && mounted) {
      setState(() {
        _currentRole = role;
      });
    }
  }

  Future<void> _loadData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      await fetchClasses();
    } catch (e) {
      debugPrint('Error loading classes: $e');
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
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
        filtered = allClasses
            .where((c) => c.status == ClassStatus.active)
            .toList();
        break;

      case 2:
        filtered = allClasses
            .where((c) => c.status == ClassStatus.inactive)
            .toList();
        break;

      case 0:
      default:
        filtered = List<ClassItem>.from(allClasses);
        break;
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((c) {
        return c.name.toLowerCase().contains(_searchQuery) ||
            c.teacher.toLowerCase().contains(_searchQuery) ||
            c.subject.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    return filtered;
  }

  Future<void> _showAddClassDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AddClassDialog(
          teachers: _teachersList,
        );
      },
    );

    if (result == true) {
      await _loadData();
    }
  }

  Future<void> _showEditClassDialog(ClassItem item) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return EditClassDialog(
          item: item,
          teachers: _teachersList,
        );
      },
    );

    if (result == true) {
      await _loadData();
    }
  }

  void _showViewDetailsDialog(ClassItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Class Details',
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow('Class Name', item.name),
                const SizedBox(height: 10),
                _detailRow('Teacher', item.teacher),
                const SizedBox(height: 10),
                _detailRow(
                  'Subject',
                  item.subject.isEmpty ? 'Not specified' : item.subject,
                ),
                const SizedBox(height: 10),
                _detailRow(
                  'Students',
                  item.studentCount.toString(),
                ),
                const SizedBox(height: 10),
                _detailRow(
                  'Status',
                  _statusText(item.status),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  String _statusText(ClassStatus status) {
    switch (status) {
      case ClassStatus.active:
        return 'Active';

      case ClassStatus.inactive:
        return 'Inactive';
    }
  }

  Future<void> _showDeleteClassDialog(ClassItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Delete Class'),
          content: Text(
            'Are you sure you want to delete ${item.name}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            GradientButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
              ),
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final success = await deleteClass(item.id);

    if (!mounted) return;

    if (success) {
      await _loadData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.name} deleted'),
          backgroundColor: AppColors.danger,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete class'),
          backgroundColor: AppColors.danger,
        ),
      );
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
      body: Container(
        color: AppColors.background,
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(
                16,
                12,
                16,
                12,
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: 'Search by class, teacher or subject',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: AppColors.textLight,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.textLight,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppColors.border,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppColors.border,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),

            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(
                16,
                0,
                16,
                12,
              ),
              child: TabBar(
                controller: _tabController,
                onTap: (_) {
                  setState(() {});
                },
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black54,
                labelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
                padding: EdgeInsets.zero,
                labelPadding: const EdgeInsets.symmetric(
                  horizontal: 4,
                ),
                tabs: const [
                  _TabChip(label: 'All Classes'),
                  _TabChip(label: 'Active'),
                  _TabChip(label: 'Inactive'),
                ],
              ),
            ),

            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : AnimatedBuilder(
                      animation: _tabController,
                      builder: (context, _) {
                        final classes = _getFilteredClasses(
                          _tabController.index,
                        );

                        if (classes.isEmpty) {
                          return const Center(
                            child: Text(
                              'No classes found',
                              style: TextStyle(
                                color: Colors.black38,
                                fontSize: 14,
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: classes.length,
                          separatorBuilder: (_, __) {
                            return const SizedBox(height: 12);
                          },
                          itemBuilder: (context, index) {
                            final item = classes[index];

                            return ClassCard(
                              item: item,
                              onEdit: () {
                                _showEditClassDialog(item);
                              },
                              onView: () {
                                _showViewDetailsDialog(item);
                              },
                              onDelete: () {
                                _showDeleteClassDialog(item);
                              },
                            );
                          },
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

/// ===============================================================
/// TAB CHIP
/// ===============================================================

class _TabChip extends StatelessWidget {
  final String label;

  const _TabChip({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 6,
        ),
        child: Text(label),
      ),
    );
  }
}

/// ===============================================================
/// CLASS CARD
/// ===============================================================

class ClassCard extends StatelessWidget {
  final ClassItem item;
  final VoidCallback? onEdit;
  final VoidCallback? onView;
  final VoidCallback? onDelete;

  const ClassCard({
    super.key,
    required this.item,
    this.onEdit,
    this.onView,
    this.onDelete,
  });

  Color get _statusColor {
    switch (item.status) {
      case ClassStatus.active:
        return AppColors.success;

      case ClassStatus.inactive:
        return AppColors.textLight;
    }
  }

  String get _statusLabel {
    switch (item.status) {
      case ClassStatus.active:
        return 'ACTIVE';

      case ClassStatus.inactive:
        return 'INACTIVE';
    }
  }

  IconData _getIconForClass(String name) {
    final lowerName = name.toLowerCase();

    if (lowerName.contains('calculus') ||
        lowerName.contains('math')) {
      return Icons.calculate_outlined;
    }

    if (lowerName.contains('psychology')) {
      return Icons.psychology_outlined;
    }

    if (lowerName.contains('chemistry')) {
      return Icons.science_outlined;
    }

    if (lowerName.contains('media') ||
        lowerName.contains('art')) {
      return Icons.palette_outlined;
    }

    if (lowerName.contains('history')) {
      return Icons.history_edu_outlined;
    }

    if (lowerName.contains('physical')) {
      return Icons.sports_soccer_outlined;
    }

    return Icons.class_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: item.iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getIconForClass(item.name),
                color: item.iconColor,
                size: 22,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _StatusBadge(
                        label: _statusLabel,
                        color: _statusColor,
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    '• ${item.teacher}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),

                  if (item.subject.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      'Subject: ${item.subject}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                    ),
                  ],

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      const Icon(
                        Icons.people_outline,
                        size: 15,
                        color: Colors.black45,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${item.studentCount} Students',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 4),

            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert,
                size: 20,
                color: Colors.black45,
              ),
              padding: EdgeInsets.zero,
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    onEdit?.call();
                    break;

                  case 'view':
                    onView?.call();
                    break;

                  case 'delete':
                    onDelete?.call();
                    break;
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),

                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(
                        Icons.visibility_outlined,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text('View Details'),
                    ],
                  ),
                ),

                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: AppColors.danger,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Delete',
                        style: TextStyle(
                          color: AppColors.danger,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// ===============================================================
/// STATUS BADGE
/// ===============================================================

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final bool isOutlined;

  const _StatusBadge({
    required this.label,
    required this.color,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: isOutlined
            ? Colors.transparent
            : color.withOpacity(0.12),
        border: isOutlined
            ? Border.all(
                color: color,
                width: 1,
              )
            : null,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isOutlined) ...[
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// ===============================================================
/// ADD CLASS DIALOG
/// ===============================================================

class AddClassDialog extends StatefulWidget {
  final List<Map<String, dynamic>> teachers;

  const AddClassDialog({
    super.key,
    required this.teachers,
  });

  @override
  State<AddClassDialog> createState() => _AddClassDialogState();
}

class _AddClassDialogState extends State<AddClassDialog> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _classController =
      TextEditingController();

  final TextEditingController _subjectController =
      TextEditingController();

  String? _selectedTeacherId;

  String _selectedStatus = 'active';

  bool _isLoading = false;

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedTeacherId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select teacher'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final teacher = widget.teachers.firstWhere(
        (t) =>
            t['id']?.toString() == _selectedTeacherId,
        orElse: () => <String, dynamic>{},
      );

      final teacherName =
          teacher['username']?.toString() ??
              teacher['name']?.toString() ??
              'Unknown';

      final teacherIdInt =
          int.tryParse(_selectedTeacherId!);

      final success = await createClass(
        teacherName,
        teacherIdInt,
        _classController.text.trim(),
        '0',
        _subjectController.text.trim(),
        _selectedStatus,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (success) {
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Failed to create class. Please try again.',
            ),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  void dispose() {
    _classController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add Class',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 20),

                DropdownButtonFormField<String>(
                  value: _selectedTeacherId,
                  decoration: _inputDecoration(
                    label: 'Teacher Name',
                  ),
                  items: widget.teachers.map((teacher) {
                    final teacherId =
                        teacher['id']?.toString() ?? '';

                    final teacherName =
                        teacher['username']?.toString() ??
                            teacher['name']?.toString() ??
                            'Unknown';

                    return DropdownMenuItem<String>(
                      value: teacherId,
                      child: Text(teacherName),
                    );
                  }).toList(),
                  onChanged: _isLoading
                      ? null
                      : (value) {
                          setState(() {
                            _selectedTeacherId = value;
                          });
                        },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Teacher Name is required';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 14),

                _DialogTextField(
                  controller: _classController,
                  label: 'Class Name',
                  hint: 'Enter class name',
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Class Name is required';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 14),

                _DialogTextField(
                  controller: _subjectController,
                  label: 'Subject',
                  hint: 'Enter subject (optional)',
                ),

                const SizedBox(height: 14),

                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: _inputDecoration(
                    label: 'Status',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'active',
                      child: Text('Active'),
                    ),
                    DropdownMenuItem(
                      value: 'inactive',
                      child: Text('Inactive'),
                    ),
                  ],
                  onChanged: _isLoading
                      ? null
                      : (value) {
                          if (value == null) return;

                          setState(() {
                            _selectedStatus = value;
                          });
                        },
                ),

                const SizedBox(height: 24),

                _DialogButtons(
                  isLoading: _isLoading,
                  buttonText: 'Save',
                  onCancel: () {
                    Navigator.of(context).pop();
                  },
                  onSubmit: _onSave,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ===============================================================
/// EDIT CLASS DIALOG
/// ===============================================================

class EditClassDialog extends StatefulWidget {
  final ClassItem item;
  final List<Map<String, dynamic>> teachers;

  const EditClassDialog({
    super.key,
    required this.item,
    required this.teachers,
  });

  @override
  State<EditClassDialog> createState() => _EditClassDialogState();
}

class _EditClassDialogState extends State<EditClassDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _classController;
  late TextEditingController _subjectController;

  String? _selectedTeacherId;
  String _selectedStatus = 'active';

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _classController = TextEditingController(
      text: widget.item.name,
    );

    _subjectController = TextEditingController(
      text: widget.item.subject,
    );

    _selectedTeacherId =
        widget.item.teacherId?.toString();

    _selectedStatus =
        widget.item.status == ClassStatus.active ? 'active' : 'inactive';
  }

  Future<void> _onUpdate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedTeacherId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select teacher'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final teacher = widget.teachers.firstWhere(
        (t) =>
            t['id']?.toString() == _selectedTeacherId,
        orElse: () => <String, dynamic>{},
      );

      final teacherName =
          teacher['username']?.toString() ??
              teacher['name']?.toString() ??
              widget.item.teacher;

      final teacherIdInt =
          int.tryParse(_selectedTeacherId!);

      final success = await updateClass(
        widget.item.id,
        teacherName,
        teacherIdInt,
        _classController.text.trim(),
        '0',
        _subjectController.text.trim(),
        _selectedStatus,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (success) {
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Failed to update class',
            ),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  void dispose() {
    _classController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Edit Class',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 20),

                DropdownButtonFormField<String>(
                  value: _selectedTeacherId,
                  decoration: _inputDecoration(
                    label: 'Teacher Name',
                  ),
                  items: widget.teachers.map((teacher) {
                    final teacherId =
                        teacher['id']?.toString() ?? '';

                    final teacherName =
                        teacher['username']?.toString() ??
                            teacher['name']?.toString() ??
                            'Unknown';

                    return DropdownMenuItem<String>(
                      value: teacherId,
                      child: Text(teacherName),
                    );
                  }).toList(),
                  onChanged: _isLoading
                      ? null
                      : (value) {
                          setState(() {
                            _selectedTeacherId = value;
                          });
                        },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Teacher Name is required';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 14),

                _DialogTextField(
                  controller: _classController,
                  label: 'Class Name',
                  hint: 'Enter class name',
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Class Name is required';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 14),

                _DialogTextField(
                  controller: _subjectController,
                  label: 'Subject',
                  hint: 'Enter subject (optional)',
                ),

                const SizedBox(height: 14),

                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: _inputDecoration(
                    label: 'Status',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'active',
                      child: Text('Active'),
                    ),
                    DropdownMenuItem(
                      value: 'inactive',
                      child: Text('Inactive'),
                    ),
                  ],
                  onChanged: _isLoading
                      ? null
                      : (value) {
                          if (value == null) return;

                          setState(() {
                            _selectedStatus = value;
                          });
                        },
                ),

                const SizedBox(height: 24),

                _DialogButtons(
                  isLoading: _isLoading,
                  buttonText: 'Update',
                  onCancel: () {
                    Navigator.of(context).pop();
                  },
                  onSubmit: _onUpdate,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ===============================================================
/// TEXT FIELD
/// ===============================================================

class _DialogTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _DialogTextField({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),

        const SizedBox(height: 6),

        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 14,
              color: Color(0xFFBDBDBD),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            filled: true,
            fillColor: const Color(0xFFFAFAFA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.border,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.danger,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// ===============================================================
/// INPUT DECORATION
/// ===============================================================

InputDecoration _inputDecoration({
  required String label,
}) {
  return InputDecoration(
    labelText: label,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: AppColors.border,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: AppColors.border,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: AppColors.primary,
        width: 1.5,
      ),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 14,
      vertical: 10,
    ),
  );
}

/// ===============================================================
/// DIALOG BUTTONS
/// ===============================================================

class _DialogButtons extends StatelessWidget {
  final bool isLoading;
  final String buttonText;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const _DialogButtons({
    required this.isLoading,
    required this.buttonText,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: isLoading ? null : onCancel,
          style: TextButton.styleFrom(
            foregroundColor: Colors.black54,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Cancel',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        const SizedBox(width: 8),

        GradientButton(
          onPressed: isLoading ? null : onSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 10,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  buttonText,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ],
    );
  }
}