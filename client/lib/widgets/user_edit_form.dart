import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../core/theme/app_theme.dart';
import '../widgets/app_button.dart';
import '../widgets/app_input.dart';
import '../widgets/app_avatar.dart';
import '../widgets/app_snackbar.dart';
import '../features/auth/services/auth_service.dart';
import '../features/client/services/user_profile_service.dart';

class UserEditForm extends StatefulWidget {
  final VoidCallback onSave;

  const UserEditForm({super.key, required this.onSave});

  @override
  State<UserEditForm> createState() => _UserEditFormState();
}

class _UserEditFormState extends State<UserEditForm> {
  final _profileService = UserProfileService();
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _cpfCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _phoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {'#': RegExp(r'[0-9]')},
  );

  bool _isLoading = true;
  bool _isSaving = false;
  String _initials = '?';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _cpfCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _profileService.getProfile();
      if (!mounted) return;
      setState(() {
        _nameCtrl.text = profile.name ?? '';
        _emailCtrl.text = profile.email;
        _cpfCtrl.text = profile.cpf ?? '';
        _phoneCtrl.text = profile.phoneNumber ?? '';
        _initials = profile.initials;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AppSnackBar.showError(
        context,
        e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      await _profileService.updateProfile(
        name: _nameCtrl.text.trim(),
        phoneNumber: _phoneCtrl.text,
      );
      if (!mounted) return;
      AppSnackBar.showSuccess(context, 'Perfil atualizado com sucesso!');
      widget.onSave();
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.showError(
        context,
        e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppTheme.spacingXl),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Center(
            child: AppAvatar(
              size: AvatarSize.large,
              initials: _initials,
              showEditBadge: true,
              onEditTap: () {
                // TODO: Implement image picker
              },
            ),
          ),
          const SizedBox(height: AppTheme.spacingXl),

          AppInput(
            label: 'Nome Completo',
            controller: _nameCtrl,
            placeholder: 'Seu nome',
            isRequired: true,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Informe seu nome' : null,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          AppInput(
            label: 'Email',
            controller: _emailCtrl,
            placeholder: 'seu@email.com',
            enabled: false,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          AppInput(
            label: 'CPF',
            controller: _cpfCtrl,
            placeholder: '000.000.000-00',
            enabled: false,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          AppInput(
            label: 'Telefone',
            controller: _phoneCtrl,
            placeholder: '(11) 99999-9999',
            keyboardType: TextInputType.phone,
            inputFormatters: [_phoneMask],
            isRequired: true,
            validator: (v) =>
                (v == null || v.length < 14) ? 'Telefone inválido' : null,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          AppInput(
            label: 'Nova Senha',
            controller: _passwordCtrl,
            placeholder: '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022',
            obscureText: true,
          ),
          const SizedBox(height: AppTheme.spacingXl),

          AppButton(
            label: 'Salvar Alterações',
            fullWidth: true,
            isLoading: _isSaving,
            onPressed: _isSaving ? null : _handleSave,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          AppButton(
            label: 'Sair da Conta',
            fullWidth: true,
            variant: AppButtonVariant.ghost,
            onPressed: () async {
              FocusScope.of(context).unfocus();
              await Future.delayed(const Duration(milliseconds: 100));
              await AuthService().logout();
              if (context.mounted) {
                Navigator.of(
                  context,
                  rootNavigator: true,
                ).pushNamedAndRemoveUntil('/', (route) => false);
              }
            },
          ),
          const SizedBox(height: AppTheme.spacingMd),
        ],
      ),
    );
  }
}
