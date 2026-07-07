import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../core/services/auth_service.dart';
import '../core/services/session_service.dart';
import '../core/services/confirmation_service.dart';
import '../core/theme/app_colors.dart';
import '../widgets/base_scaffold.dart';

class AttendanceReportScreen extends StatefulWidget {
  final int? teacherId;
  const AttendanceReportScreen({super.key, this.teacherId});

  @override
  State<AttendanceReportScreen> createState() => _AttendanceReportScreenState();
}

class _AttendanceReportScreenState extends State<AttendanceReportScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _records = [];
  List<Map<String, dynamic>> _allSessions = [];
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _weeklyData = [];
  bool _loading = true;
  String? _error;
  String _statusFilter = 'All';
  String _timeFilter = 'Last 7 Days';
  Timer? _debounce;
  Timer? _refreshTimer;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  final TextEditingController _searchController = TextEditingController();

  static const Color _bg      = AppColors.background;
  static const Color _card    = AppColors.surface;
  static const Color _primary = AppColors.primary;
  static const Color _textDark= AppColors.textPrimary;
  static const Color _textMid = AppColors.textSecondary;
  static const Color _green   = AppColors.success;
  static const Color _red     = AppColors.danger;
  static const Color _orange  = AppColors.warning;

  int? get _resolvedTeacherId {
    if (widget.teacherId != null) return widget.teacherId;
    final raw = AuthService.currentUser?['id'];
    return raw is int ? raw : int.tryParse(raw?.toString() ?? '');
  }

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _loadAll();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _loadAll(silent: true),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _refreshTimer?.cancel();
    _searchController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadAll({bool silent = false}) async {
     if (!silent) setState(() { _loading = true; _error = null; });
    try {
      final token = await AuthService.getToken();
      final headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final results = await Future.wait([
        http.get(
          Uri.parse('${AuthService.baseUrl}/attendance/report')
              .replace(queryParameters: _buildParams()),
          headers: headers,
        ),
        http.get(
          Uri.parse('${AuthService.baseUrl}/report/dashboard'),
          headers: headers,
        ),
        http.get(
          Uri.parse('${AuthService.baseUrl}/sessions'),
          headers: headers,
        ),
      ]);

      if (results[0].statusCode == 200) {
        final body = jsonDecode(results[0].body);
        final List raw = body['data'] ?? [];
        final search = _searchController.text.trim().toLowerCase();
        final filtered = raw.where((r) {
          if (search.isEmpty) return true;
          return (r['student_name'] ?? '').toLowerCase().contains(search) ||
              (r['roll_no'] ?? '').toLowerCase().contains(search) ||
              (r['session_id']?.toString() ?? '').contains(search);
        }).toList();
        _records = List<Map<String, dynamic>>.from(filtered);
      }

      if (results[1].statusCode == 200) {
        final body = jsonDecode(results[1].body);
        _stats = body['stats'] ?? {};
        _weeklyData = List<Map<String, dynamic>>.from(body['weekly_data'] ?? []);
      }

      if (results[2].statusCode == 200) {
        final body = jsonDecode(results[2].body);
        _allSessions = List<Map<String, dynamic>>.from(body['data'] ?? []);
      }

      setState(() => _loading = false);
      _animController.forward(from: 0);
    } catch (e) {
          if (!silent) setState(() { _error = 'Connection error: $e'; _loading = false; });

    }
  }

  Map<String, String> _buildParams() {
    final p = <String, String>{};
    if (_statusFilter != 'All') p['status'] = _statusFilter;
    if (widget.teacherId != null) p['teacher_id'] = widget.teacherId.toString();
    return p;
  }

  void _onSearchChanged(String _) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _loadAll);
  }

  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'present':   return _green;
      case 'absent':    return _red;
      case 'late':      return _orange;
      case 'active':    return _primary;
      case 'completed': return const Color(0xFF00BCD4);
      default:          return _textMid;
    }
  }

  IconData _statusIcon(String s) {
    switch (s.toLowerCase()) {
      case 'present': return Icons.check_circle_rounded;
      case 'absent':  return Icons.cancel_rounded;
      case 'late':    return Icons.watch_later_rounded;
      default:        return Icons.help_outline_rounded;
    }
  }

  String _statusBadge(String s) {
    switch (s.toLowerCase()) {
      case 'present': return 'VERIFIED';
      case 'absent':  return 'FLAGGED';
      case 'late':    return 'SUSPICIOUS';
      default:        return s.toUpperCase();
    }
  }

  double get _weeklyAvg {
    if (_weeklyData.isEmpty) return 0;
    return _weeklyData
        .map((e) => (e['percentage'] as num).toDouble())
        .reduce((a, b) => a + b) / _weeklyData.length;
  }

  int get _presentCount => _records.where((r) => r['status'] == 'present').length;
  int get _absentCount  => _records.where((r) => r['status'] == 'absent').length;
  int get _lateCount    => _records.where((r) => r['status'] == 'late').length;

  // ════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Reports & Audit Logs',
      role: 'teacher',
      bottomNav: _buildBottomNav(),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _primary))
          : _error != null
              ? _buildError()
              : FadeTransition(
                  opacity: _fadeAnim,
                  child: RefreshIndicator(
                    onRefresh: _loadAll,
                    color: _primary,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                      children: [
                        _buildFilterChips(),
                        const SizedBox(height: 18),
                        _buildTrendCard(),
                        const SizedBox(height: 14),
                        _buildStatsRow(),
                        const SizedBox(height: 20),
                        _buildSessionListSection(),
                        const SizedBox(height: 20),
                        _buildSearchBar(),
                        const SizedBox(height: 10),
                        if (_records.isNotEmpty) _buildSummaryChips(),
                        if (_records.isNotEmpty) const SizedBox(height: 16),
                        _buildLogsHeader(),
                        const SizedBox(height: 12),
                        ..._buildLogCards(),
                      ],
                    ),
                  ),
                ),
    );
  }

  // ── Bottom nav (same 4 tabs as Teacher Dashboard, "Reports" active) ──
  Widget _buildBottomNav() {
    final items = const [
      _NavItem(icon: Icons.home_rounded,       label: 'Home'),
      _NavItem(icon: Icons.bar_chart_rounded,  label: 'Reports'),
      _NavItem(icon: Icons.how_to_reg_rounded, label: 'View Responses'),
      _NavItem(icon: Icons.person_rounded,     label: 'Profile'),
    ];
    const currentIndex = 1; // hum abhi Reports screen par hain

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isActive = index == currentIndex;
              return GestureDetector(
                onTap: () {
                  if (index == currentIndex) return; // already yahin par hain
                  if (index == 0) {
                    Get.offAllNamed('/teacher-dashboard');
                  } else if (index == 2) {
                    _showResponseDirectory();
                  } else if (index == 3) {
                    Get.toNamed('/teacher-profile');
                  }
                },
                child: SizedBox(
                  width: 72,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item.icon,
                          color: isActive ? AppColors.primary : AppColors.textSecondary),
                      Text(item.label,
                          style: TextStyle(
                              color: isActive ? AppColors.primary : AppColors.textSecondary,
                              fontSize: 11)),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Future<void> _showResponseDirectory() async {
    final teacherId = _resolvedTeacherId;
    if (teacherId == null) return;

    final activeResult = await SessionService.getActiveSession(teacherId);
    if (!(activeResult['success'] == true &&
        activeResult['active'] == true &&
        activeResult['data'] != null)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No active session. Start a session first.'),
          backgroundColor: _red,
        ),
      );
      return;
    }

    final rawId = activeResult['data']['id'];
    final sessionId = rawId is int ? rawId : int.tryParse(rawId.toString());
    if (sessionId == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final result = await ConfirmationService.getDirectory(sessionId);
    if (!mounted) return;
    Navigator.pop(context);

    if (result['success'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Failed to load directory')),
      );
      return;
    }

    final List<dynamic> students = result['data'] ?? [];

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.how_to_reg_rounded, color: Colors.white),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text('Confirmation Directory',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 18),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _directoryChip('✅ YES', result['yes_count'] ?? 0, AppColors.success),
                    _directoryChip('❌ NO', result['no_count'] ?? 0, AppColors.danger),
                    _directoryChip('⏳ Pending', result['pending_count'] ?? 0, AppColors.warning),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      result['verdict'] ?? 'Awaiting responses',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: students.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('No students found',
                            style: TextStyle(color: AppColors.textSecondary)),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: students.length,
                        separatorBuilder: (_, __) => const Divider(height: 1, indent: 16),
                        itemBuilder: (_, i) {
                          final s = students[i];
                          final resp = s['response'] as String;
                          final respColor = resp == 'yes'
                              ? AppColors.success
                              : resp == 'no'
                                  ? AppColors.danger
                                  : AppColors.warning;
                          final respIcon = resp == 'yes'
                              ? Icons.check_circle_rounded
                              : resp == 'no'
                                  ? Icons.cancel_rounded
                                  : Icons.hourglass_empty_rounded;

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: respColor.withOpacity(0.12),
                              child: Text(
                                (s['student_name'] as String).substring(0, 1).toUpperCase(),
                                style: TextStyle(color: respColor, fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(s['student_name'] ?? '-',
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            subtitle: Text('Roll: ${s['roll_no'] ?? '-'}  •  ${s['responded_at']}',
                                style: const TextStyle(fontSize: 11)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(respIcon, color: respColor, size: 16),
                                const SizedBox(width: 4),
                                Text(resp.toUpperCase(),
                                    style: TextStyle(
                                        color: respColor, fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showResponseDirectory();
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('Refresh'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _directoryChip(String label, int count, Color color) {
    return Column(
      children: [
        Text('$count', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 22)),
        Text(label, style: TextStyle(color: color, fontSize: 11)),
      ],
    );
  }

  // ── Filter chips ──────────────────────────────────
  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _chip(_statusFilter == 'All' ? 'All Status' : _statusFilter, onTap: _showStatusSheet),
          const SizedBox(width: 8),
          _chip('All Faculty', onTap: () {}),
          const SizedBox(width: 8),
          _chip(_timeFilter, onTap: () {
            final opts = ['Today', 'Last 7 Days', 'This Month'];
            setState(() { _timeFilter = opts[(opts.indexOf(_timeFilter) + 1) % opts.length]; });
          }),
        ],
      ),
    );
  }

  Widget _chip(String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(color: _primary, borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: Colors.white),
          ],
        ),
      ),
    );
  }

  void _showStatusSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(width: 36, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 8),
          for (final s in ['All', 'present', 'absent', 'late'])
            ListTile(
              leading: Icon(s == 'All' ? Icons.list_rounded : _statusIcon(s),
                  color: s == 'All' ? _textDark : _statusColor(s)),
              title: Text(s == 'All' ? 'All Status' : s.toUpperCase(),
                  style: const TextStyle(color: _textDark)),
              trailing: _statusFilter == s ? const Icon(Icons.check_rounded, color: _primary) : null,
              onTap: () { setState(() => _statusFilter = s); Navigator.pop(context); _loadAll(); },
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ── Trend card ────────────────────────────────────
  Widget _buildTrendCard() {
    final maxVal = _weeklyData.isEmpty
        ? 1.0
        : _weeklyData.map((e) => (e['percentage'] as num).toDouble())
            .reduce((a, b) => a > b ? a : b).clamp(1.0, 100.0);
    final today = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'][DateTime.now().weekday - 1];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card, borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Attendance Trends',
                  style: TextStyle(color: _textDark, fontWeight: FontWeight.bold, fontSize: 14)),
              Text('Details', style: TextStyle(color: _primary, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 6),
          const Text('WEEKLY ATTENDANCE %',
              style: TextStyle(color: _textMid, fontSize: 10, letterSpacing: 1.1)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${_weeklyAvg.toStringAsFixed(1)}%',
                  style: const TextStyle(color: _textDark, fontSize: 30, fontWeight: FontWeight.bold, height: 1.1)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(color: _green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Row(children: [
                  const Icon(Icons.arrow_upward_rounded, size: 11, color: _green),
                  Text('$_presentCount present', style: const TextStyle(color: _green, fontSize: 11)),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 80,
            child: _weeklyData.isEmpty
                ? const Center(child: Text('No weekly data', style: TextStyle(color: _textMid)))
                : _BarLineChart(data: _weeklyData, maxVal: maxVal, today: today, primaryColor: _primary),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _weeklyData.map((d) => Text(d['day'],
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: d['day'] == today ? FontWeight.bold : FontWeight.normal,
                    color: d['day'] == today ? _primary : _textMid))).toList(),
          ),
        ],
      ),
    );
  }

  // ── Stats row ─────────────────────────────────────
  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _statCard('Total Sessions', '${_stats['total_sessions'] ?? 0}',
            Icons.play_circle_fill_rounded, _primary,
            sub: '+${_stats['active_today'] ?? 0} active today', subUp: true)),
        const SizedBox(width: 12),
        Expanded(child: _statCard('Flagged Logs', '${_stats['flagged'] ?? 0}',
            Icons.flag_rounded, _red, sub: '▼ 2% improvement', subUp: false)),
      ],
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color,
      {String? sub, bool subUp = true}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 34, height: 34,
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(9)),
              child: Icon(icon, color: color, size: 18)),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(color: _textDark, fontSize: 26, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(color: _textMid, fontSize: 11)),
          if (sub != null) ...[
            const SizedBox(height: 6),
            Text(sub, style: TextStyle(color: subUp ? _green : _red, fontSize: 11, fontWeight: FontWeight.w500)),
          ],
        ],
      ),
    );
  }

  // ── Session List ──────────────────────────────────
  Widget _buildSessionListSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('All Sessions',
                style: TextStyle(color: _textDark, fontWeight: FontWeight.bold, fontSize: 15)),
            GestureDetector(
              onTap: _loadAll,
              child: const Text('Refresh',
                  style: TextStyle(color: _primary, fontSize: 13, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _allSessions.isEmpty
            ? Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(16)),
                child: const Column(
                  children: [
                    Icon(Icons.inbox_rounded, size: 40, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('No sessions created yet.', style: TextStyle(color: _textMid)),
                  ],
                ),
              )
            : Column(children: _allSessions.map((s) => _buildSessionCard(s)).toList()),
      ],
    );
  }

  Widget _buildSessionCard(Map<String, dynamic> s) {
    final status = s['status'] as String? ?? '';
    final isActive = status == 'active';
    final statusColor = isActive ? _green : _textMid;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: statusColor, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: Icon(
                          isActive ? Icons.play_circle_fill_rounded : Icons.stop_circle_rounded,
                          color: statusColor, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Session #${s['id']}',
                            style: const TextStyle(color: _textDark, fontWeight: FontWeight.bold, fontSize: 14)),
                        Text(s['date'] ?? '-', style: const TextStyle(color: _textMid, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text(status.toUpperCase(),
                      style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                _sessionInfoChip(Icons.person_rounded, s['teacher_name'] ?? '-'),
                const SizedBox(width: 12),
                _sessionInfoChip(Icons.access_time_rounded,
                    '${s['start_time'] ?? '-'}${s['end_time'] != null ? ' - ${s['end_time']}' : ''}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sessionInfoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: _textMid),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: _textMid, fontSize: 12)),
      ],
    );
  }

  // ── Search ────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: _card, borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        style: const TextStyle(color: _textDark),
        decoration: const InputDecoration(
          hintText: 'Search student, roll no, session…',
          hintStyle: TextStyle(color: _textMid, fontSize: 13),
          prefixIcon: Icon(Icons.search_rounded, color: _textMid, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  // ── Summary chips ─────────────────────────────────
  Widget _buildSummaryChips() {
    return Row(
      children: [
        _summaryBadge('Present', _presentCount, _green),
        const SizedBox(width: 8),
        _summaryBadge('Absent', _absentCount, _red),
        const SizedBox(width: 8),
        _summaryBadge('Late', _lateCount, _orange),
        const Spacer(),
        Text('${_records.length} total', style: const TextStyle(color: _textMid, fontSize: 11)),
      ],
    );
  }

  Widget _summaryBadge(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text('$label: $count',
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  // ── Logs header ───────────────────────────────────
  Widget _buildLogsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Recent Audit Logs',
            style: TextStyle(color: _textDark, fontWeight: FontWeight.bold, fontSize: 15)),
        GestureDetector(
          onTap: _loadAll,
          child: const Text('See All',
              style: TextStyle(color: _primary, fontSize: 13, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }

  // ── Log cards ─────────────────────────────────────
  List<Widget> _buildLogCards() {
    if (_records.isEmpty) {
      return [
        const SizedBox(height: 60),
        Center(
          child: Column(children: [
            Icon(Icons.inbox_rounded, size: 52, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            const Text('No attendance records found.',
                style: TextStyle(color: _textMid, fontSize: 14)),
          ]),
        ),
      ];
    }
    return _records.map((r) => _buildLogCard(r)).toList();
  }

  Widget _buildLogCard(Map<String, dynamic> r) {
    final status = r['status'] as String? ?? '';
    final color = _statusColor(status);
    final badge = _statusBadge(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _card, borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
                  child: Center(
                    child: Text(
                      (r['student_name'] as String? ?? 'U').substring(0, 1).toUpperCase(),
                      style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r['student_name'] ?? '-',
                          style: const TextStyle(color: _textDark, fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('Roll: ${r['roll_no'] ?? '-'}  •  ${r['class'] ?? '-'}',
                          style: const TextStyle(color: _textMid, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(badge,
                      style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.3)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.access_time_rounded, size: 12, color: _textMid),
                const SizedBox(width: 4),
                Text(r['marked_at'] ?? '-', style: const TextStyle(color: _textMid, fontSize: 11)),
                const SizedBox(width: 12),
                Icon(_statusIcon(status), size: 12, color: color),
                const SizedBox(width: 3),
                Text(_statusBadge(status),
                    style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 52, color: _red),
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: _textMid)),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: _loadAll,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

// ── Chart ──────────────────────────────────────────
class _BarLineChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final double maxVal;
  final String today;
  final Color primaryColor;

  const _BarLineChart({required this.data, required this.maxVal,
      required this.today, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ChartPainter(data: data, maxVal: maxVal, today: today, color: primaryColor),
      size: Size.infinite,
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final double maxVal;
  final String today;
  final Color color;
  _ChartPainter({required this.data, required this.maxVal, required this.today, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final segW = size.width / data.length;
    final points = <Offset>[];

    for (int i = 0; i < data.length; i++) {
      final pct = (data[i]['percentage'] as num).toDouble();
      final x = i * segW + segW / 2;
      final y = size.height - (pct / maxVal * (size.height - 8)).clamp(4.0, size.height - 8);
      points.add(Offset(x, y));

      final isToday = data[i]['day'] == today;
      final barPaint = Paint()
        ..color = isToday ? color.withOpacity(0.25) : color.withOpacity(0.08)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - segW * 0.3, y, segW * 0.6, size.height - y),
          const Radius.circular(5),
        ),
        barPaint,
      );
    }

    if (points.length > 1) {
      final linePaint = Paint()
        ..color = color
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        final p = points[i - 1];
        final c = points[i];
        path.cubicTo((p.dx + c.dx) / 2, p.dy, (p.dx + c.dx) / 2, c.dy, c.dx, c.dy);
      }
      canvas.drawPath(path, linePaint);

      for (final p in points) {
        canvas.drawCircle(p, 3.5, Paint()..color = Colors.white..style = PaintingStyle.fill);
        canvas.drawCircle(p, 3.5, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2);
      }
    }
  }

  @override
  bool shouldRepaint(_ChartPainter o) => o.data != data;
}