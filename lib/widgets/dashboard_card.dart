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

  Color _iconColor() {
    switch (type) {
      case DashboardCardType.primary:
        return AppColors.primary;

      case DashboardCardType.success:
        return AppColors.success;

      case DashboardCardType.warning:
        return AppColors.warning;

      case DashboardCardType.danger:
        return AppColors.danger;

      case DashboardCardType.purple:
        return AppColors.purple;
          
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _iconColor(),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  iconData,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}