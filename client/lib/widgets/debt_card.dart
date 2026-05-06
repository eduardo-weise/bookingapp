import 'package:flutter/material.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/widgets/app_button.dart';

class DebtCard extends StatelessWidget {
  final String amount;
  final String description;
  final VoidCallback onPayPressed;
  final VoidCallback onCancelPressed;
  final EdgeInsetsGeometry margin;

  const DebtCard({
    super.key,
    required this.amount,
    required this.description,
    required this.onPayPressed,
    required this.onCancelPressed,
    this.margin = const EdgeInsets.only(bottom: AppTheme.spacingSm),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A1A), Color(0xFF2D2D2D)],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 340;
              final actionsWidth = isCompact ? 170.0 : 200.0;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          amount,
                          maxLines: 1,
                          softWrap: false,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingSm),
                  SizedBox(
                    width: actionsWidth,
                    child: Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: 'Pagar',
                            variant: AppButtonVariant.secondary,
                            small: true,
                            fullWidth: true,
                            onPressed: onPayPressed,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingSm),
                        Expanded(
                          child: AppButton(
                            label: 'Cancelar',
                            variant: AppButtonVariant.danger,
                            small: true,
                            fullWidth: true,
                            onPressed: onCancelPressed,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            description,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}