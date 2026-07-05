import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

enum DashboardCardType {
  primary,
  success,
  warning,
  danger,
  purple,
}

class DashboardCard extends StatelessWidget {
  final String title;
  final IconData iconData;
  final DashboardCardType type;
  final VoidCallback? onTap;

  const DashboardCard({
    super.key,
    required this.title,
    required this.iconData,
    required this.type,
    this.onTap,
  });

  List<Color> _gradientColors() {
    switch (type) {
      case DashboardCardType.primary:
        return [const Color(0xFF1565C0), const Color(0xFF42A5F5)];
      case DashboardCardType.success:
        return [const Color(0xFF2E7D32), const Color(0xFF66BB6A)];
      case DashboardCardType.warning:
        return [const Color(0xFFE65100), const Color(0xFFFFA726)];
      case DashboardCardType.danger:
        return [const Color(0xFFC62828), const Color(0xFFEF5350)];
      case DashboardCardType.purple:
        return [const Color(0xFF6A1B9A), const Color(0xFFAB47BC)];
    }
  }

  Color _glowColor() => _gradientColors()[0].withOpacity(0.30);

  @override
  Widget build(BuildContext context) {
    final gradColors = _gradientColors();

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Big circle — exactly like reference ──────────────────────────
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: gradColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: _glowColor(),
                  blurRadius: 18,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(iconData, color: Colors.white, size: 42),
          ),

          const SizedBox(height: 12),

          // ── Title ────────────────────────────────────────────────────────
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: gradColors[0],
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}