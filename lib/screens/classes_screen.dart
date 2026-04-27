import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:attendence_verification/core/services/auth_service.dart';

void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance Verification App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2196F3)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const ClassesScreen(),
    );
  }
}

// ─────────────────────────────────────────────
// DATA MODEL
// ─────────────────────────────────────────────

enum ClassStatus { active, inactive, scheduled }

class ClassItem {
  final String name;
  final String teacher;
  final int studentCount;
  final ClassStatus status;
  final bool isPendingTerm;
  final Color iconColor;

  const ClassItem({
    required this.name,
    required this.teacher,
    required this.studentCount,
    required this.status,
    this.isPendingTerm = false,
    required this.iconColor,
  });
}

// ─────────────────────────────────────────────
// DUMMY DATA
// ─────────────────────────────────────────────

final List<ClassItem> allClasses = [
  const ClassItem(
    name: 'Advanced Calculus',
    teacher: 'Dr. Sarah Smith',
    studentCount: 42,
    status: ClassStatus.active,
    iconColor: Color(0xFFFFA726),
  ),
  const ClassItem(
    name: 'Intro to Psychology',
    teacher: 'Prof. Mark Evans',
    studentCount: 168,
    status: ClassStatus.active,
    iconColor: Color(0xFFEF9A9A),
  ),
  const ClassItem(
    name: 'Organic Chemistry Lab',
    teacher: 'Dr. Janet Doe',
    studentCount: 0,
    status: ClassStatus.inactive,
    isPendingTerm: true,
    iconColor: Color(0xFF66BB6A),
  ),
  const ClassItem(
    name: 'Digital Media & Art',
    teacher: 'Prof. Alex Rivera',
    studentCount: 18,
    status: ClassStatus.active,
    iconColor: Color(0xFFAB47BC),
  ),
  const ClassItem(
    name: 'World History',
    teacher: 'Dr. Emily Chen',
    studentCount: 95,
    status: ClassStatus.scheduled,
    iconColor: Color(0xFF42A5F5),
  ),
  const ClassItem(
    name: 'Physical Education',
    teacher: 'Coach Brian Lee',
    studentCount: 30,
    status: ClassStatus.inactive,
    iconColor: Color(0xFFFF7043),
  ),
];

// ─────────────────────────────────────────────
// API SERVICE
// ─────────────────────────────────────────────

Future<bool> createClass(
    String name, String className, String students) async {
  try {
    final response = await http.post(
      Uri.parse('${AuthService.baseUrl}/classes'), // 🔥 REAL API
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'className': className,
        'students': students,
      }),
    );

    print("CREATE CLASS STATUS: ${response.statusCode}");
    print("CREATE CLASS RESPONSE: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    print("CREATE CLASS ERROR: $e");
    return false;
  }
}

// ─────────────────────────────────────────────
// CLASSES SCREEN
// ─────────────────────────────────────────────

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
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
        filtered =
            allClasses.where((c) => c.status == ClassStatus.active).toList();
        break;
      case 2:
        filtered =
            allClasses.where((c) => c.status == ClassStatus.inactive).toList();
        break;
      case 3:
        filtered =
            allClasses.where((c) => c.status == ClassStatus.scheduled).toList();
        break;
      default:
        filtered = allClasses;
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((c) =>
              c.name.toLowerCase().contains(_searchQuery) ||
              c.teacher.toLowerCase().contains(_searchQuery))
          .toList();
    }

    return filtered;
  }

  void _showAddClassDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddClassDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Classes',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF2196F3), size: 26),
            onPressed: _showAddClassDialog,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE0E0E0), height: 1),
        ),
      ),
      body: Column(
        children: [
          // ── Search Bar ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              decoration: InputDecoration(
                hintText: 'Search by class or teacher',
                hintStyle:
                    const TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
                prefixIcon: const Icon(Icons.search,
                    color: Color(0xFF9E9E9E), size: 20),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: Color(0xFF2196F3), width: 1.5),
                ),
              ),
            ),
          ),

          // ── Tab Bar ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TabBar(
              controller: _tabController,
              onTap: (_) => setState(() {}),
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicator: BoxDecoration(
                color: const Color(0xFF2196F3),
                borderRadius: BorderRadius.circular(20),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black54,
              labelStyle: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500),
              unselectedLabelStyle: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w400),
              padding: EdgeInsets.zero,
              labelPadding:
                  const EdgeInsets.symmetric(horizontal: 4),
              tabs: const [
                _TabChip(label: 'All Classes'),
                _TabChip(label: 'Active'),
                _TabChip(label: 'Inactive'),
                _TabChip(label: 'Scheduled'),
              ],
            ),
          ),

          // ── Class List ──
          Expanded(
            child: AnimatedBuilder(
              animation: _tabController,
              builder: (context, _) {
                final classes =
                    _getFilteredClasses(_tabController.index);
                if (classes.isEmpty) {
                  return const Center(
                    child: Text(
                      'No classes found',
                      style: TextStyle(
                          color: Colors.black38, fontSize: 14),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: classes.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) =>
                      ClassCard(item: classes[index]),
                );
              },
            ),
          ),
        ],
      ),

      // ── FAB ──
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddClassDialog,
        backgroundColor: const Color(0xFF2196F3),
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),

      // ── Bottom Navigation Bar ──
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: const Color(0xFF2196F3),
        unselectedItemColor: Colors.black38,
        selectedLabelStyle: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.w500),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        backgroundColor: Colors.white,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_outlined),
            activeIcon: Icon(Icons.school),
            label: 'Classes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Students',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TAB CHIP WIDGET
