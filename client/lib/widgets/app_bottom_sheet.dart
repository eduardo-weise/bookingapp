import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/app_theme.dart';

enum BottomSheetHeight { small, medium, large, flexible }

const _bottomSheetAnimationStyle = AnimationStyle(
  duration: Duration(milliseconds: 320),
  reverseDuration: Duration(milliseconds: 240),
);

Future<void> showAppBottomSheet({
  required BuildContext context,
  required Widget child,
  Object? title,
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
    sheetAnimationStyle: _bottomSheetAnimationStyle,
    builder: (context) => _AppBottomSheet(
      title: title,
      height: sheetHeight,
      onBack: onBack,
      child: child,
    ),
  );
}

class _AppBottomSheet extends StatelessWidget {
  final Object? title;
  final double? height;
  final Widget child;
  final VoidCallback? onBack;

  const _AppBottomSheet({
    this.title,
    required this.height,
    required this.child,
    this.onBack,
  });

  bool _hasTitle() {
    if (title == null) return false;
    if (title is String) return (title as String).isNotEmpty;
    if (title is ValueNotifier<String>) {
      return (title as ValueNotifier<String>).value.isNotEmpty;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final backAction = onBack ?? () => Navigator.of(context).pop();

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
          // Header row with mandatory back button and optional centered title
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingLg,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_hasTitle())
                  Center(
                    child: title is ValueNotifier<String>
                        ? ValueListenableBuilder<String>(
                            valueListenable: title as ValueNotifier<String>,
                            builder: (context, titleValue, _) {
                              return Text(titleValue,
                                  style: AppTextStyles.heading2);
                            },
                          )
                        : Text(title as String,
                            style: AppTextStyles.heading2),
                  ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: backAction,
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
          const SizedBox(height: AppTheme.spacingMd),
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
