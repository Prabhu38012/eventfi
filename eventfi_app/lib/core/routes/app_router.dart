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
import '../../features/wishlist/screens/wishlist_screen.dart';
import '../../features/reviews/screens/reviews_screen.dart';
import '../../features/reviews/providers/review_provider.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../../features/admin/screens/admin_events_screen.dart';
import '../../features/admin/screens/admin_event_form_screen.dart';
import '../../features/admin/screens/admin_bookings_screen.dart';
import '../../features/admin/screens/admin_coupons_screen.dart';
import '../../features/admin/screens/admin_qr_scanner_screen.dart';
import '../../features/admin/providers/admin_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_fonts.dart';

final GoRouter appRouter = GoRouter(
  debugLogDiagnostics: true,
  initialLocation: '/',
  routes: [

    // ── Auth ──────────────────────────────────────────────
    GoRoute(path: '/',            builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/onboarding',  builder: (_, __) => const OnboardingScreen()),
    GoRoute(path: '/login',       builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/signup',      builder: (_, __) => const SignupScreen()),
    GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),
    GoRoute(path: '/otp',         builder: (_, __) => const OtpScreen()),
    GoRoute(path: '/home',        builder: (_, __) => const HomeScreen()),

    // ── Events ────────────────────────────────────────────
    GoRoute(
      path: '/event/:id',
      builder: (_, state) => ChangeNotifierProvider(
        create: (_) => EventProvider(),
        child:  EventDetailScreen(eventId: state.pathParameters['id'] ?? ''),
      ),
    ),

    // ── Booking ───────────────────────────────────────────
    GoRoute(path: '/book/:id',
        builder: (_, state) {
          final e = (state.extra as Map?)?['event'];
          return e == null ? _Ph('Seat Selection','') : SeatSelectionScreen(event: e);
        }),
    GoRoute(path: '/checkout',
        builder: (_, state) {
          final e = (state.extra as Map?)?['event'];
          return e == null ? _Ph('Checkout','') : CheckoutScreen(event: e);
        }),
    GoRoute(path: '/confirmed',
        builder: (_, state) {
          final b = state.extra as BookingModel?;
          return b == null ? _Ph('Confirmed','') : BookingConfirmedScreen(booking: b);
        }),
    GoRoute(path: '/bookings',   builder: (_, __) => const BookingHistoryScreen()),
    GoRoute(path: '/ticket/:id', builder: (_, state) =>
        TicketScreen(bookingId: state.pathParameters['id'] ?? '')),

    // ── Points ────────────────────────────────────────────
    GoRoute(path: '/points',  builder: (_, __) => const PointsScreen()),
    GoRoute(path: '/rewards', builder: (_, __) => const RewardsScreen()),

    // ── Engagement ────────────────────────────────────────
    GoRoute(path: '/wishlist', builder: (_, __) => const WishlistScreen()),
    GoRoute(
      path: '/reviews/:eventId',
      builder: (_, state) {
        final eventId    = state.pathParameters['eventId'] ?? '';
        final eventTitle = (state.extra as Map?)?['title'] as String? ?? 'Event';
        return ChangeNotifierProvider(
          create: (_) => ReviewProvider(),
          child:  ReviewsScreen(eventId: eventId, eventTitle: eventTitle),
        );
      },
    ),
    GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
    GoRoute(path: '/profile',       builder: (_, __) => _Ph('Profile', 'Phase 8')),
    GoRoute(path: '/search',        builder: (_, __) => _Ph('AI Search', 'Phase 8')),

    // ── Admin ── Phase 7 ──────────────────────────────────
    GoRoute(
      path: '/admin',
      builder: (_, __) => ChangeNotifierProvider(
        create: (_) => AdminProvider(),
        child:  const AdminDashboardScreen(),
      ),
    ),
    GoRoute(
      path: '/admin/events',
      builder: (_, __) => ChangeNotifierProvider(
        create: (_) => AdminProvider(),
        child:  const AdminEventsScreen(),
      ),
    ),
    GoRoute(
      path: '/admin/events/new',
      builder: (_, __) => ChangeNotifierProvider(
        create: (_) => AdminProvider(),
        child:  const AdminEventFormScreen(),
      ),
    ),
    GoRoute(
      path: '/admin/events/edit',
      builder: (_, state) => ChangeNotifierProvider(
        create: (_) => AdminProvider(),
        child:  AdminEventFormScreen(
          event: state.extra as Map<String, dynamic>?,
        ),
      ),
    ),
    GoRoute(
      path: '/admin/bookings',
      builder: (_, __) => ChangeNotifierProvider(
        create: (_) => AdminProvider(),
        child:  const AdminBookingsScreen(),
      ),
    ),
    GoRoute(
      path: '/admin/coupons',
      builder: (_, __) => ChangeNotifierProvider(
        create: (_) => AdminProvider(),
        child:  const AdminCouponsScreen(),
      ),
    ),
    GoRoute(
      path: '/admin/scanner',
      builder: (_, __) => ChangeNotifierProvider(
        create: (_) => AdminProvider(),
        child:  const AdminQrScannerScreen(),
      ),
    ),
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
      Text(title,  style: AppFonts.headlineSmall),
      if (phase.isNotEmpty) ...[
        const SizedBox(height: 8),
        Text('Coming in $phase', style: AppFonts.bodySmall),
      ],
    ])),
  );
}
