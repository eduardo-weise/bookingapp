import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_input.dart';
import '../../../widgets/app_snackbar.dart';
import '../services/auth_service.dart';

class RecoveryTokenSheet extends StatefulWidget {
  final String email;
  final Function(String token) onSuccess;

  const RecoveryTokenSheet({
    super.key,
    required this.email,
    required this.onSuccess,
  });

  @override
  State<RecoveryTokenSheet> createState() => _RecoveryTokenSheetState();
}

class _RecoveryTokenSheetState extends State<RecoveryTokenSheet> {
  final _tokenController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _validateToken() async {
    final token = _tokenController.text.trim();
    if (token.isEmpty) {
      AppSnackBar.showError(context, 'Por favor, informe o código recebido.');
      Navigator.of(context).pop();
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.validateResetToken(email: widget.email, token: token);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('recovery_validated_token', token);

      if (mounted) {
        AppSnackBar.showSuccess(context, 'Código validado!');
        widget.onSuccess(token);
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(
          context,
          e.toString().replaceAll('Exception: ', ''),
        );
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.muted,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          child: const Icon(
            Icons.lock_outline_rounded,
            color: AppColors.brandPrimary,
            size: 26,
          ),
        ),
        const SizedBox(height: AppTheme.spacingMd),
        Text(
          'Validar Código',
          style: AppTextStyles.heading2,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Text(
          'Digite o código de 6 dígitos enviado para seu email',
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppTheme.spacingLg),
        AppInput(
          controller: _tokenController,
          label: 'Código Recebido',
          placeholder: 'Ex: 123456',
          keyboardType: TextInputType.number,
          trailingIcon: const Icon(Icons.pin_outlined),
        ),
        const SizedBox(height: AppTheme.spacingLg),
        AppButton(
          label: 'Validar Código',
          fullWidth: true,
          isLoading: _isLoading,
          onPressed: _validateToken,
        ),
        const SizedBox(height: AppTheme.spacingMd),
      ],
    );
  }
}
