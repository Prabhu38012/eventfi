import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_sizes.dart';

class PriceBreakdown extends StatelessWidget {
  final int    seats;
  final double pricePerSeat;
  final double discount;
  final String? couponCode;

  const PriceBreakdown({
    super.key,
    required this.seats,
    required this.pricePerSeat,
    required this.discount,
    this.couponCode,
  });

  double get base  => seats * pricePerSeat;
  double get total => base - discount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:     const EdgeInsets.all(AppSizes.lg),
      decoration:  BoxDecoration(
        color:        AppColors.surface1,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Price Breakdown', style: AppFonts.labelLarge),
          const SizedBox(height: AppSizes.md),
          const Divider(color: AppColors.divider),
          const SizedBox(height: AppSizes.md),

          _Row(
            label: '$seats seat${seats > 1 ? 's' : ''} × ₹${pricePerSeat.toInt()}',
            value: '₹${base.toInt()}',
          ),

          if (discount > 0) ...[
            const SizedBox(height: 8),
            _Row(
              label:      'Discount (${couponCode ?? 'coupon'})',
              value:      '− ₹${discount.toInt()}',
              valueColor: AppColors.success,
            ),
          ],

          const SizedBox(height: AppSizes.md),
          const Divider(color: AppColors.divider),
          const SizedBox(height: AppSizes.md),

          _Row(
            label:      'Total Amount',
            value:      '₹${total.toInt()}',
            isBold:     true,
            valueColor: AppColors.accent,
          ),

          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.star_rounded, color: AppColors.gold, size: 14),
            const SizedBox(width: 4),
            Text(
              'You earn ${(total / 100).floor()} Gold Points',
              style: AppFonts.caption.copyWith(color: AppColors.gold),
            ),
          ]),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool   isBold;
  final Color? valueColor;
  const _Row({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label,
          style: isBold ? AppFonts.labelLarge : AppFonts.bodySmall),
      Text(value,
          style: isBold
              ? AppFonts.spaceGrotesk(
                  fontSize: 18,
                  weight:   FontWeight.w700,
                  color:    valueColor ?? AppColors.textPrimary)
              : AppFonts.bodySmall.copyWith(
                  color: valueColor ?? AppColors.textPrimary)),
    ],
  );
}
