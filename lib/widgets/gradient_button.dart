import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class GradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;
  final bool isDanger;

  const GradientButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style,
    this.isDanger = false,
  });

  factory GradientButton.icon({
    Key? key,
    required VoidCallback? onPressed,
    required Widget icon,
    required Widget label,
    ButtonStyle? style,
    bool isDanger = false,
  }) {
    return GradientButton(
      key: key,
      onPressed: onPressed,
      style: style,
      isDanger: isDanger,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 8),
          label,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null;
    
    // Creative Gradient with an angled, multi-stop blend
    final gradient = isDanger 
        ? const LinearGradient(
            colors: [Color(0xFFFF5252), Color(0xFFD32F2F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [
              AppColors.secondary,
              Color(0xFF8B5CF6), // A mid-tone bridging secondary to primary smoothly
              AppColors.primary,
            ],
            begin: Alignment(-1.0, -0.5),
            end: Alignment(1.0, 0.5),
            stops: [0.0, 0.5, 1.0],
          );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: isDisabled ? null : gradient,
        color: isDisabled ? Colors.grey.shade300 : null,
        // Soft glowing drop-shadow when active
        boxShadow: isDisabled 
            ? [] 
            : [
                BoxShadow(
                  color: (isDanger ? Colors.red : AppColors.primary).withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                  spreadRadius: 1,
                ),
              ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: (style ?? ElevatedButton.styleFrom()).copyWith(
          backgroundColor: WidgetStateProperty.all(Colors.transparent),
          shadowColor: WidgetStateProperty.all(Colors.transparent),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        child: child,
      ),
    );
  }
}