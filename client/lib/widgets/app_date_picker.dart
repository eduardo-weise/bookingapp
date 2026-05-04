import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
export 'package:syncfusion_flutter_datepicker/datepicker.dart' show DateRangePickerSelectionMode, PickerDateRange, DateRangePickerSelectionChangedArgs, DateRangePickerViewChangedArgs;
import '../core/theme/app_colors.dart';

class AppDatePicker extends StatelessWidget {
  final DateRangePickerSelectionMode selectionMode;
  final DateTime? initialSelectedDate;
  final DateTime? initialDisplayDate;
  final PickerDateRange? initialSelectedRange;
  final DateTime? minDate;
  final DateTime? maxDate;
  final List<DateTime>? blackoutDates;
  final void Function(DateRangePickerSelectionChangedArgs)? onSelectionChanged;
  final void Function(DateRangePickerViewChangedArgs)? onViewChanged;
  final bool Function(DateTime date)? selectableDayPredicate;

  const AppDatePicker({
    super.key,
    this.selectionMode = DateRangePickerSelectionMode.single,
    this.initialSelectedDate,
    this.initialDisplayDate,
    this.initialSelectedRange,
    this.minDate,
    this.maxDate,
    this.blackoutDates,
    this.onSelectionChanged,
    this.onViewChanged,
    this.selectableDayPredicate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 340,
      color: AppColors.surface,
      child: SfDateRangePicker(
        selectionMode: selectionMode,
        initialSelectedDate: initialSelectedDate,
        initialDisplayDate: initialDisplayDate ?? initialSelectedDate,
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
        monthViewSettings: DateRangePickerMonthViewSettings(
          dayFormat: 'E',
          viewHeaderHeight: 40,
          blackoutDates: blackoutDates,
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
          blackoutDateTextStyle: TextStyle(
            color: AppColors.statusCancelled,
            fontSize: 14,
            decoration: TextDecoration.lineThrough,
            decorationColor: AppColors.statusCancelled,
          ),
          blackoutDatesDecoration: BoxDecoration(
            color: AppColors.cancelledBg,
            shape: BoxShape.circle,
          ),
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
        onViewChanged: onViewChanged,
        selectableDayPredicate: selectableDayPredicate,
      ),
    );
  }
}
