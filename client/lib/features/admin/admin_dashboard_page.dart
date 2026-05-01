import 'package:flutter/material.dart';
import 'package:app/widgets/app_date_picker.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_text_styles.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/widgets/app_avatar.dart';
import 'package:app/widgets/app_badge.dart';
import 'package:app/widgets/app_button.dart';
import 'package:app/widgets/app_card.dart';
import 'package:app/widgets/app_bottom_sheet.dart';
import 'package:app/widgets/booking_form.dart';
import 'package:app/widgets/page_header.dart';
import 'package:app/widgets/section_header.dart';
import 'package:app/widgets/appointment_card.dart';
import 'package:app/widgets/app_empty_state.dart';
import 'package:app/widgets/app_snackbar.dart';
import 'package:app/widgets/cancel_appointment_sheet.dart';
import 'package:intl/intl.dart';
import 'admin_profile_form.dart';
import 'services/admin_clients_service.dart';
import 'services/admin_appointments_service.dart';

// ── Mock Data ────────────────────────────────────────────────────────────────
class _Debt {
  final String clientName;
  final String service;
  final String date;
  final double amount;
  const _Debt({
    required this.clientName,
    required this.service,
    required this.date,
    required this.amount,
  });
}

const _debts = [
  _Debt(
    clientName: 'Maria Silva',
    service: 'Corte de Cabelo',
    date: '10 Mar 2026',
    amount: 150,
  ),
  _Debt(
    clientName: 'João Santos',
    service: 'Manicure',
    date: '12 Mar 2026',
    amount: 80,
  ),
];

