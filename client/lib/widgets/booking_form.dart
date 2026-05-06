import 'package:flutter/material.dart';
import 'package:app/widgets/app_date_picker.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/app_theme.dart';
import '../features/client/models/service_model.dart';
import '../features/client/services/booking_service.dart';
import '../features/client/services/client_appointments_service.dart';
import '../widgets/app_button.dart';
import '../widgets/app_bottom_sheet.dart';
import '../widgets/app_card.dart';
import '../widgets/app_snackbar.dart';

class BookingTargetClient {
  final String id;
  final String displayName;
  final String? subtitle;

  const BookingTargetClient({
    required this.id,
    required this.displayName,
    this.subtitle,
  });
}

/// Carries reschedule context through the booking flow steps.
class RescheduleContext {
  final String originalAppointmentId;
  final bool applyFee;

  const RescheduleContext({
    required this.originalAppointmentId,
    required this.applyFee,
  });
}

class BookingFlow {
  static final _service = BookingService();

  static void start(
    BuildContext context, {
    Future<List<BookingTargetClient>> Function()? loadTargetClients,
    BookingTargetClient? selectedTargetClient,
    VoidCallback? onBookingConfirmed,
  }) {
    if (selectedTargetClient == null && loadTargetClients != null) {
      _showTargetClientsSheet(
        context,
        loadTargetClients,
        onBookingConfirmed: onBookingConfirmed,
      );
      return;
    }

    _showServicesSheet(
      context,
      loadTargetClients: loadTargetClients,
      selectedTargetClient: selectedTargetClient,
      onBookingConfirmed: onBookingConfirmed,
    );
  }

  /// Starts the booking flow in reschedule mode.
  ///
  /// Skips service selection — the original service is pre-selected.
  /// On final confirmation the backend reschedule endpoint is called instead
  /// of the regular book endpoint, with [applyFee] propagated through.
  static void startReschedule(
    BuildContext context, {
    required RescheduleContext rescheduleContext,
    required ServiceModel preselectedService,
    VoidCallback? onRescheduled,
  }) {
    _showDatePickerSheet(
      context,
      preselectedService,
      rescheduleContext: rescheduleContext,
      onBookingConfirmed: onRescheduled,
    );
  }

  static void _showTargetClientsSheet(
    BuildContext context,
    Future<List<BookingTargetClient>> Function() loadTargetClients, {
    VoidCallback? onBookingConfirmed,
  }) {
    showAppBottomSheet(
      context: context,
      title: 'Selecione o Cliente',
      height: BottomSheetHeight.flexible,
      child: _TargetClientsSheetContent(
        loadClients: loadTargetClients,
        onClientSelected: (client) {
          Navigator.of(context).pop();
          _showServicesSheet(
            context,
            loadTargetClients: loadTargetClients,
            selectedTargetClient: client,
            onBookingConfirmed: onBookingConfirmed,
          );
        },
      ),
    );
  }

  // ── Step 1: Services ────────────────────────────────────────────────────────

