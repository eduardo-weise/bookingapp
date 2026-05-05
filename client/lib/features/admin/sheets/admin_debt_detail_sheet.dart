import 'package:flutter/material.dart';
import 'package:app/core/theme/app_text_styles.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/widgets/app_avatar.dart';
import 'package:app/widgets/app_bottom_sheet.dart';
import 'package:app/widgets/app_button.dart';
import 'package:app/widgets/debt_banner.dart';
import '../services/admin_debts_service.dart';

void showAdminDebtDetailSheet({
  required BuildContext context,
  required AdminClientDebtSummary summary,
  required Function(String clientId, List<String> debtIds) onPayDebts,
  required Function(String clientId, List<String> debtIds) onCancelDebts,
}) {
  showAppBottomSheet(
    context: context,
    title: '',
    height: BottomSheetHeight.flexible,
    child: Column(
      children: [
        AppAvatar(
          size: AvatarSize.medium,
          initials: summary.clientName.isNotEmpty ? summary.clientName[0] : '?',
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Text(summary.clientName, style: AppTextStyles.heading2),
        const SizedBox(height: AppTheme.spacingXs),
        Text(
          '${summary.debts.length} débito(s) pendente(s)',
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: AppTheme.spacingLg),
        const Divider(),
        const SizedBox(height: AppTheme.spacingMd),
        ...summary.debts.map(
          (debt) => DebtBanner(
            margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
            title: 'Débito Pendente',
            amount: 'R\$ ${debt.amount.toStringAsFixed(2)}',
            description:
                '${debt.serviceName} em ${_formatDate(debt.appointmentDate)}',
            onPaymentPressed: () => onPayDebts(summary.clientId, [debt.id]),
            onCancelPressed: () => onCancelDebts(summary.clientId, [debt.id]),
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        const Divider(),
        const SizedBox(height: AppTheme.spacingMd),
        _detailRow(
          'Total',
          'R\$ ${summary.totalAmount.toStringAsFixed(2)}',
          bold: true,
        ),
        const SizedBox(height: AppTheme.spacingLg),
        if (summary.debts.length > 1) ...[
          AppButton(
            label: 'Marcar Todos como Pagos',
            fullWidth: true,
            small: false,
            onPressed: () => onPayDebts(
              summary.clientId,
              summary.debts.map((d) => d.id).toList(),
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          AppButton(
            label: 'Cancelar Todas as Cobranças',
            variant: AppButtonVariant.ghost,
            fullWidth: true,
            small: false,
            onPressed: () => onCancelDebts(
              summary.clientId,
              summary.debts.map((e) => e.id).toList(),
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
        ],
      ],
    ),
  );
}

Widget _detailRow(String label, String value, {bool bold = false}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: AppTextStyles.caption),
      Text(
        value,
        style: AppTextStyles.body.copyWith(
          fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    ],
  );
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}
