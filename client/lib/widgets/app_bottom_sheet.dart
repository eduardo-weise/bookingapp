import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/app_theme.dart';

enum BottomSheetHeight { small, medium, large, flexible }

Future<void> showAppBottomSheet({
  required BuildContext context,
  required Widget child,
  String? title,
  BottomSheetHeight height = BottomSheetHeight.medium,
  VoidCallback? onBack,
}) {
  final screenHeight = MediaQuery.of(context).size.height;
  final sheetHeight = switch (height) {
    BottomSheetHeight.small => screenHeight * 0.45,
    BottomSheetHeight.medium => screenHeight * 0.65,
    BottomSheetHeight.large => screenHeight * 0.80,
    BottomSheetHeight.flexible => null,
  };

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.overlay,
    builder: (context) => _AppBottomSheet(
      title: title,
      height: sheetHeight,
      onBack: onBack,
      child: child,
    ),
  );
}

class _AppBottomSheet extends StatelessWidget {
  final String? title;
  final double? height;
  final Widget child;
  final VoidCallback? onBack;

  const _AppBottomSheet({
    this.title,
    required this.height,
    required this.child,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final hasTitle = title != null && title!.isNotEmpty;
    final hasBack = onBack != null;

    return Container(
      height: height,
      constraints: height == null
          ? BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.70)
          : null,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppTheme.radiusXl),
          topRight: Radius.circular(AppTheme.radiusXl),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Center(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 12,
                bottom: AppTheme.spacingMd,
              ),
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          // Title row with optional back button
          if (hasTitle)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingLg,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Title always centered
                  Center(child: Text(title!, style: AppTextStyles.heading2)),
                  // Back button anchored to the left
                  if (hasBack)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: onBack,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.muted,
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusFull,
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          if (hasTitle) const SizedBox(height: AppTheme.spacingMd),
          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingLg,
              ),
              child: child,
            ),
          ),
          SizedBox(
            height:
                MediaQuery.of(context).viewInsets.bottom + AppTheme.spacingMd,
          ),
        ],
      ),
    );
  }
}
