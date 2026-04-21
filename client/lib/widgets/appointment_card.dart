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

  const AppointmentCard({
    super.key,
    required this.service,
    required this.subtitle,
    this.date,
    required this.time,
    required this.status,
    this.variant = AppointmentCardVariant.full,
    this.onTap,
  });

  String get _statusLabel =>
      status == BadgeVariant.confirmed ? 'Confirmado' : 'Pendente';

  @override
  Widget build(BuildContext context) {
    return variant == AppointmentCardVariant.full
        ? _buildFull()
        : _buildCompact();
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
                        color: AppColors.statusConfirmed.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.calendar_month_outlined,
                            size: 14,
                            color: AppColors.statusConfirmed,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            date ?? '',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.statusConfirmed,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '•',
                            style: TextStyle(color: AppColors.statusConfirmed),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.access_time,
                            size: 14,
                            color: AppColors.statusConfirmed,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            time,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.statusConfirmed,
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
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: AppTheme.spacingLg),
              Expanded(
                child: AppButton(
                  label: 'Cancelar',
                  variant: AppButtonVariant.danger,
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Compact variant (Admin) ───────────────────────────────────────────────
  Widget _buildCompact() {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: status == BadgeVariant.confirmed
                  ? AppColors.statusConfirmed
                  : AppColors.statusPending,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppTheme.spacingSm + 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subtitle, // For admin this is clientName
                            style: AppTextStyles.heading3.copyWith(
                              fontSize: 15,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            service,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textTertiary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingSm),
                    AppBadge(label: _statusLabel, variant: status),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingSm),
                Text(
                  time,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingMd),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Reagendar',
                        variant: AppButtonVariant.secondary,
                        small: true,
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingXs),
                    Expanded(
                      child: AppButton(
                        label: 'No-show',
                        variant: AppButtonVariant.secondary,
                        small: true,
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingXs),
                    Expanded(
                      child: AppButton(
                        label: 'Cancelar',
                        variant: AppButtonVariant.danger,
                        small: true,
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
