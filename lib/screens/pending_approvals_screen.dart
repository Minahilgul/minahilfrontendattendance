import 'package:flutter/material.dart';
import '../widgets/base_scaffold.dart';
import '../core/services/student_service.dart';

// ─────────────────────────────────────────────
// DATA MODEL
// ─────────────────────────────────────────────

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

// ─────────────────────────────────────────────
// APPROVAL CARD WIDGET - Same as before
// ─────────────────────────────────────────────

class ApprovalCard extends StatelessWidget {
  final ApprovalRequest request;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const ApprovalCard({super.key, required this.request, required this.onApprove, required this.onReject});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE8EAED), width: 0.8), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(radius: 22, backgroundColor: request.avatarColor, child: Text(request.initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14))),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(request.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
                      const SizedBox(height: 3),
                      Row(children: [const Icon(Icons.badge_outlined, size: 13, color: Color(0xFF9E9E9E)), const SizedBox(width: 4), Text('${request.studentId} • ${request.classInfo}', style: const TextStyle(fontSize: 12, color: Color(0xFF757575)))]),
                      const SizedBox(height: 3),
                      Row(children: [const Icon(Icons.person_outline, size: 13, color: Color(0xFF9E9E9E)), const SizedBox(width: 4), Text('Requested by: ${request.requestedBy}', style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)))]),
                    ],
                  ),
                ),
                Text(request.timeAgo, style: const TextStyle(fontSize: 10, color: Color(0xFFBDBD), fontWeight: FontWeight.w500, letterSpacing: 0.3)),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.close, size: 15),
                    label: const Text('Reject', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFE53935), side: const BorderSide(color: Color(0xFFE53935), width: 1.2), padding: const EdgeInsets.symmetric(vertical: 11), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.check_circle_outline, size: 15),
                    label: const Text('Approve', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1565C0), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 11), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
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

// ─────────────────────────────────────────────
// APPROVALS SCREEN - API Connected
// ─────────────────────────────────────────────

class ApprovalsScreen extends StatefulWidget {
  const ApprovalsScreen({super.key});
  @override
  State<ApprovalsScreen> createState() => _ApprovalsScreenState();
}

class _ApprovalsScreenState extends State<ApprovalsScreen> with SingleTickerProviderStateMixin {
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
      final data = await StudentService.fetchPendingStudents();
      List<ApprovalRequest> list = data.map<ApprovalRequest>((s) {
        String name = s['name'] ?? '';
        String initials = name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();
        return ApprovalRequest(
          id: s['id'].toString(),
          initials: initials.isEmpty ? 'ST' : initials,
          avatarColor: Colors.primaries[s['id'].hashCode % Colors.primaries.length],
          name: name,
          studentId: '#${s['id']}',
          classInfo: s['class'] ?? '',
          requestedBy: s['teacher_name'] ?? 'Teacher',
          timeAgo: s['created_at'] ?? 'Just Now',
        );
      }).toList();
      setState(() {
        _requests = list;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  List<ApprovalRequest> get _filteredRequests {
    if (_searchQuery.isEmpty) return _requests;
    final q = _searchQuery.toLowerCase();
    return _requests.where((r) => r.name.toLowerCase().contains(q) || r.studentId.toLowerCase().contains(q) || r.classInfo.toLowerCase().contains(q) || r.requestedBy.toLowerCase().contains(q)).toList();
  }

  Future<void> _handleApprove(ApprovalRequest req) async {
    final success = await StudentService.approveStudent(req.id);
    if (success) {
      setState(() => _requests.remove(req));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${req.name} approved'), backgroundColor: const Color(0xFF2E7D32), duration: const Duration(seconds: 2)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to approve student'), backgroundColor: Colors.red));
    }
  }

  Future<void> _handleReject(ApprovalRequest req) async {
    final success = await StudentService.rejectStudent(req.id);
    if (success) {
      setState(() => _requests.remove(req));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${req.name} rejected'), backgroundColor: const Color(0xFFC62828), duration: const Duration(seconds: 2)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to reject student'), backgroundColor: Colors.red));
    }
  }

  Future<void> _approveAll() async {
    final ids = _filteredRequests.map((e) => e.id).toList();
    final success = await StudentService.approveAllStudents(ids);
    if (success) {
      setState(() => _requests.clear());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${ids.length} requests approved'), backgroundColor: const Color(0xFF2E7D32)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to approve all students'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredRequests;

    return BaseScaffold(
      title: 'Approvals',
      role: 'admin',
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: Text(
              '${_requests.length} PENDING',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: 0.5),
            ),
          ),
        ),
      ],
      body: Container(
        color: const Color(0xFFF5F7FA),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Container(
                height: 44,
                decoration: BoxDecoration(color: const Color(0xFFF0F2F5), borderRadius: BorderRadius.circular(10)),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search students, classes, or IDs',
                    hintStyle: const TextStyle(color: Color(0xFFBDBD), fontSize: 13),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFFBDBD), size: 20),
                    suffixIcon: _searchQuery.isNotEmpty? IconButton(icon: const Icon(Icons.clear, size: 18, color: Color(0xFFBDBD)), onPressed: () {_searchCtrl.clear(); setState(() => _searchQuery = '');}) : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: Colors.white,
                unselectedLabelColor: const Color(0xFF757575),
                labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                indicator: BoxDecoration(color: const Color(0xFF1565C0), borderRadius: BorderRadius.circular(20)),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                padding: EdgeInsets.zero,
                labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                tabs: [
                  _buildTab('All Students (${_requests.length})'),
                  _buildTab('Attendance Exceptions'),
                  _buildTab('Late'),
                ],
              ),
            ),
            Expanded(
              child: isLoading
               ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          const Text('QUEUE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF9E9E9E), letterSpacing: 0.8)),
                          if (filtered.isNotEmpty)
                            GestureDetector(
                              onTap: _approveAll,
                              child: const Text('✓ Approve All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1565C0))),
                            ),
                        ]),
                      ),
                      Expanded(
                        child: filtered.isEmpty
                          ? _buildEmptyState()
                            : RefreshIndicator(
                                onRefresh: _loadRequests,
                                child: ListView.builder(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  itemCount: filtered.length,
                                  itemBuilder: (context, index) {
                                    final req = filtered[index];
                                    return ApprovalCard(key: ValueKey(req.id), request: req, onApprove: () => _handleApprove(req), onReject: () => _handleReject(req));
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
    );
  }

  Tab _buildTab(String label) {
    return Tab(child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7), child: Text(label)));
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(_searchQuery.isNotEmpty? 'No results found' : 'All requests handled!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[500])),
          const SizedBox(height: 6),
          Text(_searchQuery.isNotEmpty? 'Try a different search term' : 'No pending approvals at this time', style: TextStyle(fontSize: 13, color: Colors.grey[400])),
        ],
      ),
    );
  }
}