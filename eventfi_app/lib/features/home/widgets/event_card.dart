import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_sizes.dart';
import '../../events/models/event_model.dart';

class EventCard extends StatelessWidget {
  final EventModel event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/event/${event.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.md),
        decoration: BoxDecoration(
          color:        AppColors.surface1,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ─── Image / Banner ────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSizes.radiusLg),
              ),
              child: Stack(
                children: [
                  // Image
                  SizedBox(
                    height: AppSizes.cardImgHeight,
                    width:  double.infinity,
                    child:  _buildImage(),
                  ),

                  // Category badge
                  Positioned(
                    top: 10, left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color:        AppColors.dark.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(event.categoryIcon, size: 11, color: event.categoryColor),
                          const SizedBox(width: 4),
                          Text(event.categoryLabel,
                              style: AppFonts.badgeText.copyWith(
                                  color: event.categoryColor, fontSize: 11)),
                        ],
                      ),
                    ),
                  ),

                  // Wishlist button
                  Positioned(
                    top: 4, right: 4,
                    child: IconButton(
                      icon: const Icon(Icons.favorite_border_rounded,
                          color: Colors.white, size: 20),
                      onPressed: () {
                        // Phase 6: connect to wishlist
                      },
                    ),
                  ),
                ],
              ),
            ),

            // ─── Details ───────────────────────────────
            Padding(
              padding: const EdgeInsets.all(AppSizes.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: AppFonts.cardTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),

                  // Venue
                  Row(children: [
                    const Icon(Icons.location_on_outlined,
                        size: 13, color: AppColors.textHint),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        '${event.venue}, ${event.city}',
                        style: AppFonts.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 3),

                  // Date + time
                  Row(children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 13, color: AppColors.textHint),
                    const SizedBox(width: 3),
                    Text(event.formattedDate, style: AppFonts.caption),
                    const SizedBox(width: 10),
                    const Icon(Icons.access_time_outlined,
                        size: 13, color: AppColors.textHint),
                    const SizedBox(width: 3),
                    Text(event.time, style: AppFonts.caption),
                  ]),

                  const SizedBox(height: 10),

                  // Price + Book button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(event.priceDisplay, style: AppFonts.priceText),
                          Text(event.seatsLabel,
                              style: AppFonts.caption.copyWith(
                                  color: event.seatsColor)),
                        ],
                      ),
                      SizedBox(
                        height: 34,
                        child: ElevatedButton(
                          onPressed: event.hasSeatsLeft
                              ? () => context.push('/event/${event.id}')
                              : null,
                          style: ElevatedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 18),
                            minimumSize: Size.zero,
                          ),
                          child: Text('Book',
                              style: AppFonts.buttonText
                                  .copyWith(fontSize: 13)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (event.posterUrl != null && event.posterUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl:     event.posterUrl!,
        fit:          BoxFit.cover,
        placeholder:  (_, __) => _Placeholder(event),
        errorWidget:  (_, __, ___) => _Placeholder(event),
      );
    }
    return _Placeholder(event);
  }
}

class _Placeholder extends StatelessWidget {
  final EventModel event;
  const _Placeholder(this.event);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: event.categoryColor.withOpacity(0.12),
      child: Center(
        child: Icon(
          event.categoryIcon,
          size:  48,
          color: event.categoryColor.withOpacity(0.35),
        ),
      ),
    );
  }
}
