import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey  = GlobalKey<FormState>();
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSignup() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final ok = await auth.signUpWithEmail(
      name:     _nameCtrl.text.trim(),
      email:    _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );
    if (ok && mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final auth    = context.watch<AuthProvider>();
    final loading = auth.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title: Text('Create Account', style: AppFonts.headlineSmall),
        leading: IconButton(
          icon:     const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.canPop() ? context.pop() : context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.pagePadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSizes.lg),

                Text('Join EventFi', style: AppFonts.tanker(fontSize: 34, color: AppColors.light)),
                const SizedBox(height: 6),
                Text('Create your account to start booking', style: AppFonts.bodyMedium),
                const SizedBox(height: AppSizes.xxxl),

                // ─── Error ────────────────────────────────
                if (auth.error != null) ...[
                  _ErrorBanner(message: auth.error!, onDismiss: auth.clearError),
                  const SizedBox(height: AppSizes.lg),
                ],

                // ─── Full Name ────────────────────────────
                AuthTextField(
                  label:             AppStrings.fullName,
                  controller:        _nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    color: AppColors.textSecondary,
                    size:  20,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return AppStrings.errorEmptyName;
                    if (v.trim().length < 2)           return 'Name too short.';
                    return null;
                  },
                ),

                const SizedBox(height: AppSizes.md),

                // ─── Email ────────────────────────────────
                AuthTextField(
                  label:        AppStrings.email,
                  controller:   _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: AppColors.textSecondary,
                    size:  20,
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty)  return AppStrings.errorInvalidEmail;
                    if (!v.contains('@'))         return AppStrings.errorInvalidEmail;
                    return null;
                  },
                ),

                const SizedBox(height: AppSizes.md),

                // ─── Phone ────────────────────────────────
                AuthTextField(
                  label:          AppStrings.phoneNumber,
                  controller:     _phoneCtrl,
                  keyboardType:   TextInputType.phone,
                  maxLength:      10,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  prefixIcon: const Icon(
                    Icons.phone_outlined,
                    color: AppColors.textSecondary,
                    size:  20,
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty)  return null; // Phone is optional
                    if (v.length != 10)           return AppStrings.errorInvalidPhone;
                    return null;
                  },
                ),

                const SizedBox(height: AppSizes.md),

                // ─── Password ─────────────────────────────
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

                const SizedBox(height: AppSizes.xl),

                // ─── Hint ─────────────────────────────────
                Text(
                  'By creating an account you agree to our Terms of Service.',
                  style:     AppFonts.caption,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSizes.lg),

                // ─── Create Account Button ────────────────
                AppButton(
                  text:      'Create Account',
                  onTap:     _onSignup,
                  isLoading: loading,
                ),

                const SizedBox(height: AppSizes.xxl),

                // ─── Login Link ───────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppStrings.alreadyAccount, style: AppFonts.bodySmall),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Text(
                        AppStrings.login,
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

class _ErrorBanner extends StatelessWidget {
  final String       message;
  final VoidCallback onDismiss;

  const _ErrorBanner({required this.message, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg, vertical: AppSizes.md),
      decoration: BoxDecoration(
        color:        AppColors.error.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border:       Border.all(color: AppColors.error.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 18),
          const SizedBox(width: AppSizes.sm),
          Expanded(child: Text(message, style: AppFonts.bodySmall.copyWith(color: AppColors.error))),
          GestureDetector(onTap: onDismiss, child: const Icon(Icons.close, color: AppColors.error, size: 16)),
        ],
      ),
    );
  }
}
