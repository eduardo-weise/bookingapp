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
import 'admin_profile_form.dart';

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

class _TodayAppointment {
  final String clientName;
  final String service;
  final String time;
  final BadgeVariant status;
  const _TodayAppointment({
    required this.clientName,
    required this.service,
    required this.time,
    required this.status,
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

const _todayAppointments = [
  _TodayAppointment(
    clientName: 'Maria Silva',
    service: 'Corte de Cabelo',
    time: '14:00',
    status: BadgeVariant.confirmed,
  ),
  _TodayAppointment(
    clientName: 'João Santos',
    service: 'Manicure',
    time: '15:30',
    status: BadgeVariant.pending,
  ),
];

// ── Admin Dashboard ──────────────────────────────────────────────────────────
class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
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
    BookingFlow.start(context);
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
            minDate: DateTime.now().subtract(const Duration(days: 30)),
            maxDate: DateTime.now().add(const Duration(days: 365)),
            selectionMode: DateRangePickerSelectionMode.single,
            onSelectionChanged: (args) {
              if (args.value is DateTime) {
                Navigator.pop(context);
                _showAppointmentsForDateSheet(args.value as DateTime);
              }
            },
          ),
        ],
      ),
    );
  }

  void _showAppointmentsForDateSheet(DateTime date) {
    // Show mock data for selected date
    showAppBottomSheet(
      context: context,
      title:
          'Agenda: ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
      height: BottomSheetHeight.flexible,
      child: Column(
        children: [
          const AppBadge(
            label: '3 Agendamentos',
            variant: BadgeVariant.pending,
          ),
          const SizedBox(height: AppTheme.spacingLg),
          ...List.generate(3, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
              child: AppointmentCard(
                service: 'Corte de Cabelo',
                subtitle: 'Cliente ${(i + 1)}',
                time: '${10 + i}:00',
                status: i == 0 ? BadgeVariant.confirmed : BadgeVariant.pending,
                variant: AppointmentCardVariant.compact,
              ),
            );
          }),
        ],
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
                child: const AppBadge(
                  label: 'Hoje, 20 de Abril',
                  variant: BadgeVariant.confirmed,
                ),
              ),
              const SizedBox(height: AppTheme.spacingMd),

              // ── Today's Appointments (shared AppointmentCard) ──
              ...List.generate(_todayAppointments.length, (i) {
                final a = _todayAppointments[i];
                return Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppTheme.spacingLg,
                    0,
                    AppTheme.spacingLg,
                    i < _todayAppointments.length - 1 ? AppTheme.spacingSm : 0,
                  ),
                  child: AppointmentCard(
                    service: a.service,
                    subtitle: a.clientName,
                    time: a.time,
                    status: a.status,
                    variant: AppointmentCardVariant.compact,
                  ),
                );
              }),

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
