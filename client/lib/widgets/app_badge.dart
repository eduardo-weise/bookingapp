import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/app_theme.dart';

enum BadgeVariant { confirmed, pending, cancelled }

class AppBadge extends StatelessWidget {
  final String label;
  final BadgeVariant variant;

  const AppBadge({super.key, required this.label, required this.variant});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color textColor;

    switch (variant) {
      case BadgeVariant.confirmed:
        bg = AppColors.confirmedBg;
        textColor = AppColors.statusConfirmed;
        break;
      case BadgeVariant.pending:
        bg = AppColors.pendingBg;
        textColor = AppColors.statusPending;
        break;
      case BadgeVariant.cancelled:
        bg = AppColors.cancelledBg;
        textColor = AppColors.statusCancelled;
        break;
    }

    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSm),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
