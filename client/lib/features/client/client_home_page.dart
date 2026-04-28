import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/widgets/app_avatar.dart';
import 'package:app/widgets/app_badge.dart';
import 'package:app/widgets/app_bottom_sheet.dart';
import 'package:app/widgets/booking_form.dart';
import 'package:app/widgets/page_header.dart';
import 'package:app/widgets/section_header.dart';
import 'package:app/widgets/debt_banner.dart';
import 'package:app/widgets/appointment_card.dart';
import 'package:app/widgets/user_edit_form.dart';
import 'package:app/widgets/app_empty_state.dart';
import 'package:flutter/material.dart';

// ── Mock Data ────────────────────────────────────────────────────────────────
class _Appointment {
  final String service;
  final String location;
  final String date;
  final String time;
  final BadgeVariant status;

  const _Appointment({
    required this.service,
    required this.location,
    required this.date,
    required this.time,
    required this.status,
  });
}

const _appointments = [
  _Appointment(
    service: 'Corte de Cabelo',
    location: 'Barbearia Central',
    date: '15 Abr',
    time: '14:00',
    status: BadgeVariant.confirmed,
  ),
  _Appointment(
    service: 'Manicure',
    location: 'Studio Bella',
    date: '18 Abr',
    time: '10:30',
    status: BadgeVariant.pending,
  ),
];

// ── Client Home Page ─────────────────────────────────────────────────────────
class ClientHomePage extends StatefulWidget {
  const ClientHomePage({super.key});

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
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
      child: const AppEmptyState(
        message: 'Nenhum agendamento no histórico',
        icon: Icons.history,
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
              const PageHeader(name: 'Olá, Maria', notificationCount: 1),

              // ── Avatar ──
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

              // ── Debt Banner (shared widget) ──
              DebtBanner(
                amount: 'R\$ 150,00',
                description: 'Referente ao serviço de 10 Mar 2026',
                onButtonPressed: () =>
                    Navigator.pushNamed(context, '/client/finances'),
              ),

              const SizedBox(height: AppTheme.spacingLg),

              // ── Section Header (shared widget) ──
              const SectionHeader(title: 'Próximos Agendamentos'),
              const SizedBox(height: AppTheme.spacingMd),

              // ── Appointment Cards (shared widget) ──
              ...List.generate(_appointments.length, (i) {
                final a = _appointments[i];
                return Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppTheme.spacingLg,
                    0,
                    AppTheme.spacingLg,
                    i < _appointments.length - 1 ? AppTheme.spacingMd : 0,
                  ),
                  child: AppointmentCard(
                    service: a.service,
                    subtitle: a.location,
                    date: a.date,
                    time: a.time,
                    status: a.status,
                    variant: AppointmentCardVariant.full,
                  ),
                );
              }),

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
