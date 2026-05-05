import 'package:flutter/material.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/widgets/app_avatar.dart';
import 'package:app/widgets/booking_form.dart';
import 'package:app/widgets/page_header.dart';
import 'package:app/widgets/app_snackbar.dart';
import 'package:app/widgets/cancel_appointment_sheet.dart';
import 'services/admin_appointments_service.dart';
import 'services/admin_debts_service.dart';

import 'widgets/admin_stats_section.dart';
import 'widgets/admin_pending_debts_section.dart';
import 'widgets/admin_today_appointments_section.dart';
import 'sheets/admin_debt_detail_sheet.dart';
import 'sheets/admin_all_debts_sheet.dart';
import 'sheets/admin_agenda_sheets.dart';
import 'sheets/admin_profile_sheet.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/admin_providers.dart';
import '../client/providers/client_providers.dart';

// ── Admin Dashboard ──────────────────────────────────────────────────────────
class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  // ── Profile / Edit Sheet ──
  void _showEditProfileSheet(BuildContext context) {
    showAdminProfileSheet(context);
  }

  Future<void> _cancelDebts(BuildContext context, WidgetRef ref, String clientId, List<String> debtIds) async {
    try {
      await ref.read(adminDebtsServiceProvider).cancelDebts(clientId: clientId, debtIds: debtIds);
      if (context.mounted) {
        Navigator.pop(context); // Close the detail sheet if open
        ref.read(adminPendingDebtsProvider.notifier).refresh();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro: ${e.toString().replaceAll('Exception: ', '')}',
            ),
          ),
        );
      }
    }
  }

  Future<void> _payDebts(BuildContext context, WidgetRef ref, String clientId, List<String> debtIds) async {
    try {
      await ref.read(adminDebtsServiceProvider).payDebts(clientId: clientId, debtIds: debtIds);
      if (context.mounted) {
        Navigator.pop(context); // Close the detail sheet if open
        ref.read(adminPendingDebtsProvider.notifier).refresh();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro: ${e.toString().replaceAll('Exception: ', '')}',
            ),
          ),
        );
      }
    }
  }

  void _showDebtDetail(BuildContext context, WidgetRef ref, AdminClientDebtSummary summary) {
    showAdminDebtDetailSheet(
      context: context,
      summary: summary,
      onPayDebts: (clientId, debtIds) => _payDebts(context, ref, clientId, debtIds),
      onCancelDebts: (clientId, debtIds) => _cancelDebts(context, ref, clientId, debtIds),
    );
  }

  void _showAllDebtsSheet(BuildContext context, WidgetRef ref) {
    showAdminAllDebtsSheet(
      context: context,
      onDebtSelected: (summary) => _showDebtDetail(context, ref, summary),
    );
  }

  void _showBookingSheet(BuildContext context, WidgetRef ref) {
    BookingFlow.start(
      context,
      onBookingConfirmed: () => ref.read(adminTodayAppointmentsProvider.notifier).refresh(),
      loadTargetClients: () async {
        final clients = await ref.read(adminClientsServiceProvider).getClients();
        return clients
            .map(
              (client) => BookingTargetClient(
                id: client.id,
                displayName: client.displayName,
                subtitle: client.email == client.displayName
                    ? null
                    : client.email,
              ),
            )
            .toList();
      },
    );
  }

  Future<void> _showCancelAppointmentSheet(
    BuildContext context,
    WidgetRef ref,
    AdminAppointmentModel appointment, {
    VoidCallback? onCancelled,
  }) async {
    await showCancelAppointmentSheet(
      context: context,
      serviceName: '${appointment.clientName} • ${appointment.serviceName}',
      startTime: appointment.startTime,
      servicePrice: appointment.servicePrice,
      isAdmin: true,
      onConfirm: (applyLateCancellationFee) async {
        try {
          await ref.read(adminAppointmentsServiceProvider).cancelAppointment(
            appointmentId: appointment.id,
            applyLateCancellationFee: applyLateCancellationFee,
          );
          ref.read(adminTodayAppointmentsProvider.notifier).refresh();
          ref.read(adminDateAppointmentsProvider(appointment.startTime).notifier).refresh(appointment.startTime);
          onCancelled?.call();

          if (!context.mounted) return;
          AppSnackBar.showSuccess(
            context,
            'Agendamento cancelado com sucesso.',
          );
        } catch (e) {
          if (!context.mounted) return;
          AppSnackBar.showError(
            context,
            e.toString().replaceAll('Exception: ', ''),
          );
          rethrow;
        }
      },
    );
  }

  void _showFutureAppointmentsDatePickerSheet(BuildContext context, WidgetRef ref) {
    showFutureAppointmentsDatePickerSheet(
      context: context,
      appointmentsService: ref.read(adminAppointmentsServiceProvider),
      onCancelAppointment: (appointment) =>
          _showCancelAppointmentSheet(context, ref, appointment),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: profileAsync.when(
          data: (profile) => SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageHeader(
                  greeting: 'Bem-vindo de volta',
                  name: profile.displayName,
                  notificationCount: 1,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppTheme.spacingLg,
                  ),
                  child: Center(
                    child: AppAvatar(
                      size: AvatarSize.large,
                      initials: profile.initials,
                      showEditBadge: true,
                      onEditTap: () => _showEditProfileSheet(context),
                    ),
                  ),
                ),
                const AdminStatsSection(),
                const SizedBox(height: AppTheme.spacingLg),
                AdminPendingDebtsSection(
                  onSeeAll: () => _showAllDebtsSheet(context, ref),
                  onDebtSelected: (summary) =>
                      _showDebtDetail(context, ref, summary),
                ),
                const SizedBox(height: AppTheme.spacingLg),
                AdminTodayAppointmentsSection(
                  onCancelAppointment: (appointment) =>
                      _showCancelAppointmentSheet(context, ref, appointment),
                ),
                const SizedBox(height: AppTheme.spacingXl),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Text('Erro ao carregar perfil: $error'),
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'admin_debts_fab',
            onPressed: () => _showAllDebtsSheet(context, ref),
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.statusCancelled,
            elevation: 4,
            child: const Icon(Icons.attach_money),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          FloatingActionButton.small(
            heroTag: 'admin_future_fab',
            onPressed: () => _showFutureAppointmentsDatePickerSheet(context, ref),
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.brandPrimary,
            elevation: 4,
            child: const Icon(Icons.calendar_month),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          FloatingActionButton(
            heroTag: 'admin_add_fab',
            onPressed: () => _showBookingSheet(context, ref),
            backgroundColor: AppColors.brandPrimary,
            foregroundColor: AppColors.textInverse,
            elevation: 4,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
