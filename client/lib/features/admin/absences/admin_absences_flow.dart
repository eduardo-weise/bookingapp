import 'package:flutter/material.dart';
import 'package:app/widgets/app_date_picker.dart';
import '../../../widgets/app_bottom_sheet.dart';
import 'services/absence_service.dart';
import 'sheets/absences_list_sheet.dart';
import 'sheets/create_absence_sheet.dart';
import 'sheets/date_range_sheet.dart';
import 'sheets/time_range_sheet.dart';

class AdminAbsencesFlow {
  static final _service = AbsenceService();

  static void start(BuildContext context) {
    showAppBottomSheet(
      context: context,
      title: 'Ausências / Férias',
      height: BottomSheetHeight.flexible,
      onBack: () => Navigator.of(context).pop(),
      child: AbsencesListSheet(
        service: _service,
        onCreateTap: (ctx) {
          Navigator.of(ctx).pop();
          _showCreateSheet(context, isSingleDay: true);
        },
      ),
    );
  }

  static void _showCreateSheet(
    BuildContext context, {
    DateTime? startDate,
    DateTime? endDate,
    required bool isSingleDay,
  }) {
    showAppBottomSheet(
      context: context,
      title: 'Registrar Ausência',
      height: BottomSheetHeight.flexible,
      onBack: () {
        Navigator.of(context).pop();
        start(context);
      },
      child: CreateAbsenceSheet(
        service: _service,
        initialStartDate: startDate,
        initialEndDate: endDate,
        initialIsSingleDay: isSingleDay,
        onSaved: () {
          Navigator.of(context).pop();
          start(context);
        },
        onPickDate:
            (ctx, isStart, currentStart, currentEnd, currentIsSingleDay) async {
              Navigator.of(ctx).pop(); // Close CreateAbsenceSheet

              if (currentIsSingleDay) {
                _showDatePicker(
                  context, // use original root context
                  isStart: isStart,
                  startDate: currentStart,
                  endDate: currentEnd,
                  isSingleDay: currentIsSingleDay,
                );
              } else {
                _showDateRangePickerSheet(
                  context,
                  currentStart: currentStart,
                  currentEnd: currentEnd,
                  isSingleDay: currentIsSingleDay,
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
  }) {
    showAppBottomSheet(
      context: context,
      title: 'Período de Ausência',
      height: BottomSheetHeight.flexible,
      onBack: () {
        Navigator.of(context).pop();
        _showCreateSheet(
          context,
          startDate: currentStart,
          endDate: currentEnd,
          isSingleDay: isSingleDay,
        );
      },
      child: DateRangeSheet(
        initialStartDate: currentStart,
        initialEndDate: currentEnd,
        onConfirmed: (start, end) {
          Navigator.of(context).pop();
          _showCreateSheet(
            context,
            startDate: start,
            endDate: end,
            isSingleDay: isSingleDay,
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
        Navigator.of(context).pop();
        _showCreateSheet(
          context,
          startDate: startDate,
          endDate: endDate,
          isSingleDay: isSingleDay,
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
                Navigator.of(context).pop(); // Close date picker
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
  }) {
    showAppBottomSheet(
      context: context,
      title: 'Período',
      height: BottomSheetHeight.flexible,
      onBack: () {
        Navigator.of(context).pop();
        _showDatePicker(
          context,
          isStart: true,
          startDate: startDate,
          endDate: endDate,
          isSingleDay: isSingleDay,
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
          Navigator.of(context).pop();
          _showCreateSheet(
            context,
            startDate: start,
            endDate: end,
            isSingleDay: isSingleDay,
          );
        },
      ),
    );
  }
}
