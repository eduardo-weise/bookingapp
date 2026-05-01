import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_text_styles.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/client/services/client_appointments_service.dart';
import 'package:app/widgets/app_avatar.dart';
import 'package:app/widgets/app_badge.dart';
import 'package:app/widgets/app_bottom_sheet.dart';
import 'package:app/widgets/app_card.dart';
import 'package:app/widgets/booking_form.dart';
import 'package:app/widgets/page_header.dart';
import 'package:app/widgets/section_header.dart';
import 'package:app/widgets/debt_banner.dart';
import 'package:app/widgets/appointment_card.dart';
import 'package:app/widgets/user_edit_form.dart';
import 'package:app/widgets/app_empty_state.dart';
import 'package:app/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ── Client Home Page ─────────────────────────────────────────────────────────
class ClientHomePage extends StatefulWidget {
  const ClientHomePage({super.key});

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
  final _appointmentsService = ClientAppointmentsService();
  late Future<List<ClientAppointmentModel>> _appointmentsFuture;

  @override
  void initState() {
    super.initState();
    _appointmentsFuture = _loadAppointments();
  }

  Future<List<ClientAppointmentModel>> _loadAppointments() async {
    try {
      return await _appointmentsService.getAppointmentHistory();
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        AppSnackBar.showError(
          context,
          e.toString().replaceAll('Exception: ', ''),
        );
      });
      rethrow;
    }
  }

  // ── Booking Sheet ──
  void _showBookingSheet() {
    BookingFlow.start(context);
  }

  // ── History Sheet ──
  void _showHistorySheet() {
    showAppBottomSheet(
      context: context,
      title: 'Histórico',
      height: BottomSheetHeight.flexible,
      child: FutureBuilder<List<ClientAppointmentModel>>(
        future: _appointmentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: AppTheme.spacingXl),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: AppTheme.spacingXl),
              child: AppEmptyState(
                message: 'Não foi possível carregar o histórico.',
                icon: Icons.history_toggle_off,
              ),
            );
          }

          final appointments = snapshot.data ?? [];
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
                            Text(appointment.serviceName, style: AppTextStyles.heading3),
                            const SizedBox(height: 2),
                            Text(
                              _formatHistoryDateTime(appointment.startTime),
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppBadge(
                        label: _statusLabel(appointment.status),
                        variant: _statusVariant(appointment.status),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  // ── Profile / Edit Sheet ──
  void _showEditProfileSheet() {
    showAppBottomSheet(
      context: context,
      title: 'Editar Perfil',
      height: BottomSheetHeight.flexible,
      child: UserEditForm(
        onSave: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  String _formatCardDate(DateTime value) => DateFormat('dd MMM', 'pt_BR').format(value);

  String _formatCardTime(DateTime value) => DateFormat('HH:mm', 'pt_BR').format(value);

  String _formatHistoryDateTime(DateTime value) =>
      DateFormat("dd 'de' MMMM, HH:mm", 'pt_BR').format(value);

  BadgeVariant _statusVariant(String status) {
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

  String _statusLabel(String status) {
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FutureBuilder<List<ClientAppointmentModel>>(
          future: _appointmentsFuture,
          builder: (context, snapshot) {
            final appointments = snapshot.data ?? [];
            final upcomingAppointments = appointments
                .where(
                  (appointment) =>
                      appointment.startTime.isAfter(DateTime.now()) &&
                      appointment.status.toLowerCase() != 'canceled',
                )
                .toList()
              ..sort((left, right) => left.startTime.compareTo(right.startTime));

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const PageHeader(name: 'Olá, Maria', notificationCount: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppTheme.spacingLg,
                    ),
                    child: Center(
                      child: AppAvatar(
                        size: AvatarSize.large,
                        initials: 'MS',
                        showEditBadge: true,
                        onEditTap: _showEditProfileSheet,
                      ),
                    ),
                  ),
                  DebtBanner(
                    amount: 'R\$ 150,00',
                    description: 'Referente ao serviço de 10 Mar 2026',
                    onButtonPressed: () =>
                        Navigator.pushNamed(context, '/client/finances'),
                  ),
                  const SizedBox(height: AppTheme.spacingLg),
                  const SectionHeader(title: 'Próximos Agendamentos'),
                  const SizedBox(height: AppTheme.spacingMd),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppTheme.spacingXl),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (snapshot.hasError)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
                      child: AppEmptyState(
                        message: 'Não foi possível carregar os agendamentos.',
                        icon: Icons.event_busy,
                      ),
                    )
                  else if (upcomingAppointments.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
                      child: AppEmptyState(
                        message: 'Nenhum agendamento futuro encontrado',
                        icon: Icons.event_busy,
                      ),
                    )
                  else
                    ...List.generate(upcomingAppointments.length, (i) {
                      final appointment = upcomingAppointments[i];
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
                          subtitle: _statusLabel(appointment.status),
                          date: _formatCardDate(appointment.startTime),
                          time: _formatCardTime(appointment.startTime),
                          status: _statusVariant(appointment.status),
                          variant: AppointmentCardVariant.full,
                        ),
                      );
                    }),
                  const SizedBox(height: AppTheme.spacingXl + 64),
                ],
              ),
            );
          },
        ),
      ),

      // ── FAB ──
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'history_fab',
            onPressed: _showHistorySheet,
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.textPrimary,
            elevation: 4,
            child: const Icon(Icons.history),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          FloatingActionButton(
            heroTag: 'add_fab',
            onPressed: _showBookingSheet,
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
