import 'package:flutter/material.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_text_styles.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/widgets/app_button.dart';
import 'package:app/widgets/app_card.dart';
import 'package:app/widgets/app_snackbar.dart';
import 'package:app/widgets/app_empty_state.dart';
import '../services/absence_service.dart';

class AbsencesListSheet extends StatefulWidget {
  final AbsenceService service;
  final void Function(BuildContext ctx) onCreateTap;

  const AbsencesListSheet({
    super.key,
    required this.service,
    required this.onCreateTap,
  });

  @override
  State<AbsencesListSheet> createState() => _AbsencesListSheetState();
}

class _AbsencesListSheetState extends State<AbsencesListSheet> {
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
      if (mounted) {
        setState(() {
          _future = items;
          _isLoadingFuture = false;
        });
      }
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
        AppSnackBar.showError(
          context,
          e.toString().replaceAll('Exception: ', ''),
        );
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
        else if (_error != null || _future.isEmpty)
          const AppEmptyState(message: 'Nenhuma ausência futura programada.')
        else
          ..._future.map(
            (a) => _AbsenceCard(absence: a, onDelete: () => _delete(a)),
          ),

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
            const AppEmptyState(message: 'Nenhuma ausência passada.')
          else
            ..._past.map(
              (a) => _AbsenceCard(absence: a, onDelete: () => _delete(a)),
            ),
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
                const Icon(
                  Icons.event_busy_outlined,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
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
