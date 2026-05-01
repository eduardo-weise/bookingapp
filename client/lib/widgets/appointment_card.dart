import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/app_theme.dart';
import 'app_badge.dart';
import 'app_button.dart';
import 'app_card.dart';

/// Layout variant for the appointment card.
enum AppointmentCardVariant {
  /// Full card with icon, date/time row, and overflow menu (Client Home).
  full,

  /// Compact card with color stripe on the left (Admin Dashboard).
  compact,
}

/// A reusable card that displays an appointment / booking.
///
/// Supports two visual variants:
/// - [AppointmentCardVariant.full] — calendar icon + date/time row (client)
/// - [AppointmentCardVariant.compact] — color stripe + time label (admin)
class AppointmentCard extends StatelessWidget {
  final String service;
  final String subtitle;
  final String? date;
  final String time;
  final BadgeVariant status;
  final AppointmentCardVariant variant;
  final VoidCallback? onTap;
  final VoidCallback? onReschedulePressed;
  final VoidCallback? onCancelPressed;

  const AppointmentCard({
    super.key,
    required this.service,
    required this.subtitle,
    this.date,
    required this.time,
    required this.status,
    this.variant = AppointmentCardVariant.full,
    this.onTap,
    this.onReschedulePressed,
    this.onCancelPressed,
  });

  Color get _statusColor {
    switch (status) {
      case BadgeVariant.confirmed:
        return AppColors.statusConfirmed;
      case BadgeVariant.pending:
        return AppColors.statusPending;
      case BadgeVariant.cancelled:
        return AppColors.statusCancelled;
    }
  }

  Color get _statusBackground => _statusColor.withValues(alpha: 0.12);

  @override
  Widget build(BuildContext context) {
    return variant == AppointmentCardVariant.full
        ? _buildFull()
      : _buildFull();
  }

  // ── Full variant (Client) ─────────────────────────────────────────────────
  Widget _buildFull() {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.muted,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: const Icon(
                  Icons.calendar_today_outlined,
                  size: 26,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(service, style: AppTextStyles.heading3),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingSm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingSm,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _statusBackground,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.calendar_month_outlined,
                            size: 14,
                            color: AppColors.textPrimary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            date ?? '',
                            style: AppTextStyles.caption.copyWith(
                              color: _statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '•',
                            style: TextStyle(color: _statusColor),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.access_time,
                            size: 14,
                            color: AppColors.textPrimary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            time,
                            style: AppTextStyles.caption.copyWith(
                              color: _statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingLg),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: AppTheme.spacingLg),
          Row(
            children: [
               Expanded(
                child: AppButton(
                  label: 'Reagendar',
                  variant: AppButtonVariant.secondary,
                  onPressed: onReschedulePressed,
                ),
              ),
              const SizedBox(width: AppTheme.spacingLg),
              Expanded(
                child: AppButton(
                  label: 'Cancelar',
                  variant: AppButtonVariant.danger,
                  onPressed: onCancelPressed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
