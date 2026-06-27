import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/services/auth_service.dart';

class SessionReportScreen extends StatefulWidget {
  const SessionReportScreen({super.key});

  @override
  State<SessionReportScreen> createState() => SessionReportScreenState();
}

class SessionReportScreenState extends State<SessionReportScreen> {
  Map<String, dynamic>? _data;
  List<Map<String, dynamic>> _sessions = [];
  bool _loading = true;
  String? _error;

  static const Color _green    = Color(0xFF0F9D58);
  static const Color _red      = Color(0xFFE53935);
  static const Color _primary  = Color(0xFF1565C0);
  static const Color _textMid  = Color(0xFF6B7280);
  static const Color _textDark = Color(0xFF212121);
  static const Color _card     = Colors.white;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> refresh() => _loadAll();

  Future<void> _loadAll() async {
    setState(() { _loading = true; _error = null; });
    try {
      final token = await AuthService.getToken();
      final headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final results = await Future.wait([
        http.get(Uri.parse('${AuthService.baseUrl}/report/dashboard'), headers: headers),
        http.get(Uri.parse('${AuthService.baseUrl}/sessions'), headers: headers),
      ]);

      if (results[0].statusCode == 200) {
        _data = jsonDecode(results[0].body);
      }
      if (results[1].statusCode == 200) {
        final body = jsonDecode(results[1].body);
        _sessions = List<Map<String, dynamic>>.from(body['data'] ?? []);
      }
      
      

      setState(() => _loading = false);
    } catch (e) {
      setState(() { _error = 'Connection error: $e'; _loading = false; });
    }
  }

