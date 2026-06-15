import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Interactive star rating — user taps to set rating
class StarRatingInput extends StatelessWidget {
  final int            rating;
  final ValueChanged<int> onChanged;
  final double         size;

  const StarRatingInput({
    super.key,
    required this.rating,
    required this.onChanged,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < rating;
        return GestureDetector(
          onTap: () => onChanged(i + 1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Icon(
              filled ? Icons.star_rounded : Icons.star_border_rounded,
              color: AppColors.gold,
              size:  size,
            ),
          ),
        );
      }),
    );
  }
}

/// Display-only star rating with optional count label
class StarRatingDisplay extends StatelessWidget {
  final double rating;
  final int?   count;
  final double size;
  final bool   showNumber;

  const StarRatingDisplay({
    super.key,
    required this.rating,
    this.count,
    this.size = 16,
    this.showNumber = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (i) {
          IconData icon;
          if (rating >= i + 1)      icon = Icons.star_rounded;
          else if (rating >= i + 0.5) icon = Icons.star_half_rounded;
          else                       icon = Icons.star_border_rounded;
          return Icon(icon, color: AppColors.gold, size: size);
        }),
        if (showNumber) ...[
          const SizedBox(width: 5),
          Text(
            count != null ? '$rating ($count)' : '$rating',
            style: TextStyle(
              fontSize:   size * 0.8,
              color:      AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
