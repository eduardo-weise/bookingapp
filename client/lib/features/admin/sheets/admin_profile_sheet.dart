import 'package:flutter/material.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/widgets/app_button.dart';
import 'package:app/widgets/app_avatar.dart';
import 'package:app/widgets/app_bottom_sheet.dart';
import '../absences/admin_absences_flow.dart';
import '../../auth/services/auth_service.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../client/providers/client_providers.dart';

void showAdminProfileSheet(BuildContext context) {
  showAppBottomSheet(
    context: context,
    title: 'Editar Perfil',
    height: BottomSheetHeight.flexible,
    child: _AdminProfileSheetContent(parentContext: context),
  );
}

class _AdminProfileSheetContent extends ConsumerWidget {
  const _AdminProfileSheetContent({required this.parentContext});

  final BuildContext parentContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return profileAsync.when(
      data: (profile) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: AppAvatar(
              size: AvatarSize.large,
              initials: profile.initials,
              showEditBadge: true,
              onEditTap: () {
                // TODO: Implement image picker
              },
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
              child: Text(
                'Olá, ${profile.displayName}!\nAltere sua foto de perfil tocando na imagem acima.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingXl),
          AppButton(
            label: 'Férias e Ausências',
            variant: AppButtonVariant.secondary,
            fullWidth: true,
            onPressed: () {
              Navigator.of(context).pop();
              AdminAbsencesFlow.start(
                parentContext,
                onBack: () {
                  Navigator.of(parentContext).pop();
                  showAdminProfileSheet(parentContext);
                },
              );
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
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Text('Erro ao carregar perfil: $error'),
      ),
    );
  }
}

