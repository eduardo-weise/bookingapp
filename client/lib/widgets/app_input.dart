import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/app_theme.dart';

class AppInput extends StatefulWidget {
  final String? label;
  final bool isRequired;
  final String? placeholder;
  final Widget? trailingIcon;
  final bool obscureText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool? enabled;
  final List<TextInputFormatter>? inputFormatters;
  final AutovalidateMode? autovalidateMode;

  const AppInput({
    super.key,
    this.label,
    this.isRequired = false,
    this.placeholder,
    this.trailingIcon,
    this.obscureText = false,
    this.controller,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.enabled,
    this.inputFormatters,
    this.autovalidateMode,
  });

  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> {
  late final FocusNode _focusNode;
  bool _blurredWhileEmpty = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && widget.isRequired) {
      final isEmpty = (widget.controller?.text ?? '').trim().isEmpty;
      if (isEmpty && !_blurredWhileEmpty) {
        setState(() => _blurredWhileEmpty = true);
      }
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  String? _effectiveValidator(String? value) {
    if (widget.isRequired && (value == null || value.trim().isEmpty)) {
      return 'Campo obrigatório';
    }
    return widget.validator?.call(value);
  }

  AutovalidateMode get _effectiveAutovalidateMode {
    if (_blurredWhileEmpty) return AutovalidateMode.always;
    return widget.autovalidateMode ?? AutovalidateMode.disabled;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          RichText(
            text: TextSpan(
              style: AppTextStyles.label,
              children: [
                TextSpan(text: widget.label!),
                if (widget.isRequired)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: AppColors.statusCancelled,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingXs),
        ],
        TextFormField(
          focusNode: _focusNode,
          controller: widget.controller,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          validator: _effectiveValidator,
          onChanged: widget.onChanged,
          enabled: widget.enabled,
          inputFormatters: widget.inputFormatters,
          autovalidateMode: _effectiveAutovalidateMode,
          style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: widget.placeholder,
            hintStyle: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
            suffixIcon: widget.trailingIcon != null
                ? Padding(
                    padding: const EdgeInsets.only(right: AppTheme.spacingMd),
                    child: Align(
                      alignment: Alignment.center,
                      widthFactor: 1.0,
                      child: IconButtonTheme(
                        data: IconButtonThemeData(
                          style: IconButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        child: IconTheme(
                          data: const IconThemeData(
                            color: AppColors.textSecondary,
                            size: 18,
                          ),
                          child: widget.trailingIcon!,
                        ),
                      ),
                    ),
                  )
                : null,
            suffixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            filled: true,
            fillColor: AppColors.inputBackground,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMd,
              vertical: AppTheme.spacingMd,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              borderSide: const BorderSide(
                color: AppColors.brandPrimary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              borderSide: const BorderSide(
                color: AppColors.statusCancelled,
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              borderSide: const BorderSide(
                color: AppColors.statusCancelled,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
