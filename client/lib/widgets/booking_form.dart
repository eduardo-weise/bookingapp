import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/app_theme.dart';
import '../features/client/models/service_model.dart';
import '../features/client/services/booking_service.dart';
import '../widgets/app_button.dart';
import '../widgets/app_bottom_sheet.dart';
import '../widgets/app_card.dart';
import '../widgets/app_snackbar.dart';

class BookingFlow {
  static final _service = BookingService();

  static void start(BuildContext context) {
    _showServicesSheet(context);
  }

  // ── Step 1: Services ────────────────────────────────────────────────────────

  static void _showServicesSheet(BuildContext context) {
    showAppBottomSheet(
      context: context,
      title: 'Selecione o Serviço',
      height: BottomSheetHeight.flexible,
      child: _ServicesSheetContent(
        bookingService: _service,
        onServiceSelected: (service) {
          Navigator.of(context).pop();
          _showDatePickerSheet(context, service);
        },
      ),
    );
  }

  // ── Step 2: Date ─────────────────────────────────────────────────────────────

  static void _showDatePickerSheet(BuildContext context, ServiceModel service) {
    showAppBottomSheet(
      context: context,
      title: 'Data - ${service.name}',
      height: BottomSheetHeight.flexible,
      onBack: () {
        Navigator.of(context).pop();
        _showServicesSheet(context);
      },
      child: Column(
        children: [
          const Text(
            'Selecione uma data para o agendamento.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          CalendarDatePicker(
            initialDate: DateTime.now().add(const Duration(days: 1)),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 90)),
            onDateChanged: (date) {
              Navigator.of(context).pop();
              _showTimesSheet(context, service, date);
            },
          ),
        ],
      ),
    );
  }

  // ── Step 3: Time ─────────────────────────────────────────────────────────────

  static void _showTimesSheet(
    BuildContext context,
    ServiceModel service,
    DateTime date,
  ) {
    showAppBottomSheet(
      context: context,
      title:
          'Horário - ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
      height: BottomSheetHeight.flexible,
      onBack: () {
        Navigator.of(context).pop();
        _showDatePickerSheet(context, service);
      },
      child: _TimesSheetContent(
        bookingService: _service,
        service: service,
        date: date,
        onConfirmed: () => Navigator.of(context).pop(),
      ),
    );
  }
}

// ── Services Sheet Content ────────────────────────────────────────────────────

class _ServicesSheetContent extends StatefulWidget {
  final BookingService bookingService;
  final void Function(ServiceModel service) onServiceSelected;

  const _ServicesSheetContent({
    required this.bookingService,
    required this.onServiceSelected,
  });

  @override
  State<_ServicesSheetContent> createState() => _ServicesSheetContentState();
}

class _ServicesSheetContentState extends State<_ServicesSheetContent> {
  List<ServiceModel>? _services;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final services = await widget.bookingService.getServices();
      if (mounted) setState(() { _services = services; _isLoading = false; });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppTheme.spacingXl),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingXl),
        child: Center(
          child: Text(_error!, style: const TextStyle(color: AppColors.statusCancelled)),
        ),
      );
    }

    final services = _services ?? [];
    if (services.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppTheme.spacingXl),
        child: Center(
          child: Text(
            'Nenhum serviço disponível.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Column(
      children: services.map((s) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
          child: AppCard(
            onTap: () => widget.onServiceSelected(s),
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.name, style: AppTextStyles.heading3),
                    const SizedBox(height: 2),
                    Text(
                      '${s.durationLabel} • ${s.priceLabel}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Times Sheet Content ───────────────────────────────────────────────────────

class _TimesSheetContent extends StatefulWidget {
  final BookingService bookingService;
  final ServiceModel service;
  final DateTime date;
  final VoidCallback onConfirmed;

  const _TimesSheetContent({
    required this.bookingService,
    required this.service,
    required this.date,
    required this.onConfirmed,
  });

  @override
  State<_TimesSheetContent> createState() => _TimesSheetContentState();
}

class _TimesSheetContentState extends State<_TimesSheetContent> {
  List<String>? _slots;
  bool _isLoadingSlots = true;
  bool _isBooking = false;
  String? _error;
  String? _selectedTime;

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    try {
      final slots = await widget.bookingService.getAvailableSlots(
        date: widget.date,
        serviceId: widget.service.id,
      );
      if (mounted) setState(() { _slots = slots; _isLoadingSlots = false; });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoadingSlots = false;
        });
      }
    }
  }

  Future<void> _confirm() async {
    if (_selectedTime == null) return;
    setState(() => _isBooking = true);
    try {
      await widget.bookingService.bookAppointment(
        serviceId: widget.service.id,
        date: widget.date,
        timeSlot: _selectedTime!,
      );
      if (!mounted) return;
      widget.onConfirmed();
      AppSnackBar.showSuccess(context, 'Agendamento confirmado com sucesso!');
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(
          context,
          e.toString().replaceAll('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Serviço selecionado: ${widget.service.name}', style: AppTextStyles.body),
        const SizedBox(height: AppTheme.spacingLg),
        Text(
          'Horários Disponíveis',
          style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        if (_isLoadingSlots)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppTheme.spacingXl),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_error != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingLg),
            child: Text(_error!, style: const TextStyle(color: AppColors.statusCancelled)),
          )
        else if ((_slots ?? []).isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppTheme.spacingLg),
            child: Text(
              'Nenhum horário disponível para este dia.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          )
        else
          Wrap(
            spacing: AppTheme.spacingSm,
            runSpacing: AppTheme.spacingSm,
            children: (_slots ?? []).map((time) {
              final selected = _selectedTime == time;
              return GestureDetector(
                onTap: () => setState(() => _selectedTime = time),
                child: Container(
                  width: (MediaQuery.of(context).size.width - 48 - 24 - 16) / 3,
                  height: 44,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.muted : AppColors.surface,
                    border: Border.all(
                      color: selected ? AppColors.brandPrimary : AppColors.border,
                      width: selected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    time,
                    style: AppTextStyles.body.copyWith(
                      color: selected ? AppColors.brandPrimary : AppColors.textSecondary,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        const SizedBox(height: AppTheme.spacingXl),
        AppButton(
          label: 'Confirmar Agendamento',
          fullWidth: true,
          isLoading: _isBooking,
          onPressed: (_selectedTime == null || _isBooking) ? null : _confirm,
        ),
        const SizedBox(height: AppTheme.spacingMd),
      ],
    );
  }
}
