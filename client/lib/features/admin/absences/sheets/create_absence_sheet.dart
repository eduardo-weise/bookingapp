import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_text_styles.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/widgets/app_button.dart';
import 'package:app/widgets/app_snackbar.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/absence_providers.dart';

class CreateAbsenceSheet extends ConsumerStatefulWidget {
  final VoidCallback onSaved;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final bool initialIsSingleDay;
  final void Function(
    BuildContext context,
    bool isStart,
    DateTime? currentStart,
    DateTime? currentEnd,
    bool isSingleDay,
  )
  onPickDate;

  const CreateAbsenceSheet({
    super.key,
    required this.onSaved,
    this.initialStartDate,
    this.initialEndDate,
    this.initialIsSingleDay = true,
    required this.onPickDate,
  });

  @override
  ConsumerState<CreateAbsenceSheet> createState() => _CreateAbsenceSheetState();
}

class _CreateAbsenceSheetState extends ConsumerState<CreateAbsenceSheet> {
  DateTime? _startDate;
  DateTime? _endDate;
  late bool _isSingleDay;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
    _isSingleDay = widget.initialIsSingleDay;
  }

  void _pickDate({required bool isStart}) {
    widget.onPickDate(context, isStart, _startDate, _endDate, _isSingleDay);
  }

  Future<void> _save() async {
    if (_startDate == null) return;
    final end = _isSingleDay
        ? (_endDate ?? _startDate!)
        : (_endDate ?? _startDate!);

    setState(() => _isSaving = true);
    try {
      await ref.read(absenceServiceProvider).createAbsence(startDate: _startDate!, endDate: end);
      if (!mounted) return;
      
      ref.read(futureAbsencesProvider.notifier).refresh();
      
      widget.onSaved();
      AppSnackBar.showSuccess(context, 'Ausência registrada com sucesso!');
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(
          context,
          e.toString().replaceAll('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }


  String _formatDateString(DateTime date, {bool includeYear = false}) {
    if (includeYear) {
      final format = DateFormat("EEE, d 'de' MMM 'de' yyyy", 'pt_BR');
      String formatted = format.format(date).toLowerCase();
      if (!formatted.contains('.')) {
        formatted = formatted.replaceFirst(',', '.,'); // seg, -> seg.,
      }
      return formatted;
    }
    final format = DateFormat("EEE, d 'de' MMM", 'pt_BR');
    String formatted = format.format(date).toLowerCase();
    if (!formatted.contains('.')) {
      formatted = formatted.replaceFirst(',', '.,'); // seg, -> seg.,
      formatted = '$formatted.'; // de set -> de set.
    }
    return formatted;
  }

  String _formatSingleDayDate(DateTime date) {
    final weekday = DateFormat('EEE', 'pt_BR').format(date).substring(0, 3);
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$weekday, $day/$month/$year';
  }

  String get _displayValue {
    if (_startDate == null) return 'Selecionar';
    final d1 = _isSingleDay
        ? _formatSingleDayDate(_startDate!)
        : _formatDateString(_startDate!);

    if (_isSingleDay) {
      if (_endDate == null) return d1;
      final sh = _startDate!.hour.toString().padLeft(2, '0');
      final sm = _startDate!.minute.toString().padLeft(2, '0');
      final eh = _endDate!.hour.toString().padLeft(2, '0');
      final em = _endDate!.minute.toString().padLeft(2, '0');
      return '$d1 ($sh:$sm - $eh:$em)';
    } else {
      if (_endDate == null) return d1;
      // Include year in end date to show period context
      final d2 = _formatDateString(_endDate!, includeYear: true);
      return '$d1 — $d2';
    }
  }

  Widget _datePicker({required String label, required VoidCallback onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: AppTheme.spacingSm),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _displayValue,
                  style: AppTextStyles.body.copyWith(
                    color: _startDate != null
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
                const Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _setSingleDay(bool isSingleDay) {
    setState(() {
      _isSingleDay = isSingleDay;
      _startDate = null;
      _endDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final canSave =
        _startDate != null &&
        (_isSingleDay ? _endDate != null : _endDate != null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Type toggle
        Text('Tipo de Ausência', style: AppTextStyles.label),
        const SizedBox(height: AppTheme.spacingSm),
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Dia Único',
                variant: _isSingleDay
                    ? AppButtonVariant.primary
                    : AppButtonVariant.secondary,
                onPressed: () => _setSingleDay(true),
              ),
            ),
            const SizedBox(width: AppTheme.spacingSm),
            Expanded(
              child: AppButton(
                label: 'Período',
                variant: !_isSingleDay
                    ? AppButtonVariant.primary
                    : AppButtonVariant.secondary,
                onPressed: () => _setSingleDay(false),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingLg),

        _datePicker(
          label: _isSingleDay ? 'Data' : 'Período de Ausência',
          onTap: () => _pickDate(isStart: true),
        ),

        const SizedBox(height: AppTheme.spacingXl),
        AppButton(
          label: 'Salvar Ausência',
          fullWidth: true,
          isLoading: _isSaving,
          onPressed: canSave && !_isSaving ? _save : null,
        ),
        const SizedBox(height: AppTheme.spacingMd),
      ],
    );
  }
}
