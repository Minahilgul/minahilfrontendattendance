import 'package:flutter/material.dart';
import '../../widgets/base_scaffold.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/confirmation_service.dart';

class AdminVerificationScreen extends StatefulWidget {
  const AdminVerificationScreen({super.key});

  @override
  State<AdminVerificationScreen> createState() => _AdminVerificationScreenState();
}

class _AdminVerificationScreenState extends State<AdminVerificationScreen> {
  bool _loading = true;
  String? _error;
  List<dynamic> _sessions = [];

  @override
  void initState() {
    super.initState();
    _loadOverview();
  }

  Future<void> _loadOverview() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await ConfirmationService.getAdminOverview();
    if (!mounted) return;
    if (result['success'] == true) {
      setState(() {
        _sessions = result['data'] ?? [];
        _loading = false;
      });
    } else {
      setState(() {
        _error = result['message'] ?? 'Failed to load verification responses';
        _loading = false;
      });
    }
  }

  Color _verdictColor(String verdict) {
    if (verdict.contains('Present ✓')) return AppColors.success;
    if (verdict.contains('NOT Present')) return AppColors.danger;
    return Colors.orange;
  }

  String _formatDate(String? raw) {
    if (raw == null) return '-';
    try {
      final dt = DateTime.parse(raw);
      String two(int n) => n.toString().padLeft(2, '0');
      return '${two(dt.day)}/${two(dt.month)}/${dt.year}  ${two(dt.hour)}:${two(dt.minute)}';
    } catch (_) {
      return raw;
    }
  }

  void _openDirectory(int sessionId, String className, String teacherName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _SessionDirectorySheet(
        sessionId: sessionId,
        className: className,
        teacherName: teacherName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Verification Responses',
      role: 'admin',
      body: RefreshIndicator(
        onRefresh: _loadOverview,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? ListView(
                    children: [
                      const SizedBox(height: 120),
                      Icon(Icons.error_outline, size: 48, color: AppColors.danger),
                      const SizedBox(height: 12),
                      Center(child: Text(_error!, textAlign: TextAlign.center)),
                    ],
                  )
                : _sessions.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 120),
                          Icon(Icons.fact_check_outlined, size: 48, color: Colors.grey),
                          SizedBox(height: 12),
                          Center(child: Text('No verification requests yet')),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _sessions.length,
                        itemBuilder: (context, index) {
                          final s = _sessions[index];
                          final verdict = s['verdict'] ?? 'Awaiting responses';
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 2,
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(14),
                              onTap: () => _openDirectory(
                                s['session_id'],
                                s['class_name'] ?? 'Unknown',
                                s['teacher_name'] ?? 'Unknown',
                              ),
                              title: Text(
                                '${s['class_name'] ?? 'Unknown'}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Teacher: ${s['teacher_name'] ?? 'Unknown'}'),
                                    Text(_formatDate(s['session_date'] as String?)),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Yes: ${s['yes_count']}   No: ${s['no_count']}   Pending: ${s['pending_count']}',
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _verdictColor(verdict).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  verdict,
                                  style: TextStyle(
                                    color: _verdictColor(verdict),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}

class _SessionDirectorySheet extends StatefulWidget {
  final int sessionId;
  final String className;
  final String teacherName;

  const _SessionDirectorySheet({
    required this.sessionId,
    required this.className,
    required this.teacherName,
  });

  @override
  State<_SessionDirectorySheet> createState() => _SessionDirectorySheetState();
}

class _SessionDirectorySheetState extends State<_SessionDirectorySheet> {
  bool _loading = true;
  List<dynamic> _data = [];
  String _verdict = 'Awaiting responses';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await ConfirmationService.getDirectory(widget.sessionId);
    if (!mounted) return;
    setState(() {
      _data = (result['data'] ?? []) as List<dynamic>;
      _verdict = result['verdict'] ?? 'Awaiting responses';
      _loading = false;
    });
  }

  Color _responseColor(String response) {
    if (response == 'yes') return AppColors.success;
    if (response == 'no') return AppColors.danger;
    return Colors.grey;
  }

  IconData _responseIcon(String response) {
    if (response == 'yes') return Icons.check_circle;
    if (response == 'no') return Icons.cancel;
    return Icons.hourglass_empty;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.className,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('Teacher: ${widget.teacherName}',
                  style: const TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 6),
              Text(_verdict,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const Divider(height: 24),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: _data.length,
                        itemBuilder: (context, index) {
                          final item = _data[index];
                          final response = item['response'] ?? 'pending';
                          return ListTile(
                            leading: Icon(_responseIcon(response), color: _responseColor(response)),
                            title: Text(item['student_name'] ?? 'Unknown'),
                            subtitle: Text('Roll No: ${item['roll_no'] ?? '-'}'),
                            trailing: Text(
                              response == 'pending' ? 'Pending' : response.toString().toUpperCase(),
                              style: TextStyle(
                                color: _responseColor(response),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}