import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance Verification',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF1565C0),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      ),
      home: const TeacherDirectoryScreen(),
    );
  }
}

// ─────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────

enum TeacherStatus { verified, inactive, securityAlert }

class TeacherModel {
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

  const TeacherModel({
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
  });
}

final List<TeacherModel> _allTeachers = [
  TeacherModel(
    initials: 'SJ',
    avatarColor: const Color(0xFF1565C0),
    name: 'Dr. Sarah Jenkins',
    department: 'Computer Science',
    role: 'Senior Dean',
    status: TeacherStatus.verified,
    activeClasses: 6,
    deviceInfo: 'iPhone 14 Pro',
    lastSeen: '2M AGO',
  ),
  TeacherModel(
    initials: 'MT',
    avatarColor: const Color(0xFF6A1B9A),
    name: 'Prof. Marcus Thorne',
    department: 'Mathematics',
    role: 'Associate Prof.',
    status: TeacherStatus.securityAlert,
    activeClasses: 5,
    securityMessage: 'NEW LOGIN DETECTED\nUnknown Windows PC • Austin, TX',
  ),
  TeacherModel(
    initials: 'ER',
    avatarColor: const Color(0xFF00695C),
    name: 'Elena Rodriguez',
    department: 'Fine Arts',
    role: 'Assistant',
    status: TeacherStatus.inactive,
    activeClasses: 0,
    registeredInfo: 'Registered',
  ),
];

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
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
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
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add New Teacher',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                'Fill in the details to add a new faculty member',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              const SizedBox(height: 20),
              _buildField('Username', _usernameCtrl, Icons.person_outline),
              const SizedBox(height: 14),
              _buildField('Email', _emailCtrl, Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 14),
              _buildPasswordField(),
              const SizedBox(height: 14),
              _buildField('Phone Number', _phoneCtrl, Icons.phone_outlined,
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey[400]!),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Cancel',
                          style: TextStyle(color: Colors.black87)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Save'),
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

  Widget _buildField(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        isDense: true,
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordCtrl,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: const Icon(Icons.lock_outline, size: 20),
        suffixIcon: IconButton(
          icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              size: 20),
          onPressed: () =>
              setState(() => _obscurePassword = !_obscurePassword),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        isDense: true,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TEACHER CARD WIDGET
// ─────────────────────────────────────────────

class TeacherCard extends StatelessWidget {
  final TeacherModel teacher;

  const TeacherCard({super.key, required this.teacher});

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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 22,
                  backgroundColor: teacher.avatarColor,
                  child: Text(
                    teacher.initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StatusBadge(status: teacher.status),
                      const SizedBox(height: 4),
                      Text(
                        teacher.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      Text(
                        '${teacher.department} • ${teacher.role}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.class_outlined,
                              size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            '${teacher.activeClasses} Active Classes',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600]),
                          ),
                          if (teacher.deviceInfo != null) ...[
                            const SizedBox(width: 12),
                            Icon(Icons.smartphone,
                                size: 14, color: Colors.grey[500]),
                            const SizedBox(width: 4),
                            Text(
                              teacher.deviceInfo!,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                          if (teacher.registeredInfo != null) ...[
                            const SizedBox(width: 12),
                            Icon(Icons.check_circle_outline,
                                size: 14, color: Colors.grey[500]),
                            const SizedBox(width: 4),
                            Text(
                              teacher.registeredInfo!,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ],
                      ),
                      if (teacher.lastSeen != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'LAST SEEN ${teacher.lastSeen}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[400],
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // More icon
                Icon(Icons.more_vert, color: Colors.grey[400], size: 20),
              ],
            ),
          ),

          // Security alert section
          if (isAlert) ...[
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8F8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFFCDD2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: Color(0xFFE53935), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'NEW LOGIN DETECTED',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFE53935),
                            letterSpacing: 0.3,
                          ),
                        ),
                        Text(
                          'Unknown Windows PC • Austin, TX',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE53935)),
                        foregroundColor: const Color(0xFFE53935),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('LOCK ACCOUNT',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('VERIFY ID',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // View logs for verified
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
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('VIEW LOGS',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 14),
                    ],
                  ),
                ),
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
  const TeacherDirectoryScreen({super.key});

  @override
  State<TeacherDirectoryScreen> createState() => _TeacherDirectoryScreenState();
}

class _TeacherDirectoryScreenState extends State<TeacherDirectoryScreen> {
  int _selectedTab = 0;
  int _selectedNavIndex = 0;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  final List<String> _tabs = ['All Faculty', 'Registered', 'Security Alerts'];
  final List<String> _navLabels = ['Faculty', 'Classes', 'Security', 'Settings'];
  final List<IconData> _navIcons = [
    Icons.people_outline,
    Icons.class_outlined,
    Icons.security_outlined,
    Icons.settings_outlined,
  ];

  List<TeacherModel> get _filteredTeachers {
    List<TeacherModel> list = _allTeachers;

    // Filter by tab
    if (_selectedTab == 1) {
      list = list
          .where((t) => t.status == TeacherStatus.verified || t.registeredInfo != null)
          .toList();
    } else if (_selectedTab == 2) {
      list = list.where((t) => t.status == TeacherStatus.securityAlert).toList();
    }

    // Filter by search
    if (_searchQuery.isNotEmpty) {
      list = list
          .where((t) =>
              t.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              t.department.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return list;
  }

  void _openAddTeacherDialog() {
    showDialog(
      context: context,
      builder: (_) => const AddTeacherDialog(),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // ── HEADER ──
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {},
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Teacher Directory',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                            Text(
                              'Manage faculty and security',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1565C0),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.add,
                              color: Colors.white, size: 20),
                          onPressed: _openAddTeacherDialog,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Search bar
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F2F5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: 'Search by name or department',
                        hintStyle:
                            TextStyle(color: Colors.grey[400], fontSize: 13),
                        prefixIcon: Icon(Icons.search,
                            color: Colors.grey[400], size: 20),
                        suffixIcon: Icon(Icons.tune,
                            color: Colors.grey[400], size: 18),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Tab bar
                  Row(
                    children: List.generate(_tabs.length, (i) {
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
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _tabs[i],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? Colors.white
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),

            // ── LIST ──
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: [
                  // Active staff header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ACTIVE STAFF (${_filteredTeachers.length})',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey[500],
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          'Sort by: Recent',
                          style: TextStyle(
                              fontSize: 11, color: const Color(0xFF1565C0)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  ..._filteredTeachers
                      .map((t) => TeacherCard(teacher: t)),

                  // ── Security Sync footer ──
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1565C0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.sync, color: Colors.white, size: 18),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Security Sync',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              'Last synced 5 mins ago',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Text(
                          'Details',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // ── BOTTOM NAV ──
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 12,
                offset: const Offset(0, -2))
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_navLabels.length, (i) {
                final selected = _selectedNavIndex == i;
                return GestureDetector(
                  onTap: () => setState(() => _selectedNavIndex = i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _navIcons[i],
                        size: 22,
                        color: selected
                            ? const Color(0xFF1565C0)
                            : Colors.grey[400],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _navLabels[i],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? const Color(0xFF1565C0)
                              : Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}