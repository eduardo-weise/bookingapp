import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_input.dart';
import '../../../widgets/app_snackbar.dart';
import '../services/auth_service.dart';

class RecoveryNewPasswordSheet extends StatefulWidget {
  final String email;
  final String token;
  final VoidCallback onSuccess;

  const RecoveryNewPasswordSheet({
    super.key,
    required this.email,
    required this.token,
    required this.onSuccess,
  });

  @override
  State<RecoveryNewPasswordSheet> createState() =>
      _RecoveryNewPasswordSheetState();
}

class _RecoveryNewPasswordSheetState extends State<RecoveryNewPasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  final _passwordPattern = RegExp(r'^.{8,}$');

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      AppSnackBar.showError(context, 'Corrija os campos antes de continuar.');
      return;
    }

    final password = _newPasswordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    setState(() => _isLoading = true);
    try {
      await _authService.resetPassword(
        email: widget.email,
        token: widget.token,
        newPassword: password,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('recovery_email');
      await prefs.remove('recovery_expiry');
      await prefs.remove('recovery_validated_token');

      if (mounted) {
        AppSnackBar.showSuccess(
          context,
          'Senha redefinida com sucesso! Você já pode fazer login.',
        );
        widget.onSuccess();
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
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
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
          'Redefinir Senha',
          style: AppTextStyles.heading2,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Text(
          'Digite a nova senha para a sua conta',
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppTheme.spacingLg),
        AppInput(
          controller: _newPasswordController,
          label: 'Nova Senha',
          placeholder: 'Mínimo 8 caracteres',
          obscureText: _obscurePassword,
          validator: (value) {
            final password = value?.trim() ?? '';
            if (password.isEmpty) {
              return 'Informe a nova senha.';
            }
            if (!_passwordPattern.hasMatch(password)) {
              return 'A senha deve ter no mínimo 8 caracteres.';
            }
            return null;
          },
          trailingIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.textSecondary,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        const SizedBox(height: AppTheme.spacingMd),
        AppInput(
          controller: _confirmPasswordController,
          label: 'Confirmar Nova Senha',
          placeholder: 'Repita a nova senha',
          obscureText: _obscurePassword,
          validator: (value) {
            final confirm = value?.trim() ?? '';
            if (confirm.isEmpty) {
              return 'Confirme a nova senha.';
            }
            if (confirm != _newPasswordController.text.trim()) {
              return 'As senhas não coincidem.';
            }
            return null;
          },
        ),
        const SizedBox(height: AppTheme.spacingLg),
        AppButton(
          label: 'Redefinir Senha',
          fullWidth: true,
          isLoading: _isLoading,
          onPressed: _resetPassword,
        ),
        const SizedBox(height: AppTheme.spacingMd),
        ],
      ),
    );
  }
}
