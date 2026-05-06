import 'package:flutter/material.dart';
import 'package:app/core/extensions/date_time_extensions.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/widgets/app_badge.dart';
import 'package:app/widgets/app_bottom_sheet.dart';
import 'package:app/widgets/app_date_picker.dart';
import 'package:app/widgets/app_empty_state.dart';
import 'package:app/widgets/appointment_card.dart';
import '../services/admin_appointments_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_providers.dart';

void showFutureAppointmentsDatePickerSheet({
  required BuildContext context,
  required AdminAppointmentsService appointmentsService,
  required Function(AdminAppointmentModel) onCancelAppointment,
  required Function(AdminAppointmentModel) onRescheduleAppointment,
}) {
  showAppBottomSheet(
    context: context,
    title: 'Agendamentos',
    height: BottomSheetHeight.flexible,
    child: Column(
      children: [
        const Text(
          'Selecione uma data para visualizar os agendamentos.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppTheme.spacingMd),
        AppDatePicker(
          selectionMode: DateRangePickerSelectionMode.single,
          onSelectionChanged: (args) {
            if (args.value is DateTime) {
              final selectedDate = args.value as DateTime;
              Navigator.pop(context);
              Future.delayed(const Duration(milliseconds: 100), () {
                if (context.mounted) {
                  showAppointmentsForDateSheet(
                    context: context,
                    date: selectedDate,
                    onCancelAppointment: onCancelAppointment,
                    onRescheduleAppointment: onRescheduleAppointment,
                    onBack: () => showFutureAppointmentsDatePickerSheet(
                      context: context,
                      appointmentsService: appointmentsService,
                      onCancelAppointment: onCancelAppointment,
                      onRescheduleAppointment: onRescheduleAppointment,
                    ),
                  );
                }
              });
            }
          },
        ),
      ],
    ),
  );
}

void showAppointmentsForDateSheet({
  required BuildContext context,
  required DateTime date,
  required Function(AdminAppointmentModel) onCancelAppointment,
  required Function(AdminAppointmentModel) onRescheduleAppointment,
  VoidCallback? onBack,
}) {
  showAppBottomSheet(
    context: context,
    title: 'Agenda: ${_formatDate(date)}',
    height: BottomSheetHeight.flexible,
    onBack: () {
      Navigator.pop(context);
      Future.delayed(const Duration(milliseconds: 100), () {
        if (context.mounted && onBack != null) {
          onBack();
        }
      });
    },
    child: _AdminDateAppointmentsContent(
      date: date,
      onCancelAppointment: onCancelAppointment,
      onRescheduleAppointment: onRescheduleAppointment,
    ),
  );
}

class _AdminDateAppointmentsContent extends ConsumerWidget {
  final DateTime date;
  final Function(AdminAppointmentModel) onCancelAppointment;
  final Function(AdminAppointmentModel) onRescheduleAppointment;

  const _AdminDateAppointmentsContent({
    required this.date,
    required this.onCancelAppointment,
    required this.onRescheduleAppointment,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsAsync = ref.watch(adminDateAppointmentsProvider(date));

    return appointmentsAsync.when(
      data: (appointments) {
        if (appointments.isEmpty) {
          return const AppEmptyState(
            message: 'Nenhum agendamento para a data selecionada.',
          );
        }

        return Column(
          children: [
            AppBadge(
              label: '${appointments.length} Agendamentos',
              variant: BadgeVariant.pending,
            ),
            const SizedBox(height: AppTheme.spacingLg),
            ...appointments.map(
              (a) {
                final isPastStartTime = _isPastStartTime(a.startTime);
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
                  child: AppointmentCard(
                    service: '${a.clientName} • ${a.serviceName}',
                    subtitle: _statusLabel(_statusToBadge(a.status)),
                    date: _formatCardDate(a.startTime),
                    time: _formatHour(a.startTime),
                    status: _statusToBadge(a.status),
                    variant: AppointmentCardVariant.full,
                    onReschedulePressed: isPastStartTime
                        ? null
                        : () => onRescheduleAppointment(a),
                    onCancelPressed: () {
                      onCancelAppointment(a);
                      // No need to manually refresh here, the consumer of the callback 
                      // (AdminDashboardPage) should call ref.refresh or similar if needed.
                      // Actually, if we want to refresh THIS specific date, we can do it here too:
                      // ref.read(adminDateAppointmentsProvider(date).notifier).refresh(date);
                    },
                  ),
                );
              },
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) {
        final message = error.toString().replaceAll('Exception: ', '');
        return AppEmptyState(message: message);
      },
    );
  }
  bool _isPastStartTime(DateTime startTime) {
    return startTime.localDateTime.isBefore(DateTime.now());
  }
}


String _formatDate(DateTime date) {
  return date.formatLocal('dd/MM/yyyy');
}

String _formatHour(DateTime date) {
  return date.displayTime;
}

String _formatCardDate(DateTime date) =>
    date.displayDateShort;

String _statusLabel(BadgeVariant status) {
  switch (status) {
    case BadgeVariant.confirmed:
      return 'Confirmado';
    case BadgeVariant.cancelled:
      return 'Cancelado';
    case BadgeVariant.pending:
      return 'Pendente';
  }
}

BadgeVariant _statusToBadge(String status) {
  final normalized = status.toLowerCase();
  if (normalized == 'scheduled' || normalized == 'rescheduled') {
    return BadgeVariant.confirmed;
  }
  return BadgeVariant.pending;
}
