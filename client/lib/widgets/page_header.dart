import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/app_theme.dart';
import 'app_avatar.dart';

/// Reusable page header with avatar, greeting text and notification bell.
///
/// Used in both Client Home and Admin Dashboard.
class PageHeader extends StatelessWidget {
  final String? greeting;
  final String name;
  final int notificationCount;
  final VoidCallback? onNotificationTap;
  final String? imageUrl;
  final String initials;
  final bool showEditBadge;
  final VoidCallback? onAvatarTap;

  const PageHeader({
    super.key,
    this.greeting,
    required this.name,
    this.notificationCount = 0,
    this.onNotificationTap,
    this.imageUrl,
    required this.initials,
    this.showEditBadge = false,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacingLg,
        AppTheme.spacingLg,
        AppTheme.spacingLg,
        AppTheme.spacingXl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Avatar centered, bell pinned top-right
          Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: AppTheme.spacingSm),
                child: AppAvatar(
                  size: AvatarSize.large,
                  initials: initials,
                  imageUrl: imageUrl,
                  showEditBadge: showEditBadge,
                  onEditTap: onAvatarTap,
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: GestureDetector(
                  onTap: onNotificationTap,
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusSm),
                        ),
                        child: const Icon(
                          Icons.notifications_none_rounded,
                          size: 22,
                          color: AppColors.brandPrimary,
                        ),
                      ),
                      if (notificationCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.statusCancelled,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (greeting != null) ...[
                Text(
                  greeting!,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXs),
              ],
              Text(name, style: AppTextStyles.heading1),
            ],
          ),
        ],
      ),
    );
  }
}
