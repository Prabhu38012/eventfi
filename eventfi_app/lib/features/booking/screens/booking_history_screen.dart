import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/booking_provider.dart';
import '../models/booking_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../../../shared/widgets/app_loader.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().loadMyBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bp = context.watch<BookingProvider>();

    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title: Text('My Bookings', style: AppFonts.appLogo.copyWith(fontSize: 22)),
        backgroundColor: AppColors.dark,
        automaticallyImplyLeading: false,
      ),
      body: bp.histLoading
          ? ListView.builder(
              padding:     const EdgeInsets.all(AppSizes.pagePadding),
              itemCount:   4,
              itemBuilder: (_, __) => const EventCardSkeleton(),
            )
          : bp.myBookings.isEmpty
              ? _EmptyState()
              : ListView.builder(
                  padding:    const EdgeInsets.all(AppSizes.pagePadding),
                  itemCount:  bp.myBookings.length,
                  itemBuilder: (_, i) =>
                      _BookingCard(booking: bp.myBookings[i]),
                ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  const _BookingCard({required this.booking});

  Color get _statusColor {
    switch (booking.paymentStatus) {
      case 'paid':      return booking.attended ? AppColors.textSecondary : AppColors.success;
      case 'cancelled': return AppColors.error;
      case 'refunded':  return AppColors.warning;
      default:          return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/ticket/${booking.id}'),
      child: Container(
        margin:     const EdgeInsets.only(bottom: AppSizes.md),
        padding:    const EdgeInsets.all(AppSizes.cardPadding),
        decoration: BoxDecoration(
          color:        AppColors.surface1,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: icon
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                color:        AppColors.accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: const Icon(Icons.confirmation_number_outlined,
                  color: AppColors.accent, size: 24),
            ),

            const SizedBox(width: 12),

            // Middle: details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.eventTitle ?? 'Event',
                    style: AppFonts.labelLarge,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    booking.eventVenue != null
                        ? '${booking.eventVenue}, ${booking.eventCity}'
                        : booking.eventCity ?? '',
                    style: AppFonts.caption,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(booking.formattedDate, style: AppFonts.caption),
                  const SizedBox(height: 6),
                  Text(
                    '${booking.seats} seat${booking.seats > 1 ? 's' : ''}'
                    ' · ₹${booking.finalAmount.toInt()}',
                    style: AppFonts.bodySmall
                        .copyWith(color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),

            // Right: status badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:        _statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  ),
                  child: Text(booking.statusLabel,
                      style: AppFonts.badgeText
                          .copyWith(color: _statusColor, fontSize: 10)),
                ),
                const SizedBox(height: 8),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textSecondary, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('🎟️', style: TextStyle(fontSize: 56)),
        const SizedBox(height: 20),
        Text('No bookings yet', style: AppFonts.headlineSmall),
        const SizedBox(height: 8),
        Text('Your tickets will appear here',
            style: AppFonts.bodySmall),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => context.go('/home'),
          child: Text('Explore Events', style: AppFonts.buttonText),
        ),
      ],
    ),
  );
}
