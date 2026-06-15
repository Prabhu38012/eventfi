import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/event_provider.dart';
import '../widgets/event_gallery.dart';
import '../widgets/organizer_card.dart';
import '../widgets/event_map_widget.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../shared/widgets/app_snackbar.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;
  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().loadEvent(widget.eventId);
    });
  }

  void _share(String title, String venue, String city, String date, String time) {
    if (kIsWeb) {
      Clipboard.setData(ClipboardData(
        text: '$title\n$venue, $city\n$date at $time\n\nBooked via EventFi',
      ));
      AppSnackbar.success(context, 'Event details copied to clipboard');
    } else {
      Share.share(
        'Check out $title on EventFi!\n$venue, $city\n$date at $time',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ep = context.watch<EventProvider>();

    // ── Loading ────────────────────────────────────────────
    if (ep.loading) {
      return const Scaffold(
        backgroundColor: AppColors.dark,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.accent, strokeWidth: 2,
          ),
        ),
      );
    }

    // ── Error ──────────────────────────────────────────────
    if (ep.error != null || ep.event == null) {
      return Scaffold(
        backgroundColor: AppColors.dark,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              Text(ep.error ?? 'Event not found', style: AppFonts.bodyMedium),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      );
    }

    final event = ep.event!;

    return Scaffold(
      backgroundColor: AppColors.dark,
      body: CustomScrollView(
        slivers: [

          // ── Gallery SliverAppBar ───────────────────────
          SliverAppBar(
            expandedHeight: 280,
            pinned:          true,
            backgroundColor: AppColors.dark,
            elevation:       0,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () => context.canPop() ? context.pop() : context.go('/home'),
                child: Container(
                  decoration: BoxDecoration(
                    color:  AppColors.dark.withOpacity(0.65),
                    shape:  BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 18, color: AppColors.light),
                ),
              ),
            ),
            actions: [
              // Wishlist
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: GestureDetector(
                  onTap: ep.toggleWishlist,
                  child: Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color:  AppColors.dark.withOpacity(0.65),
                      shape:  BoxShape.circle,
                    ),
                    child: Icon(
                      ep.inWishlist
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      size:  18,
                      color: ep.inWishlist ? Colors.redAccent : AppColors.light,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Share
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8, right: 8),
                child: GestureDetector(
                  onTap: () => _share(
                    event.title, event.venue,
                    event.city, event.formattedDate, event.time,
                  ),
                  child: Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color:  AppColors.dark.withOpacity(0.65),
                      shape:  BoxShape.circle,
                    ),
                    child: const Icon(Icons.share_outlined,
                        size: 18, color: AppColors.light),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: EventGallery(event: event, height: 280),
            ),
          ),

          // ── Detail Content ─────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.pagePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Category badge
                  _CategoryBadge(event: event),
                  const SizedBox(height: 12),

                  // Title
                  Text(event.title,
                      style: AppFonts.heroTitle.copyWith(fontSize: 28),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),

                  const SizedBox(height: 20),

                  // Info rows
                  _InfoRow(icon: Icons.calendar_today_outlined, label: 'Date',  value: event.formattedDate),
                  _InfoRow(icon: Icons.access_time_outlined,    label: 'Time',  value: event.time),
                  _InfoRow(icon: Icons.location_on_outlined,    label: 'Venue', value: '${event.venue}, ${event.city}'),
                  _InfoRow(
                    icon:  Icons.event_seat_outlined,
                    label: 'Seats',
                    value: event.seatsLabel,
                    valueColor: event.seatsColor,
                  ),

                  const SizedBox(height: 24),
                  const Divider(color: AppColors.divider),
                  const SizedBox(height: 20),

                  // About
                  Text('About this Event', style: AppFonts.headlineSmall),
                  const SizedBox(height: 10),
                  Text(event.description,
                      style: AppFonts.bodyMedium.copyWith(height: 1.8)),

                  const SizedBox(height: 24),
                  const Divider(color: AppColors.divider),
                  const SizedBox(height: 20),

                  // Location map
                  Text('Location', style: AppFonts.headlineSmall),
                  const SizedBox(height: 10),
                  EventMapWidget(
                    latitude:  event.latitude,
                    longitude: event.longitude,
                    venue:     event.venue,
                  ),

                  const SizedBox(height: 24),
                  const Divider(color: AppColors.divider),
                  const SizedBox(height: 20),

                  // Organizer
                  Text('Organizer', style: AppFonts.headlineSmall),
                  const SizedBox(height: 10),
                  OrganizerCard(
                    name:  event.organizerName,
                    phone: event.organizerPhone,
                  ),

                  const SizedBox(height: 24),
                  const Divider(color: AppColors.divider),
                  const SizedBox(height: 20),

                   // Reviews — navigates to Phase 6 reviews screen
                  Text('Reviews', style: AppFonts.headlineSmall),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => context.push(
                      '/reviews/${event.id}',
                      extra: {'title': event.title},
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(AppSizes.cardPadding),
                      decoration: BoxDecoration(
                        color:        AppColors.surface1,
                        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                        border:       Border.all(color: AppColors.border, width: 0.5),
                      ),
                      child: Row(children: [
                        const Icon(Icons.star_rounded, color: AppColors.gold, size: 20),
                        const SizedBox(width: 10),
                        Text('See Reviews & Ratings',
                            style: AppFonts.labelMedium),
                        const Spacer(),
                        const Icon(Icons.chevron_right_rounded,
                            color: AppColors.textSecondary, size: 20),
                      ]),
                    ),
                  ),

                  // Padding for sticky bottom bar
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Sticky Bottom Bar ────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(
            AppSizes.pagePadding, 12, AppSizes.pagePadding, 28),
        decoration: BoxDecoration(
          color:  AppColors.surface1,
          border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
        ),
        child: Row(
          children: [
            // Price
            Column(
              mainAxisSize:        MainAxisSize.min,
              crossAxisAlignment:  CrossAxisAlignment.start,
              children: [
                Text(event.priceDisplay, style: AppFonts.priceLarge),
                Text('per person', style: AppFonts.caption),
              ],
            ),

            const SizedBox(width: AppSizes.lg),

            // Book button
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: event.hasSeatsLeft
                      ? () => context.push('/book/${event.id}', extra: {'event': event})
                      : null,
                  child: Text(
                    event.hasSeatsLeft ? 'Book Now' : 'Sold Out',
                    style: AppFonts.buttonText,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Category Badge ────────────────────────────────────────────
class _CategoryBadge extends StatelessWidget {
  final dynamic event;
  const _CategoryBadge({required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color:        event.categoryColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        border:       Border.all(color: event.categoryColor.withOpacity(0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(event.categoryIcon, size: 13, color: event.categoryColor),
        const SizedBox(width: 5),
        Text(event.categoryLabel,
            style: AppFonts.labelSmall.copyWith(color: event.categoryColor)),
      ]),
    );
  }
}

// ── Info Row ──────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   value;
  final Color?   valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color:        AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Icon(icon, size: 17, color: AppColors.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppFonts.caption.copyWith(
                        color: AppColors.textHint)),
                const SizedBox(height: 2),
                Text(value,
                    style: AppFonts.bodyMedium.copyWith(
                        color: valueColor ?? AppColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
