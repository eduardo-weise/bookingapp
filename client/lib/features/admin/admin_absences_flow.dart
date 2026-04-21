import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_bottom_sheet.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_input.dart';

class AdminAbsencesFlow {
  static void start(BuildContext context) {
    _showAbsencesSheet(context);
  }

  static void _showAbsencesSheet(BuildContext context) {
    // Mock data for current absences
    final absences = [
      {'reason': 'Férias', 'period': '10 Dez - 20 Dez'},
      {'reason': 'Assuntos Pessoais', 'period': '15 Mai (Dia Inteiro)'},
    ];

    showAppBottomSheet(
      context: context,
      title: 'Ausências / Férias',
      height: BottomSheetHeight.flexible,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gerencie os dias que você não estará disponível.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppTheme.spacingLg),
          if (absences.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(AppTheme.spacingXl),
                child: Text('Nenhuma ausência programada', style: TextStyle(color: AppColors.textTertiary)),
              ),
            )
          else
            ...absences.map((a) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
                child: AppCard(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a['reason'] as String, style: AppTextStyles.heading3),
                          Text(a['period'] as String, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
                        ],
                      ),
                      const SizedBox(),
                      // Optionally an edit/delete icon button could go here
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: AppTheme.spacingXl),
          AppButton(
            label: 'Nova Ausência',
            fullWidth: true,
            onPressed: () {
              final safeContext = Navigator.of(context).context;
              Navigator.pop(context); // close list
              _showCreateAbsenceSheet(safeContext);
            },
          ),
        ],
      ),
    );
  }

  static void _showCreateAbsenceSheet(BuildContext context) {
    bool isFullDay = true;
    DateTime? startDate;
    DateTime? endDate;

    showAppBottomSheet(
      context: context,
      title: 'Registrar Ausência',
      height: BottomSheetHeight.flexible,
      child: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppInput(
                label: 'Motivo',
                placeholder: 'Ex: Férias, Imprevisto',
              ),
              const SizedBox(height: AppTheme.spacingLg),
              
              Text('Tipo de Ausência', style: AppTextStyles.label),
              const SizedBox(height: AppTheme.spacingSm),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Dia Único',
                      variant: isFullDay ? AppButtonVariant.primary : AppButtonVariant.secondary,
                      onPressed: () => setState(() => isFullDay = true),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingSm),
                  Expanded(
                    child: AppButton(
                      label: 'Período',
                      variant: !isFullDay ? AppButtonVariant.primary : AppButtonVariant.secondary,
                      onPressed: () => setState(() => isFullDay = false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingLg),

              Text('Data Inicial', style: AppTextStyles.label),
              const SizedBox(height: AppTheme.spacingSm),
              GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                  );
                  if (date != null) setState(() => startDate = date);
                },
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
                        startDate != null
                            ? '${startDate!.day.toString().padLeft(2, "0")}/${startDate!.month.toString().padLeft(2, "0")}/${startDate!.year}'
                            : 'Selecionar',
                        style: AppTextStyles.body.copyWith(
                          color: startDate != null ? AppColors.textPrimary : AppColors.textSecondary,
                        ),
                      ),
                      const Icon(Icons.calendar_today, size: 18, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),

              if (!isFullDay) ...[
                const SizedBox(height: AppTheme.spacingMd),
                Text('Data Final', style: AppTextStyles.label),
                const SizedBox(height: AppTheme.spacingSm),
                GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: startDate ?? DateTime.now(),
                      firstDate: startDate ?? DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                    );
                    if (date != null) setState(() => endDate = date);
                  },
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
                          endDate != null
                              ? '${endDate!.day.toString().padLeft(2, "0")}/${endDate!.month.toString().padLeft(2, "0")}/${endDate!.year}'
                              : 'Selecionar',
                          style: AppTextStyles.body.copyWith(
                            color: endDate != null ? AppColors.textPrimary : AppColors.textSecondary,
                          ),
                        ),
                        const Icon(Icons.calendar_today, size: 18, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: AppTheme.spacingXl),
              AppButton(
                label: 'Salvar Ausência',
                fullWidth: true,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: AppTheme.spacingMd),
            ],
          );
        },
      ),
    );
  }
}
