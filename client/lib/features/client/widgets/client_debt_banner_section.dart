import 'package:app/core/theme/app_text_styles.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/extensions/date_time_extensions.dart';
import 'package:app/features/client/providers/client_providers.dart';
import 'package:app/features/client/services/client_debt_service.dart';
import 'package:app/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ClientDebtBannerSection extends ConsumerStatefulWidget {
  final VoidCallback onPaymentPressed;

  const ClientDebtBannerSection({super.key, required this.onPaymentPressed});

  @override
  ConsumerState<ClientDebtBannerSection> createState() =>
      _ClientDebtBannerSectionState();
}

class _ClientDebtBannerSectionState
    extends ConsumerState<ClientDebtBannerSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final debtsAsync = ref.watch(clientDebtsProvider);

    return debtsAsync.when(
      data: (debts) {
        if (debts.isEmpty) return const SizedBox.shrink();

        final totalAmount = debts.fold<double>(0, (sum, d) => sum + d.amount);
        final amountText = NumberFormat.currency(
          locale: 'pt_BR',
          symbol: 'R\$',
        ).format(totalAmount);

        final visibleDebts =
            _isExpanded || debts.length <= 2 ? debts : debts.take(2).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingLg,
              ),
              child: _buildBanner(debts, visibleDebts, amountText),
            ),
            const SizedBox(height: AppTheme.spacingLg),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildBanner(
    List<ClientDebtModel> debts,
    List<ClientDebtModel> visibleDebts,
    String amountText,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 360;
        final amountFontSize = isCompact ? 30.0 : 36.0;
        final buttonWidth = isCompact ? 112.0 : 128.0;
        final valueButtonGap = isCompact
            ? AppTheme.spacingMd
            : AppTheme.spacingLg;

        return Container(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A1A1A), Color(0xFF2D2D2D)],
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Débitos pendentes',
                style: AppTextStyles.heading2.copyWith(color: Colors.white),
              ),
              if (debts.length > 1) ...[
                const SizedBox(height: AppTheme.spacingXs),
                Text(
                  'Soma de ${debts.length} faturas pendentes',
                  style: AppTextStyles.body.copyWith(color: Colors.white70),
                ),
              ],
              const SizedBox(height: AppTheme.spacingLg),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        height: 52,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            amountText,
                            maxLines: 1,
                            softWrap: false,
                            style: TextStyle(
                              fontSize: amountFontSize,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: valueButtonGap),
                  SizedBox(
                    width: buttonWidth,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: AppButton(
                        label: 'Pagar tudo',
                        variant: AppButtonVariant.secondary,
                        fullWidth: true,
                        small: isCompact,
                        onPressed: widget.onPaymentPressed,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingMd),
              Divider(color: Colors.white.withValues(alpha: 0.24), height: 1),
              const SizedBox(height: AppTheme.spacingMd),
              ...visibleDebts.map(
                (debt) => Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacingXs),
                  child: Row(
                    children: [
                      const Text('• ', style: TextStyle(color: Colors.white70)),
                      Expanded(
                        child: Text(
                          debt.serviceName,
                          style: AppTextStyles.body.copyWith(
                            color: Colors.white70,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      Text(
                        ' (${_formatDate(debt.appointmentDate)}) - ${NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(debt.amount)}',
                        style: AppTextStyles.body.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
              if (debts.length > 2) ...[
                const SizedBox(height: AppTheme.spacingXs),
                GestureDetector(
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  child: Text(
                    _isExpanded
                        ? 'Ver menos'
                        : 'Ver todos os ${debts.length} débitos pendentes',
                    style: AppTextStyles.body.copyWith(
                      color: const Color(0xFF8BA9FF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return date.displayDateShort.toLowerCase();
  }
}
