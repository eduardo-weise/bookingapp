import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_input.dart';
import '../../../widgets/app_snackbar.dart';
import '../services/auth_service.dart';

class RecoveryEmailSheet extends StatefulWidget {
  final Function(String email) onSuccess;

  const RecoveryEmailSheet({super.key, required this.onSuccess});

  @override
  State<RecoveryEmailSheet> createState() => _RecoveryEmailSheetState();
}

class _RecoveryEmailSheetState extends State<RecoveryEmailSheet> {
  final _emailController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _sendCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      AppSnackBar.showError(context, 'Por favor, informe seu email.');
      Navigator.of(context).pop();
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.forgotPassword(email);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('recovery_email', email);
      await prefs.setString(
        'recovery_expiry',
        DateTime.now().add(const Duration(minutes: 15)).toIso8601String(),
      );

      if (mounted) {
        AppSnackBar.showSuccess(
          context,
          'Código enviado! Verifique seu email.',
        );
        widget.onSuccess(email);
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
    _emailController.dispose();
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
          'Recuperar Senha',
          style: AppTextStyles.heading2,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Text(
          'Digite seu email abaixo e enviaremos um link para redefinir sua senha',
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppTheme.spacingLg),
        AppInput(
          controller: _emailController,
          label: 'Email',
          placeholder: 'seu@email.com',
          trailingIcon: const Icon(Icons.mail_outline_rounded),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: AppTheme.spacingLg),
        AppButton(
          label: 'Enviar Código de Recuperação',
          fullWidth: true,
          isLoading: _isLoading,
          onPressed: _sendCode,
        ),
        const SizedBox(height: AppTheme.spacingMd),
      ],
    );
  }
}
