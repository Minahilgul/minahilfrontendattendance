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

  // filters
  final TextEditingController _teacherController = TextEditingController();
  final TextEditingController _classController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  // Pagination
  int _currentPage = 1;
  static const int _itemsPerPage = 5;

  @override
  void initState() {
    super.initState();
    _loadOverview();
    _teacherController.addListener(_onFilterTextChanged);
    _classController.addListener(_onFilterTextChanged);
  }

  @override
  void dispose() {
    _teacherController.dispose();
    _classController.dispose();
    super.dispose();
  }

  void _onFilterTextChanged() {
    setState(() => _currentPage = 1);
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
        _currentPage = 1;
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

  
  double _presentPercentage(int yes, int no, int pending) {
    final total = yes + no + pending;
    if (total == 0) return 0.0;
    return (yes / total) * 100;
  }

  // filtering
  List<dynamic> get _filteredSessions {
    final teacherQuery = _teacherController.text.trim().toLowerCase();
    final classQuery = _classController.text.trim().toLowerCase();

    return _sessions.where((s) {
      final teacherName = (s['teacher_name'] ?? '').toString().toLowerCase();
      final className = (s['class_name'] ?? '').toString().toLowerCase();

      if (teacherQuery.isNotEmpty && !teacherName.contains(teacherQuery)) {
        return false;
      }
      if (classQuery.isNotEmpty && !className.contains(classQuery)) {
        return false;
      }

      if (_startDate != null || _endDate != null) {
        final rawDate = s['session_date'] as String?;
        if (rawDate == null) return false;
        DateTime? sessionDate;
        try {
          sessionDate = DateTime.parse(rawDate);
        } catch (_) {
          return false;
        }
        final dateOnly = DateTime(sessionDate.year, sessionDate.month, sessionDate.day);
        if (_startDate != null && dateOnly.isBefore(_startDate!)) return false;
        if (_endDate != null && dateOnly.isAfter(_endDate!)) return false;
      }

      return true;
    }).toList();
  }

  int get _totalPages {
    final total = _filteredSessions.length;
    if (total == 0) return 1;
    return (total / _itemsPerPage).ceil();
  }

  List<dynamic> get _pagedSessions {
    final filtered = _filteredSessions;
    final start = (_currentPage - 1) * _itemsPerPage;
    if (start >= filtered.length) return [];
    final end = (start + _itemsPerPage).clamp(0, filtered.length);
    return filtered.sublist(start, end);
  }

  bool get _hasActiveFilters =>
      _teacherController.text.trim().isNotEmpty ||
      _classController.text.trim().isNotEmpty ||
      _startDate != null ||
      _endDate != null;

  Future<void> _pickDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (picked != null) {
      setState(() {
        _startDate = DateTime(picked.start.year, picked.start.month, picked.start.day);
        _endDate = DateTime(picked.end.year, picked.end.month, picked.end.day);
        _currentPage = 1;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _teacherController.clear();
      _classController.clear();
      _startDate = null;
      _endDate = null;
      _currentPage = 1;
    });
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

  
  Widget _buildFilterBar() {
    final dateLabel = (_startDate != null && _endDate != null)
        ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year} - ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
        : 'Date Range';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _teacherController,
                    decoration: InputDecoration(
                      isDense: true,
                      labelText: 'Teacher',
                      hintText: 'Search teacher...',
                      prefixIcon: const Icon(Icons.person_outline, size: 18),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _classController,
                    decoration: InputDecoration(
                      isDense: true,
                      labelText: 'Class',
                      hintText: 'Search class...',
                      prefixIcon: const Icon(Icons.class_outlined, size: 18),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDateRange,
                    icon: Icon(Icons.date_range, size: 16, color: AppColors.primary),
                    label: Text(
                      dateLabel,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
                if (_hasActiveFilters) ...[
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: _clearFilters,
                    icon: Icon(Icons.clear, color: AppColors.danger),
                    tooltip: 'Clear filters',
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.danger.withOpacity(0.08),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }


  
  Widget _buildPaginationBar() {
    final totalPages = _totalPages;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left,
                color: _currentPage > 1 ? AppColors.primary : AppColors.textLight),
            onPressed: _currentPage > 1
                ? () => setState(() => _currentPage--)
                : null,
          ),
          Text(
            'Page $_currentPage of $totalPages',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right,
                color: _currentPage < totalPages ? AppColors.primary : AppColors.textLight),
            onPressed: _currentPage < totalPages
                ? () => setState(() => _currentPage++)
                : null,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredSessions;
    final paged = _pagedSessions;

    return BaseScaffold(
      title: 'Verification Responses',
      role: 'admin',
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: RefreshIndicator(
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
                      : filtered.isEmpty
                          ? ListView(
                              children: [
                                const SizedBox(height: 120),
                                Icon(
                                  _hasActiveFilters ? Icons.filter_alt_off : Icons.fact_check_outlined,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 12),
                                Center(
                                  child: Text(
                                    _hasActiveFilters
                                        ? 'No results match your filters'
                                        : 'No verification requests yet',
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                              itemCount: paged.length,
                              itemBuilder: (context, index) {
                                final s = paged[index];
                                final verdict = s['verdict'] ?? 'Awaiting responses';

                                final int yesCount = (s['yes_count'] as num?)?.toInt() ?? 0;
                                final int noCount = (s['no_count'] as num?)?.toInt() ?? 0;
                                final int pendingCount = (s['pending_count'] as num?)?.toInt() ?? 0;
                                final double presentPct = _presentPercentage(yesCount, noCount, pendingCount);

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
                                          const SizedBox(height: 4),
                                          Text(_formatDate(s['session_date'] as String?)),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Yes: $yesCount   No: $noCount   Pending: $pendingCount',
                                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                    trailing: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerRight,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Container(
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
                                          const SizedBox(height: 22),
                                          Text(
                                            '${presentPct.toStringAsFixed(0)}% Present',
                                            style: TextStyle(
                                              color: AppColors.success,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ),
          if (!_loading && _error == null && filtered.isNotEmpty) _buildPaginationBar(),
        ],
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