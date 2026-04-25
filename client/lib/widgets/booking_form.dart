import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/app_theme.dart';
import '../widgets/app_button.dart';
import '../widgets/app_bottom_sheet.dart';
import '../widgets/app_card.dart';

class BookingFlow {
  static const _services = [
    {'name': 'Corte de Cabelo', 'duration': '45min', 'price': 50.0},
    {'name': 'Manicure', 'duration': '30min', 'price': 40.0},
    {'name': 'Massagem', 'duration': '60min', 'price': 120.0},
    {'name': 'Depilação', 'duration': '40min', 'price': 80.0},
  ];

  static const _availableTimes = [
    '09:00',
    '10:00',
    '11:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
    '18:00',
  ];

  static void start(BuildContext context) {
    _showServicesSheet(context);
  }

  static void _showServicesSheet(BuildContext context) {
    showAppBottomSheet(
      context: context,
      title: 'Selecione o Serviço',
      height: BottomSheetHeight.flexible,
      child: Column(
        children: _services.map((s) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
            child: AppCard(
              onTap: () {
                Navigator.of(context).pop();
                _showDatePickerSheet(context, s['name'] as String);
              },
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s['name'] as String, style: AppTextStyles.heading3),
                      const SizedBox(height: 2),
                      Text(
                        '${s['duration']} • R\$ ${(s['price'] as double).toStringAsFixed(2)}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  static void _showDatePickerSheet(BuildContext context, String serviceName) {
    showAppBottomSheet(
      context: context,
      title: 'Data - $serviceName',
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
              _showTimesSheet(context, serviceName, date);
            },
          ),
        ],
      ),
    );
  }

  static void _showTimesSheet(
    BuildContext context,
    String serviceName,
    DateTime date,
  ) {
    String? selectedTime;

    showAppBottomSheet(
      context: context,
      title:
          'Horário - ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
      height: BottomSheetHeight.flexible,
      onBack: () {
        Navigator.of(context).pop();
        _showDatePickerSheet(context, serviceName);
      },
      child: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Serviço selecionado: $serviceName',
                style: AppTextStyles.body,
              ),
              const SizedBox(height: AppTheme.spacingLg),
              Text(
                'Horários Disponíveis',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppTheme.spacingSm),
              Wrap(
                spacing: AppTheme.spacingSm,
                runSpacing: AppTheme.spacingSm,
                children: _availableTimes.map((time) {
                  final selected = selectedTime == time;
                  return GestureDetector(
                    onTap: () => setState(() => selectedTime = time),
                    child: Container(
                      width:
                          (MediaQuery.of(context).size.width - 48 - 24 - 16) /
                          3, // Roughly 3 columns
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
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
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
                onPressed: selectedTime == null
                    ? null
                    : () {
                        // Confirm and close the flow
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
