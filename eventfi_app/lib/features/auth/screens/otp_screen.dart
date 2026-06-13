import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_sizes.dart';

class OtpScreen extends StatefulWidget {
  final String initialPhone;

  const OtpScreen({super.key, this.initialPhone = ''});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _phoneCtrl = TextEditingController();
  final _otpCtrl   = TextEditingController();
  bool  _otpSent   = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialPhone.isNotEmpty) _phoneCtrl.text = widget.initialPhone;
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid 10-digit phone number')),
      );
      return;
    }
    // Format with country code +91 (India)
    await context.read<AuthProvider>().sendOtp('+91$phone');
    if (mounted) setState(() => _otpSent = true);
  }

  Future<void> _verifyOtp() async {
    final otp = _otpCtrl.text.trim();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the 6-digit OTP')),
      );
      return;
    }
    final ok = await context.read<AuthProvider>().verifyOtp(otp);
    if (ok && mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final auth    = context.watch<AuthProvider>();
    final loading = auth.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title:   Text(_otpSent ? 'Verify OTP' : 'Phone Login', style: AppFonts.headlineSmall),
        leading: IconButton(
          icon:      const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () {
            if (_otpSent) {
              setState(() { _otpSent = false; _otpCtrl.clear(); });
            } else {
              context.canPop() ? context.pop() : context.go('/login');
            }
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.pagePadding),
          child: _otpSent
              ? _OtpStep(
                  phone:    '+91 ${_phoneCtrl.text}',
                  ctrl:     _otpCtrl,
                  loading:  loading,
                  error:    auth.error,
                  onClear:  auth.clearError,
                  onVerify: _verifyOtp,
                  onResend: () => setState(() { _otpSent = false; _otpCtrl.clear(); }),
                )
              : _PhoneStep(
                  ctrl:     _phoneCtrl,
                  loading:  loading,
                  error:    auth.error,
                  onClear:  auth.clearError,
                  onSend:   _sendOtp,
                ),
        ),
      ),
    );
  }
}

// ─── Step 1 — Enter Phone ────────────────────────────────────

class _PhoneStep extends StatelessWidget {
  final TextEditingController ctrl;
  final bool                  loading;
  final String?               error;
  final VoidCallback          onClear;
  final VoidCallback          onSend;

  const _PhoneStep({
    required this.ctrl,
    required this.loading,
    required this.error,
    required this.onClear,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSizes.lg),
        Text('Your phone number', style: AppFonts.tanker(fontSize: 30, color: AppColors.light)),
        const SizedBox(height: AppSizes.sm),
        Text('We\'ll send you a 6-digit verification code.', style: AppFonts.bodyMedium),
        const SizedBox(height: AppSizes.xxxl),

        if (error != null) ...[
          _ErrorBanner(message: error!, onDismiss: onClear),
          const SizedBox(height: AppSizes.lg),
        ],

        // Phone field with +91 prefix
        TextFormField(
          controller:     ctrl,
          keyboardType:   TextInputType.phone,
          maxLength:      10,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style:           AppFonts.inputText,
          decoration: InputDecoration(
            labelText:   'Phone number',
            counterText: '',
            prefixIcon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🇮🇳', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 6),
                  Text('+91', style: AppFonts.spaceGrotesk(fontSize: 15, color: AppColors.textPrimary)),
                  const SizedBox(width: 8),
                  Container(width: 1, height: 20, color: AppColors.border),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: AppSizes.xl),

        AppButton(
          text:      'Send OTP',
          onTap:     onSend,
          isLoading: loading,
        ),
      ],
    );
  }
}

// ─── Step 2 — Enter OTP ──────────────────────────────────────

class _OtpStep extends StatelessWidget {
  final String                ctrl_phone;
  final String                phone;
  final TextEditingController ctrl;
  final bool                  loading;
  final String?               error;
  final VoidCallback          onClear;
  final VoidCallback          onVerify;
  final VoidCallback          onResend;

  const _OtpStep({
    required this.phone,
    required this.ctrl,
    required this.loading,
    required this.error,
    required this.onClear,
    required this.onVerify,
    required this.onResend,
    this.ctrl_phone = '',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSizes.lg),
        Text('Enter OTP', style: AppFonts.tanker(fontSize: 30, color: AppColors.light)),
        const SizedBox(height: AppSizes.sm),
        Text('Sent to $phone', style: AppFonts.bodyMedium),
        const SizedBox(height: AppSizes.xxxl),

        if (error != null) ...[
          _ErrorBanner(message: error!, onDismiss: onClear),
          const SizedBox(height: AppSizes.lg),
        ],

        // 6-digit OTP field
        TextFormField(
          controller:      ctrl,
          keyboardType:    TextInputType.number,
          maxLength:       6,
          textAlign:       TextAlign.center,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style:           AppFonts.spaceGrotesk(fontSize: 28, weight: FontWeight.w700, color: AppColors.accent),
          decoration: const InputDecoration(
            hintText:    '— — — — — —',
            counterText: '',
          ),
        ),

        const SizedBox(height: AppSizes.xl),

        AppButton(
          text:      'Verify OTP',
          onTap:     onVerify,
          isLoading: loading,
        ),

        const SizedBox(height: AppSizes.lg),

        TextButton(
          onPressed: onResend,
          child: Text(
            'Didn\'t receive? Resend OTP',
            style: AppFonts.labelSmall.copyWith(color: AppColors.accent),
          ),
        ),
      ],
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
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: AppFonts.bodySmall.copyWith(color: AppColors.error))),
          GestureDetector(onTap: onDismiss, child: const Icon(Icons.close, color: AppColors.error, size: 16)),
        ],
      ),
    );
  }
}
