import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/core/extensions/date_time_extensions.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/client/providers/client_providers.dart';
import 'package:app/features/client/services/client_appointments_service.dart';
import 'package:app/widgets/app_badge.dart';
import 'package:app/widgets/app_empty_state.dart';
import 'package:app/widgets/appointment_card.dart';
import 'package:app/widgets/section_header.dart';

class ClientUpcomingAppointmentsSection extends ConsumerWidget {
  final Future<void> Function(ClientAppointmentModel appointment) onCancelTap;
  final Future<void> Function(ClientAppointmentModel appointment)
  onRescheduleTap;

  const ClientUpcomingAppointmentsSection({
    super.key,
    required this.onCancelTap,
    required this.onRescheduleTap,
  });

  String formatCardDate(DateTime value) =>
      value.displayDateShort;

  String formatCardTime(DateTime value) =>
      value.displayTime;

  BadgeVariant statusVariant(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
      case 'rescheduled':
      case 'completed':
        return BadgeVariant.confirmed;
      case 'canceled':
        return BadgeVariant.cancelled;
      default:
        return BadgeVariant.pending;
    }
  }

  String statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return 'Confirmado';
      case 'rescheduled':
        return 'Reagendado';
      case 'canceled':
        return 'Cancelado';
      case 'completed':
        return 'Concluído';
      case 'noshow':
        return 'No-show';
      default:
        return 'Pendente';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsAsync = ref.watch(clientAppointmentsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Próximos Agendamentos'),
        const SizedBox(height: AppTheme.spacingMd),
        appointmentsAsync.when(
          data: (appointments) {
            final upcomingAppointments = appointments.toList()
              ..sort(
                (left, right) => left.startTime.compareTo(right.startTime),
              );

            if (upcomingAppointments.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
                child: AppEmptyState(
                  message: 'Nenhum agendamento futuro encontrado',
                  icon: Icons.event_busy,
                ),
              );
            }

            return Column(
              children: List.generate(upcomingAppointments.length, (i) {
                final appointment = upcomingAppointments[i];
                final now = DateTime.now().toUtc();
                final isWithin1Hour = appointment.startTime.toUtc().isBefore(
                  now.add(const Duration(hours: 1)),
                );

                return Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppTheme.spacingLg,
                    0,
                    AppTheme.spacingLg,
                    i < upcomingAppointments.length - 1
                        ? AppTheme.spacingMd
                        : 0,
                  ),
                  child: AppointmentCard(
                    service: appointment.serviceName,
                    subtitle: statusLabel(appointment.status),
                    date: formatCardDate(appointment.startTime),
                    time: formatCardTime(appointment.startTime),
                    status: statusVariant(appointment.status),
                    variant: AppointmentCardVariant.full,
                    onReschedulePressed: isWithin1Hour
                        ? null
                        : () => onRescheduleTap(appointment),
                    onCancelPressed: () => onCancelTap(appointment),
                  ),
                );
              }),
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: AppTheme.spacingXl),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stackTrace) => const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
            child: AppEmptyState(
              message: 'Não foi possível carregar os agendamentos.',
              icon: Icons.event_busy,
            ),
          ),
        ),
      ],
    );
  }
}
