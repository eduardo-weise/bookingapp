import 'package:flutter/material.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/app_theme.dart';
import 'app_button.dart';

/// A dark gradient banner that shows a pending debt amount.
///
/// Accepts formatted strings so it works for both client-facing
/// and admin-facing contexts.
class DebtBanner extends StatelessWidget {
  final String title;
  final String amount;
  final String description;
  final String buttonLabel;
  final VoidCallback onPaymentPressed;
  final String? cancelLabel;
  final VoidCallback? onCancelPressed;
  final EdgeInsetsGeometry? margin;

  const DebtBanner({
    super.key,
    this.title = 'Débito Pendente',
    required this.amount,
    required this.description,
    this.buttonLabel = 'Pagar',
    required this.onPaymentPressed,
    this.cancelLabel,
    this.onCancelPressed,
    this.margin = const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1A1A), Color(0xFF2D2D2D)],
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingXs),
                      Text(
                        amount,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                IntrinsicWidth(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppButton(
                        label: buttonLabel,
                        variant: AppButtonVariant.secondary,
                        small: true,
                        fullWidth: true,
                        onPressed: onPaymentPressed,
                      ),
                      if (onCancelPressed != null) ...[
                        const SizedBox(height: AppTheme.spacingSm),
                        AppButton(
                          label: cancelLabel ?? 'Cancelar',
                          variant: AppButtonVariant.danger,
                          small: true,
                          fullWidth: true,
                          onPressed: onCancelPressed,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
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
      ),
    );
  }
}
