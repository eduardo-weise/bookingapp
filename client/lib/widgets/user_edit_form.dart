import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../widgets/app_button.dart';
import '../widgets/app_input.dart';
import '../widgets/app_avatar.dart';
import '../features/auth/services/auth_service.dart';

class UserEditForm extends StatelessWidget {
  final VoidCallback onSave;

  const UserEditForm({
    super.key,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar field
        Center(
          child: AppAvatar(
            size: AvatarSize.large,
            initials: 'M',
            showEditBadge: true,
            onEditTap: () {
              // TODO: Implement image picker
            },
          ),
        ),
        const SizedBox(height: AppTheme.spacingXl),

        const AppInput(
          label: 'Nome Completo',
          placeholder: 'Maria Silva',
        ),
        const SizedBox(height: AppTheme.spacingMd),
        const AppInput(
          label: 'Email',
          placeholder: 'maria@email.com',
          enabled: false,
        ),
        const SizedBox(height: AppTheme.spacingMd),
        const AppInput(
          label: 'CPF',
          placeholder: '000.000.000-00',
          enabled: false,
        ),
        const SizedBox(height: AppTheme.spacingMd),
        const AppInput(
          label: 'Telefone',
          placeholder: '(11) 99999-9999',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: AppTheme.spacingMd),
        const AppInput(
          label: 'Nova Senha',
          placeholder: '••••••••',
          obscureText: true,
        ),
        const SizedBox(height: AppTheme.spacingXl),

        AppButton(
          label: 'Salvar Alterações',
          fullWidth: true,
          onPressed: onSave,
        ),
        const SizedBox(height: AppTheme.spacingMd),
        AppButton(
          label: 'Sair da Conta (Logoff)',
          fullWidth: true,
          variant: AppButtonVariant.ghost,
          onPressed: () async {
            FocusScope.of(context).unfocus();
            await Future.delayed(const Duration(milliseconds: 100));
            await AuthService().logout();
            if (context.mounted) {
              Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil('/', (route) => false);
            }
          },
        ),
        const SizedBox(height: AppTheme.spacingMd),
      ],
    );
  }
}
