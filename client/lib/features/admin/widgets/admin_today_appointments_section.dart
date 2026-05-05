import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/widgets/app_badge.dart';
import 'package:app/widgets/app_empty_state.dart';
import 'package:app/widgets/appointment_card.dart';
import 'package:app/widgets/section_header.dart';
import '../providers/admin_providers.dart';
import '../services/admin_appointments_service.dart';

class AdminTodayAppointmentsSection extends ConsumerWidget {
  final Function(AdminAppointmentModel) onCancelAppointment;

  const AdminTodayAppointmentsSection({
    super.key,
    required this.onCancelAppointment,
  });

  String _formatTodayBadge(DateTime date) =>
      'Hoje, ${DateFormat("dd 'de' MMMM", 'pt_BR').format(date)}';

  String _formatCardDate(DateTime date) =>
      DateFormat('dd MMM', 'pt_BR').format(date);

  String _formatHour(DateTime date) =>
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayAppointmentsAsync = ref.watch(adminTodayAppointmentsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Hoje',
          trailing: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.muted,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
          child: AppBadge(
            label: _formatTodayBadge(DateTime.now()),
            variant: BadgeVariant.confirmed,
          ),
        ),
        const SizedBox(height: AppTheme.spacingMd),
        todayAppointmentsAsync.when(
          data: (todayAppointments) {
            if (todayAppointments.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
                child: AppEmptyState(
                  message: 'Nenhum agendamento para hoje.',
                  icon: Icons.event_available,
                ),
              );
            }

            return Column(
              children: List.generate(todayAppointments.length, (i) {
                final appointment = todayAppointments[i];
                return Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppTheme.spacingLg,
                    0,
                    AppTheme.spacingLg,
                    i < todayAppointments.length - 1 ? AppTheme.spacingSm : 0,
                  ),
                  child: AppointmentCard(
                    service:
                        '${appointment.clientName} • ${appointment.serviceName}',
                    subtitle: _statusLabel(_statusToBadge(appointment.status)),
                    date: _formatCardDate(appointment.startTime),
                    time: _formatHour(appointment.startTime),
                    status: _statusToBadge(appointment.status),
                    variant: AppointmentCardVariant.full,
                    onCancelPressed: () => onCancelAppointment(appointment),
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
              message: 'Não foi possível carregar os agendamentos de hoje.',
              icon: Icons.event_busy,
            ),
          ),
        ),
      ],
    );
  }
}
