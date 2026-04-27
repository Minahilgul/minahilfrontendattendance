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
      home: const ApprovalsScreen(),
    );
  }
}

// ─────────────────────────────────────────────
// DATA MODEL
// ─────────────────────────────────────────────

class ApprovalRequest {
  final String initials;
  final Color avatarColor;
  final String name;
  final String studentId;
  final String classInfo;
  final String requestedBy;
  final String timeAgo;

  const ApprovalRequest({
    required this.initials,
    required this.avatarColor,
    required this.name,
    required this.studentId,
    required this.classInfo,
    required this.requestedBy,
    required this.timeAgo,
  });
}

final List<ApprovalRequest> _allRequests = [
  ApprovalRequest(
    initials: 'AS',
    avatarColor: const Color(0xFF1565C0),
    name: 'Arjun Sharma',
    studentId: '#18342',
    classInfo: 'Class 12 B',
    requestedBy: 'Mr. Vikram Singh',
    timeAgo: '3M AGO',
  ),
  ApprovalRequest(
    initials: 'MK',
    avatarColor: const Color(0xFF00695C),
    name: 'Meera Kapur',
    studentId: '#19101',
    classInfo: 'CS Dept',
    requestedBy: 'Dr. Anjali Rao',
    timeAgo: '7M AGO',
  ),
  ApprovalRequest(
    initials: 'KL',
    avatarColor: const Color(0xFF6A1B9A),
    name: 'Karan Luthra',
    studentId: '#17162',
    classInfo: 'B.Arch III',
    requestedBy: 'Prof. Samuel',
    timeAgo: '1H AGO',
  ),
  ApprovalRequest(
    initials: 'PR',
    avatarColor: const Color(0xFFAD1457),
    name: 'Priya Reddy',
    studentId: '#20345',
    classInfo: 'Class 11 A',
    requestedBy: 'Ms. Nisha Patel',
    timeAgo: '2H AGO',
  ),
  ApprovalRequest(
    initials: 'RK',
    avatarColor: const Color(0xFFE65100),
    name: 'Rahul Kumar',
    studentId: '#16789',
    classInfo: 'MBA II',
    requestedBy: 'Dr. Ramesh Iyer',
    timeAgo: '3H AGO',
  ),
  ApprovalRequest(
    initials: 'SM',
    avatarColor: const Color(0xFF01579B),
    name: 'Sneha Mishra',
    studentId: '#22001',
    classInfo: 'Class 9 C',
    requestedBy: 'Mr. Ajay Verma',
    timeAgo: '4H AGO',
  ),
  ApprovalRequest(
    initials: 'VT',
    avatarColor: const Color(0xFF33691E),
    name: 'Vikram Tiwari',
    studentId: '#21456',
    classInfo: 'BCA I',
    requestedBy: 'Ms. Pooja Gupta',
    timeAgo: '5H AGO',
  ),
  ApprovalRequest(
    initials: 'DG',
    avatarColor: const Color(0xFF4A148C),
    name: 'Divya Gupta',
    studentId: '#23678',
    classInfo: 'Class 10 B',
    requestedBy: 'Mr. Suresh Rao',
    timeAgo: '6H AGO',
  ),
  ApprovalRequest(
    initials: 'NK',
    avatarColor: const Color(0xFF880E4F),
    name: 'Nikhil Khanna',
    studentId: '#24901',
    classInfo: 'M.Tech I',
    requestedBy: 'Dr. Priya Nair',
    timeAgo: '7H AGO',
  ),
  ApprovalRequest(
    initials: 'AS',
    avatarColor: const Color(0xFF1B5E20),
    name: 'Anita Singh',
    studentId: '#25112',
    classInfo: 'Class 8 A',
    requestedBy: 'Ms. Rekha Sharma',
    timeAgo: '8H AGO',
  ),
];

