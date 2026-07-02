import 'package:flutter/material.dart';
import '../../widgets/base_scaffold.dart';
import '../../core/services/student_service.dart';
import '../../core/theme/app_colors.dart';


// DATA MODEL


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


// APPROVAL CARD

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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
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
                  child: Text(
                    request.initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Icons.badge_outlined,
                              size: 13, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            '${request.studentId} • ${request.classInfo}',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Icons.person_outline,
                              size: 13, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            'Requested by: ${request.requestedBy}',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  request.timeAgo,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
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
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: BorderSide(
                          color: AppColors.danger, width: 1.2),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.check_circle_outline, size: 15),
                    label: const Text('Approve',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
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


// APPROVALS SCREEN


class ApprovalsScreen extends StatefulWidget {
  const ApprovalsScreen({super.key});

  @override
  State<ApprovalsScreen> createState() => _ApprovalsScreenState();
}

class _ApprovalsScreenState extends State<ApprovalsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  List<ApprovalRequest> _requests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadRequests() async {
    setState(() => isLoading = true);
    try {
      //  fetchPendingStudents now returns List<Map<String,dynamic>>
      final data = await StudentService.fetchPendingStudents();

      final list = data.map<ApprovalRequest>((s) {
        //  normalise field names — handle both 'name' and 'username'
        final name = (s['name'] ?? s['username'] ?? '') as String;
        final initials = name
            .split(' ')
            .where((e) => e.isNotEmpty)
            .map((e) => e[0])
            .take(2)
            .join()
            .toUpperCase();

        //  handle 'class' or 'class_name'
        final classInfo =
            (s['class'] ?? s['class_name'] ?? 'N/A') as String;

        //  teacher name can come as teacher_name or via nested teacher object
        final requestedBy = (s['teacher_name'] ??
                s['teacher']?['username'] ??
                'Teacher') as String;

        //  format created_at nicely if present
        final rawDate = s['created_at'] as String?;
        final timeAgo = rawDate != null ? _formatDate(rawDate) : 'Just now';

        final idVal = s['id'];
        return ApprovalRequest(
          id: idVal.toString(),
          initials: initials.isEmpty ? 'ST' : initials,
          avatarColor:
              Colors.primaries[idVal.hashCode % Colors.primaries.length],
          name: name.isEmpty ? 'Unknown Student' : name,
          studentId: 'ID#${idVal.toString()}',
          classInfo: classInfo,
          requestedBy: requestedBy,
          timeAgo: timeAgo,
        );
      }).toList();

      setState(() {
        _requests = list;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading requests: $e')),
        );
      }
    }
  }

  /// Simple relative-date formatter
  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return iso;
    }
  }

  List<ApprovalRequest> get _filteredRequests {
    if (_searchQuery.isEmpty) return _requests;
    final q = _searchQuery.toLowerCase();
    return _requests
        .where((r) =>
            r.name.toLowerCase().contains(q) ||
            r.studentId.toLowerCase().contains(q) ||
            r.classInfo.toLowerCase().contains(q) ||
            r.requestedBy.toLowerCase().contains(q))
        .toList();
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
      //  NO floatingActionButton here
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: Text(
              '${_requests.length} PENDING',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
      body: Container(
        color: AppColors.background,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Search ──
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search students, classes, or IDs',
                    hintStyle: TextStyle(
                        color: AppColors.textLight, fontSize: 13),
                    prefixIcon: Icon(Icons.search,
                        color: AppColors.textLight, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear,
                                size: 18, color: AppColors.textLight),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            // ── Tabs ──
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600),
                unselectedLabelStyle: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500),
                indicator: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(20),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                padding: EdgeInsets.zero,
                labelPadding:
                    const EdgeInsets.symmetric(horizontal: 4),
                tabs: [
                  _buildTab('All Students (${_requests.length})'),
                  _buildTab('Attendance Exceptions'),
                  _buildTab('Late'),
                ],
              ),
            ),
            // ── List ──
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(16, 14, 16, 6),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'QUEUE',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              if (filtered.isNotEmpty)
                                GestureDetector(
                                  onTap: _approveAll,
                                  child: Text(
                                    '✓ Approve All',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: filtered.isEmpty
                              ? _buildEmptyState()
                              : RefreshIndicator(
                                  onRefresh: _loadRequests,
                                  child: ListView.builder(
                                    padding: const EdgeInsets.only(
                                        bottom: 16),
                                    itemCount: filtered.length,
                                    itemBuilder: (context, index) {
                                      final req = filtered[index];
                                      return ApprovalCard(
                                        key: ValueKey(req.id),
                                        request: req,
                                        onApprove: () =>
                                            _handleApprove(req),
                                        onReject: () =>
                                            _handleReject(req),
                                      );
                                    },
                                  ),
                                ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
      //  floatingActionButton intentionally omitted
    );
  }

  Tab _buildTab(String label) {
    return Tab(
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        child: Text(label),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 64, color: AppColors.border),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? 'No results found'
                : 'All requests handled!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try a different search term'
                : 'No pending approvals at this time',
            style: TextStyle(fontSize: 13, color: AppColors.textLight),
          ),
        ],
      ),
    );
  }
}