import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/events/screens/event_detail_screen.dart';
import '../../features/events/providers/event_provider.dart';
import '../../features/booking/screens/seat_selection_screen.dart';
import '../../features/booking/screens/checkout_screen.dart';
import '../../features/booking/screens/booking_confirmed_screen.dart';
import '../../features/booking/screens/booking_history_screen.dart';
import '../../features/booking/screens/ticket_screen.dart';
import '../../features/booking/models/booking_model.dart';
import '../../features/points/screens/points_screen.dart';
import '../../features/points/screens/rewards_screen.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_fonts.dart';

final GoRouter appRouter = GoRouter(
  debugLogDiagnostics: true,
  initialLocation: '/',
  routes: [

    // ─── Auth ─────────────────────────────────────────────
    GoRoute(path: '/',            builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/onboarding',  builder: (_, __) => const OnboardingScreen()),
    GoRoute(path: '/login',       builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/signup',      builder: (_, __) => const SignupScreen()),
    GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),
    GoRoute(path: '/otp',         builder: (_, __) => const OtpScreen()),

    // ─── Home ─────────────────────────────────────────────
    GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),

    // ─── Event Detail — Phase 3 ───────────────────────────
    GoRoute(
      path: '/event/:id',
      builder: (_, state) => ChangeNotifierProvider(
        create: (_) => EventProvider(),
        child:  EventDetailScreen(eventId: state.pathParameters['id'] ?? ''),
      ),
    ),

    // ─── Booking — Phase 4 ────────────────────────────────
    GoRoute(
      path: '/book/:id',
      builder: (_, state) {
        final event = (state.extra as Map?)?['event'];
        if (event == null) return _Ph('Seat Selection', 'Pass event via extra');
        return SeatSelectionScreen(event: event);
      },
    ),
    GoRoute(
      path: '/checkout',
      builder: (_, state) {
        final event = (state.extra as Map?)?['event'];
        if (event == null) return _Ph('Checkout', 'Pass event via extra');
        return CheckoutScreen(event: event);
      },
    ),
    GoRoute(
      path: '/confirmed',
      builder: (_, state) {
        final booking = state.extra as BookingModel?;
        if (booking == null) return _Ph('Confirmed', 'No booking data');
        return BookingConfirmedScreen(booking: booking);
      },
    ),
    GoRoute(path: '/bookings',    builder: (_, __) => const BookingHistoryScreen()),
    GoRoute(path: '/ticket/:id',  builder: (_, state) =>
        TicketScreen(bookingId: state.pathParameters['id'] ?? '')),

    // ─── Points & Rewards — Phase 5 ───────────────────────
    GoRoute(path: '/points',  builder: (_, __) => const PointsScreen()),
    GoRoute(path: '/rewards', builder: (_, __) => const RewardsScreen()),

    // ─── Upcoming ─────────────────────────────────────────
    GoRoute(path: '/wishlist',      builder: (_, __) => _Ph('Wishlist',      'Phase 6')),
    GoRoute(path: '/reviews/:id',   builder: (_, __) => _Ph('Reviews',       'Phase 6')),
    GoRoute(path: '/notifications', builder: (_, __) => _Ph('Notifications', 'Phase 6')),
    GoRoute(path: '/profile',       builder: (_, __) => _Ph('Profile',       'Phase 6')),
    GoRoute(path: '/search',        builder: (_, __) => _Ph('AI Search',     'Phase 8')),
    GoRoute(path: '/admin',         builder: (_, __) => _Ph('Admin',         'Phase 7')),
  ],
);

class _Ph extends StatelessWidget {
  final String title, phase;
  const _Ph(this.title, this.phase);

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.dark,
    appBar: AppBar(
      title:           Text(title, style: AppFonts.appLogo.copyWith(fontSize: 20)),
      backgroundColor: AppColors.dark,
      leading: IconButton(
        icon:      const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
      ),
    ),
    body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('🚧', style: TextStyle(fontSize: 56)),
      const SizedBox(height: 20),
      Text(title, style: AppFonts.headlineSmall),
      const SizedBox(height: 8),
      Text('Coming in $phase', style: AppFonts.bodySmall),
    ])),
  );
}
