import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_fonts.dart';
import '../../core/constants/app_sizes.dart';

class AppSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    bool isError = false,
    bool isSuccess = false,
  }) {
    final color = isError
        ? AppColors.error
        : isSuccess
            ? AppColors.success
            : AppColors.surface2;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: AppFonts.bodySmall.copyWith(color: AppColors.textPrimary),
          ),
          backgroundColor: color,
          behavior:  SnackBarBehavior.floating,
          margin:    const EdgeInsets.all(AppSizes.lg),
          shape:     RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
        ),
      );
  }

  static void error(BuildContext context, String msg) =>
      show(context, message: msg, isError: true);

  static void success(BuildContext context, String msg) =>
      show(context, message: msg, isSuccess: true);
}
