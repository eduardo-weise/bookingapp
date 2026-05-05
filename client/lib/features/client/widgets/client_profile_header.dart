import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/client/providers/client_providers.dart';
import 'package:app/widgets/app_avatar.dart';
import 'package:app/widgets/page_header.dart';

class ClientProfileHeader extends ConsumerWidget {
  final VoidCallback onEditTap;

  const ClientProfileHeader({super.key, required this.onEditTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return profileAsync.when(
      data: (profile) {
        final name = profile.displayName;
        final initials = profile.initials;
        return _buildContent(name, initials);
      },
      loading: () => _buildContent('', '?'), // Show loading state
      error: (error, stackTrace) => _buildContent('', '?'),
    );
  }

  Widget _buildContent(String name, String initials) {
    return Column(
      children: [
        PageHeader(
          name: name.isNotEmpty ? 'Olá, $name' : 'Olá!',
          notificationCount: 1,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingLg),
          child: Center(
            child: AppAvatar(
              size: AvatarSize.large,
              initials: initials,
              showEditBadge: true,
              onEditTap: onEditTap,
            ),
          ),
        ),
      ],
    );
  }
}
