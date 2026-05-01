import 'package:flutter/material.dart';
import 'dart:async';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../main.dart';

class AppSnackBar {
  static OverlayEntry? _currentEntry;
  static Timer? _dismissTimer;

  static void showError(BuildContext context, String message) {
    _showOverlay(message: message, backgroundColor: AppColors.statusCancelled);
  }

  static void showSuccess(BuildContext context, String message) {
    _showOverlay(message: message, backgroundColor: AppColors.statusConfirmed);
  }

  static void _showOverlay({
    required String message,
    required Color backgroundColor,
  }) {
    _dismissCurrent();

    final overlayState = navigatorKey.currentState?.overlay;
    if (overlayState == null) {
      scaffoldMessengerKey.currentState
        ?..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              message,
              style: AppTextStyles.body.copyWith(color: AppColors.textInverse),
            ),
            backgroundColor: backgroundColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }

    _currentEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: IgnorePointer(
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Material(
                color: Colors.transparent,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Text(
                      message,
                      style: AppTextStyles.body.copyWith(color: AppColors.textInverse),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlayState.insert(_currentEntry!);
    _dismissTimer = Timer(const Duration(seconds: 4), _dismissCurrent);
  }

  static void _dismissCurrent() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _currentEntry?.remove();
    _currentEntry = null;
  }
}
