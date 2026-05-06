import 'package:flutter/material.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_text_styles.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/widgets/app_avatar.dart';
import 'package:app/widgets/app_bottom_sheet.dart';
import 'package:app/widgets/app_empty_state.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_providers.dart';
import 'admin_all_debts_sheet.dart';

void showAdminDebtClientsSheet({
  required BuildContext context,
  required Function(String clientId, List<String> debtIds) onPayDebts,
  required Function(String clientId, List<String> debtIds) onCancelDebts,
}) {
  showAppBottomSheet(
    context: context,
    title: 'Todos os Débitos',
    height: BottomSheetHeight.flexible,
    child: _AdminDebtClientsSheetContent(
      parentContext: context,
      onPayDebts: onPayDebts,
      onCancelDebts: onCancelDebts,
    ),
  );
}

class _AdminDebtClientsSheetContent extends ConsumerWidget {
  final BuildContext parentContext;
  final Function(String clientId, List<String> debtIds) onPayDebts;
  final Function(String clientId, List<String> debtIds) onCancelDebts;

  const _AdminDebtClientsSheetContent({
    required this.parentContext,
    required this.onPayDebts,
    required this.onCancelDebts,
  });

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

        return Column(
          children: [
            for (var i = 0; i < summaries.length; i++) ...[
              if (i > 0) const SizedBox(height: AppTheme.spacingMd),
              GestureDetector(
                onTap: () {
                  final summary = summaries[i];
                  Navigator.of(context).pop();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!parentContext.mounted) return;
                    showAdminAllDebtsSheet(
                      context: parentContext,
                      onPayDebts: onPayDebts,
                      onCancelDebts: onCancelDebts,
                      clientId: summary.clientId,
                      clientName: summary.clientName,
                      onBackToClients: () {
                        showAdminDebtClientsSheet(
                          context: parentContext,
                          onPayDebts: onPayDebts,
                          onCancelDebts: onCancelDebts,
                        );
                      },
                    );
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border, width: 1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Row(
                    children: [
                      AppAvatar(
                        size: AvatarSize.small,
                        initials: summaries[i].clientName.isNotEmpty
                            ? summaries[i].clientName[0]
                            : '?',
                      ),
                      const SizedBox(width: AppTheme.spacingSm),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              summaries[i].clientName,
                              style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppTheme.spacingXs),
                            Text(
                              '${summaries[i].debts.length} débito${summaries[i].debts.length != 1 ? 's' : ''} • R\$ ${summaries[i].totalAmount.toStringAsFixed(2)}',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
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
