import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_sizes.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool  _sent      = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSend() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await context.read<AuthProvider>().sendPasswordReset(
      _emailCtrl.text.trim(),
    );
    if (ok && mounted) setState(() => _sent = true);
  }

  @override
  Widget build(BuildContext context) {
    final auth    = context.watch<AuthProvider>();
    final loading = auth.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title:   Text('Reset Password', style: AppFonts.headlineSmall),
        leading: IconButton(
          icon:      const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.canPop() ? context.pop() : context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.pagePadding),
          child: _sent ? _SentState(email: _emailCtrl.text.trim()) : _FormState(
            formKey:   _formKey,
            emailCtrl: _emailCtrl,
            loading:   loading,
            error:     auth.error,
            onClear:   auth.clearError,
            onSend:    _onSend,
          ),
        ),
      ),
    );
  }
}

// ─── Form State ──────────────────────────────────────────────

class _FormState extends StatelessWidget {
  final GlobalKey<FormState>  formKey;
  final TextEditingController emailCtrl;
  final bool                  loading;
  final String?               error;
  final VoidCallback          onClear;
  final VoidCallback          onSend;

  const _FormState({
    required this.formKey,
    required this.emailCtrl,
    required this.loading,
    required this.error,
    required this.onClear,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSizes.lg),
          Text('Forgot your password?', style: AppFonts.tanker(fontSize: 30, color: AppColors.light)),
          const SizedBox(height: AppSizes.sm),
          Text(
            'Enter your email and we\'ll send you a reset link.',
            style: AppFonts.bodyMedium,
          ),
          const SizedBox(height: AppSizes.xxxl),

          if (error != null) ...[
            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color:        AppColors.error.withOpacity(0.12),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(error!, style: AppFonts.bodySmall.copyWith(color: AppColors.error))),
                  GestureDetector(onTap: onClear, child: const Icon(Icons.close, color: AppColors.error, size: 16)),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.lg),
          ],

          AuthTextField(
            label:        'Email address',
            controller:   emailCtrl,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textSecondary, size: 20),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please enter your email.';
              if (!v.contains('@'))       return 'Enter a valid email address.';
              return null;
            },
          ),

          const SizedBox(height: AppSizes.xl),

          AppButton(
            text:      'Send Reset Link',
            onTap:     onSend,
            isLoading: loading,
          ),
        ],
      ),
    );
  }
}

// ─── Sent Confirmation State ─────────────────────────────────

class _SentState extends StatelessWidget {
  final String email;

  const _SentState({required this.email});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.mark_email_read_outlined, color: AppColors.accent, size: 64),
        const SizedBox(height: AppSizes.xxl),
        Text('Check your email', style: AppFonts.tanker(fontSize: 30, color: AppColors.light), textAlign: TextAlign.center),
        const SizedBox(height: AppSizes.md),
        Text(
          'We sent a password reset link to\n$email',
          style:     AppFonts.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSizes.xxxl),
        AppButton(
          text:  'Back to Login',
          onTap: () => context.go('/login'),
        ),
      ],
    );
  }
}
