import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
export 'package:syncfusion_flutter_datepicker/datepicker.dart' show DateRangePickerSelectionMode, PickerDateRange, DateRangePickerSelectionChangedArgs;
import '../core/theme/app_colors.dart';

class AppDatePicker extends StatelessWidget {
  final DateRangePickerSelectionMode selectionMode;
  final DateTime? initialSelectedDate;
  final PickerDateRange? initialSelectedRange;
  final DateTime? minDate;
  final DateTime? maxDate;
  final void Function(DateRangePickerSelectionChangedArgs)? onSelectionChanged;

  const AppDatePicker({
    super.key,
    this.selectionMode = DateRangePickerSelectionMode.single,
    this.initialSelectedDate,
    this.initialSelectedRange,
    this.minDate,
    this.maxDate,
    this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 340,
      color: AppColors.surface,
      child: SfDateRangePicker(
        selectionMode: selectionMode,
        initialSelectedDate: initialSelectedDate,
        initialSelectedRange: initialSelectedRange,
        minDate: minDate,
        maxDate: maxDate,
        backgroundColor: AppColors.surface,
        headerHeight: 50,
        headerStyle: const DateRangePickerHeaderStyle(
          backgroundColor: AppColors.surface,
          textAlign: TextAlign.left,
          textStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        monthViewSettings: const DateRangePickerMonthViewSettings(
          dayFormat: 'E',
          viewHeaderHeight: 40,
          viewHeaderStyle: DateRangePickerViewHeaderStyle(
            textStyle: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        monthCellStyle: const DateRangePickerMonthCellStyle(
          textStyle: TextStyle(color: AppColors.textPrimary, fontSize: 14),
          disabledDatesTextStyle: TextStyle(color: AppColors.textTertiary, fontSize: 14),
          todayTextStyle: TextStyle(color: AppColors.brandPrimary, fontWeight: FontWeight.bold),
        ),
        yearCellStyle: const DateRangePickerYearCellStyle(
          textStyle: TextStyle(color: AppColors.textPrimary),
          disabledDatesTextStyle: TextStyle(color: AppColors.textTertiary),
        ),
        selectionTextStyle: const TextStyle(color: AppColors.surface, fontWeight: FontWeight.bold),
        rangeTextStyle: const TextStyle(color: AppColors.textPrimary),
        rangeSelectionColor: AppColors.brandLight, // Light gray for the range
        startRangeSelectionColor: AppColors.brandPrimary, // Black circle for start
        endRangeSelectionColor: AppColors.brandPrimary,   // Black circle for end
        todayHighlightColor: AppColors.brandPrimary,
        selectionColor: AppColors.brandPrimary,
        selectionShape: DateRangePickerSelectionShape.circle,
        onSelectionChanged: onSelectionChanged,
      ),
    );
  }
}
