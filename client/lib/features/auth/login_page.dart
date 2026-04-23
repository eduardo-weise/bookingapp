import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_input.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_bottom_sheet.dart';
import '../../widgets/app_snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/auth_service.dart';
import 'sheets/recovery_email_sheet.dart';
import 'sheets/recovery_new_password_sheet.dart';
import 'sheets/recovery_token_sheet.dart';
import 'sheets/register_sheet.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _authService = AuthService();

  bool _rememberMe = false;
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final role = await _authService.login(
        _emailCtrl.text,
        _passwordCtrl.text,
      );
      if (!mounted) return;
      if (role.toLowerCase() == 'admin') {
        Navigator.pushReplacementNamed(context, '/admin');
      } else {
        Navigator.pushReplacementNamed(context, '/client');
      }
    } catch (e) {
      if (!mounted) return;
      setState(
        () => _errorMessage = e.toString().replaceAll('Exception: ', ''),
      );
      AppSnackBar.showError(context, _errorMessage!);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showRegister() {
    showAppBottomSheet(
      context: context,
      title: 'Criar Conta',
      height: BottomSheetHeight.large,
      child: RegisterSheet(
        onSuccess: () {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/client', (route) => false);
        },
      ),
    );
  }

  Future<void> _showRecovery() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryStr = prefs.getString('recovery_expiry');
    final validatedToken = prefs.getString('recovery_validated_token');
    final email = prefs.getString('recovery_email');

    if (validatedToken != null && email != null) {
      // Já tem token validado, abre a tela de nova senha
      await _showRecoveryNewPassword(email, validatedToken);
      return;
    }

    if (expiryStr != null && email != null) {
      final expiry = DateTime.tryParse(expiryStr);
      if (expiry != null && expiry.isAfter(DateTime.now())) {
        // Token ainda na validade, vai pra tela de token
        await _showRecoveryToken(email);
        return;
      }
    }

    // Caso não exista validade ou tenha expirado
    await _showRecoveryEmail();
  }

  Future<void> _showRecoveryEmail() async {
    String? nextEmail;

    await showAppBottomSheet(
      context: context,
      title: '',
      height: BottomSheetHeight.flexible,
      child: RecoveryEmailSheet(
        onSuccess: (email) {
          nextEmail = email;
        },
      ),
    );

    if (!mounted || nextEmail == null) return;
    await _showRecoveryToken(nextEmail!);
  }

  Future<void> _showRecoveryToken(String email) async {
    String? validatedToken;

    await showAppBottomSheet(
      context: context,
      title: '',
      height: BottomSheetHeight.flexible,
      child: RecoveryTokenSheet(
        email: email,
        onSuccess: (token) {
          validatedToken = token;
        },
      ),
    );

    if (!mounted || validatedToken == null) return;
    await _showRecoveryNewPassword(email, validatedToken!);
  }

  Future<void> _showRecoveryNewPassword(String email, String token) async {
    await showAppBottomSheet(
      context: context,
      title: '',
      height: BottomSheetHeight.flexible,
      child: RecoveryNewPasswordSheet(
        email: email,
        token: token,
        onSuccess: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: Column(
            children: [
              const SizedBox(height: AppTheme.spacing2Xl),

              // Logo + Title
              Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1A1A1A), Color(0xFF2D2D2D)],
                      ),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      boxShadow: AppTheme.shadowMd,
                    ),
                    child: const Icon(
                      Icons.calendar_today_rounded,
                      color: AppColors.textInverse,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  Text(
                    'BookingApp',
                    style: AppTextStyles.heading1.copyWith(fontSize: 32),
                  ),
                  const SizedBox(height: AppTheme.spacingXs),
                  Text(
                    'Agende seus serviços com facilidade',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppTheme.spacing2Xl),

              // Login card — using AppCard
              AppCard(
                padding: const EdgeInsets.all(AppTheme.spacingXl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Entrar na sua conta', style: AppTextStyles.heading2),
                    const SizedBox(height: AppTheme.spacingLg),

                    AppInput(
                      label: 'Email',
                      controller: _emailCtrl,
                      placeholder: 'seu@email.com',
                      trailingIcon: const Icon(Icons.mail_outline_rounded),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    AppInput(
                      label: 'Senha',
                      controller: _passwordCtrl,
                      placeholder: '••••••••',
                      obscureText: _obscurePassword,
                      trailingIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingMd),

                    // Remember me + Forgot password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () =>
                              setState(() => _rememberMe = !_rememberMe),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: Checkbox(
                                  value: _rememberMe,
                                  onChanged: (v) =>
                                      setState(() => _rememberMe = v ?? false),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  side: const BorderSide(
                                    color: AppColors.border,
                                  ),
                                  activeColor: AppColors.brandPrimary,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                              const SizedBox(width: AppTheme.spacingXs),
                              Text(
                                'Lembrar-me',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: _showRecovery,
                          child: Text(
                            'Esqueceu a senha?',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.brandPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingMd),

                    AppButton(
                      label: 'Entrar',
                      onPressed: _isLoading ? null : _handleLogin,
                      fullWidth: true,
                      isLoading: _isLoading,
                    ),

                    // Divider "ou"
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppTheme.spacingMd,
                      ),
                      child: Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacingSm,
                            ),
                            child: Text(
                              'ou',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                    ),

                    // Register link
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Não tem uma conta? ',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          GestureDetector(
                            onTap: _showRegister,
                            child: Text(
                              'Cadastre-se',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.brandPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Demo buttons
                    const SizedBox(height: AppTheme.spacingLg),
                    const Divider(),
                    const SizedBox(height: AppTheme.spacingMd),
                    Center(
                      child: Text(
                        'Acesso rápido (demonstração)',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingSm),
                    AppButton(
                      label: 'Entrar como Cliente',
                      variant: AppButtonVariant.secondary,
                      fullWidth: true,
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/client'),
                    ),
                    const SizedBox(height: AppTheme.spacingSm),
                    AppButton(
                      label: 'Entrar como Admin',
                      variant: AppButtonVariant.ghost,
                      fullWidth: true,
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/admin'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacingXl),
            ],
          ),
        ),
      ),
    );
  }
}
