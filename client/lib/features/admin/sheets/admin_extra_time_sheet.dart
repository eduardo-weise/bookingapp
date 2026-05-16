import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_text_styles.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/widgets/app_button.dart';
import 'package:app/widgets/app_bottom_sheet.dart';
import 'package:app/features/admin/services/admin_clients_service.dart';
import 'package:app/features/admin/providers/admin_providers.dart';
import 'package:app/features/admin/sheets/admin_clients_sheet.dart';

void showAdminExtraTimeSheet({
  required BuildContext context,
  required AdminClientModel client,
  required Function(String clientId, List<String> debtIds) onPayDebts,
  required Function(String clientId, List<String> debtIds) onCancelDebts,
}) {
  showAppBottomSheet(
    context: context,
    title: 'Tempo Extra - ${client.displayName}',
    height: BottomSheetHeight.flexible,
    onBack: () {
      Navigator.of(context).pop();
      showAdminClientsSheet(
        context: context,
        onPayDebts: onPayDebts,
        onCancelDebts: onCancelDebts,
      );
    },
    child: _ExtraTimeForm(
      client: client,
      onBackToClients: () {
        showAdminClientsSheet(
          context: context,
          onPayDebts: onPayDebts,
          onCancelDebts: onCancelDebts,
        );
      },
    ),
  );
}

class _ExtraTimeForm extends ConsumerStatefulWidget {
  final AdminClientModel client;
  final VoidCallback onBackToClients;

  const _ExtraTimeForm({required this.client, required this.onBackToClients});

  @override
  ConsumerState<_ExtraTimeForm> createState() => _ExtraTimeFormState();
}

class _ExtraTimeFormState extends ConsumerState<_ExtraTimeForm> {
  late int _selectedMinutes;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedMinutes = widget.client.extraDurationMinutes;
  }

  Future<void> _save() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    try {
      final service = ref.read(adminClientsServiceProvider);
      await service.updateClientExtraDuration(widget.client.id, _selectedMinutes);
      
      if (mounted) {
        Navigator.of(context).pop(); // Close this sheet
        ref.read(adminAllClientsProvider.notifier).refresh();
        widget.onBackToClients(); // Return to clients list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.statusCancelled,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Selecione o tempo extra que será adicionado a todos os agendamentos deste cliente:',
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppTheme.spacingLg),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              isExpanded: true,
              value: _selectedMinutes,
              items: [0, 5, 10, 15, 20, 25, 30].map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(value == 0 ? 'Sem tempo extra' : '$value minutos'),
                );
              }).toList(),
              onChanged: (int? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedMinutes = newValue;
                  });
                }
              },
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spacingXl),
        AppButton(
          label: 'Salvar',
          fullWidth: true,
          onPressed: _save,
          isLoading: _isLoading,
        ),
      ],
    );
  }
}
