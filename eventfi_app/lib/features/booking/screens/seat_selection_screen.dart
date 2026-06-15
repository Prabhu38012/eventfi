import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/booking_provider.dart';
import '../widgets/seat_grid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_sizes.dart';
import '../../events/models/event_model.dart';

class SeatSelectionScreen extends StatefulWidget {
  final EventModel event;
  const SeatSelectionScreen({super.key, required this.event});

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().init(widget.event.price);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bp = context.watch<BookingProvider>();

    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title: Text('Select Seats', style: AppFonts.headlineSmall),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event mini card
            Container(
              padding: const EdgeInsets.all(AppSizes.cardPadding),
              decoration: BoxDecoration(
                color:        AppColors.surface1,
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              ),
              child: Row(children: [
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    color:        widget.event.categoryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: Icon(widget.event.categoryIcon,
                      color: widget.event.categoryColor, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.event.title,
                          style: AppFonts.labelLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(
                        '${widget.event.formattedDate} · ${widget.event.time}',
                        style: AppFonts.caption,
                      ),
                    ],
                  ),
                ),
              ]),
            ),

            const SizedBox(height: AppSizes.xxl),
            Text('Choose Your Seats', style: AppFonts.headlineSmall),
            const SizedBox(height: AppSizes.lg),

            // Seat grid
            SeatGrid(
              totalSeats:    widget.event.totalSeats,
              bookedCount:   widget.event.bookingCount,
              selectedCount: bp.selectedSeats,
              onChanged:     bp.setSeats,
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),

      // Bottom bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(
            AppSizes.pagePadding, 12, AppSizes.pagePadding, 28),
        decoration: BoxDecoration(
          color:  AppColors.surface1,
          border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
        ),
        child: Row(children: [
          Column(
            mainAxisSize:        MainAxisSize.min,
            crossAxisAlignment:  CrossAxisAlignment.start,
            children: [
              Text(
                '${bp.selectedSeats} seat${bp.selectedSeats != 1 ? 's' : ''}',
                style: AppFonts.labelLarge,
              ),
              Text(
                '₹${bp.baseAmount.toInt()} total',
                style: AppFonts.priceText,
              ),
            ],
          ),
          const SizedBox(width: AppSizes.lg),
          Expanded(
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: bp.selectedSeats > 0
                    ? () => context.push(
                          '/checkout',
                          extra: {'event': widget.event},
                        )
                    : null,
                child: Text('Continue', style: AppFonts.buttonText),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
