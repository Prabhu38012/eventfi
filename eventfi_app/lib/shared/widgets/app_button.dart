import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_sizes.dart';

class AppButton extends StatelessWidget {
  final String        text;
  final VoidCallback? onTap;
  final bool          isLoading;
  final bool          isOutlined;
  final Color?        backgroundColor;
  final Color?        foregroundColor;
  final double?       width;
  final double        height;
  final Widget?       prefixIcon;

  const AppButton({
    super.key,
    required this.text,
    this.onTap,
    this.isLoading     = false,
    this.isOutlined    = false,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.height        = AppSizes.buttonHeight,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppColors.accent;
    final fg = foregroundColor ?? (isOutlined ? AppColors.accent : AppColors.dark);

    final child = isLoading
        ? SizedBox(
            width:  20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (prefixIcon != null) ...[prefixIcon!, const SizedBox(width: 8)],
              Text(text, style: AppFonts.buttonText.copyWith(color: fg)),
            ],
          );

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
    );

    return SizedBox(
      width:  width ?? double.infinity,
      height: height,
      child: isOutlined
          ? OutlinedButton(
              onPressed: isLoading ? null : onTap,
              style: OutlinedButton.styleFrom(
                side:  BorderSide(color: bg, width: 1.5),
                shape: shape,
              ),
              child: child,
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: bg,
                foregroundColor: fg,
                shape:           shape,
                elevation:       0,
              ),
              child: child,
            ),
    );
  }
}
