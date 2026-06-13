import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_sizes.dart';
import '../../events/models/event_model.dart';
import '../../../shared/widgets/app_loader.dart';

class TrendingSection extends StatelessWidget {
  final List<EventModel> events;
  final bool loading;

  const TrendingSection({
    super.key,
    required this.events,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── Header ────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.pagePadding),
          child: Row(children: [
            Text('Trending Now', style: AppFonts.headlineSmall),
            const SizedBox(width: 6),
            const Text('🔥', style: TextStyle(fontSize: 16)),
          ]),
        ),

        const SizedBox(height: AppSizes.md),

        // ─── Horizontal List ────────────────────────
        SizedBox(
          height: 160,
          child: loading
              ? ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.pagePadding),
                  scrollDirection: Axis.horizontal,
                  itemCount: 4,
                  itemBuilder: (_, __) => const TrendingCardSkeleton(),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.pagePadding),
                  scrollDirection: Axis.horizontal,
                  itemCount: events.length,
                  itemBuilder: (_, i) => _TrendingCard(event: events[i]),
                ),
        ),

        const SizedBox(height: AppSizes.sectionGap),
      ],
    );
  }
}

class _TrendingCard extends StatelessWidget {
  final EventModel event;
  const _TrendingCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/event/${event.id}'),
      child: Container(
        width: 148,
        margin: const EdgeInsets.only(right: AppSizes.md),
        decoration: BoxDecoration(
          color:        AppColors.surface1,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Color banner + icon
            Container(
              height: 80,
              decoration: BoxDecoration(
                color:        event.categoryColor.withOpacity(0.15),
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppSizes.radiusMd)),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      event.categoryIcon,
                      size:  36,
                      color: event.categoryColor.withOpacity(0.4),
                    ),
                  ),
                  // Rank badge
                  Positioned(
                    top: 6, right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color:        AppColors.dark.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '₹${event.price.toInt()}',
                        style: AppFonts.badgeText.copyWith(
                            color: AppColors.accent, fontSize: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Details
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: AppFonts.labelSmall
                        .copyWith(color: AppColors.textPrimary, fontSize: 11),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${event.city} · ${event.shortDate}',
                    style: AppFonts.caption.copyWith(fontSize: 10),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
