import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/client/models/service_model.dart';
import 'package:app/features/client/services/booking_service.dart';
import 'package:app/features/client/services/client_appointments_service.dart';
import 'package:app/widgets/booking_form.dart';
import 'package:app/widgets/app_snackbar.dart';
import 'package:app/widgets/appointment_action_sheet.dart';
import 'package:flutter/material.dart';

import 'widgets/client_profile_header.dart';
import 'widgets/client_debt_banner_section.dart';
import 'widgets/client_upcoming_appointments_section.dart';
import 'sheets/client_history_sheet.dart';
import 'sheets/client_profile_sheet.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/features/client/providers/client_providers.dart';

// ── Client Home Page ─────────────────────────────────────────────────────────
class ClientHomePage extends ConsumerWidget {
  const ClientHomePage({super.key});

  // ── Booking Sheet ──
  void _showBookingSheet(BuildContext context, WidgetRef ref) {
    BookingFlow.start(
      context,
      onBookingConfirmed: () {
        ref.read(clientAppointmentsProvider.notifier).refresh();
      },
    );
  }

  Future<void> _showCancelAppointmentSheet(
    BuildContext context,
    WidgetRef ref,
    ClientAppointmentModel appointment,
  ) async {
    await showAppointmentActionSheet(
      context: context,
      serviceName: appointment.serviceName,
      startTime: appointment.startTime,
      servicePrice: appointment.servicePrice,
      isAdmin: false,
      action: AppointmentActionType.cancel,
      onConfirm: (_) async {
        try {
          await ref
              .read(clientAppointmentsServiceProvider)
              .cancelAppointment(appointment.id);
          ref.read(clientAppointmentsProvider.notifier).refresh();
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

  Future<void> _showRescheduleSheet(
    BuildContext context,
    WidgetRef ref,
    ClientAppointmentModel appointment,
  ) async {
    // Fetch the full service model to pass into BookingFlow
    ServiceModel? service;
    try {
      final services = await BookingService().getServices();
      service = services.firstWhere(
        (s) => s.name == appointment.serviceName,
        orElse: () => services.first,
      );
    } catch (_) {
      if (!context.mounted) return;
      AppSnackBar.showError(context, 'Não foi possível carregar o serviço.');
      return;
    }

    if (!context.mounted) return;

    await showAppointmentActionSheet(
      context: context,
      serviceName: appointment.serviceName,
      startTime: appointment.startTime,
      servicePrice: appointment.servicePrice,
      isAdmin: false,
      action: AppointmentActionType.reschedule,
      onConfirm: (applyFee) async {
        // Confirmation sheet closes itself; then open booking flow in reschedule mode
        if (!context.mounted) return;
        BookingFlow.startReschedule(
          context,
          rescheduleContext: RescheduleContext(
            originalAppointmentId: appointment.id,
            applyFee: applyFee,
          ),
          preselectedService: service!,
          onRescheduled: () =>
              ref.read(clientAppointmentsProvider.notifier).refresh(),
        );
      },
    );
  }

  // ── History Sheet ──
  void _showHistorySheet(BuildContext context) {
    showClientHistorySheet(context: context);
  }

  // ── Profile / Edit Sheet ──
  void _showEditProfileSheet(BuildContext context, WidgetRef ref) {
    showClientProfileSheet(
      context: context,
      onSave: () {
        ref.read(userProfileProvider.notifier).refresh();
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClientProfileHeader(
                onEditTap: () => _showEditProfileSheet(context, ref),
              ),
              ClientDebtBannerSection(
                onPaymentPressed: () =>
                    Navigator.pushNamed(context, '/client/finances'),
              ),
              ClientUpcomingAppointmentsSection(
                onCancelTap: (app) =>
                    _showCancelAppointmentSheet(context, ref, app),
                onRescheduleTap: (app) =>
                    _showRescheduleSheet(context, ref, app),
              ),
              const SizedBox(height: AppTheme.spacingXl + 64),
            ],
          ),
        ),
      ),

      // ── FAB ──
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'history_fab',
            onPressed: () => _showHistorySheet(context),
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.textPrimary,
            elevation: 4,
            child: const Icon(Icons.history),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          FloatingActionButton(
            heroTag: 'add_fab',
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
