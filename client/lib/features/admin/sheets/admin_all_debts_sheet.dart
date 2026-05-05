import 'package:flutter/material.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_text_styles.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/widgets/app_avatar.dart';
import 'package:app/widgets/app_bottom_sheet.dart';
import 'package:app/widgets/app_card.dart';
import 'package:app/widgets/app_empty_state.dart';
import '../services/admin_debts_service.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_providers.dart';

void showAdminAllDebtsSheet({
  required BuildContext context,
  required Function(AdminClientDebtSummary) onDebtSelected,
}) {
  showAppBottomSheet(
    context: context,
    title: 'Todos os Débitos',
    height: BottomSheetHeight.flexible,
    child: _AdminAllDebtsSheetContent(onDebtSelected: onDebtSelected),
  );
}

class _AdminAllDebtsSheetContent extends ConsumerWidget {
  final Function(AdminClientDebtSummary) onDebtSelected;

  const _AdminAllDebtsSheetContent({required this.onDebtSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debtsAsync = ref.watch(adminPendingDebtsProvider);

    return debtsAsync.when(
      data: (summaries) {
        if (summaries.isEmpty) {
          return const AppEmptyState(
            message: 'Nenhum débito pendente.',
            icon: Icons.check_circle_outline,
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: summaries.length,
          separatorBuilder: (context, index) =>
              const SizedBox(height: AppTheme.spacingSm),
          itemBuilder: (context, i) {
            final summary = summaries[i];
            return AppCard(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              onTap: () {
                Navigator.pop(context);
                onDebtSelected(summary);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        AppAvatar(
                          size: AvatarSize.small,
                          initials: summary.clientName.isNotEmpty
                              ? summary.clientName[0]
                              : '?',
                        ),
                        const SizedBox(width: AppTheme.spacingMd),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                summary.clientName,
                                style: AppTextStyles.body.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${summary.debts.length} débito(s)',
                                style: AppTextStyles.caption,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingSm),
                  Text(
                    'R\$ ${summary.totalAmount.toStringAsFixed(2)}',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.statusCancelled,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(AppTheme.spacingXl),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => const AppEmptyState(
        message: 'Não foi possível carregar os débitos.',
        icon: Icons.error_outline,
      ),
    );
  }
}
