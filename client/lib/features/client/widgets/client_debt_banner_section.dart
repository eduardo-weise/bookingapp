import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/client/providers/client_providers.dart';
import 'package:app/widgets/debt_banner.dart';

class ClientDebtBannerSection extends ConsumerWidget {
  final VoidCallback onPaymentPressed;

  const ClientDebtBannerSection({super.key, required this.onPaymentPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debtsAsync = ref.watch(clientDebtsProvider);

    return debtsAsync.when(
      data: (debts) {
        if (debts.isNotEmpty) {
          final debt = debts.first;
          final formattedAmount = NumberFormat.currency(
            locale: 'pt_BR',
            symbol: 'R\$',
          ).format(debt.amount);

          return Column(
            children: [
              DebtBanner(
                amount: formattedAmount,
                description:
                    'Débito pendente criado em ${DateFormat('dd MMM yyyy', 'pt_BR').format(debt.createdAt)}',
                onPaymentPressed: onPaymentPressed,
              ),
              const SizedBox(height: AppTheme.spacingLg),
            ],
          );
        }
        return const SizedBox.shrink();
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }
}
