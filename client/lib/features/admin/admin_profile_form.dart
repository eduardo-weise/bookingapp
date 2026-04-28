import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_avatar.dart';
import 'absences/admin_absences_flow.dart';
import '../auth/services/auth_service.dart';

class AdminProfileForm extends StatelessWidget {
  final VoidCallback onSave;

  const AdminProfileForm({
    super.key,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: AppAvatar(
            size: AvatarSize.large,
            initials: 'A',
            showEditBadge: true,
            onEditTap: () {
              // TODO: Implement image picker
            },
          ),
        ),
        const SizedBox(height: AppTheme.spacingMd),

        const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
            child: Text(
              'Altere sua foto de perfil tocando na imagem acima.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spacingXl),
        
        AppButton(
          label: 'Férias e Ausências',
          variant: AppButtonVariant.secondary,
          fullWidth: true,
          onPressed: () {
            final currentContext = Navigator.of(context).context;
            Navigator.pop(context); // Close profile sheet
            AdminAbsencesFlow.start(currentContext); // Open absences flow
          },
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
              Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil('/', (route) => false);
            }
          },
        ),
        const SizedBox(height: AppTheme.spacingMd),
      ],
    );
  }
}
