import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_sizes.dart';

class PointsBalanceCard extends StatelessWidget {
  final int    balance;
  final String tier;
  final String tierEmoji;
  final int    pointsToNextTier;
  final double tierProgress;

  const PointsBalanceCard({
    super.key,
    required this.balance,
    required this.tier,
    required this.tierEmoji,
    required this.pointsToNextTier,
    required this.tierProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width:   double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color:        AppColors.surface1,
        borderRadius: BorderRadius.circular(20),
        border:       Border.all(color: AppColors.gold.withOpacity(0.35), width: 1),
      ),
      child: Column(
        children: [

          // ─── Label ───────────────────────────────────────
          Text(
            'GOLD POINTS',
            style: AppFonts.caption.copyWith(
              color:          AppColors.gold,
              letterSpacing:  2.5,
            ),
          ),

          const SizedBox(height: 6),

          // ─── Balance ─────────────────────────────────────
          Text(
            '$balance',
            style: AppFonts.tanker(fontSize: 68, color: AppColors.gold),
          ),

          const SizedBox(height: 8),

          // ─── Tier badge ──────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            decoration: BoxDecoration(
              color:        AppColors.gold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              border:       Border.all(
                color: AppColors.gold.withOpacity(0.3), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(tierEmoji, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(
                  tier,
                  style: AppFonts.labelMedium
                      .copyWith(color: AppColors.gold, fontSize: 13),
                ),
              ],
            ),
          ),

          // ─── Progress to next tier ───────────────────────
          if (pointsToNextTier > 0) ...[
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$tier Member',
                  style: AppFonts.caption,
                ),
                Text(
                  '$pointsToNextTier pts to next tier',
                  style: AppFonts.caption
                      .copyWith(color: AppColors.gold.withOpacity(0.8)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value:           tierProgress,
                minHeight:       6,
                backgroundColor: AppColors.surface3,
                valueColor:      const AlwaysStoppedAnimation<Color>(AppColors.gold),
              ),
            ),
          ] else ...[
            const SizedBox(height: 10),
            Text(
              '✦ Maximum Tier Achieved ✦',
              style: AppFonts.caption.copyWith(color: AppColors.gold),
            ),
          ],

          const SizedBox(height: 16),

          // ─── Earn rate note ───────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color:        AppColors.surface2,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline_rounded,
                    color: AppColors.textHint, size: 13),
                const SizedBox(width: 6),
                Text(
                  '₹100 spent = 1 Gold Point · Points expire in 90 days',
                  style: AppFonts.caption.copyWith(fontSize: 10.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
