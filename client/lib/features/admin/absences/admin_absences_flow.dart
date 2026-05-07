import 'package:flutter/material.dart';
import 'package:app/widgets/app_date_picker.dart';
import '../../../widgets/app_bottom_sheet.dart';
import 'sheets/absences_list_sheet.dart';
import 'sheets/create_absence_sheet.dart';
import 'sheets/date_range_sheet.dart';
import 'sheets/time_range_sheet.dart';

class AdminAbsencesFlow {
  static void start(BuildContext context, {VoidCallback? onBack}) {
    showAppBottomSheet(
      context: context,
      title: 'Ausências / Férias',
      height: BottomSheetHeight.flexible,
      onBack: onBack ?? () => Navigator.of(context, rootNavigator: true).pop(),
      child: AbsencesListSheet(
        onCreateTap: (_) {
          Navigator.of(context, rootNavigator: true).pop();
          _showCreateSheet(
            context,
            isSingleDay: true,
            onBack: onBack,
          );
        },
      ),
    );
  }

  static void _showCreateSheet(
    BuildContext context, {
    DateTime? startDate,
    DateTime? endDate,
    required bool isSingleDay,
    VoidCallback? onBack,
  }) {
    showAppBottomSheet(
      context: context,
      title: 'Registrar Ausência',
      height: BottomSheetHeight.flexible,
      onBack: () {
        Navigator.of(context, rootNavigator: true).pop();
        start(context, onBack: onBack);
      },
      child: CreateAbsenceSheet(
        initialStartDate: startDate,
        initialEndDate: endDate,
        initialIsSingleDay: isSingleDay,
        onSaved: (_) {
          Navigator.of(context, rootNavigator: true).pop();
        },

        onPickDate:
            (ctx, isStart, currentStart, currentEnd, currentIsSingleDay) async {
              Navigator.of(ctx, rootNavigator: true).pop(); // Close CreateAbsenceSheet

              if (currentIsSingleDay) {
                _showDatePicker(
                  context, // use original root context
                  isStart: isStart,
                  startDate: currentStart,
                  endDate: currentEnd,
                  isSingleDay: currentIsSingleDay,
                  onBack: onBack,
                );
              } else {
                _showDateRangePickerSheet(
                  context,
                  currentStart: currentStart,
                  currentEnd: currentEnd,
                  isSingleDay: currentIsSingleDay,
                  onBack: onBack,
                );
              }
            },
      ),
    );
  }

  static void _showDateRangePickerSheet(
    BuildContext context, {
    DateTime? currentStart,
    DateTime? currentEnd,
    required bool isSingleDay,
    VoidCallback? onBack,
  }) {
    showAppBottomSheet(
      context: context,
      title: 'Período de Ausência',
      height: BottomSheetHeight.flexible,
      onBack: () {
        Navigator.of(context, rootNavigator: true).pop();
        _showCreateSheet(
          context,
          startDate: currentStart,
          endDate: currentEnd,
          isSingleDay: isSingleDay,
          onBack: onBack,
        );
      },
      child: DateRangeSheet(
        initialStartDate: currentStart,
        initialEndDate: currentEnd,
        onConfirmed: (start, end) {
          Navigator.of(context, rootNavigator: true).pop();
          _showCreateSheet(
            context,
            startDate: start,
            endDate: end,
            isSingleDay: isSingleDay,
            onBack: onBack,
          );
        },
      ),
    );
  }

  static void _showDatePicker(
    BuildContext context, {
    required bool isStart,
    DateTime? startDate,
    DateTime? endDate,
    required bool isSingleDay,
    VoidCallback? onBack,
  }) {
    final initial = isStart
        ? (startDate ?? DateTime.now())
        : (endDate ?? startDate ?? DateTime.now());
    final first = isStart ? DateTime.now() : (startDate ?? DateTime.now());

    showAppBottomSheet(
      context: context,
      title: isStart
          ? (isSingleDay ? 'Data da Ausência' : 'Data Inicial')
          : 'Data Final',
      height: BottomSheetHeight.flexible,
      onBack: () {
        Navigator.of(context, rootNavigator: true).pop();
        _showCreateSheet(
          context,
          startDate: startDate,
          endDate: endDate,
          isSingleDay: isSingleDay,
          onBack: onBack,
        );
      },
      child: Column(
        children: [
          AppDatePicker(
            initialSelectedDate: initial,
            minDate: first,
            maxDate: DateTime.now().add(const Duration(days: 365 * 2)),
            selectionMode: DateRangePickerSelectionMode.single,
            onSelectionChanged: (args) {
              if (args.value is DateTime) {
                final picked = args.value as DateTime;
                Navigator.of(context, rootNavigator: true).pop(); // Close date picker
                Future.microtask(() {
                  if (!context.mounted) {
                    return;
                  }
                  if (isSingleDay) {
                    _showTimeRange(
                      context,
                      date: picked,
                      startDate: startDate,
                      endDate: endDate,
                      isSingleDay: isSingleDay,
                      onBack: onBack,
                    );
                  } else {
                    DateTime? newStart = startDate;
                    DateTime? newEnd = endDate;
                    if (isStart) {
                      newStart = picked;
                      if (newEnd != null && newEnd.isBefore(picked)) {
                        newEnd = null;
                      }
                    } else {
                      newEnd = picked;
                    }
                    _showCreateSheet(
                      context,
                      startDate: newStart,
                      endDate: newEnd,
                      isSingleDay: isSingleDay,
                      onBack: onBack,
                    );
                  }
                });
              }
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  static void _showTimeRange(
    BuildContext context, {
    required DateTime date,
    DateTime? startDate,
    DateTime? endDate,
    required bool isSingleDay,
    VoidCallback? onBack,
  }) {
    showAppBottomSheet(
      context: context,
      title: 'Período',
      height: BottomSheetHeight.flexible,
      onBack: () {
        Navigator.of(context, rootNavigator: true).pop();
        _showDatePicker(
          context,
          isStart: true,
          startDate: startDate,
          endDate: endDate,
          isSingleDay: isSingleDay,
          onBack: onBack,
        );
      },
      child: TimeRangeSheet(
        date: date,
        initialStartMinutes: startDate != null
            ? startDate.hour * 60 + startDate.minute
            : 480,
        initialEndMinutes: endDate != null
            ? endDate.hour * 60 + endDate.minute
            : 1140,
        onConfirmed: (start, end) {
          Navigator.of(context, rootNavigator: true).pop();
          _showCreateSheet(
            context,
            startDate: start,
            endDate: end,
            isSingleDay: isSingleDay,
            onBack: onBack,
          );
        },
      ),
    );
  }
}
