import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/widgets/app_button.dart';
import 'package:app/widgets/app_date_picker.dart';

class DateRangeSheet extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final void Function(DateTime start, DateTime end) onConfirmed;

  const DateRangeSheet({
    super.key,
    this.initialStartDate,
    this.initialEndDate,
    required this.onConfirmed,
  });

  @override
  State<DateRangeSheet> createState() => _DateRangeSheetState();
}

class _DateRangeSheetState extends State<DateRangeSheet> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    if (args.value is PickerDateRange) {
      setState(() {
        _startDate = args.value.startDate;
        _endDate = args.value.endDate ?? args.value.startDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSave = _startDate != null && _endDate != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppDatePicker(
          selectionMode: DateRangePickerSelectionMode.range,
          initialSelectedRange: PickerDateRange(
            widget.initialStartDate,
            widget.initialEndDate,
          ),
          minDate: DateTime.now(),
          maxDate: DateTime.now().add(const Duration(days: 365 * 2)),
          onSelectionChanged: _onSelectionChanged,
        ),
        const SizedBox(height: AppTheme.spacingXl),
        AppButton(
          label: 'Confirmar Período',
          fullWidth: true,
          onPressed: canSave
              ? () => widget.onConfirmed(_startDate!, _endDate!)
              : null,
        ),
        const SizedBox(height: AppTheme.spacingMd),
      ],
    );
  }
}