  static void _showServicesSheet(
    BuildContext context, {
    Future<List<BookingTargetClient>> Function()? loadTargetClients,
    BookingTargetClient? selectedTargetClient,
    VoidCallback? onBookingConfirmed,
  }) {
    showAppBottomSheet(
      context: context,
      title: 'Selecione o Serviço',
      height: BottomSheetHeight.flexible,
      onBack: selectedTargetClient != null && loadTargetClients != null
          ? () {
              Navigator.of(context).pop();
              _showTargetClientsSheet(context, loadTargetClients);
            }
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (selectedTargetClient != null) ...[
            _SelectedClientBanner(client: selectedTargetClient),
            const SizedBox(height: AppTheme.spacingMd),
          ],
          _ServicesSheetContent(
            bookingService: _service,
            onServiceSelected: (service) {
              Navigator.of(context).pop();
              _showDatePickerSheet(
                context,
                service,
                loadTargetClients: loadTargetClients,
                selectedTargetClient: selectedTargetClient,
                onBookingConfirmed: onBookingConfirmed,
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Step 2: Date ─────────────────────────────────────────────────────────────

  static void _showDatePickerSheet(
    BuildContext context,
    ServiceModel service, {
    Future<List<BookingTargetClient>> Function()? loadTargetClients,
    BookingTargetClient? selectedTargetClient,
    VoidCallback? onBookingConfirmed,
    RescheduleContext? rescheduleContext,
  }) {
    showAppBottomSheet(
      context: context,
      title: rescheduleContext != null
          ? 'Reagendar — Data - ${service.name}'
          : 'Data - ${service.name}',
      height: BottomSheetHeight.flexible,
      onBack: rescheduleContext == null
          ? () {
              Navigator.of(context).pop();
              _showServicesSheet(
                context,
                loadTargetClients: loadTargetClients,
                selectedTargetClient: selectedTargetClient,
                onBookingConfirmed: onBookingConfirmed,
              );
            }
          : () => Navigator.of(context).pop(),
      child: _DatePickerSheetContent(
        bookingService: _service,
        service: service,
        selectedTargetClient: selectedTargetClient,
        onDateSelected: (selectedDate) {
          Navigator.of(context).pop();
          _showTimesSheet(
            context,
            service,
            selectedDate,
            loadTargetClients: loadTargetClients,
            selectedTargetClient: selectedTargetClient,
            onBookingConfirmed: onBookingConfirmed,
            rescheduleContext: rescheduleContext,
          );
        },
      ),
    );
  }

  // ── Step 3: Time ─────────────────────────────────────────────────────────────

  static void _showTimesSheet(
    BuildContext context,
    ServiceModel service,
    DateTime date, {
    Future<List<BookingTargetClient>> Function()? loadTargetClients,
    BookingTargetClient? selectedTargetClient,
    VoidCallback? onBookingConfirmed,
    RescheduleContext? rescheduleContext,
  }) {
    showAppBottomSheet(
      context: context,
      title:
          '${rescheduleContext != null ? 'Reagendar — ' : ''}Horário - ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
      height: BottomSheetHeight.flexible,
      onBack: () {
        Navigator.of(context).pop();
        _showDatePickerSheet(
          context,
          service,
          loadTargetClients: loadTargetClients,
          selectedTargetClient: selectedTargetClient,
          onBookingConfirmed: onBookingConfirmed,
          rescheduleContext: rescheduleContext,
        );
      },
      child: _TimesSheetContent(
        bookingService: _service,
        service: service,
        date: date,
        selectedTargetClient: selectedTargetClient,
        onBookingConfirmed: onBookingConfirmed,
        rescheduleContext: rescheduleContext,
        onConfirmed: () => Navigator.of(context).pop(),
      ),
    );
  }
}

class _DatePickerSheetContent extends StatefulWidget {
  final BookingService bookingService;
  final ServiceModel service;
  final BookingTargetClient? selectedTargetClient;
  final ValueChanged<DateTime> onDateSelected;

  const _DatePickerSheetContent({
    required this.bookingService,
    required this.service,
    required this.selectedTargetClient,
    required this.onDateSelected,
  });

  @override
  State<_DatePickerSheetContent> createState() =>
      _DatePickerSheetContentState();
}

class _DatePickerSheetContentState extends State<_DatePickerSheetContent> {
  late final DateTime _minDate;
  late final DateTime _maxDate;

  bool _isLoadingUnavailableDates = true;
  final Set<String> _loadedMonths = <String>{};
  final Set<String> _loadingMonths = <String>{};
  final Set<DateTime> _blackoutDatesSet = <DateTime>{};

  List<DateTime> get _blackoutDates => _blackoutDatesSet.toList();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _minDate = DateTime(now.year, now.month, now.day);
    _maxDate = _minDate.add(const Duration(days: 90));
    _loadUnavailableDatesForVisibleDate(_minDate);
  }

  String _monthKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}';

  DateTime _monthStart(DateTime date) => DateTime(date.year, date.month, 1);

  DateTime _monthEnd(DateTime date) => DateTime(date.year, date.month + 1, 0);

  DateTime _maxDateTime(DateTime left, DateTime right) =>
      left.isAfter(right) ? left : right;

  DateTime _minDateTime(DateTime left, DateTime right) =>
      left.isBefore(right) ? left : right;

  Future<void> _loadUnavailableDatesForVisibleDate(DateTime visibleDate) async {
    final monthKey = _monthKey(visibleDate);
    if (_loadedMonths.contains(monthKey) || _loadingMonths.contains(monthKey)) {
      return;
    }

    final start = _maxDateTime(_monthStart(visibleDate), _minDate);
    final end = _minDateTime(_monthEnd(visibleDate), _maxDate);

    _loadingMonths.add(monthKey);

    if (mounted && _loadedMonths.isEmpty) {
      setState(() {
        _isLoadingUnavailableDates = true;
      });
    }

    try {
      final blocked = await widget.bookingService.getUnavailableDates(
        startDate: start,
        endDate: end,
        serviceId: widget.service.id,
        clientId: widget.selectedTargetClient?.id,
      );

      if (!mounted) return;
      setState(() {
        _blackoutDatesSet.addAll(
          blocked.map((date) => DateTime(date.year, date.month, date.day)),
        );
        _loadedMonths.add(monthKey);
        _isLoadingUnavailableDates = false;
      });
    } catch (e) {
      if (!mounted) return;

      final message = e.toString().replaceAll('Exception: ', '');
      AppSnackBar.showError(context, message);

      setState(() {
        _isLoadingUnavailableDates = false;
      });
    } finally {
      _loadingMonths.remove(monthKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.selectedTargetClient != null) ...[
          _SelectedClientBanner(client: widget.selectedTargetClient!),
          const SizedBox(height: AppTheme.spacingMd),
        ],
        const Text(
          'Selecione uma data para o agendamento.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppTheme.spacingXs),
        const Text(
          'Dias marcados em vermelho estão indisponíveis.',
          style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
        ),
        const SizedBox(height: AppTheme.spacingMd),
        if (_isLoadingUnavailableDates)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppTheme.spacingXl),
            child: Center(child: CircularProgressIndicator()),
          )
        else
          AppDatePicker(
            initialDisplayDate: _minDate,
            minDate: _minDate,
            maxDate: _maxDate,
            blackoutDates: _blackoutDates,
            selectionMode: DateRangePickerSelectionMode.single,
            // Admins booking for a client can pick any day — the backend
            // determines slot availability. The day-of-week filter is only
            // applied in the self-booking (client) flow.
            selectableDayPredicate: widget.selectedTargetClient != null
                ? null
                : (date) {
                    return date.weekday != DateTime.sunday &&
                        date.weekday != DateTime.monday;
                  },
            onSelectionChanged: (args) {
              if (args.value is DateTime) {
                widget.onDateSelected(args.value as DateTime);
              }
            },
            onViewChanged: (args) {
              final visibleStart = args.visibleDateRange.startDate;
              if (visibleStart == null) return;
              _loadUnavailableDatesForVisibleDate(visibleStart);
            },
          ),
      ],
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
      if (mounted) {
        setState(() {
          _services = services;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().replaceAll('Exception: ', '');
      AppSnackBar.showError(context, message);
      setState(() {
        _error = message;
        _isLoading = false;
      });
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
          child: AppButton(
            label: 'Tentar novamente',
            onPressed: () {
              setState(() {
                _isLoading = true;
                _error = null;
              });
              _load();
            },
          ),
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

class _SelectedClientBanner extends StatelessWidget {
  final BookingTargetClient client;

  const _SelectedClientBanner({required this.client});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Row(
        children: [
          const Icon(
            Icons.person_outline_rounded,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client.displayName,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (client.subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    client.subtitle!,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TargetClientsSheetContent extends StatefulWidget {
  final Future<List<BookingTargetClient>> Function() loadClients;
  final void Function(BookingTargetClient client) onClientSelected;

  const _TargetClientsSheetContent({
    required this.loadClients,
    required this.onClientSelected,
  });

  @override
  State<_TargetClientsSheetContent> createState() =>
      _TargetClientsSheetContentState();
}

class _TargetClientsSheetContentState
    extends State<_TargetClientsSheetContent> {
  List<BookingTargetClient>? _clients;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final clients = await widget.loadClients();
      if (mounted) {
        setState(() {
          _clients = clients;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().replaceAll('Exception: ', '');
      AppSnackBar.showError(context, message);
      setState(() {
        _error = message;
        _isLoading = false;
      });
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
          child: AppButton(
            label: 'Tentar novamente',
            onPressed: () {
              setState(() {
                _isLoading = true;
                _error = null;
              });
              _load();
            },
          ),
        ),
      );
    }

    final clients = _clients ?? [];
    if (clients.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppTheme.spacingXl),
        child: Center(
          child: Text(
            'Nenhum cliente cadastrado.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Column(
      children: clients.map((client) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
          child: AppCard(
            onTap: () => widget.onClientSelected(client),
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(client.displayName, style: AppTextStyles.heading3),
                      if (client.subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          client.subtitle!,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ],
                  ),
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
  final BookingTargetClient? selectedTargetClient;
  final VoidCallback onConfirmed;
  final VoidCallback? onBookingConfirmed;
  final RescheduleContext? rescheduleContext;

  const _TimesSheetContent({
    required this.bookingService,
    required this.service,
    required this.date,
    required this.selectedTargetClient,
    required this.onConfirmed,
    this.onBookingConfirmed,
    this.rescheduleContext,
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

  bool get _isReschedule => widget.rescheduleContext != null;

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
        clientId: widget.selectedTargetClient?.id,
      );
      if (mounted) {
        setState(() {
          _slots = slots;
          _isLoadingSlots = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().replaceAll('Exception: ', '');
      AppSnackBar.showError(context, message);
      setState(() {
        _error = message;
        _isLoadingSlots = false;
      });
    }
  }

  Future<void> _confirm() async {
    if (_selectedTime == null) return;
    setState(() => _isBooking = true);

    // Build startTime from selected date + time slot
    final timeParts = _selectedTime!.split(':');
    final startTime = DateTime(
      widget.date.year,
      widget.date.month,
      widget.date.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );

    try {
      if (_isReschedule) {
        final ctx = widget.rescheduleContext!;
        await ClientAppointmentsService().rescheduleAppointment(
          appointmentId: ctx.originalAppointmentId,
          serviceId: widget.service.id,
          startTime: startTime,
          applyLateRescheduleFee: ctx.applyFee ? true : null,
        );
      } else {
        await widget.bookingService.bookAppointment(
          serviceId: widget.service.id,
          date: widget.date,
          timeSlot: _selectedTime!,
          clientId: widget.selectedTargetClient?.id,
        );
      }

      if (!mounted) return;
      widget.onConfirmed();
      widget.onBookingConfirmed?.call();
      AppSnackBar.showSuccess(
        context,
        _isReschedule
            ? 'Agendamento reagendado com sucesso!'
            : widget.selectedTargetClient == null
            ? 'Agendamento confirmado com sucesso!'
            : 'Agendamento para ${widget.selectedTargetClient!.displayName} confirmado com sucesso!',
      );
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
        if (widget.selectedTargetClient != null) ...[
          _SelectedClientBanner(client: widget.selectedTargetClient!),
          const SizedBox(height: AppTheme.spacingLg),
        ],
        Text(
          'Serviço selecionado: ${widget.service.name}',
          style: AppTextStyles.body,
        ),
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
            child: AppButton(
              label: 'Tentar novamente',
              fullWidth: true,
              onPressed: () {
                setState(() {
                  _isLoadingSlots = true;
                  _error = null;
                });
                _loadSlots();
              },
            ),
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
                      color: selected
                          ? AppColors.brandPrimary
                          : AppColors.border,
                      width: selected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    time,
                    style: AppTextStyles.body.copyWith(
                      color: selected
                          ? AppColors.brandPrimary
                          : AppColors.textSecondary,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        const SizedBox(height: AppTheme.spacingXl),
        AppButton(
          label: _isReschedule
              ? 'Confirmar Reagendamento'
              : 'Confirmar Agendamento',
          fullWidth: true,
          isLoading: _isBooking,
          onPressed: (_selectedTime == null || _isBooking) ? null : _confirm,
        ),
        const SizedBox(height: AppTheme.spacingMd),
      ],
    );
  }
}
