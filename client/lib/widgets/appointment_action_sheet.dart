import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_text_styles.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/widgets/app_bottom_sheet.dart';
import 'package:app/widgets/app_button.dart';

enum AppointmentActionType { cancel, reschedule }

/// Shows a confirmation sheet for appointment actions (cancel or reschedule).
///
/// - [onConfirm] receives `applyFee` (true/false) and must complete without
///   throwing to be considered successful. For reschedule, confirmation only
///   dismisses this sheet — the caller opens the booking flow afterwards.
Future<void> showAppointmentActionSheet({
  required BuildContext context,
  required String serviceName,
  required DateTime startTime,
  required double servicePrice,
  required bool isAdmin,
  required AppointmentActionType action,
  required Future<void> Function(bool applyFee) onConfirm,
}) {
  return showAppBottomSheet(
    context: context,
    title: action == AppointmentActionType.cancel
        ? 'Cancelar Agendamento'
        : 'Reagendar Atendimento',
    height: BottomSheetHeight.flexible,
    child: _AppointmentActionSheetContent(
      serviceName: serviceName,
      startTime: startTime,
      servicePrice: servicePrice,
      isAdmin: isAdmin,
      action: action,
      onConfirm: onConfirm,
    ),
  );
}

class _AppointmentActionSheetContent extends StatefulWidget {
  final String serviceName;
  final DateTime startTime;
  final double servicePrice;
  final bool isAdmin;
  final AppointmentActionType action;
  final Future<void> Function(bool applyFee) onConfirm;

  const _AppointmentActionSheetContent({
    required this.serviceName,
    required this.startTime,
    required this.servicePrice,
    required this.isAdmin,
    required this.action,
    required this.onConfirm,
  });

  @override
  State<_AppointmentActionSheetContent> createState() =>
      _AppointmentActionSheetContentState();
}

class _AppointmentActionSheetContentState
    extends State<_AppointmentActionSheetContent> {
  bool _isSubmitting = false;
  bool _applyFee = true;

  bool get _isCancel => widget.action == AppointmentActionType.cancel;

  /// Fee percentage: 35% for cancellation, 15% for reschedule.
  double get _feePercent => _isCancel ? 0.35 : 0.15;

  bool get _isWithin1Hour {
    final now = DateTime.now().toUtc();
    final start = widget.startTime.toUtc();
    return start.isBefore(now.add(const Duration(hours: 1)));
  }

  bool get _isPastStartTime {
    final now = DateTime.now();
    final start = widget.startTime.toLocal();
    return start.isBefore(now);
  }

  bool get _isWithin24Hours {
    final now = DateTime.now().toUtc();
    final start = widget.startTime.toUtc();
    return start.isBefore(now.add(const Duration(hours: 24)));
  }

  double get _feeAmount => widget.servicePrice * _feePercent;

  String get _formattedFeeAmount =>
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(_feeAmount);

  String get _formattedFeePercent =>
      '${(_feePercent * 100).toStringAsFixed(0)}%';

  String get _message {
    if (_isCancel) {
      if (!_isWithin24Hours) {
        return 'Tem certeza que deseja cancelar este atendimento?';
      }
      if (widget.isAdmin) {
        return 'Este cancelamento está dentro de 24h do atendimento. Você pode optar por aplicar ou não a taxa de $_formattedFeePercent. Taxa estimada: $_formattedFeeAmount.';
      }
      return 'Este cancelamento está dentro de 24h do atendimento. Será cobrada uma taxa de $_formattedFeePercent no valor de $_formattedFeeAmount.';
    }

    // Reschedule
    if (!_isWithin24Hours) {
      return 'Tem certeza que deseja reagendar este atendimento?';
    }
    if (widget.isAdmin) {
      return 'Este reagendamento está dentro de 24h do atendimento. Você pode optar por aplicar ou não a taxa de $_formattedFeePercent. Taxa estimada: $_formattedFeeAmount.';
    }
    return 'Este reagendamento está dentro de 24h do atendimento. Será cobrada uma taxa de $_formattedFeePercent no valor de $_formattedFeeAmount. Deseja continuar?';
  }

  /// Determines if the action button should be disabled.
  /// - Reschedule: disabled for clients within 1h, disabled for admins AFTER start time.
  /// - Cancel: never disabled due to time.
  bool get _isBlocked {
    if (_isCancel) {
      return false; // Cancel is never blocked by time
    }
    if (widget.isAdmin) {
      return _isPastStartTime; // Admin: blocked only after start
    }
    return _isWithin1Hour; // Client: blocked within 1h before start
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    try {
      final applyFee = _isWithin24Hours ? _applyFee : false;

      // For reschedule, close confirmation first, then open booking flow.
      // This avoids popping the newly opened sheet by mistake.
      if (!_isCancel) {
        if (mounted) {
          Navigator.of(context).pop();
        }
        await widget.onConfirm(applyFee);
        return;
      }

      await widget.onConfirm(applyFee);
      if (!mounted) return;
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
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
              color: _isBlocked
                  ? AppColors.statusCancelled
                  : AppColors.textSecondary,
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
                          'Taxa ($_formattedFeePercent): $_formattedFeeAmount',
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
                  onPressed: _isSubmitting
                      ? null
                      : () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: AppButton(
                  label: 'Confirmar',
                  variant: _isCancel
                      ? AppButtonVariant.danger
                      : AppButtonVariant.primary,
                  fullWidth: true,
                  small: true,
                  isLoading: _isSubmitting,
                  onPressed: (_isSubmitting || _isBlocked) ? null : _submit,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
