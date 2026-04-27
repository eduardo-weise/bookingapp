import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/app_bottom_sheet.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_snackbar.dart';
import 'services/absence_service.dart';

class AdminAbsencesFlow {
  static final _service = AbsenceService();

  static void start(BuildContext context) {
    showAppBottomSheet(
      context: context,
      title: 'Ausências / Férias',
      height: BottomSheetHeight.large,
      child: _AbsencesSheetContent(
        service: _service,
        onCreateTap: (ctx) {
          Navigator.of(ctx).pop();
          _showCreateSheet(ctx);
        },
      ),
    );
  }

  static void _showCreateSheet(BuildContext context) {
    showAppBottomSheet(
      context: context,
      title: 'Registrar Ausência',
      height: BottomSheetHeight.flexible,
      onBack: () {
        Navigator.of(context).pop();
        start(context);
      },
      child: _CreateAbsenceSheetContent(
        service: _service,
        onSaved: () {
          Navigator.of(context).pop();
          start(context);
        },
      ),
    );
  }
}

// ── Absences list sheet ────────────────────────────────────────────────────────

class _AbsencesSheetContent extends StatefulWidget {
  final AbsenceService service;
  final void Function(BuildContext ctx) onCreateTap;

  const _AbsencesSheetContent({
    required this.service,
    required this.onCreateTap,
  });

  @override
  State<_AbsencesSheetContent> createState() => _AbsencesSheetContentState();
}

class _AbsencesSheetContentState extends State<_AbsencesSheetContent> {
  List<AbsenceDayModel> _future = [];
  List<AbsenceDayModel> _past = [];
  bool _isLoadingFuture = true;
  bool _isLoadingPast = false;
  bool _showPast = false;
  bool _hasMorePast = true;
  int _pastPage = 1;
  String? _error;

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadFuture();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_showPast || _isLoadingPast || !_hasMorePast) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      _loadMorePast();
    }
  }

  Future<void> _loadFuture() async {
    try {
      final items = await widget.service.getFutureAbsences();
      if (mounted) setState(() { _future = items; _isLoadingFuture = false; });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoadingFuture = false;
        });
      }
    }
  }

  Future<void> _loadMorePast() async {
    if (_isLoadingPast || !_hasMorePast) return;
    setState(() => _isLoadingPast = true);
    try {
      final items = await widget.service.getPastAbsences(page: _pastPage);
      if (mounted) {
        setState(() {
          _past.addAll(items);
          _pastPage++;
          _hasMorePast = items.length == 10;
          _isLoadingPast = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingPast = false);
    }
  }

  Future<void> _delete(AbsenceDayModel absence) async {
    try {
      await widget.service.deleteAbsence(absence.id);
      if (!mounted) return;
      setState(() {
        _future.remove(absence);
        _past.remove(absence);
      });
      AppSnackBar.showSuccess(context, 'Ausência removida.');
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gerencie os dias que você não estará disponível.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppTheme.spacingLg),

        // ── Future absences ──
        if (_isLoadingFuture)
          const Center(child: CircularProgressIndicator())
        else if (_error != null)
          Text(_error!, style: const TextStyle(color: AppColors.statusCancelled))
        else if (_future.isEmpty)
          const Text(
            'Nenhuma ausência futura programada.',
            style: TextStyle(color: AppColors.textTertiary),
          )
        else
          ..._future.map((a) => _AbsenceCard(absence: a, onDelete: () => _delete(a))),

        // ── Past absences toggle ──
        const SizedBox(height: AppTheme.spacingLg),
        if (!_showPast)
          AppButton(
            label: 'Ver ausências passadas',
            variant: AppButtonVariant.ghost,
            onPressed: () {
              setState(() => _showPast = true);
              _loadMorePast();
            },
          )
        else ...[
          Text('Ausências Passadas', style: AppTextStyles.label),
          const SizedBox(height: AppTheme.spacingSm),
          if (_past.isEmpty && !_isLoadingPast)
            const Text(
              'Nenhuma ausência passada.',
              style: TextStyle(color: AppColors.textTertiary),
            )
          else
            ..._past.map((a) => _AbsenceCard(absence: a, onDelete: () => _delete(a))),
          if (_isLoadingPast)
            const Padding(
              padding: EdgeInsets.all(AppTheme.spacingMd),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (!_hasMorePast && _past.isNotEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
              child: Center(
                child: Text(
                  'Todas as ausências carregadas.',
                  style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
                ),
              ),
            ),
          if (_hasMorePast && !_isLoadingPast)
            AppButton(
              label: 'Carregar mais',
              variant: AppButtonVariant.ghost,
              onPressed: _loadMorePast,
            ),
        ],

        const SizedBox(height: AppTheme.spacingXl),
        AppButton(
          label: 'Nova Ausência',
          fullWidth: true,
          onPressed: () => widget.onCreateTap(context),
        ),
        const SizedBox(height: AppTheme.spacingMd),
      ],
    );
  }
}

