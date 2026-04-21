import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_input.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_bottom_sheet.dart';
import '../../widgets/app_snackbar.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'services/auth_service.dart';

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
      final role = await _authService.login(_emailCtrl.text, _passwordCtrl.text);
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
      child: _RegisterForm(
        onSuccess: () {
          Navigator.of(context).pushNamedAndRemoveUntil('/client', (route) => false);
        },
      ),
    );
  }

  void _showRecovery() {
    showAppBottomSheet(
      context: context,
      title: '',
      height: BottomSheetHeight.small,
      child: _RecoveryForm(onSuccess: () => Navigator.pop(context)),
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
                      obscureText: true,
                      trailingIcon: const Icon(Icons.visibility_outlined),
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

// ── Register Form ────────────────────────────────────────────────────────────
class _RegisterForm extends StatefulWidget {
  final VoidCallback onSuccess;
  const _RegisterForm({required this.onSuccess});

  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cpfCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  final _cpfMask = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );
  final _phoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _cpfCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordCtrl.text != _confirmCtrl.text) {
      AppSnackBar.showError(context, 'As senhas não coincidem.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.register(
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
        name: _nameCtrl.text,
        phone: _phoneCtrl.text,
        cpf: _cpfCtrl.text,
      );
      if (!mounted) return;
      widget.onSuccess();
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.showError(
        context,
        e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppInput(
            label: 'Nome Completo',
            controller: _nameCtrl,
            placeholder: 'Seu nome',
            trailingIcon: const Icon(Icons.person_outline_rounded),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Informe seu nome' : null,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          AppInput(
            label: 'CPF',
            controller: _cpfCtrl,
            placeholder: '000.000.000-00',
            trailingIcon: const Icon(Icons.badge_outlined),
            keyboardType: TextInputType.number,
            inputFormatters: [_cpfMask],
            validator: (v) =>
                (v == null || v.length != 14) ? 'CPF inválido' : null,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          AppInput(
            label: 'Email',
            controller: _emailCtrl,
            placeholder: 'seu@email.com',
            trailingIcon: const Icon(Icons.mail_outline_rounded),
            keyboardType: TextInputType.emailAddress,
            validator: (v) =>
                (v == null || !v.contains('@')) ? 'Email inválido' : null,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          AppInput(
            label: 'Telefone',
            controller: _phoneCtrl,
            placeholder: '(11) 99999-9999',
            trailingIcon: const Icon(Icons.phone_outlined),
            keyboardType: TextInputType.phone,
            inputFormatters: [_phoneMask],
            validator: (v) =>
                (v == null || v.length < 14) ? 'Telefone inválido' : null,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          AppInput(
            label: 'Senha',
            controller: _passwordCtrl,
            placeholder: '••••••••',
            obscureText: true,
            trailingIcon: const Icon(Icons.visibility_outlined),
            validator: (v) =>
                (v == null || v.length < 6) ? 'Mínimo de 6 caracteres' : null,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          AppInput(
            label: 'Confirmar Senha',
            controller: _confirmCtrl,
            placeholder: '••••••••',
            obscureText: true,
            trailingIcon: const Icon(Icons.visibility_outlined),
            validator: (v) =>
                (v != _passwordCtrl.text) ? 'Senhas diferentes' : null,
          ),
          const SizedBox(height: AppTheme.spacingXl),
          AppButton(
            label: 'Criar Conta',
            fullWidth: true,
            onPressed: _isLoading ? null : _handleRegister,
            isLoading: _isLoading,
          ),
          const SizedBox(height: AppTheme.spacingMd),
        ],
      ),
    );
  }
}

// ── Recovery Form ────────────────────────────────────────────────────────────
class _RecoveryForm extends StatelessWidget {
  final VoidCallback onSuccess;
  const _RecoveryForm({required this.onSuccess});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.muted,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          child: const Icon(
            Icons.lock_outline_rounded,
            color: AppColors.brandPrimary,
            size: 26,
          ),
        ),
        const SizedBox(height: AppTheme.spacingMd),
        Text(
          'Recuperar Senha',
          style: AppTextStyles.heading2,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Text(
          'Digite seu email abaixo e enviaremos um link para redefinir sua senha',
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppTheme.spacingLg),
        const AppInput(
          label: 'Email',
          placeholder: 'seu@email.com',
          trailingIcon: Icon(Icons.mail_outline_rounded),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: AppTheme.spacingLg),
        AppButton(
          label: 'Enviar Link de Recuperação',
          fullWidth: true,
          onPressed: onSuccess,
        ),
        const SizedBox(height: AppTheme.spacingMd),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Text(
            '← Voltar ao login',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spacingMd),
      ],
    );
  }
}
