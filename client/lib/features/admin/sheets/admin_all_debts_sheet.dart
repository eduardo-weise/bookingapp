import 'package:flutter/material.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/widgets/app_bottom_sheet.dart';
import 'package:app/widgets/app_empty_state.dart';
import 'package:app/widgets/debt_card.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_providers.dart';

void showAdminAllDebtsSheet({
  required BuildContext context,
  required Function(String clientId, List<String> debtIds) onPayDebts,
  required Function(String clientId, List<String> debtIds) onCancelDebts,
  required String clientId,
  required String clientName,
  VoidCallback? onBackToClients,
}) {
  showAppBottomSheet(
    context: context,
    title: clientName,
    height: BottomSheetHeight.flexible,
    onBack: () {
      Navigator.of(context).pop();
      if (onBackToClients == null) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        onBackToClients();
      });
    },
    child: _AdminAllDebtsSheetContent(
      clientId: clientId,
      onPayDebts: onPayDebts,
      onCancelDebts: onCancelDebts,
    ),
  );
}

class _AdminAllDebtsSheetContent extends ConsumerStatefulWidget {
  final String clientId;
  final Function(String clientId, List<String> debtIds) onPayDebts;
  final Function(String clientId, List<String> debtIds) onCancelDebts;

  const _AdminAllDebtsSheetContent({
    required this.clientId,
    required this.onPayDebts,
    required this.onCancelDebts,
  });

  @override
  ConsumerState<_AdminAllDebtsSheetContent> createState() =>
      _AdminAllDebtsSheetContentState();
}

class _AdminAllDebtsSheetContentState
    extends ConsumerState<_AdminAllDebtsSheetContent> {
  bool _contentReady = false;
  static const _initialContentDelay = Duration(milliseconds: 260);

  @override
  void initState() {
    super.initState();
    Future.delayed(_initialContentDelay, () {
      if (!mounted) return;
      setState(() => _contentReady = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_contentReady) {
      return const Padding(
        padding: EdgeInsets.all(AppTheme.spacingXl),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final debtsAsync = ref.watch(adminPendingDebtsProvider);
    return debtsAsync.when(
      data: (summaries) {
        if (summaries.isEmpty) {
          return const AppEmptyState(
            message: 'Nenhum débito pendente.',
            icon: Icons.check_circle_outline,
          );
        }

        final matchedSummary = summaries.where((s) => s.clientId == widget.clientId);
        if (matchedSummary.isEmpty) {
          return const AppEmptyState(
            message: 'Este cliente não possui débitos pendentes.',
            icon: Icons.check_circle_outline,
          );
        }

        final clientSummary = matchedSummary.first;

        return Column(
          children: [
            const SizedBox(height: AppTheme.spacingMd),
            ...clientSummary.debts.map(
              (debt) => Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                child: DebtCard(
                  amount: 'R\$ ${debt.amount.toStringAsFixed(2)}',
                  description:
                      '${debt.serviceName} em ${_formatDate(debt.appointmentDate)}',
                  onPayPressed: () =>
                      widget.onPayDebts(clientSummary.clientId, [debt.id]),
                  onCancelPressed: () =>
                      widget.onCancelDebts(clientSummary.clientId, [debt.id]),
                  margin: EdgeInsets.zero,
                ),
              ),
            ),
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

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}
