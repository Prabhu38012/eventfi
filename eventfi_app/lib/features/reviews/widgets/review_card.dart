import 'package:flutter/material.dart';
import '../models/review_model.dart';
import '../widgets/star_rating_widget.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_sizes.dart';

class ReviewCard extends StatelessWidget {
  final ReviewModel review;

  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final initial = review.userName.isNotEmpty
        ? review.userName[0].toUpperCase()
        : 'U';

    return Container(
      margin:     const EdgeInsets.only(bottom: AppSizes.md),
      padding:    const EdgeInsets.all(AppSizes.cardPadding),
      decoration: BoxDecoration(
        color:        AppColors.surface1,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────
          Row(children: [
            // Avatar
            Container(
              width: 38, height: 38,
              decoration: const BoxDecoration(
                color: AppColors.surface2,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  initial,
                  style: AppFonts.labelLarge.copyWith(
                    color: AppColors.accent, fontSize: 16),
                ),
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(review.userName,
                      style: AppFonts.labelMedium,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(review.formattedDate, style: AppFonts.caption),
                ],
              ),
            ),

            // Stars
            StarRatingDisplay(
              rating:     review.rating.toDouble(),
              size:       14,
              showNumber: false,
            ),
          ]),

          // ── Comment ──────────────────────────────────
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: AppSizes.sm),
            Text(review.comment,
                style: AppFonts.bodySmall.copyWith(
                    color: AppColors.textPrimary, height: 1.6)),
          ],
        ],
      ),
    );
  }
}
