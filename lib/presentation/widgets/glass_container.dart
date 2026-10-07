import 'dart:ui';
import 'package:flutter/material.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_design_tokens.dart';

/// A reusable frosted-glass card used across dashboard, member profile,
/// scanner popup, etc. Wraps [child] with a blur + translucent surface
/// that adapts to the active theme via [BuildContext] color getters.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? borderColor;
  final double? width;
  final VoidCallback? onTap;
  final bool interactive; // hover lift on desktop

  const GlassContainer({
    super.key,
    required this.child,
    this.margin,
    this.width,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 14,
    this.borderColor,
    this.onTap,
    this.interactive = false,
  });

  @override
  Widget build(BuildContext context) {
    final surface = AppColors.surfaceOf(context);
    final border = borderColor ?? AppColors.borderOf(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(borderRadius),
            splashColor: AppColors.primary.withValues(alpha: 0.08),
            highlightColor: AppColors.primary.withValues(alpha: 0.04),
            child: Container(
              margin: margin,
              width: width,
              padding: padding,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    surface.withValues(alpha: 0.7),
                    surface.withValues(alpha: 0.55),
                  ],
                ),
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: border.withValues(alpha: 0.6),
                  width: 1,
                ),
                boxShadow: AppShadows.of(context).elevation1,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}