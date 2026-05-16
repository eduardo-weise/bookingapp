import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_text_styles.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/widgets/app_avatar.dart';
import 'package:app/widgets/app_bottom_sheet.dart';
import 'package:app/widgets/app_empty_state.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_providers.dart';
import 'admin_all_debts_sheet.dart';
import 'admin_extra_time_sheet.dart';

void showAdminClientsSheet({
  required BuildContext context,
  required Function(String clientId, List<String> debtIds) onPayDebts,
  required Function(String clientId, List<String> debtIds) onCancelDebts,
}) {
  showAppBottomSheet(
    context: context,
    title: 'Clientes',
    height: BottomSheetHeight.flexible,
    child: _AdminClientsSheetContent(
      parentContext: context,
      onPayDebts: onPayDebts,
      onCancelDebts: onCancelDebts,
    ),
  );
}

class _AdminClientsSheetContent extends ConsumerWidget {
  final BuildContext parentContext;
  final Function(String clientId, List<String> debtIds) onPayDebts;
  final Function(String clientId, List<String> debtIds) onCancelDebts;

  const _AdminClientsSheetContent({
    required this.parentContext,
    required this.onPayDebts,
    required this.onCancelDebts,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientsAsync = ref.watch(adminAllClientsProvider);
    final debtsAsync = ref.watch(adminPendingDebtsProvider);

    return clientsAsync.when(
      data: (clients) {
        if (clients.isEmpty) {
          return const AppEmptyState(
            message: 'Nenhum cliente encontrado.',
            icon: Icons.group_outlined,
          );
        }

        final debtsList = debtsAsync.value ?? [];

        return Column(
          children: [
            for (var i = 0; i < clients.length; i++) ...[
              if (i > 0) const SizedBox(height: AppTheme.spacingMd),
              Builder(
                builder: (context) {
                  final summary = debtsList
                      .where((d) => d.clientId == clients[i].id)
                      .firstOrNull;
                  return Slidable(
                    key: ValueKey(clients[i].id),
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      extentRatio: 0.5,
                      children: [
                        if (summary != null && summary.debts.isNotEmpty)
                          SlidableAction(
                            onPressed: (context) {
                              Navigator.of(
                                context,
                              ).pop(); // Close current sheet
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (!parentContext.mounted) return;
                                showAdminAllDebtsSheet(
                                  context: parentContext,
                                  onPayDebts: onPayDebts,
                                  onCancelDebts: onCancelDebts,
                                  clientId: summary.clientId,
                                  clientName: summary.clientName,
                                  onBackToClients: () {
                                    showAdminClientsSheet(
                                      context: parentContext,
                                      onPayDebts: onPayDebts,
                                      onCancelDebts: onCancelDebts,
                                    );
                                  },
                                );
                              });
                            },
                            backgroundColor: AppColors.statusCancelled,
                            foregroundColor: AppColors.textInverse,
                            icon: Icons.money_off,
                            label: 'Débitos',
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(AppTheme.radiusSm),
                              bottomLeft: Radius.circular(AppTheme.radiusSm),
                            ),
                          ),
                        SlidableAction(
                          onPressed: (context) {
                            Navigator.of(context).pop(); // Close current sheet
                            showAdminExtraTimeSheet(
                              context: parentContext,
                              client: clients[i],
                              onPayDebts: onPayDebts,
                              onCancelDebts: onCancelDebts,
                            );
                          },
                          backgroundColor: AppColors.brandPrimary,
                          foregroundColor: AppColors.textInverse,
                          icon: Icons.timer,
                          label: 'Tempo',
                          borderRadius:
                              (summary != null && summary.debts.isNotEmpty)
                              ? const BorderRadius.only(
                                  topRight: Radius.circular(AppTheme.radiusSm),
                                  bottomRight: Radius.circular(
                                    AppTheme.radiusSm,
                                  ),
                                )
                              : BorderRadius.circular(AppTheme.radiusSm),
                        ),
                      ],
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(AppTheme.spacingMd),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border, width: 1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                        color: AppColors
                            .surface, // Ensure surface color covers actions
                      ),
                      child: Row(
                        children: [
                          AppAvatar(
                            size: AvatarSize.small,
                            initials: clients[i].displayName.isNotEmpty
                                ? clients[i].displayName[0].toUpperCase()
                                : '?',
                            imageUrl: clients[i].avatarUrl,
                          ),
                          const SizedBox(width: AppTheme.spacingSm),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  clients[i].displayName,
                                  style: AppTextStyles.body.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: AppTheme.spacingXs),
                                Builder(
                                  builder: (context) {
                                    final summary = debtsList
                                        .where(
                                          (d) => d.clientId == clients[i].id,
                                        )
                                        .firstOrNull;
                                    final extraTime =
                                        clients[i].extraDurationMinutes;

                                    final List<String> badges = [];
                                    if (summary != null &&
                                        summary.debts.isNotEmpty) {
                                      badges.add('Débitos pendentes');
                                    }
                                    if (extraTime > 0) {
                                      badges.add('+${extraTime}m extra');
                                    }

                                    if (badges.isEmpty) {
                                      return Text(
                                        clients[i].email,
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      );
                                    }

                                    return Text(
                                      badges.join(' • '),
                                      style: AppTextStyles.caption.copyWith(
                                        color: summary != null
                                            ? AppColors.statusCancelled
                                            : AppColors.brandPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons
                                .chevron_left, // Arrow pointing left to hint swipe
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  );
                },
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
        message: 'Não foi possível carregar os clientes.',
        icon: Icons.error_outline,
      ),
    );
  }
}