// ── Admin Dashboard ──────────────────────────────────────────────────────────
class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final _clientsService = AdminClientsService();
  final _appointmentsService = AdminAppointmentsService();
  late Future<List<AdminAppointmentModel>> _todayAppointmentsFuture;

  @override
  void initState() {
    super.initState();
    _todayAppointmentsFuture = _appointmentsService.getAppointmentsByDate(DateTime.now());
  }

  // ── Profile / Edit Sheet ──
  void _showEditProfileSheet() {
    showAppBottomSheet(
      context: context,
      title: 'Editar Perfil',
      height: BottomSheetHeight.flexible,
      child: AdminProfileForm(
        onSave: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showDebtDetail(_Debt debt) {
    showAppBottomSheet(
      context: context,
      title: '',
      height: BottomSheetHeight.medium,
      child: Column(
        children: [
          AppAvatar(size: AvatarSize.medium, initials: debt.clientName[0]),
          const SizedBox(height: AppTheme.spacingSm),
          Text(debt.clientName, style: AppTextStyles.heading2),
          const SizedBox(height: AppTheme.spacingXs),
          Text('Débito pendente', style: AppTextStyles.caption),
          const SizedBox(height: AppTheme.spacingLg),
          const Divider(),
          const SizedBox(height: AppTheme.spacingMd),
          _detailRow('Serviço', debt.service),
          const SizedBox(height: AppTheme.spacingMd),
          _detailRow('Data', debt.date),
          const SizedBox(height: AppTheme.spacingMd),
          _detailRow(
            'Valor',
            'R\$ ${debt.amount.toStringAsFixed(2)}',
            bold: true,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          const Divider(),
          const SizedBox(height: AppTheme.spacingLg),
          AppButton(
            label: 'Marcar como Pago',
            fullWidth: true,
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          AppButton(
            label: 'Cancelar Cobrança',
            variant: AppButtonVariant.ghost,
            fullWidth: true,
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(height: AppTheme.spacingMd),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.caption),
        Text(
          value,
          style: AppTextStyles.body.copyWith(
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showBookingSheet() {
    BookingFlow.start(
      context,
      loadTargetClients: () async {
        final clients = await _clientsService.getClients();
        return clients
            .map(
              (client) => BookingTargetClient(
                id: client.id,
                displayName: client.displayName,
                subtitle: client.email == client.displayName ? null : client.email,
              ),
            )
            .toList();
      },
    );
  }

  void _refreshTodayAppointments() {
    if (!mounted) return;
    setState(() {
      _todayAppointmentsFuture = _appointmentsService.getAppointmentsByDate(DateTime.now());
    });
  }

  Future<void> _showCancelAppointmentSheet(
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
          await _appointmentsService.cancelAppointment(
            appointmentId: appointment.id,
            applyLateCancellationFee: applyLateCancellationFee,
          );
          _refreshTodayAppointments();
          onCancelled?.call();

          if (!mounted) return;
          AppSnackBar.showSuccess(context, 'Agendamento cancelado com sucesso.');
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

  void _showAllDebtsSheet() {
    showAppBottomSheet(
      context: context,
      title: 'Todos os Débitos',
      height: BottomSheetHeight.flexible,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _debts.length,
        separatorBuilder: (context, index) =>
            const SizedBox(height: AppTheme.spacingSm),
        itemBuilder: (context, i) {
          final d = _debts[i];
          return AppCard(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            onTap: () {
              Navigator.pop(context);
              _showDebtDetail(d);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    AppAvatar(
                      size: AvatarSize.small,
                      initials: d.clientName[0],
                    ),
                    const SizedBox(width: AppTheme.spacingMd),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          d.clientName,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${d.service} • ${d.date}',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  'R\$ ${d.amount.toStringAsFixed(2)}',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.statusCancelled,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showFutureAppointmentsDatePickerSheet() {
    showAppBottomSheet(
      context: context,
      title: 'Agendamentos Futuros',
      height: BottomSheetHeight.flexible,
      child: Column(
        children: [
          const Text(
            'Selecione uma data para visualizar os agendamentos.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          AppDatePicker(
            initialSelectedDate: DateTime.now(),
            minDate: DateTime.now(),
            maxDate: DateTime.now().add(const Duration(days: 365)),
            selectionMode: DateRangePickerSelectionMode.single,
            onSelectionChanged: (args) {
              if (args.value is DateTime) {
                Navigator.pop(context);
                _showAppointmentsForDateSheet(
                  args.value as DateTime,
                  onBack: _showFutureAppointmentsDatePickerSheet,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatHour(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatCardDate(DateTime date) => DateFormat('dd MMM', 'pt_BR').format(date);

  String _formatTodayBadge(DateTime date) =>
      'Hoje, ${DateFormat("dd 'de' MMMM", 'pt_BR').format(date)}';

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

  void _showAppointmentsForDateSheet(
    DateTime date, {
    VoidCallback? onBack,
  }) {
    Future<List<AdminAppointmentModel>> appointmentsFuture =
        _appointmentsService.getAppointmentsByDate(date);

    showAppBottomSheet(
      context: context,
      title: 'Agenda: ${_formatDate(date)}',
      height: BottomSheetHeight.flexible,
      onBack: onBack,
      child: StatefulBuilder(
        builder: (context, setModalState) {
          Future<void> refreshDateAppointments() async {
            setModalState(() {
              appointmentsFuture = _appointmentsService.getAppointmentsByDate(date);
            });
          }

          return FutureBuilder<List<AdminAppointmentModel>>(
            future: appointmentsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                final message = snapshot.error
                        ?.toString()
                        .replaceAll('Exception: ', '') ??
                    'Erro ao buscar agendamentos.';
                return AppEmptyState(message: message);
              }

              final appointments = snapshot.data ?? [];
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
                    (a) => Padding(
                      padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
                      child: AppointmentCard(
                        service: '${a.clientName} • ${a.serviceName}',
                        subtitle: _statusLabel(_statusToBadge(a.status)),
                        date: _formatCardDate(a.startTime),
                        time: _formatHour(a.startTime),
                        status: _statusToBadge(a.status),
                        variant: AppointmentCardVariant.full,
                        onCancelPressed: () => _showCancelAppointmentSheet(
                          a,
                          onCancelled: () {
                            refreshDateAppointments();
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
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
              // ── Header (shared widget) ──
              const PageHeader(
                greeting: 'Bem-vindo de volta',
                name: 'Admin João',
                notificationCount: 1,
              ),

              // ── Avatar ──
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppTheme.spacingLg,
                ),
                child: Center(
                  child: AppAvatar(
                    size: AvatarSize.large,
                    initials: 'A',
                    showEditBadge: true,
                    onEditTap: _showEditProfileSheet,
                  ),
                ),
              ),

              // ── Stats Cards ──
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingLg,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.people_outline,
                        iconColor: AppColors.brandPrimary,
                        gradientColors: const [
                          AppColors.muted,
                          AppColors.border,
                        ],
                        label: 'Clientes',
                        value: '48',
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingMd),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.attach_money,
                        iconColor: const Color(0xFF059669),
                        gradientColors: const [
                          AppColors.confirmedBg,
                          Color(0xFFA7F3D0),
                        ],
                        label: 'Receita (mês)',
                        value: '8.5k',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.spacingLg),

              // ── Débitos Pendentes (shared SectionHeader) ──
              const SectionHeader(
                title: 'Débitos Pendentes',
                actionLabel: 'Ver todos',
              ),
              const SizedBox(height: AppTheme.spacingMd),
              SizedBox(
                height: 175,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingLg,
                  ),
                  itemCount: _debts.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: AppTheme.spacingSm),
                  itemBuilder: (context, i) {
                    final d = _debts[i];
                    return GestureDetector(
                      onTap: () => _showDebtDetail(d),
                      child: SizedBox(
                        width: 160,
                        child: AppCard(
                          padding: const EdgeInsets.all(AppTheme.spacingMd),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  AppAvatar(
                                    size: AvatarSize.small,
                                    initials: d.clientName[0],
                                  ),
                                  const SizedBox(width: AppTheme.spacingSm),
                                  Expanded(
                                    child: Text(
                                      d.clientName.split(' ')[0],
                                      style: AppTextStyles.label.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppTheme.spacingSm),
                              Text(
                                d.service,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textTertiary,
                                  fontSize: 11,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: AppTheme.spacingSm),
                              const AppBadge(
                                label: 'Pendente',
                                variant: BadgeVariant.pending,
                              ),
                              const Spacer(),
                              Text(
                                'R\$ ${d.amount.toStringAsFixed(2)}',
                                style: AppTextStyles.heading3.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: AppTheme.spacingLg),

              // ── Hoje (shared SectionHeader + AppointmentCard) ──
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
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingLg,
                ),
                child: AppBadge(
                  label: _formatTodayBadge(DateTime.now()),
                  variant: BadgeVariant.confirmed,
                ),
              ),
              const SizedBox(height: AppTheme.spacingMd),

              FutureBuilder<List<AdminAppointmentModel>>(
                future: _todayAppointmentsFuture,
                builder: (context, snapshot) {
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
                        message: 'Não foi possível carregar os agendamentos de hoje.',
                        icon: Icons.event_busy,
                      ),
                    );
                  }

                  final todayAppointments = snapshot.data ?? [];
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
                          service: '${appointment.clientName} • ${appointment.serviceName}',
                          subtitle: _statusLabel(_statusToBadge(appointment.status)),
                          date: _formatCardDate(appointment.startTime),
                          time: _formatHour(appointment.startTime),
                          status: _statusToBadge(appointment.status),
                          variant: AppointmentCardVariant.full,
                          onCancelPressed: () => _showCancelAppointmentSheet(appointment),
                        ),
                      );
                    }),
                  );
                },
              ),

              const SizedBox(height: AppTheme.spacingXl),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'admin_debts_fab',
            onPressed: _showAllDebtsSheet,
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.statusCancelled,
            elevation: 4,
            child: const Icon(Icons.attach_money),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          FloatingActionButton.small(
            heroTag: 'admin_future_fab',
            onPressed: _showFutureAppointmentsDatePickerSheet,
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.brandPrimary,
            elevation: 4,
            child: const Icon(Icons.calendar_month),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          FloatingActionButton(
            heroTag: 'admin_add_fab',
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

// ── Stat Card (admin-only, local widget) ─────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final List<Color> gradientColors;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.gradientColors,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradientColors),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Icon(icon, size: 22, color: iconColor),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Text(label, style: AppTextStyles.caption),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
