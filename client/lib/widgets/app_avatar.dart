import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

enum AvatarSize { small, medium, large }

class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? initials;
  final AvatarSize size;
  final bool showEditBadge;
  final VoidCallback? onEditTap;

  const AppAvatar({
    super.key,
    this.imageUrl,
    this.initials,
    this.size = AvatarSize.medium,
    this.showEditBadge = false,
    this.onEditTap,
  });

  double get _diameter => switch (size) {
    AvatarSize.small => 40,
    AvatarSize.medium => 56,
    AvatarSize.large => 80,
  };

  double get _fontSize => switch (size) {
    AvatarSize.small => 14,
    AvatarSize.medium => 18,
    AvatarSize.large => 28,
  };

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: _diameter,
          height: _diameter,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.muted,
            border: Border.all(
              color: AppColors.textTertiary.withValues(alpha: 0.25),
              width: 1,
            ),
            image: imageUrl != null
                ? DecorationImage(
                    image: NetworkImage(imageUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: imageUrl == null
              ? Center(
                  child: Text(
                    initials ?? '?',
                    style: TextStyle(
                      fontSize: _fontSize,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
              : null,
        ),
        if (showEditBadge)
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: onEditTap,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: AppColors.brandPrimary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit,
                  size: 10,
                  color: AppColors.textInverse,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
