import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/booking_provider.dart';
import '../models/booking_model.dart';
import '../widgets/qr_ticket_widget.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../shared/widgets/app_snackbar.dart';

class TicketScreen extends StatefulWidget {
  final String bookingId;
  const TicketScreen({super.key, required this.bookingId});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  BookingModel? _booking;
  bool          _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final b = await context.read<BookingProvider>()
          .loadMyBookings()
          .then((_) => context.read<BookingProvider>()
              .myBookings
              .firstWhere((b) => b.id == widget.bookingId));
      setState(() { _booking = b; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title: Text('My Ticket', style: AppFonts.headlineSmall),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.canPop() ? context.pop() : context.go('/bookings'),
        ),
        actions: [
          if (_booking != null)
            IconButton(
              icon: const Icon(Icons.copy_outlined, size: 20),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _booking!.bookingId));
                AppSnackbar.success(context, 'Booking ID copied');
              },
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(
              color: AppColors.accent, strokeWidth: 2))
          : _booking == null
              ? Center(child: Text('Ticket not found', style: AppFonts.bodyMedium))
              : _TicketView(booking: _booking!),
    );
  }
}

class _TicketView extends StatelessWidget {
  final BookingModel booking;
  const _TicketView({required this.booking});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // ─── Ticket card ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppSizes.pagePadding),
            child: Container(
              decoration: BoxDecoration(
                color:        AppColors.surface1,
                borderRadius: BorderRadius.circular(AppSizes.radiusXl),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    width:  double.infinity,
                    padding: const EdgeInsets.all(AppSizes.xl),
                    decoration: BoxDecoration(
                      color:        AppColors.accent,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppSizes.radiusXl)),
                    ),
                    child: Column(children: [
                      Text('EventFi',
                          style: AppFonts.appLogo.copyWith(
                              color: AppColors.dark, fontSize: 26)),
                      Text('Tamil Nadu\'s Live Event Platform',
                          style: AppFonts.caption.copyWith(
                              color: AppColors.dark.withOpacity(0.7))),
                    ]),
                  ),

                  // Event info
                  Padding(
                    padding: const EdgeInsets.all(AppSizes.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (booking.eventTitle != null) ...[
                          Text(booking.eventTitle!,
                              style: AppFonts.eventTitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 14),
                          _Row(Icons.calendar_today_outlined, 'Date',  booking.formattedDate),
                          _Row(Icons.access_time_outlined,    'Time',  booking.eventTime ?? ''),
                          _Row(Icons.location_on_outlined,    'Venue',
                              '${booking.eventVenue ?? ''}, ${booking.eventCity ?? ''}'),
                          _Row(Icons.event_seat_outlined,     'Seats',
                              '${booking.seats} seat${booking.seats > 1 ? 's' : ''}'),
                        ],
                      ],
                    ),
                  ),

                  // Dashed divider
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(children: List.generate(
                      30,
                      (i) => Expanded(
                        child: Container(
                          height: 1,
                          color:  i.isEven ? AppColors.border : Colors.transparent,
                        ),
                      ),
                    )),
                  ),

                  // QR code
                  Padding(
                    padding: const EdgeInsets.all(AppSizes.xl),
                    child: Column(children: [
                      QrTicketWidget(
                          data: booking.bookingId, size: 180),
                      const SizedBox(height: AppSizes.lg),
                      Text('BOOKING ID',
                          style: AppFonts.caption
                              .copyWith(letterSpacing: 2)),
                      const SizedBox(height: 4),
                      Text(booking.bookingId,
                          style: AppFonts.tanker(
                              fontSize: 24, color: AppColors.accent)),
                      const SizedBox(height: 4),
                      Text('Show this QR code at the venue entrance',
                          style: AppFonts.caption,
                          textAlign: TextAlign.center),
                    ]),
                  ),

                  // Status badge
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: booking.attended
                          ? AppColors.surface2
                          : AppColors.success.withOpacity(0.1),
                      borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(AppSizes.radiusXl)),
                    ),
                    child: Text(
                      booking.attended ? '✓ Attended' : '✓ Confirmed',
                      textAlign: TextAlign.center,
                      style: AppFonts.labelLarge.copyWith(
                        color: booking.attended
                            ? AppColors.textSecondary
                            : AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   value;
  const _Row(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 15, color: AppColors.accent),
      const SizedBox(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: AppFonts.caption.copyWith(color: AppColors.textHint)),
        Text(value, style: AppFonts.bodySmall
            .copyWith(color: AppColors.textPrimary)),
      ]),
    ]),
  );
}
