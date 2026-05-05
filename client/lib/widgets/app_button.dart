import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/app_theme.dart';

enum AppButtonVariant { primary, secondary, ghost, danger }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool fullWidth;
  final bool small;
  final Widget? icon;
  final bool isLoading;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.fullWidth = false,
    this.small = true,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final height = small ? 32.0 : 48.0;
    final horizontalPadding = small ? 12.0 : 24.0;
    final fontSize = small ? 13.0 : 15.0;

    Color bg;
    Color fg;
    Border? border;

    switch (variant) {
      case AppButtonVariant.primary:
        bg = AppColors.brandPrimary;
        fg = AppColors.textInverse;
        break;
      case AppButtonVariant.secondary:
        bg = AppColors.surface;
        fg = AppColors.brandPrimary;
        border = Border.all(color: AppColors.border, width: 1);
        break;
      case AppButtonVariant.ghost:
        bg = Colors.transparent;
        fg = AppColors.textSecondary;
        break;
      case AppButtonVariant.danger:
        bg = AppColors.dangerBg;
        fg = AppColors.statusCancelled;
        border = Border.all(color: const Color(0xFFFECACA), width: 1);
        break;
    }

    Widget child = isLoading
        ? SizedBox(
            height: fontSize + 4,
            width: fontSize + 4,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[icon!, const SizedBox(width: 8)],
              Text(
                label,
                style: AppTextStyles.button.copyWith(
                  color: fg,
                  fontSize: fontSize,
                ),
              ),
            ],
          );

    final disabled = onPressed == null;

    return GestureDetector(
      onTap: onPressed,
      child: AnimatedScale(
        scale: 1.0,
        duration: const Duration(milliseconds: 100),
        child: Opacity(
          opacity: disabled ? 0.5 : 1.0,
          child: Container(
            height: height,
            width: fullWidth ? double.infinity : null,
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border: border,
            ),
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
  }
}