  // ── Toggle session active/inactive ────────────────
  Future<void> _toggleSession(int sessionId, bool newVal) async {
    // 1. Instant UI update
    setState(() {
      final idx = _sessions.indexWhere((s) => (s['id'] as num?)?.toInt() == sessionId);
      if (idx != -1) {
        _sessions[idx] = {
          ..._sessions[idx],
          'status': newVal ? 'active' : 'inactive',
        };
      }
    });

    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse('${AuthService.baseUrl}/sessions/$sessionId/toggle-status'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Sync actual status from server response
        final body = jsonDecode(response.body);
        final serverStatus = body['status'] as String? ?? (newVal ? 'active' : 'inactive');
        setState(() {
          final idx = _sessions.indexWhere((s) => (s['id'] as num?)?.toInt() == sessionId);
          if (idx != -1) {
            _sessions[idx] = { ..._sessions[idx], 'status': serverStatus };
          }
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(newVal ? 'Session Active ✓' : 'Session Inactive'),
            backgroundColor: newVal ? _green : Colors.grey,
            duration: const Duration(seconds: 1),
          ));
        }
      } else {
        // Revert on failure
        setState(() {
          final idx = _sessions.indexWhere((s) => (s['id'] as num?)?.toInt() == sessionId);
          if (idx != -1) {
            _sessions[idx] = {
              ..._sessions[idx],
              'status': newVal ? 'inactive' : 'active',
            };
          }
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Update failed — please try again'),
            backgroundColor: Colors.red,
          ));
        }
      }
    } catch (e) {
      // Revert on network error
      setState(() {
        final idx = _sessions.indexWhere((s) => (s['id'] as num?)?.toInt() == sessionId);
        if (idx != -1) {
          _sessions[idx] = {
            ..._sessions[idx],
            'status': newVal ? 'inactive' : 'active',
          };
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: _card,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Reports & Audit Logs',
            style: TextStyle(color: _textDark, fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: _textDark),
            onPressed: () {},
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _green))
          : _error != null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _loadAll,
                  child: _buildContent(),
                ),
    );
  }

  Widget _buildContent() {
    final stats = _data?['stats'] ?? {};
    final weeklyData = List<Map<String, dynamic>>.from(_data?['weekly_data'] ?? []);
    final logs = List<Map<String, dynamic>>.from(_data?['recent_logs'] ?? []);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHeaderCard(),
        const SizedBox(height: 16),
        _buildChartCard(weeklyData),
        const SizedBox(height: 16),

        // Stats
        Row(children: [
          Expanded(child: _buildStatCard('Total Sessions',
              '${stats['total_sessions'] ?? 0}', Icons.calendar_today_rounded, _green)),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard('Active Today',
              '${stats['active_today'] ?? 0}', Icons.play_circle_rounded, _primary)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _buildStatCard('Students Present',
              '${stats['total_present'] ?? 0}', Icons.people_rounded, const Color(0xFF7B1FA2))),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard('Flagged Sessions',
              '${stats['flagged'] ?? 0}', Icons.flag_rounded, _red)),
        ]),
        const SizedBox(height: 20),

        // ── Sessions with toggle ──
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('All Sessions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _textDark)),
            TextButton(onPressed: _loadAll, child: const Text('Refresh')),
          ],
        ),
        const SizedBox(height: 8),

        _sessions.isEmpty
            ? Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(16)),
                child: const Column(children: [
                  Icon(Icons.inbox_rounded, size: 40, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('No sessions created yet.',
                      style: TextStyle(color: Colors.grey, fontSize: 15)),
                ]),
              )
            : Column(children: _sessions.map((s) => _buildSessionCard(s)).toList()),

        const SizedBox(height: 20),

        // ── Audit logs ──
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Recent Audit Logs',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _textDark)),
            TextButton(onPressed: _loadAll, child: const Text('Refresh')),
          ],
        ),
        const SizedBox(height: 8),

        logs.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('No logs yet.', style: TextStyle(color: Colors.grey, fontSize: 15)),
                ),
              )
            : Column(children: logs.map((log) => _buildLogCard(log)).toList()),
      ],
    );
  }

  // ── Session card with toggle ──────────────────────
  Widget _buildSessionCard(Map<String, dynamic> s) {
    final status      = s['status'] as String? ?? '';
    final isActive    = status == 'active';
    final statusColor = isActive ? _green : _textMid;
    final int sessionId = (s['id'] as num?)?.toInt() ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: statusColor, width: 4)),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Play/Stop icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(
                      isActive ? Icons.play_circle_fill_rounded : Icons.stop_circle_rounded,
                      color: statusColor, size: 20),
                ),
                const SizedBox(width: 10),

                // Session info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Session #${s['id']}',
                          style: const TextStyle(
                              color: _textDark, fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(s['date'] ?? '-',
                          style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),

                // Badge + Toggle stacked
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        isActive ? 'ACTIVE' : 'INACTIVE',
                        style: TextStyle(
                            color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Toggle row
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isActive ? _green : _textMid),
                        ),
                        const SizedBox(width: 4),
                        Transform.scale(
                          scale: 0.75,
                          child: Switch(
                            value: isActive,
                            onChanged: (val) => _toggleSession(sessionId, val),
                            activeColor: Colors.white,
                            activeTrackColor: _green,
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: Colors.grey.shade400,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                _infoChip(Icons.person_rounded, s['teacher_name'] ?? '-'),
                const SizedBox(width: 12),
                _infoChip(Icons.access_time_rounded,
                    '${s['start_time'] ?? '-'}'
                    '${s['end_time'] != null ? ' - ${s['end_time']}' : ''}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: _textMid),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
                color: _green.withOpacity(0.12), borderRadius: BorderRadius.circular(24)),
            child: const Icon(Icons.bar_chart_rounded, color: _green, size: 26),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Reports & Audit',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: _textDark)),
              Text('ADMIN DASHBOARD',
                  style: TextStyle(fontSize: 11, color: Colors.grey, letterSpacing: 1)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(List<Map<String, dynamic>> weeklyData) {
    final maxVal = weeklyData.isEmpty
        ? 1.0
        : weeklyData.map((e) => (e['percentage'] as num).toDouble())
            .reduce((a, b) => a > b ? a : b).clamp(1.0, 100.0);
    final avg = weeklyData.isEmpty
        ? 0.0
        : weeklyData.map((e) => (e['percentage'] as num).toDouble())
            .reduce((a, b) => a + b) / weeklyData.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Attendance Trends',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: _textDark)),
              Text('Last 7 Days',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            ],
          ),
          const SizedBox(height: 8),
          Text('${avg.toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _textDark)),
          const Text('Weekly Attendance %',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 16),
          SizedBox(
            height: 80,
            child: weeklyData.isEmpty
                ? const Center(child: Text('No data yet', style: TextStyle(color: Colors.grey)))
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: weeklyData.map((d) {
                      final pct = (d['percentage'] as num).toDouble();
                      final barH = (pct / maxVal) * 64;
                      final isToday = d['day'] ==
                          ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                              [DateTime.now().weekday - 1];
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            width: 28,
                            height: barH.clamp(4.0, 64.0),
                            decoration: BoxDecoration(
                              color: isToday ? _green : _green.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(d['day'],
                              style: TextStyle(
                                  fontSize: 10, color: isToday ? _green : Colors.grey)),
                        ],
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
                color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
                Text(title,
                    style: const TextStyle(fontSize: 10, color: Colors.grey), maxLines: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogCard(Map<String, dynamic> log) {
    final isSession = log['type'] == 'session';
    final status = log['status'] as String? ?? '';

    Color statusColor;
    String statusLabel;
    switch (status) {
      case 'active':    statusColor = _green;   statusLabel = 'ACTIVE';   break;
      case 'inactive':  statusColor = _textMid; statusLabel = 'INACTIVE'; break;
      case 'completed': statusColor = _primary; statusLabel = 'VERIFIED'; break;
      case 'present':   statusColor = _green;   statusLabel = 'PRESENT';  break;
      case 'absent':    statusColor = _red;     statusLabel = 'ABSENT';   break;
      case 'late':      statusColor = const Color(0xFFF57C00); statusLabel = 'LATE'; break;
      default:          statusColor = Colors.grey; statusLabel = status.toUpperCase();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card, borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: statusColor, width: 3)),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(18)),
            child: Icon(
              isSession ? Icons.person : Icons.school_rounded,
              color: statusColor, size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(log['title'] ?? '',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13, color: _textDark)),
                Text(log['subtitle'] ?? '',
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 2),
                Row(children: [
                  const Icon(Icons.access_time, size: 11, color: Colors.grey),
                  const SizedBox(width: 3),
                  Text(log['time'] ?? '',
                      style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  const SizedBox(width: 8),
                  Icon(isSession ? Icons.videocam_rounded : Icons.check_circle,
                      size: 11, color: Colors.grey),
                  const SizedBox(width: 3),
                  Text(isSession ? 'Session' : 'Attendance',
                      style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ]),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8)),
            child: Text(statusLabel,
                style: TextStyle(
                    color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadAll, child: const Text('Retry')),
        ],
      ),
    );
  }
}