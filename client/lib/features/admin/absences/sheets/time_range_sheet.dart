import 'package:flutter/material.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_text_styles.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/widgets/app_button.dart';

class TimeRangeSheet extends StatefulWidget {
  final DateTime date;
  final int initialStartMinutes;
  final int initialEndMinutes;
  final void Function(DateTime start, DateTime end) onConfirmed;

  const TimeRangeSheet({
    super.key,
    required this.date,
    required this.initialStartMinutes,
    required this.initialEndMinutes,
    required this.onConfirmed,
  });

  @override
  State<TimeRangeSheet> createState() => _TimeRangeSheetState();
}

class _TimeRangeSheetState extends State<TimeRangeSheet> {
  late RangeValues _currentRange;

  @override
  void initState() {
    super.initState();
    _currentRange = RangeValues(
      widget.initialStartMinutes.toDouble(),
      widget.initialEndMinutes.toDouble(),
    );
  }

  String _formatTime(double totalMinutes) {
    final int hours = totalMinutes ~/ 60;
    final int minutes = (totalMinutes % 60).toInt();
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selecione o período de ausência',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppTheme.spacingXl),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Início: ${_formatTime(_currentRange.start)}', style: AppTextStyles.body),
            Text('Fim: ${_formatTime(_currentRange.end)}', style: AppTextStyles.body),
          ],
        ),
        const SizedBox(height: AppTheme.spacingMd),
        RangeSlider(
          values: _currentRange,
          min: 0,
          max: 1440,
          divisions: 1440 ~/ 5,
          activeColor: AppColors.brandPrimary,
          inactiveColor: AppColors.border,
          onChanged: (values) {
            setState(() {
              _currentRange = values;
            });
          },
        ),
        const SizedBox(height: AppTheme.spacingXl),
        AppButton(
          label: 'Confirmar Período',
          fullWidth: true,
          onPressed: () {
            final startMins = _currentRange.start.toInt();
            final endMins = _currentRange.end.toInt();
            final d = widget.date;
            final start = DateTime(d.year, d.month, d.day, startMins ~/ 60, startMins % 60);
            final end = DateTime(d.year, d.month, d.day, endMins ~/ 60, endMins % 60);
            widget.onConfirmed(start, end);
          },
        ),
        const SizedBox(height: AppTheme.spacingMd),
      ],
    );
  }
}
