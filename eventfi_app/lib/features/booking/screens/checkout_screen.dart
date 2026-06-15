import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/booking_provider.dart';
import '../widgets/coupon_input.dart';
import '../widgets/price_breakdown.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../../events/models/event_model.dart';

class CheckoutScreen extends StatefulWidget {
  final EventModel event;
  const CheckoutScreen({super.key, required this.event});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  @override
  void initState() {
    super.initState();
    // Listen for booking confirmation → navigate to confirmed screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().addListener(_onProviderChange);
    });
  }

  void _onProviderChange() {
    final bp = context.read<BookingProvider>();
    if (bp.confirmed && bp.booking != null) {
      context.go('/confirmed', extra: bp.booking);
    }
    if (bp.error != null) {
      AppSnackbar.error(context, bp.error!);
    }
  }

  @override
  void dispose() {
    try { context.read<BookingProvider>().removeListener(_onProviderChange); }
    catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bp    = context.watch<BookingProvider>();
    final event = widget.event;

    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title: Text('Checkout', style: AppFonts.headlineSmall),
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

            // Event summary
            Text('Event', style: AppFonts.labelSmall),
            const SizedBox(height: 8),
            Container(
              padding:    const EdgeInsets.all(AppSizes.cardPadding),
              decoration: BoxDecoration(
                color:        AppColors.surface1,
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title,
                      style: AppFonts.cardTitle,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 13, color: AppColors.textHint),
                    const SizedBox(width: 5),
                    Text(event.formattedDate, style: AppFonts.caption),
                    const SizedBox(width: 14),
                    const Icon(Icons.access_time_outlined,
                        size: 13, color: AppColors.textHint),
                    const SizedBox(width: 5),
                    Text(event.time, style: AppFonts.caption),
                  ]),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.location_on_outlined,
                        size: 13, color: AppColors.textHint),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        '${event.venue}, ${event.city}',
                        style: AppFonts.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ]),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.xl),

            // Coupon
            Text('Have a coupon?', style: AppFonts.labelSmall),
            const SizedBox(height: 8),
            CouponInput(
              isLoading: bp.couponLoading,
              isValid:   bp.couponValid,
              message:   bp.couponMessage,
              onApply:   bp.applyCoupon,
              onRemove:  bp.removeCoupon,
            ),

            const SizedBox(height: AppSizes.xl),

            // Price breakdown
            PriceBreakdown(
              seats:       bp.selectedSeats,
              pricePerSeat: bp.pricePerSeat,
              discount:    bp.discount,
              couponCode:  bp.couponCode,
            ),

            const SizedBox(height: AppSizes.xl),

            // Razorpay note
            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color:        AppColors.surface2,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Row(children: [
                const Icon(Icons.lock_outline_rounded,
                    color: AppColors.success, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Secure payment powered by Razorpay.\n'
                    'Test card: 4111 1111 1111 1111 · Any future date · Any CVV',
                    style: AppFonts.caption,
                  ),
                ),
              ]),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),

      // Pay button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(
            AppSizes.pagePadding, 12, AppSizes.pagePadding, 28),
        decoration: BoxDecoration(
          color:  AppColors.surface1,
          border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
        ),
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: (bp.creatingOrder || bp.verifying)
                ? null
                : () {
                    bp.setPendingBookingData(
                      eventId:     event.id,
                      seats:       bp.selectedSeats,
                      amount:      bp.baseAmount,
                      discount:    bp.discount,
                      finalAmount: bp.finalAmount,
                      couponCode:  bp.couponCode,
                    );
                    bp.startPayment(event.id);
                  },
            child: (bp.creatingOrder || bp.verifying)
                ? const SizedBox(width: 22, height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.dark))
                : Text('Pay ₹${bp.finalAmount.toInt()} with Razorpay',
                    style: AppFonts.buttonText),
          ),
        ),
      ),
    );
  }
}
