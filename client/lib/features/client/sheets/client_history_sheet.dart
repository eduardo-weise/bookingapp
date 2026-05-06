import 'package:app/features/client/providers/client_providers.dart';
import 'package:app/core/extensions/date_time_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_text_styles.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/widgets/app_badge.dart';
import 'package:app/widgets/app_bottom_sheet.dart';
import 'package:app/widgets/app_card.dart';
import 'package:app/widgets/app_empty_state.dart';

void showClientHistorySheet({required BuildContext context}) {
  String formatHistoryDateTime(DateTime value) =>
  value.formatLocal("dd 'de' MMMM, HH:mm");

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

  showAppBottomSheet(
    context: context,
    title: 'Histórico',
    height: BottomSheetHeight.flexible,
    child: _ClientHistorySheetContent(
      formatHistoryDateTime: formatHistoryDateTime,
      statusLabel: statusLabel,
      statusVariant: statusVariant,
    ),
  );
}

class _ClientHistorySheetContent extends ConsumerWidget {
  final String Function(DateTime) formatHistoryDateTime;
  final String Function(String) statusLabel;
  final BadgeVariant Function(String) statusVariant;

  const _ClientHistorySheetContent({
    required this.formatHistoryDateTime,
    required this.statusLabel,
    required this.statusVariant,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(clientAppointmentsProvider);

    return historyAsync.when(
      data: (appointments) {
        if (appointments.isEmpty) {
          return const AppEmptyState(
            message: 'Nenhum agendamento no histórico',
            icon: Icons.history,
          );
        }

        return Column(
          children: appointments.map((appointment) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
              child: AppCard(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment.serviceName,
                            style: AppTextStyles.heading3,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            formatHistoryDateTime(appointment.startTime),
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppBadge(
                      label: statusLabel(appointment.status),
                      variant: statusVariant(appointment.status),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppTheme.spacingXl),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppTheme.spacingXl),
        child: AppEmptyState(
          message: 'Não foi possível carregar o histórico.',
          icon: Icons.history_toggle_off,
        ),
      ),
    );
  }
}