// ─────────────────────────────────────────────

class _TabChip extends StatelessWidget {
  final String label;
  const _TabChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Text(label),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CLASS CARD WIDGET
// ─────────────────────────────────────────────

class ClassCard extends StatelessWidget {
  final ClassItem item;
  const ClassCard({super.key, required this.item});

  Color get _statusColor {
    switch (item.status) {
      case ClassStatus.active:
        return const Color(0xFF4CAF50);
      case ClassStatus.inactive:
        return const Color(0xFF9E9E9E);
      case ClassStatus.scheduled:
        return const Color(0xFF2196F3);
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
            // ── Left Icon ──
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

            // ── Content ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status badges row
                  Row(
                    children: [
                      _StatusBadge(
                        label: _statusLabel,
                        color: _statusColor,
                      ),
                      if (item.isPendingTerm) ...[
                        const SizedBox(width: 6),
                        _StatusBadge(
                          label: 'Pending Term',
                          color: const Color(0xFFFF9800),
                          isOutlined: true,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Class name
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 3),
                  // Teacher name
                  Text(
                    '• ${item.teacher}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Student count
                  Row(
                    children: [
                      const Icon(Icons.people_outline,
                          size: 15, color: Colors.black45),
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

            // ── Three-dot Menu ──
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert,
                  size: 20, color: Colors.black45),
              padding: EdgeInsets.zero,
              onSelected: (value) {
                // Handle menu actions
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'view', child: Text('View Details')),
                const PopupMenuItem(
                    value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForClass(String name) {
    if (name.contains('Calculus') || name.contains('Math')) {
      return Icons.calculate_outlined;
    } else if (name.contains('Psychology')) {
      return Icons.psychology_outlined;
    } else if (name.contains('Chemistry')) {
      return Icons.science_outlined;
    } else if (name.contains('Media') || name.contains('Art')) {
      return Icons.palette_outlined;
    } else if (name.contains('History')) {
      return Icons.history_edu_outlined;
    } else if (name.contains('Physical')) {
      return Icons.sports_soccer_outlined;
    }
    return Icons.class_outlined;
  }
}

// ─────────────────────────────────────────────
// STATUS BADGE WIDGET
// ─────────────────────────────────────────────

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
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: isOutlined ? Colors.transparent : color.withOpacity(0.12),
        border: isOutlined ? Border.all(color: color, width: 1) : null,
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

// ─────────────────────────────────────────────
// ADD CLASS DIALOG
// ─────────────────────────────────────────────

class AddClassDialog extends StatefulWidget {
  const AddClassDialog({super.key});

  @override
  State<AddClassDialog> createState() => _AddClassDialogState();
}

class _AddClassDialogState extends State<AddClassDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _classController = TextEditingController();
  final TextEditingController _studentsController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _classController.dispose();
    _studentsController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final success = await createClass(
      _nameController.text.trim(),
      _classController.text.trim(),
      _studentsController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Class created successfully!'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create class. Please try again.'),
          backgroundColor: Color(0xFFF44336),
        ),
      );
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
              // ── Title ──
              const Text(
                'Add Class',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),

              // ── Name Field ──
              _DialogTextField(
                controller: _nameController,
                label: 'Name',
                hint: 'Enter teacher name',
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: 14),

              // ── Class Field ──
              _DialogTextField(
                controller: _classController,
                label: 'Class',
                hint: 'Enter class name',
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Class is required' : null,
              ),
              const SizedBox(height: 14),

              // ── Students Field ──
              _DialogTextField(
                controller: _studentsController,
                label: 'Roll No',
                hint: 'Enter number of students',
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Students is required';
                  if (int.tryParse(v) == null)
                    return 'Enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // ── Buttons ──
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Cancel
                  TextButton(
                    onPressed:
                        _isLoading ? null : () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black54,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Save
                  ElevatedButton(
                    onPressed: _isLoading ? null : _onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Save',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DIALOG TEXT FIELD
// ─────────────────────────────────────────────

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
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                const TextStyle(fontSize: 14, color: Color(0xFFBDBDBD)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            filled: true,
            fillColor: const Color(0xFFFAFAFA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                  color: Color(0xFF2196F3), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFF44336)),
            ),
          ),
        ),
      ],
    );
  }
}