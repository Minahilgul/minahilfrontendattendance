import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../widgets/base_scaffold.dart';
import '../../widgets/dashboard_card.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/admin_dashboard_service.dart';


class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminDashboard();
  }
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  bool _statsLoading = true;
  Map<String, dynamic> _stats = {};
  String _adminName = 'Admin';

  @override
  void initState() {
    super.initState();
    _loadAdminName();
    _loadStats();
  }

  void _loadAdminName() {
    final storage = GetStorage();
    final name = storage.read<String>('username') ??
        storage.read<String>('name') ??
        storage.read<String>('user_name');
    if (name != null && name.trim().isNotEmpty && mounted) {
      setState(() => _adminName = name);
    }
  }

  Future<void> _loadStats() async {
    setState(() => _statsLoading = true);
    final data = await DashboardService.fetchAdminStats();
    if (!mounted) return;
    setState(() {
      _stats = data;
      _statsLoading = false;
    });
  }

  // Inline responsive helper: on desktop-sized widths (>=800), center the
  // content in a max-width column instead of letting it stretch edge to
  // edge; on mobile/tablet widths, return the child untouched (full width,
  // exactly as before). No other logic is affected by this.
  Widget _responsive(BuildContext context, Widget child) {
    final width = MediaQuery.of(context).size.width;
    if (width < 800) return child;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Admin Dashboard',
      role: 'admin',

      bottomNav: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        backgroundColor: AppColors.surface,
        showUnselectedLabels: true,
        elevation: 8,
        onTap: (index) {
          if (index == 0) {
            setState(() => _selectedIndex = 0);
            return;
          }
          switch (index) {
            case 1:
              Get.toNamed('/classes');
              break;
            case 2:
              Get.toNamed('/reports');
              break;
            case 3:
              Get.toNamed('/admin-profile');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.class_), label: 'Manage Classes'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'View Reports'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: _responsive(
            context,
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _WelcomeStatsCard(
                    adminName: _adminName,
                    loading: _statsLoading,
                    stats: _stats,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Quick actions',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(builder: (context, constraints) {
                    final cols = constraints.maxWidth > 700
                        ? 4
                        : constraints.maxWidth > 520
                            ? 3
                            : 2;
                    final aspectRatio = cols == 2 ? 0.85 : 1.05;
                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: cols,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: aspectRatio,
                      children: [
                        DashboardCard(
                          title: 'Manage Classes',
                          iconData: Icons.grid_view_rounded,
                          type: DashboardCardType.primary,
                          onTap: () => Get.toNamed('/classes'),
                        ),
                        DashboardCard(
                          title: 'Teacher Directory',
                          iconData: Icons.shield_outlined,
                          type: DashboardCardType.success,
                          onTap: () => Get.toNamed('/teacher-directory'),
                        ),
                        DashboardCard(
                          title: 'Student Directory',
                          iconData: Icons.people_alt_outlined,
                          type: DashboardCardType.warning,
                          onTap: () => Get.toNamed('/student-directory'),
                        ),
                        DashboardCard(
                          title: 'Pending Approvals',
                          iconData: Icons.pending_actions_outlined,
                          type: DashboardCardType.purple,
                          onTap: () => Get.toNamed('/approvals'),
                        ),
                        DashboardCard(
                          title: 'Verification Responses',
                          iconData: Icons.fact_check_outlined,
                          type: DashboardCardType.primary,
                          onTap: () => Get.toNamed('/admin-verification'),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Single purple "Welcome" card. Same gradient as the student dashboard's
// welcome banner (primary -> primaryLight) for a consistent look across
// roles. Five stats: Students, Teachers, Classes, Active, Subjects — laid
// out as compact single-line (icon + number + label) entries across two
// rows (3 + 2), separated by thin vertical dividers.
class _WelcomeStatsCard extends StatelessWidget {
  final String adminName;
  final bool loading;
  final Map<String, dynamic> stats;

  const _WelcomeStatsCard({
    required this.adminName,
    required this.loading,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final row1 = <_StatData>[
      _StatData(Icons.people_alt_rounded, stats['total_students'], 'Students'),
      _StatData(Icons.school_rounded, stats['total_teachers'], 'Teachers'),
      _StatData(Icons.category_rounded, stats['total_classes'], 'Classes'),
    ];
    final row2 = <_StatData>[
      _StatData(Icons.check_circle_rounded, stats['active_classes'], 'Active'),
      _StatData(Icons.menu_book_rounded, stats['total_subjects'], 'Subjects'),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
              color: AppColors.primary.withOpacity(0.25),
              blurRadius: 16,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, $adminName! 👋',
            style: const TextStyle(
                color: Colors.white, fontSize: 19, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Admin Portal · Attendance Verification System',
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12.5),
          ),
          const SizedBox(height: 18),
          Container(height: 1, color: Colors.white.withOpacity(0.18)),
          const SizedBox(height: 16),
          loading
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    ),
                  ),
                )
              : Column(
                  children: [
                    _StatLine(items: row1),
                    const SizedBox(height: 14),
                    _StatLine(items: row2),
                  ],
                ),
        ],
      ),
    );
  }
}

class _StatData {
  final IconData icon;
  final dynamic value;
  final String label;
  const _StatData(this.icon, this.value, this.label);
}

// One row of stats, each separated by a thin vertical divider.
class _StatLine extends StatelessWidget {
  final List<_StatData> items;
  const _StatLine({required this.items});

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      if (i > 0) {
        children.add(Container(
          width: 1,
          height: 30,
          color: Colors.white.withOpacity(0.18),
        ));
      }
      children.add(Expanded(child: _StatCell(data: items[i])));
    }
    return Row(children: children);
  }
}

class _StatCell extends StatelessWidget {
  final _StatData data;
  const _StatCell({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(data.icon, size: 14, color: Colors.white.withOpacity(0.85)),
            const SizedBox(width: 5),
            Text(
              '${data.value ?? '-'}',
              style: const TextStyle(
                  color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          data.label,
          style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 10.5),
        ),
      ],
    );
  }
}