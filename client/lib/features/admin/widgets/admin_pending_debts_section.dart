import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_text_styles.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/widgets/app_avatar.dart';
import 'package:app/widgets/app_badge.dart';
import 'package:app/widgets/app_card.dart';
import 'package:app/widgets/section_header.dart';
import '../providers/admin_providers.dart';
import '../services/admin_debts_service.dart';

class AdminPendingDebtsSection extends ConsumerWidget {
  final VoidCallback onSeeAll;
  final Function(AdminClientDebtSummary) onDebtSelected;

  const AdminPendingDebtsSection({
    super.key,
    required this.onSeeAll,
    required this.onDebtSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debtsAsync = ref.watch(adminPendingDebtsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Débitos Pendentes',
          actionLabel: 'Ver todos',
          onActionTap: onSeeAll,
        ),
        const SizedBox(height: AppTheme.spacingMd),
        debtsAsync.when(
          data: (summaries) {
            if (summaries.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
                child: Text(
                  'Nenhum débito pendente.',
                  style: TextStyle(color: AppColors.textTertiary),
                ),
              );
            }

            return SizedBox(
              height: 175,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingLg,
                ),
                itemCount: summaries.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(width: AppTheme.spacingSm),
                itemBuilder: (context, i) {
                  final summary = summaries[i];
                  return GestureDetector(
                    onTap: () => onDebtSelected(summary),
                    child: SizedBox(
                      width: 160,
                      child: AppCard(
                        padding: const EdgeInsets.all(AppTheme.spacingMd),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                AppAvatar(
                                  size: AvatarSize.small,
                                  initials: summary.clientName.isNotEmpty
                                      ? summary.clientName[0]
                                      : '?',
                                ),
                                const SizedBox(width: AppTheme.spacingSm),
                                Expanded(
                                  child: Text(
                                    summary.clientName.split(' ').isNotEmpty
                                        ? summary.clientName.split(' ')[0]
                                        : summary.clientName,
                                    style: AppTextStyles.label.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppTheme.spacingSm),
                            Text(
                              '${summary.debts.length} débito(s)',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textTertiary,
                                fontSize: 11,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppTheme.spacingSm),
                            const AppBadge(
                              label: 'Pendente',
                              variant: BadgeVariant.pending,
                            ),
                            const Spacer(),
                            Text(
                              'R\$ ${summary.totalAmount.toStringAsFixed(2)}',
                              style: AppTextStyles.heading3.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: AppTheme.spacingLg),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stackTrace) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}
