import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../main.dart';

class AppSnackBar {
  static void showError(BuildContext context, String message) {
    scaffoldMessengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: AppTextStyles.body.copyWith(color: AppColors.textInverse),
          ),
          backgroundColor: AppColors.statusCancelled,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  static void showSuccess(BuildContext context, String message) {
    scaffoldMessengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: AppTextStyles.body.copyWith(color: AppColors.textInverse),
          ),
          backgroundColor: AppColors.statusConfirmed,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}
