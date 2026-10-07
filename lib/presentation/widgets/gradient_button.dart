import 'package:flutter/material.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_design_tokens.dart';

/// Primary CTA button used across the app (login, approve entry, save, etc).
/// Hover/disabled states come from the active ElevatedButton theme, so this
/// component is mostly a layout wrapper with the signature gradient look.
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Opacity(
        opacity: disabled ? 0.5 : 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: disabled
                ? null
                : AppColors.primaryGradient,
            color: disabled ? AppColors.borderOf(context) : null,
            borderRadius: BorderRadius.circular(AppRadii.sm),
            boxShadow: disabled ? null : AppShadows.of(context).accentGlow,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadii.sm),
              onTap: isLoading ? null : onPressed,
              child: Center(
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (icon != null) ...[
                            Icon(icon, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}