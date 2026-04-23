import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../../core/theme/app_theme.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_input.dart';
import '../../../widgets/app_snackbar.dart';
import '../services/auth_service.dart';

class RegisterSheet extends StatefulWidget {
  final VoidCallback onSuccess;

  const RegisterSheet({super.key, required this.onSuccess});

  @override
  State<RegisterSheet> createState() => _RegisterSheetState();
}

class _RegisterSheetState extends State<RegisterSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cpfCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  final _cpfMask = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {'#': RegExp(r'[0-9]')},
  );
  final _phoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {'#': RegExp(r'[0-9]')},
  );

  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _cpfCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordCtrl.text != _confirmCtrl.text) {
      AppSnackBar.showError(context, 'As senhas não coincidem.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.register(
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
        name: _nameCtrl.text,
        phone: _phoneCtrl.text,
        cpf: _cpfCtrl.text,
      );
      if (!mounted) return;
      widget.onSuccess();
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.showError(
        context,
        e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppInput(
            label: 'Nome Completo',
            controller: _nameCtrl,
            placeholder: 'Seu nome',
            trailingIcon: const Icon(Icons.person_outline_rounded),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Informe seu nome' : null,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          AppInput(
            label: 'CPF',
            controller: _cpfCtrl,
            placeholder: '000.000.000-00',
            trailingIcon: const Icon(Icons.badge_outlined),
            keyboardType: TextInputType.number,
            inputFormatters: [_cpfMask],
            validator: (v) =>
              (v == null || v.length != 14) ? 'CPF inválido' : null,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          AppInput(
            label: 'Email',
            controller: _emailCtrl,
            placeholder: 'seu@email.com',
            trailingIcon: const Icon(Icons.mail_outline_rounded),
            keyboardType: TextInputType.emailAddress,
            validator: (v) =>
              (v == null || !v.contains('@')) ? 'Email inválido' : null,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          AppInput(
            label: 'Telefone',
            controller: _phoneCtrl,
            placeholder: '(11) 99999-9999',
            trailingIcon: const Icon(Icons.phone_outlined),
            keyboardType: TextInputType.phone,
            inputFormatters: [_phoneMask],
            validator: (v) =>
              (v == null || v.length < 14) ? 'Telefone inválido' : null,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          AppInput(
            label: 'Senha',
            controller: _passwordCtrl,
            placeholder: '••••••••',
            obscureText: true,
            trailingIcon: const Icon(Icons.visibility_outlined),
            validator: (v) =>
              (v == null || v.length < 6) ? 'Mínimo de 6 caracteres' : null,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          AppInput(
            label: 'Confirmar Senha',
            controller: _confirmCtrl,
            placeholder: '••••••••',
            obscureText: true,
            trailingIcon: const Icon(Icons.visibility_outlined),
            validator: (v) =>
                (v != _passwordCtrl.text) ? 'Senhas diferentes' : null,
          ),
          const SizedBox(height: AppTheme.spacingXl),
          AppButton(
            label: 'Criar Conta',
            fullWidth: true,
            onPressed: _isLoading ? null : _handleRegister,
            isLoading: _isLoading,
          ),
          const SizedBox(height: AppTheme.spacingMd),
        ],
      ),
    );
  }
}
