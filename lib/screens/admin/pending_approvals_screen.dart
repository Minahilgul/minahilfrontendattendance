import 'package:flutter/material.dart';
import '../../widgets/base_scaffold.dart';
import '../../core/services/student_service.dart';
import '../../core/theme/app_colors.dart';


// ── DATA MODELS ───────────────────────────────────────────────────────────────

class ApprovalRequest {
  final String id;
  final String initials;
  final Color avatarColor;
  final String name;
  final String studentId;
  final String classInfo;
  final String requestedBy;
  final String timeAgo;

  const ApprovalRequest({
    required this.id,
    required this.initials,
    required this.avatarColor,
    required this.name,
    required this.studentId,
    required this.classInfo,
    required this.requestedBy,
    required this.timeAgo,
  });
}

class LateStudent {
  final String id;
  final String name;
  final String initials;
  final Color avatarColor;
  final String classInfo;
  final String teacherName;
  final String sessionDate;
  final String markedTime;

  const LateStudent({
    required this.id,
    required this.name,
    required this.initials,
    required this.avatarColor,
    required this.classInfo,
    required this.teacherName,
    required this.sessionDate,
    required this.markedTime,
  });
}


// ── APPROVAL CARD ─────────────────────────────────────────────────────────────

class ApprovalCard extends StatelessWidget {
  final ApprovalRequest request;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const ApprovalCard({
    super.key,
    required this.request,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: request.avatarColor,
                  child: Text(request.initials,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(request.name,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      const SizedBox(height: 3),
                      Row(children: [
                        Icon(Icons.badge_outlined, size: 13, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text('${request.studentId} • ${request.classInfo}',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ]),
                      const SizedBox(height: 3),
                      Row(children: [
                        Icon(Icons.person_outline, size: 13, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text('Requested by: ${request.requestedBy}',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ]),
                    ],
                  ),
                ),
                Text(request.timeAgo,
                    style: TextStyle(fontSize: 10, color: AppColors.textLight, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.close, size: 15),
                    label: const Text('Reject',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: BorderSide(color: AppColors.danger, width: 1.2),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.check_circle_outline, size: 15),
                    label: const Text('Approve',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// ── LATE STUDENT CARD ─────────────────────────────────────────────────────────

class LateStudentCard extends StatelessWidget {
  final LateStudent student;
  const LateStudentCard({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withOpacity(0.4), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            CircleAvatar(
              radius: 22,
              backgroundColor: student.avatarColor,
              child: Text(student.initials,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student.name,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 3),
                  Row(children: [
                    Icon(Icons.class_outlined, size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(student.classInfo,
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ]),
                  const SizedBox(height: 2),
                  Row(children: [
                    Icon(Icons.person_outline, size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text('Teacher: ${student.teacherName}',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ]),
                  const SizedBox(height: 2),
                  Row(children: [
                    Icon(Icons.access_time, size: 12, color: AppColors.textLight),
                    const SizedBox(width: 4),
                    Text('${student.sessionDate}  •  ${student.markedTime}',
                        style: TextStyle(fontSize: 11, color: AppColors.textLight)),
                  ]),
                ],
              ),
            ),
            // Late badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.schedule_rounded, size: 13, color: AppColors.warning),
                const SizedBox(width: 4),
                Text('LATE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.warning)),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}


// ── MAIN SCREEN ───────────────────────────────────────────────────────────────

class ApprovalsScreen extends StatefulWidget {
  const ApprovalsScreen({super.key});
  @override
  State<ApprovalsScreen> createState() => _ApprovalsScreenState();
}

class _ApprovalsScreenState extends State<ApprovalsScreen>
    with SingleTickerProviderStateMixin {
  // ✅ TabController length: 3 → 2 (Attendance Exceptions removed)
  late TabController _tabController;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  // Tab 0: Pending approvals
  List<ApprovalRequest> _requests = [];
  bool _loadingRequests = true;

  // Tab 1: Late students (real API)
  List<LateStudent> _lateStudents = [];
  bool _loadingLate = false;
  bool _lateLoaded = false;

  @override
  void initState() {
    super.initState();
    // ✅ length 2 — only 'All Students' and 'Late'
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      // Load late students when tab 1 is first opened
      if (_tabController.index == 1 && !_lateLoaded) {
        _loadLateStudents();
      }
    });
    _loadRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Load pending approval requests ────────────────────────────────────────
  Future<void> _loadRequests() async {
    setState(() => _loadingRequests = true);
    try {
      final data = await StudentService.fetchPendingStudents();
      final list = data.map<ApprovalRequest>((s) {
        final name = (s['name'] ?? s['username'] ?? '') as String;
        final initials = name.split(' ').where((e) => e.isNotEmpty)
            .map((e) => e[0]).take(2).join().toUpperCase();
        final classInfo = (s['class'] ?? s['class_name'] ?? 'N/A') as String;
        final requestedBy = (s['teacher_name'] ?? s['teacher']?['username'] ?? 'Teacher') as String;
        final rawDate = s['created_at'] as String?;
        final timeAgo = rawDate != null ? _formatDate(rawDate) : 'Just now';
        final idVal = s['id'];
        return ApprovalRequest(
          id: idVal.toString(),
          initials: initials.isEmpty ? 'ST' : initials,
          avatarColor: Colors.primaries[idVal.hashCode % Colors.primaries.length],
          name: name.isEmpty ? 'Unknown Student' : name,
          studentId: 'ID#${idVal.toString()}',
          classInfo: classInfo,
          requestedBy: requestedBy,
          timeAgo: timeAgo,
        );
      }).toList();
      setState(() { _requests = list; _loadingRequests = false; });
    } catch (e) {
      setState(() => _loadingRequests = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading requests: $e')));
      }
    }
  }

  // ── Load late students from real API ──────────────────────────────────────
  Future<void> _loadLateStudents() async {
    setState(() { _loadingLate = true; });
    try {
      final data = await StudentService.fetchLateStudents();
      final list = data.map<LateStudent>((s) {
        final name = (s['student_name'] ?? s['name'] ?? '') as String;
        final initials = name.split(' ').where((e) => e.isNotEmpty)
            .map((e) => e[0]).take(2).join().toUpperCase();
        final idVal = s['student_id'] ?? s['id'] ?? 0;
        return LateStudent(
          id: idVal.toString(),
          name: name.isEmpty ? 'Unknown' : name,
          initials: initials.isEmpty ? 'ST' : initials,
          avatarColor: Colors.primaries[idVal.hashCode % Colors.primaries.length],
          classInfo: (s['class_name'] ?? s['class'] ?? '-') as String,
          teacherName: (s['teacher_name'] ?? '-') as String,
          sessionDate: _formatDateShort(s['session_date'] ?? s['date'] ?? ''),
          markedTime: (s['marked_time'] ?? s['time'] ?? '-') as String,
        );
      }).toList();
      setState(() { _lateStudents = list; _loadingLate = false; _lateLoaded = true; });
    } catch (e) {
      setState(() { _loadingLate = false; _lateLoaded = true; });
    }
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) { return iso; }
  }

  String _formatDateShort(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) { return iso; }
  }

  List<ApprovalRequest> get _filteredRequests {
    if (_searchQuery.isEmpty) return _requests;
    final q = _searchQuery.toLowerCase();
    return _requests.where((r) =>
        r.name.toLowerCase().contains(q) ||
        r.studentId.toLowerCase().contains(q) ||
        r.classInfo.toLowerCase().contains(q) ||
        r.requestedBy.toLowerCase().contains(q)).toList();
  }

  List<LateStudent> get _filteredLate {
    if (_searchQuery.isEmpty) return _lateStudents;
    final q = _searchQuery.toLowerCase();
    return _lateStudents.where((s) =>
        s.name.toLowerCase().contains(q) ||
        s.classInfo.toLowerCase().contains(q) ||
        s.teacherName.toLowerCase().contains(q)).toList();
  }

  Future<void> _handleApprove(ApprovalRequest req) async {
    final success = await StudentService.approveStudent(req.id);
    if (!mounted) return;
    if (success) {
      setState(() => _requests.removeWhere((r) => r.id == req.id));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${req.name} approved'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Failed to approve student'),
        backgroundColor: AppColors.danger,
      ));
    }
  }

  Future<void> _handleReject(ApprovalRequest req) async {
    final success = await StudentService.rejectStudent(req.id);
    if (!mounted) return;
    if (success) {
      setState(() => _requests.removeWhere((r) => r.id == req.id));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${req.name} rejected'),
        backgroundColor: AppColors.danger,
        duration: const Duration(seconds: 2),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Failed to reject student'),
        backgroundColor: AppColors.danger,
      ));
    }
  }

  Future<void> _approveAll() async {
    final ids = _filteredRequests.map((e) => e.id).toList();
    if (ids.isEmpty) return;
    final success = await StudentService.approveAllStudents(ids);
    if (!mounted) return;
    if (success) {
      setState(() => _requests.clear());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${ids.length} requests approved'),
        backgroundColor: AppColors.success,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Failed to approve all students'),
        backgroundColor: AppColors.danger,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredRequests;

    return BaseScaffold(
      title: 'Pending Approvals',
      role: 'admin',
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: Text(
              '${_requests.length} PENDING',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                  color: Colors.white, letterSpacing: 0.5),
            ),
          ),
        ),
      ],
      body: Container(
        color: AppColors.background,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Search ──────────────────────────────────────────────────────
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                    color: AppColors.background, borderRadius: BorderRadius.circular(10)),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search students, classes, or IDs',
                    hintStyle: TextStyle(color: AppColors.textLight, fontSize: 13),
                    prefixIcon: Icon(Icons.search, color: AppColors.textLight, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, size: 18, color: AppColors.textLight),
                            onPressed: () { _searchCtrl.clear(); setState(() => _searchQuery = ''); })
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),

            // ── Tabs: only 2 now ─────────────────────────────────────────────
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                indicator: BoxDecoration(
                    color: AppColors.primaryDark, borderRadius: BorderRadius.circular(20)),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                padding: EdgeInsets.zero,
                labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                tabs: [
                  // ✅ Tab 0: All Students (pending approvals)
                  _buildTab('All Students (${_requests.length})'),
                  // ✅ Tab 1: Late (real data, Attendance Exceptions removed)
                  _buildTab('Late'),
                ],
              ),
            ),

            // ── Tab views ────────────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // ── Tab 0: Pending approvals ─────────────────────────────
                  _loadingRequests
                      ? const Center(child: CircularProgressIndicator())
                      : Column(children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('QUEUE',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                                        color: AppColors.textSecondary, letterSpacing: 0.8)),
                                if (filtered.isNotEmpty)
                                  GestureDetector(
                                    onTap: _approveAll,
                                    child: Text('✓ Approve All',
                                        style: TextStyle(fontSize: 12,
                                            fontWeight: FontWeight.w600, color: AppColors.primaryDark)),
                                  ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: filtered.isEmpty
                                ? _buildEmptyState('All requests handled!', 'No pending approvals at this time')
                                : RefreshIndicator(
                                    onRefresh: _loadRequests,
                                    child: ListView.builder(
                                      padding: const EdgeInsets.only(bottom: 16),
                                      itemCount: filtered.length,
                                      itemBuilder: (context, index) {
                                        final req = filtered[index];
                                        return ApprovalCard(
                                          key: ValueKey(req.id),
                                          request: req,
                                          onApprove: () => _handleApprove(req),
                                          onReject: () => _handleReject(req),
                                        );
                                      },
                                    ),
                                  ),
                          ),
                        ]),

                  // ── Tab 1: Late students (real API) ──────────────────────
                  _loadingLate
                      ? const Center(child: CircularProgressIndicator())
                      : Column(children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('LATE STUDENTS',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                                        color: AppColors.textSecondary, letterSpacing: 0.8)),
                                GestureDetector(
                                  onTap: _loadLateStudents,
                                  child: Text('↻ Refresh',
                                      style: TextStyle(fontSize: 12,
                                          fontWeight: FontWeight.w600, color: AppColors.primaryDark)),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: _filteredLate.isEmpty
                                ? _buildEmptyState('No late students', 'All students arrived on time')
                                : RefreshIndicator(
                                    onRefresh: _loadLateStudents,
                                    child: ListView.builder(
                                      padding: const EdgeInsets.only(bottom: 16),
                                      itemCount: _filteredLate.length,
                                      itemBuilder: (_, i) => LateStudentCard(
                                          key: ValueKey(_filteredLate[i].id),
                                          student: _filteredLate[i]),
                                    ),
                                  ),
                          ),
                        ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Tab _buildTab(String label) => Tab(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          child: Text(label),
        ),
      );

  Widget _buildEmptyState(String title, String subtitle) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: AppColors.border),
            const SizedBox(height: 16),
            Text(title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            Text(subtitle, style: TextStyle(fontSize: 13, color: AppColors.textLight)),
          ],
        ),
      );
}