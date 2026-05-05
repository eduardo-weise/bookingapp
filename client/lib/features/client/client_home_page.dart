import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_text_styles.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/client/models/service_model.dart';
import 'package:app/features/client/services/booking_service.dart';
import 'package:app/features/client/services/client_appointments_service.dart';
import 'package:app/features/client/services/client_debt_service.dart';
import 'package:app/features/client/services/user_profile_service.dart';
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
import 'package:app/widgets/appointment_action_sheet.dart';
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
  final _debtService = ClientDebtService();
  final _profileService = UserProfileService();
  final GlobalKey<_UpcomingAppointmentsSectionState> _upcomingSectionKey =
      GlobalKey<_UpcomingAppointmentsSectionState>();
  late Future<List<ClientDebtModel>> _debtsFuture;
  late Future<UserProfileModel> _profileFuture;

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

  Future<List<ClientDebtModel>> _loadDebts() async {
    try {
      final debts = await _debtService.getDebts();
      debugPrint('✅ Débitos carregados: ${debts.length} débito(s)');
      for (var debt in debts) {
        debugPrint('  - Débito: R\$ ${debt.amount}, Status: ${debt.status}');
      }
      return debts;
    } catch (e) {
      // Silently handle error - debts are optional
      debugPrint('❌ Erro ao carregar débitos: $e');
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
    _debtsFuture = _loadDebts();
    _profileFuture = _profileService.getProfile();
  }

  // ── Booking Sheet ──
  void _showBookingSheet() {
    BookingFlow.start(
      context,
      onBookingConfirmed: () {
        _upcomingSectionKey.currentState?.refresh();
      },
    );
  }

  Future<void> _showCancelAppointmentSheet(
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
          await _appointmentsService.cancelAppointment(appointment.id);
          _upcomingSectionKey.currentState?.refresh();
          if (!mounted) return;
          AppSnackBar.showSuccess(
            context,
            'Agendamento cancelado com sucesso.',
          );
        } catch (e) {
          if (!mounted) return;
          AppSnackBar.showError(
            context,
            e.toString().replaceAll('Exception: ', ''),
          );
          rethrow;
        }
      },
    );
  }

  Future<void> _showRescheduleSheet(ClientAppointmentModel appointment) async {
    // Fetch the full service model to pass into BookingFlow
    ServiceModel? service;
    try {
      final services = await BookingService().getServices();
      service = services.firstWhere(
        (s) => s.name == appointment.serviceName,
        orElse: () => services.first,
      );
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.showError(context, 'Não foi possível carregar o serviço.');
      return;
    }

    if (!mounted) return;

    await showAppointmentActionSheet(
      context: context,
      serviceName: appointment.serviceName,
      startTime: appointment.startTime,
      servicePrice: appointment.servicePrice,
      isAdmin: false,
      action: AppointmentActionType.reschedule,
      onConfirm: (applyFee) async {
        // Confirmation sheet closes itself; then open booking flow in reschedule mode
        if (!mounted) return;
        BookingFlow.startReschedule(
          context,
          rescheduleContext: RescheduleContext(
            originalAppointmentId: appointment.id,
            applyFee: applyFee,
          ),
          preselectedService: service!,
          onRescheduled: () => _upcomingSectionKey.currentState?.refresh(),
        );
      },
    );
  }

  // ── History Sheet ──
  void _showHistorySheet() {
    showAppBottomSheet(
      context: context,
      title: 'Histórico',
      height: BottomSheetHeight.flexible,
      child: FutureBuilder<List<ClientAppointmentModel>>(
        future: _loadAppointments(),
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
                            Text(
                              appointment.serviceName,
                              style: AppTextStyles.heading3,
                            ),
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
      height: BottomSheetHeight.large,
      child: UserEditForm(
        onSave: () {
          Navigator.pop(context);
          // Refresh profile after saving
          setState(() {
            _profileFuture = _profileService.getProfile();
          });
        },
      ),
    );
  }

  String _formatCardDate(DateTime value) =>
      DateFormat('dd MMM', 'pt_BR').format(value);

  String _formatCardTime(DateTime value) =>
      DateFormat('HH:mm', 'pt_BR').format(value);

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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<UserProfileModel>(
                future: _profileFuture,
                builder: (context, snapshot) {
                  final name = snapshot.data?.displayName ?? '';
                  final initials = snapshot.data?.initials ?? '?';
                  return Column(
                    children: [
                      PageHeader(
                        name: name.isNotEmpty ? 'Olá, $name' : 'Olá!',
                        notificationCount: 1,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppTheme.spacingLg,
                        ),
                        child: Center(
                          child: AppAvatar(
                            size: AvatarSize.large,
                            initials: initials,
                            showEditBadge: true,
                            onEditTap: _showEditProfileSheet,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              FutureBuilder<List<ClientDebtModel>>(
                future: _debtsFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    final debt = snapshot.data!.first;
                    final formattedAmount = NumberFormat.currency(
                      locale: 'pt_BR',
                      symbol: 'R\$',
                    ).format(debt.amount);

                    return Column(
                      children: [
                        DebtBanner(
                          amount: formattedAmount,
                          description:
                              'Débito pendente criado em ${DateFormat('dd MMM yyyy', 'pt_BR').format(debt.createdAt)}',
                          onPaymentPressed: () =>
                              Navigator.pushNamed(context, '/client/finances'),
                        ),
                        const SizedBox(height: AppTheme.spacingLg),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              _UpcomingAppointmentsSection(
                key: _upcomingSectionKey,
                loadAppointments: _loadAppointments,
                formatCardDate: _formatCardDate,
                formatCardTime: _formatCardTime,
                statusLabel: _statusLabel,
                statusVariant: _statusVariant,
                onCancelTap: _showCancelAppointmentSheet,
                onRescheduleTap: _showRescheduleSheet,
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

class _UpcomingAppointmentsSection extends StatefulWidget {
  final Future<List<ClientAppointmentModel>> Function() loadAppointments;
  final String Function(DateTime) formatCardDate;
  final String Function(DateTime) formatCardTime;
  final String Function(String) statusLabel;
  final BadgeVariant Function(String) statusVariant;
  final Future<void> Function(ClientAppointmentModel appointment) onCancelTap;
  final Future<void> Function(ClientAppointmentModel appointment)
  onRescheduleTap;

  const _UpcomingAppointmentsSection({
    super.key,
    required this.loadAppointments,
    required this.formatCardDate,
    required this.formatCardTime,
    required this.statusLabel,
    required this.statusVariant,
    required this.onCancelTap,
    required this.onRescheduleTap,
  });

  @override
  State<_UpcomingAppointmentsSection> createState() =>
      _UpcomingAppointmentsSectionState();
}

class _UpcomingAppointmentsSectionState
    extends State<_UpcomingAppointmentsSection> {
  late Future<List<ClientAppointmentModel>> _appointmentsFuture;

  @override
  void initState() {
    super.initState();
    _appointmentsFuture = widget.loadAppointments();
  }

  void refresh() {
    if (!mounted) return;
    setState(() {
      _appointmentsFuture = widget.loadAppointments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Próximos Agendamentos'),
        const SizedBox(height: AppTheme.spacingMd),
        FutureBuilder<List<ClientAppointmentModel>>(
          future: _appointmentsFuture,
          builder: (context, snapshot) {
            final appointments = snapshot.data ?? [];
            final upcomingAppointments = appointments.toList()
              ..sort(
                (left, right) => left.startTime.compareTo(right.startTime),
              );

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: AppTheme.spacingXl),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
                child: AppEmptyState(
                  message: 'Não foi possível carregar os agendamentos.',
                  icon: Icons.event_busy,
                ),
              );
            }

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
                    subtitle: widget.statusLabel(appointment.status),
                    date: widget.formatCardDate(appointment.startTime),
                    time: widget.formatCardTime(appointment.startTime),
                    status: widget.statusVariant(appointment.status),
                    variant: AppointmentCardVariant.full,
                    onReschedulePressed: isWithin1Hour
                        ? null
                        : () => widget.onRescheduleTap(appointment),
                    onCancelPressed: () => widget.onCancelTap(appointment),
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }
}