class _AbsenceCard extends StatelessWidget {
  final AbsenceDayModel absence;
  final VoidCallback onDelete;

  const _AbsenceCard({required this.absence, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      child: AppCard(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: AppTheme.spacingSm,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.event_busy_outlined, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: AppTheme.spacingSm),
                Text(absence.formattedDate, style: AppTextStyles.body),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              color: AppColors.statusCancelled,
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Create absence sheet ───────────────────────────────────────────────────────

class _CreateAbsenceSheetContent extends StatefulWidget {
  final AbsenceService service;
  final VoidCallback onSaved;

  const _CreateAbsenceSheetContent({
    required this.service,
    required this.onSaved,
  });

  @override
  State<_CreateAbsenceSheetContent> createState() =>
      _CreateAbsenceSheetContentState();
}

class _CreateAbsenceSheetContentState
    extends State<_CreateAbsenceSheetContent> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isSingleDay = true;
  bool _isSaving = false;

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? _startDate ?? DateTime.now());
    final first = isStart ? DateTime.now() : (_startDate ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
        // Reset end if before new start
        if (_endDate != null && _endDate!.isBefore(picked)) _endDate = null;
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _save() async {
    if (_startDate == null) return;
    final end = _isSingleDay ? _startDate! : (_endDate ?? _startDate!);

    setState(() => _isSaving = true);
    try {
      await widget.service.createAbsence(startDate: _startDate!, endDate: end);
      if (!mounted) return;
      widget.onSaved();
      AppSnackBar.showSuccess(context, 'Ausência registrada com sucesso!');
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Selecionar';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Widget _datePicker({required String label, required DateTime? value, required VoidCallback onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: AppTheme.spacingSm),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(value),
                  style: AppTextStyles.body.copyWith(
                    color: value != null ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                ),
                const Icon(Icons.calendar_today, size: 18, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final canSave = _startDate != null && (_isSingleDay || _endDate != null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Type toggle
        Text('Tipo de Ausência', style: AppTextStyles.label),
        const SizedBox(height: AppTheme.spacingSm),
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Dia Único',
                variant: _isSingleDay ? AppButtonVariant.primary : AppButtonVariant.secondary,
                onPressed: () => setState(() { _isSingleDay = true; _endDate = null; }),
              ),
            ),
            const SizedBox(width: AppTheme.spacingSm),
            Expanded(
              child: AppButton(
                label: 'Período',
                variant: !_isSingleDay ? AppButtonVariant.primary : AppButtonVariant.secondary,
                onPressed: () => setState(() => _isSingleDay = false),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingLg),

        _datePicker(
          label: _isSingleDay ? 'Data' : 'Data Inicial',
          value: _startDate,
          onTap: () => _pickDate(isStart: true),
        ),

        if (!_isSingleDay) ...[
          const SizedBox(height: AppTheme.spacingMd),
          _datePicker(
            label: 'Data Final',
            value: _endDate,
            onTap: () => _pickDate(isStart: false),
          ),
        ],

        const SizedBox(height: AppTheme.spacingXl),
        AppButton(
          label: 'Salvar Ausência',
          fullWidth: true,
          isLoading: _isSaving,
          onPressed: canSave && !_isSaving ? _save : null,
        ),
        const SizedBox(height: AppTheme.spacingMd),
      ],
    );
  }
}
