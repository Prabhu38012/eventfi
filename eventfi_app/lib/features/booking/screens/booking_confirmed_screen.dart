import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../models/booking_model.dart';
import '../widgets/qr_ticket_widget.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../shared/widgets/app_button.dart';

class BookingConfirmedScreen extends StatelessWidget {
  final BookingModel booking;
  const BookingConfirmedScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.pagePadding),
          child: Column(
            children: [
              const SizedBox(height: AppSizes.xxxl),

              // ─── Success icon ─────────────────────────────
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color:  AppColors.accent.withOpacity(0.15),
                  shape:  BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    color: AppColors.accent, size: 42),
              )
                  .animate()
                  .scale(duration: 500.ms, curve: Curves.elasticOut),

              const SizedBox(height: AppSizes.xl),

              Text('Booking Confirmed!',
                  style: AppFonts.eventTitle,
                  textAlign: TextAlign.center)
                  .animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 6),
              Text('Your ticket is ready. Show the QR at the gate.',
                  style: AppFonts.bodySmall,
                  textAlign: TextAlign.center)
                  .animate().fadeIn(delay: 300.ms),

              const SizedBox(height: AppSizes.xxl),

              // ─── Booking ID ───────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color:        AppColors.surface1,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  border:       Border.all(
                      color: AppColors.accent.withOpacity(0.3)),
                ),
                child: Column(children: [
                  Text('BOOKING ID',
                      style: AppFonts.caption
                          .copyWith(letterSpacing: 1.5)),
                  const SizedBox(height: 4),
                  Text(booking.bookingId,
                      style: AppFonts.tanker(
                          fontSize: 28, color: AppColors.accent)),
                ]),
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: AppSizes.xxl),

              // ─── QR Code ──────────────────────────────────
              QrTicketWidget(data: booking.bookingId, size: 180)
                  .animate().fadeIn(delay: 500.ms),

              const SizedBox(height: AppSizes.xxl),

              // ─── Event details ────────────────────────────
              if (booking.eventTitle != null)
                Container(
                  width:   double.infinity,
                  padding: const EdgeInsets.all(AppSizes.lg),
                  decoration: BoxDecoration(
                    color:        AppColors.surface1,
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(booking.eventTitle!,
                          style: AppFonts.headlineSmall,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 8),
                      _Detail(Icons.event_seat_outlined,
                          '${booking.seats} seat${booking.seats > 1 ? 's' : ''}'),
                      _Detail(Icons.calendar_today_outlined,
                          booking.formattedDate),
                      _Detail(Icons.access_time_outlined,
                          booking.eventTime ?? ''),
                      _Detail(Icons.location_on_outlined,
                          '${booking.eventVenue ?? ''}, ${booking.eventCity ?? ''}'),
                      const Divider(color: AppColors.divider),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Paid', style: AppFonts.labelLarge),
                          Text('₹${booking.finalAmount.toInt()}',
                              style: AppFonts.priceText),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 600.ms),

              const SizedBox(height: AppSizes.xxl),

              // ─── Buttons ──────────────────────────────────
              AppButton(
                text:      'View My Bookings',
                onTap:     () => context.go('/bookings'),
              ).animate().fadeIn(delay: 700.ms),

              const SizedBox(height: AppSizes.md),

              AppButton(
                text:      'Back to Home',
                isOutlined: true,
                onTap:     () => context.go('/home'),
              ).animate().fadeIn(delay: 800.ms),

              const SizedBox(height: AppSizes.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  final IconData icon;
  final String   text;
  const _Detail(this.icon, this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Row(children: [
      Icon(icon, size: 13, color: AppColors.accent),
      const SizedBox(width: 8),
      Expanded(child: Text(text,
          style: AppFonts.bodySmall,
          maxLines: 1, overflow: TextOverflow.ellipsis)),
    ]),
  );
}
