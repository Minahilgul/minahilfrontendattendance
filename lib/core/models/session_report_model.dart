class SessionReportItem {
  final int sessionId;
  final String userName;
  final String currentLocation;
  final String status;
  final String createdAt;

  SessionReportItem({
    required this.sessionId,
    required this.userName,
    required this.currentLocation,
    required this.status,
    required this.createdAt,
  });

  factory SessionReportItem.fromJson(Map<String, dynamic> json) {
    return SessionReportItem(
      sessionId: json['session_id'],
      userName: json['user_name'] ?? 'Unknown',
      currentLocation: json['current_location'] ?? '-',
      status: json['status'] ?? '-',
      createdAt: json['created_at'] ?? '-',
    );
  }
}