// ─────────────────────────────────────────────
// APPROVAL CARD WIDGET
// ─────────────────────────────────────────────

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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EAED), width: 0.8),
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
          // ── Top row: avatar + info + time ──
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
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.badge_outlined,
                              size: 13, color: Color(0xFF9E9E9E)),
                          const SizedBox(width: 4),
                          Text(
                            '${request.studentId} • ${request.classInfo}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF757575),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.person_outline,
                              size: 13, color: Color(0xFF9E9E9E)),
                          const SizedBox(width: 4),
                          Text(
                            'Requested by: ${request.requestedBy}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9E9E9E),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  request.timeAgo,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFFBDBDBD),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),

          // ── Divider ──
          const Divider(height: 1, color: Color(0xFFF0F0F0)),

          // ── Action buttons ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Row(
              children: [
                // Reject button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.close, size: 15),
                    label: const Text(
                      'Reject',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFE53935),
                      side: const BorderSide(color: Color(0xFFE53935), width: 1.2),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Approve button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.check_circle_outline, size: 15),
                    label: const Text(
                      'Approve',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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

// ─────────────────────────────────────────────
// APPROVALS SCREEN
// ─────────────────────────────────────────────

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
  int _selectedNavIndex = 1;
  late List<ApprovalRequest> _requests;

  final List<String> _navLabels = [
    'Dashboard',
    'Approvals',
    'Directory',
    'Settings',
  ];
  final List<IconData> _navIcons = [
    Icons.dashboard_outlined,
    Icons.check_circle_outline,
    Icons.people_outline,
    Icons.settings_outlined,
  ];
  final List<IconData> _navIconsFilled = [
    Icons.dashboard,
    Icons.check_circle,
    Icons.people,
    Icons.settings,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _requests = List.from(_allRequests);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<ApprovalRequest> get _filteredRequests {
    if (_searchQuery.isEmpty) return _requests;
    final q = _searchQuery.toLowerCase();
    return _requests.where((r) {
      return r.name.toLowerCase().contains(q) ||
          r.studentId.toLowerCase().contains(q) ||
          r.classInfo.toLowerCase().contains(q) ||
          r.requestedBy.toLowerCase().contains(q);
    }).toList();
  }

  void _handleApprove(ApprovalRequest req) {
    setState(() => _requests.remove(req));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${req.name} approved successfully'),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleReject(ApprovalRequest req) {
    setState(() => _requests.remove(req));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${req.name}\'s request rejected'),
        backgroundColor: const Color(0xFFC62828),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _approveAll() {
    final count = _filteredRequests.length;
    setState(() => _requests.clear());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$count requests approved'),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredRequests;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HEADER ──
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back + Title + More
                  Row(
                    children: [
                      const Icon(Icons.arrow_back,
                          size: 22, color: Color(0xFF1A1A2E)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Approvals',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                            Text(
                              '${_requests.length} REQUESTS PENDING',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1565C0),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.more_vert,
                          color: Color(0xFF9E9E9E), size: 22),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── Search bar ──
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F2F5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Search students, classes, or IDs',
                        hintStyle: const TextStyle(
                            color: Color(0xFFBDBDBD), fontSize: 13),
                        prefixIcon: const Icon(Icons.search,
                            color: Color(0xFFBDBDBD), size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear,
                                    size: 18, color: Color(0xFFBDBDBD)),
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
                  const SizedBox(height: 12),

                  // ── Tab bar ──
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    labelColor: Colors.white,
                    unselectedLabelColor: const Color(0xFF757575),
                    labelStyle: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                    unselectedLabelStyle: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500),
                    indicator: BoxDecoration(
                      color: const Color(0xFF1565C0),
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
                  const SizedBox(height: 4),
                ],
              ),
            ),

            // ── LIST ──
            Expanded(
              child: Column(
                children: [
                  // Queue header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'QUEUE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF9E9E9E),
                            letterSpacing: 0.8,
                          ),
                        ),
                        if (filtered.isNotEmpty)
                          GestureDetector(
                            onTap: _approveAll,
                            child: const Text(
                              '✓ Approve All',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1565C0),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Cards list
                  Expanded(
                    child: filtered.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 16),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final req = filtered[index];
                              return ApprovalCard(
                                key: ValueKey(req.studentId + req.name),
                                request: req,
                                onApprove: () => _handleApprove(req),
                                onReject: () => _handleReject(req),
                              );
                            },
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
              offset: const Offset(0, -2),
            ),
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
                  child: SizedBox(
                    width: 72,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Badge for approvals
                        i == 1 && _requests.isNotEmpty
                            ? Badge(
                                backgroundColor: const Color(0xFFE53935),
                                label: Text(
                                  '${_requests.length}',
                                  style: const TextStyle(fontSize: 9),
                                ),
                                child: Icon(
                                  selected
                                      ? _navIconsFilled[i]
                                      : _navIcons[i],
                                  size: 22,
                                  color: selected
                                      ? const Color(0xFF1565C0)
                                      : const Color(0xFF9E9E9E),
                                ),
                              )
                            : Icon(
                                selected
                                    ? _navIconsFilled[i]
                                    : _navIcons[i],
                                size: 22,
                                color: selected
                                    ? const Color(0xFF1565C0)
                                    : const Color(0xFF9E9E9E),
                              ),
                        const SizedBox(height: 3),
                        Text(
                          _navLabels[i],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? const Color(0xFF1565C0)
                                : const Color(0xFF9E9E9E),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Tab _buildTab(String label) {
    return Tab(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        child: Text(label),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline,
              size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? 'No results found'
                : 'All requests handled!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try a different search term'
                : 'No pending approvals at this time',
            style: TextStyle(fontSize: 13, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}