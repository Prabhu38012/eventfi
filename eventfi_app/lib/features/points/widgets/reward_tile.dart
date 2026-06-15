import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_sizes.dart';

class RewardTile extends StatelessWidget {
  final Map<String, dynamic> reward;
  final int                  userPoints;
  final bool                 isRedeeming;
  final VoidCallback         onRedeem;

  const RewardTile({
    super.key,
    required this.reward,
    required this.userPoints,
    required this.isRedeeming,
    required this.onRedeem,
  });

  bool get canRedeem => userPoints >= (reward['points'] as int);
  int  get pointsNeeded => (reward['points'] as int) - userPoints;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(AppSizes.cardPadding),
      decoration: BoxDecoration(
        color:        AppColors.surface1,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border:       Border.all(
          color: canRedeem
              ? AppColors.gold.withOpacity(0.4)
              : AppColors.border,
          width: canRedeem ? 1.2 : 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ─── Emoji ─────────────────────────────────────
          Text(reward['emoji'] ?? '🎁',
              style: const TextStyle(fontSize: 34)),

          const SizedBox(height: AppSizes.sm),

          // ─── Name ──────────────────────────────────────
          Text(
            reward['name'] ?? '',
            style: AppFonts.labelLarge.copyWith(fontSize: 13),
            maxLines: 2,
          ),

          const SizedBox(height: 4),

          Text(
            reward['description'] ?? '',
            style: AppFonts.caption,
            maxLines: 2,
          ),

          const Spacer(),

          const Divider(color: AppColors.divider),

          // ─── Points cost ───────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                const Icon(Icons.star_rounded,
                    color: AppColors.gold, size: 14),
                const SizedBox(width: 4),
                Text(
                  '${reward['points']} pts',
                  style: AppFonts.labelSmall
                      .copyWith(color: AppColors.gold),
                ),
              ]),

              // Redeem / locked
              canRedeem
                  ? SizedBox(
                      height: 30,
                      child: ElevatedButton(
                        onPressed: isRedeeming ? null : onRedeem,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          minimumSize: Size.zero,
                          textStyle: const TextStyle(fontSize: 11),
                        ),
                        child: isRedeeming
                            ? const SizedBox(
                                width: 14, height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  color: AppColors.dark))
                            : const Text('Redeem'),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Icon(Icons.lock_outline_rounded,
                            color: AppColors.textHint, size: 14),
                        Text(
                          '+$pointsNeeded more',
                          style: AppFonts.caption
                              .copyWith(fontSize: 9),
                        ),
                      ],
                    ),
            ],
          ),
        ],
      ),
    );
  }
}
