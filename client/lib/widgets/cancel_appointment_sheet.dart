import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_text_styles.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/widgets/app_bottom_sheet.dart';
import 'package:app/widgets/app_button.dart';

Future<void> showCancelAppointmentSheet({
  required BuildContext context,
  required String serviceName,
  required DateTime startTime,
  required double servicePrice,
  required bool isAdmin,
  required Future<void> Function(bool applyLateCancellationFee) onConfirm,
}) {
  return showAppBottomSheet(
    context: context,
    title: 'Cancelar Agendamento',
    height: BottomSheetHeight.flexible,
    child: _CancelAppointmentSheetContent(
      serviceName: serviceName,
      startTime: startTime,
      servicePrice: servicePrice,
      isAdmin: isAdmin,
      onConfirm: onConfirm,
    ),
  );
}

class _CancelAppointmentSheetContent extends StatefulWidget {
  final String serviceName;
  final DateTime startTime;
  final double servicePrice;
  final bool isAdmin;
  final Future<void> Function(bool applyLateCancellationFee) onConfirm;

  const _CancelAppointmentSheetContent({
    required this.serviceName,
    required this.startTime,
    required this.servicePrice,
    required this.isAdmin,
    required this.onConfirm,
  });

  @override
  State<_CancelAppointmentSheetContent> createState() =>
      _CancelAppointmentSheetContentState();
}

class _CancelAppointmentSheetContentState
    extends State<_CancelAppointmentSheetContent> {
  bool _isSubmitting = false;
  bool _applyFee = true;

  bool get _isWithin24Hours {
    final now = DateTime.now().toUtc();
    final start = widget.startTime.toUtc();
    return start.isBefore(now.add(const Duration(hours: 24)));
  }

  double get _feeAmount => widget.servicePrice * 0.35;

  String get _formattedFeeAmount =>
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(_feeAmount);

  String get _message {
    if (!_isWithin24Hours) {
      return 'Tem certeza que deseja cancelar este atendimento?';
    }

    if (widget.isAdmin) {
      return 'Este cancelamento está dentro de 24h do atendimento. Você pode optar por aplicar ou não a taxa de 35%. Taxa estimada: $_formattedFeeAmount.';
    }

    return 'Este cancelamento está dentro de 24h do atendimento. Será cobrada uma taxa de 35% no valor de $_formattedFeeAmount.';
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    try {
      await widget.onConfirm(_isWithin24Hours ? _applyFee : false);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final shouldShowFeeOption = widget.isAdmin && _isWithin24Hours;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.serviceName,
            style: AppTextStyles.heading3,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            _message,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          if (shouldShowFeeOption) ...[
            const SizedBox(height: AppTheme.spacingMd),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMd,
                vertical: AppTheme.spacingSm,
              ),
              decoration: BoxDecoration(
                color: AppColors.muted,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Taxa: $_formattedFeeAmount',
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          'Desativar = sem débito',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textTertiary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _applyFee,
                    onChanged: _isSubmitting
                        ? null
                        : (value) => setState(() => _applyFee = value),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppTheme.spacingLg),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Voltar',
                  variant: AppButtonVariant.secondary,
                  fullWidth: true,
                  small: true,
                  onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: AppButton(
                  label: 'Confirmar',
                  variant: AppButtonVariant.danger,
                  fullWidth: true,
                  small: true,
                  isLoading: _isSubmitting,
                  onPressed: _isSubmitting ? null : _submit,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
