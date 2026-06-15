import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_sizes.dart';

class CouponInput extends StatefulWidget {
  final bool    isLoading;
  final bool    isValid;
  final String? message;
  final Future<void> Function(String) onApply;
  final VoidCallback onRemove;

  const CouponInput({
    super.key,
    required this.isLoading,
    required this.isValid,
    this.message,
    required this.onApply,
    required this.onRemove,
  });

  @override
  State<CouponInput> createState() => _CouponInputState();
}

class _CouponInputState extends State<CouponInput> {
  final _ctrl = TextEditingController();

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Coupon Code', style: AppFonts.labelLarge),
        const SizedBox(height: AppSizes.sm),

        Row(children: [
          Expanded(
            child: TextField(
              controller:     _ctrl,
              style:          AppFonts.inputText,
              textCapitalization: TextCapitalization.characters,
              enabled:        !widget.isValid,
              decoration: InputDecoration(
                hintText:  'e.g. WELCOME10',
                hintStyle: AppFonts.hintText,
                filled:    true,
                fillColor: AppColors.surface3,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  borderSide:   BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  borderSide:   const BorderSide(color: AppColors.accent, width: 1.5),
                ),
                suffixIcon: widget.isValid
                    ? const Icon(Icons.check_circle_rounded,
                        color: AppColors.success)
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
              ),
            ),
          ),

          const SizedBox(width: AppSizes.sm),

          SizedBox(
            height: 48,
            child: widget.isValid
                ? OutlinedButton(
                    onPressed: () {
                      _ctrl.clear();
                      widget.onRemove();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                    ),
                    child: const Text('Remove'),
                  )
                : ElevatedButton(
                    onPressed: widget.isLoading
                        ? null
                        : () => widget.onApply(_ctrl.text.trim()),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: widget.isLoading
                        ? const SizedBox(width: 18, height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.dark))
                        : Text('Apply', style: AppFonts.buttonText),
                  ),
          ),
        ]),

        // Feedback message
        if (widget.message != null) ...[
          const SizedBox(height: 6),
          Text(
            widget.message!,
            style: AppFonts.caption.copyWith(
              color: widget.isValid ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ],
    );
  }
}
