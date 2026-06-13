import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/social_login_button.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey  = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool  _googleLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.loginWithEmail(
      email:    _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );
    if (ok && mounted) context.go('/home');
  }

  Future<void> _onGoogle() async {
    setState(() => _googleLoading = true);
    final ok = await context.read<AuthProvider>().signInWithGoogle();
    if (mounted) {
      setState(() => _googleLoading = false);
      if (ok) context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth    = context.watch<AuthProvider>();
    final loading = auth.status == AuthStatus.loading && !_googleLoading;

    return Scaffold(
      backgroundColor: AppColors.dark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.pagePadding,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 56),

                // ─── Header ──────────────────────────────
                Text(
                  AppStrings.appName,
                  style:     AppFonts.tanker(fontSize: 40, color: AppColors.light),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Welcome back',
                  style:     AppFonts.bodyMedium,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // ─── Error Banner ─────────────────────────
                if (auth.error != null) ...[
                  _ErrorBanner(
                    message:   auth.error!,
                    onDismiss: auth.clearError,
                  ),
                  const SizedBox(height: AppSizes.lg),
                ],

                // ─── Inputs ──────────────────────────────
                AuthTextField(
                  label:        AppStrings.email,
                  controller:   _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon:   const Icon(
                    Icons.email_outlined,
                    color: AppColors.textSecondary,
                    size:  20,
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty)    return AppStrings.errorInvalidEmail;
                    if (!v.contains('@'))           return AppStrings.errorInvalidEmail;
                    return null;
                  },
                ),

                const SizedBox(height: AppSizes.md),

                AuthTextField(
                  label:      AppStrings.password,
                  controller: _passCtrl,
                  isPassword: true,
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: AppColors.textSecondary,
                    size:  20,
                  ),
                  validator: (v) {
                    if (v == null || v.length < 6) return AppStrings.errorShortPass;
                    return null;
                  },
                ),

                const SizedBox(height: AppSizes.xs),

                // ─── Forgot Password ─────────────────────
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    child: Text(
                      AppStrings.forgotPass,
                      style: AppFonts.labelSmall.copyWith(color: AppColors.accent),
                    ),
                  ),
                ),

                const SizedBox(height: AppSizes.md),

                // ─── Login Button ─────────────────────────
                AppButton(
                  text:      AppStrings.login,
                  onTap:     _onLogin,
                  isLoading: loading,
                ),

                const SizedBox(height: AppSizes.xxl),

                // ─── Divider ─────────────────────────────
                _OrDivider(),

                const SizedBox(height: AppSizes.xxl),

                // ─── Social Buttons ───────────────────────
                Row(
                  children: [
                    Expanded(
                      child: SocialLoginButton(
                        label:     'Google',
                        icon:      _GoogleLogo(),
                        onTap:     _onGoogle,
                        isLoading: _googleLoading,
                      ),
                    ),
                    const SizedBox(width: AppSizes.md),
                    Expanded(
                      child: SocialLoginButton(
                        label: 'Phone',
                        icon:  const Icon(
                          Icons.phone_outlined,
                          color: AppColors.textPrimary,
                          size:  20,
                        ),
                        onTap: () => context.push('/otp', extra: ''),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSizes.xxxl),

                // ─── Sign Up Link ─────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppStrings.noAccount, style: AppFonts.bodySmall),
                    GestureDetector(
                      onTap: () => context.push('/signup'),
                      child: Text(
                        AppStrings.signup,
                        style: AppFonts.labelMedium.copyWith(color: AppColors.accent),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSizes.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Private Widgets ─────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String      message;
  final VoidCallback onDismiss;

  const _ErrorBanner({required this.message, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.lg,
        vertical:   AppSizes.md,
      ),
      decoration: BoxDecoration(
        color:        AppColors.error.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border:       Border.all(color: AppColors.error.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 18),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Text(
              message,
              style: AppFonts.bodySmall.copyWith(color: AppColors.error),
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: const Icon(Icons.close, color: AppColors.error, size: 16),
          ),
        ],
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.divider)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          child: Text(AppStrings.orContinueWith, style: AppFonts.caption),
        ),
        const Expanded(child: Divider(color: AppColors.divider)),
      ],
    );
  }
}

class _GoogleLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Text(
      'G',
      style: TextStyle(
        color:      Colors.white,
        fontSize:   18,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
