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
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_fonts.dart';

final GoRouter appRouter = GoRouter(
  debugLogDiagnostics: true,
  initialLocation: '/',
  routes: [

    // ─── Splash ───────────────────────────────────────────
    GoRoute(path: '/', name: 'splash',
        builder: (_, __) => const SplashScreen()),

    // ─── Onboarding ───────────────────────────────────────
    GoRoute(path: '/onboarding', name: 'onboarding',
        builder: (_, __) => const OnboardingScreen()),

    // ─── Auth ─────────────────────────────────────────────
    GoRoute(path: '/login',           builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/signup',          builder: (_, __) => const SignupScreen()),
    GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),
    GoRoute(path: '/otp',             builder: (_, __) => const OtpScreen()),

    // ─── Home ─────────────────────────────────────────────
    GoRoute(path: '/home', name: 'home',
        builder: (_, __) => const HomeScreen()),

    // ─── Event Detail ✅ Phase 3 ──────────────────────────
    // EventProvider is scoped locally — each detail screen gets its own instance
    GoRoute(
      path: '/event/:id',
      name: 'event-detail',
      builder: (_, state) {
        final id = state.pathParameters['id'] ?? '';
        return ChangeNotifierProvider(
          create: (_) => EventProvider(),
          child:  EventDetailScreen(eventId: id),
        );
      },
    ),

    // ─── Booking (Phase 4) ────────────────────────────────
    GoRoute(path: '/book/:id',   builder: (_, __) => _Ph('Seat Selection',    'Phase 4')),
    GoRoute(path: '/checkout',   builder: (_, __) => _Ph('Checkout',          'Phase 4')),
    GoRoute(path: '/confirmed',  builder: (_, __) => _Ph('Booking Confirmed', 'Phase 4')),
    GoRoute(path: '/bookings',   builder: (_, __) => _Ph('My Bookings',       'Phase 4')),
    GoRoute(path: '/ticket/:id', builder: (_, __) => _Ph('My Ticket',         'Phase 4')),

    // ─── Points & Rewards (Phase 5) ───────────────────────
    GoRoute(path: '/points',  builder: (_, __) => _Ph('Gold Points', 'Phase 5')),
    GoRoute(path: '/rewards', builder: (_, __) => _Ph('Rewards',     'Phase 5')),

    // ─── Engagement (Phase 6) ─────────────────────────────
    GoRoute(path: '/wishlist',      builder: (_, __) => _Ph('Wishlist',      'Phase 6')),
    GoRoute(path: '/reviews/:id',   builder: (_, __) => _Ph('Reviews',       'Phase 6')),
    GoRoute(path: '/notifications', builder: (_, __) => _Ph('Notifications', 'Phase 6')),

    // ─── Profile & Search ─────────────────────────────────
    GoRoute(path: '/profile', builder: (_, __) => _Ph('Profile',             'coming soon')),
    GoRoute(path: '/search',  builder: (_, __) => _Ph('AI Search',           'Phase 8')),

    // ─── Admin (Phase 7) ──────────────────────────────────
    GoRoute(path: '/admin', builder: (_, __) => _Ph('Admin Dashboard', 'Phase 7')),
  ],
);

/// Temporary placeholder screen — replaced phase by phase
class _Ph extends StatelessWidget {
  final String title;
  final String phase;
  const _Ph(this.title, this.phase);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title:           Text(title, style: AppFonts.appLogo.copyWith(fontSize: 20)),
        backgroundColor: AppColors.dark,
        leading: IconButton(
          icon:      const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🚧', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 20),
            Text(title,  style: AppFonts.headlineSmall),
            const SizedBox(height: 8),
            Text('Coming in $phase', style: AppFonts.bodySmall),
          ],
        ),
      ),
    );
  }
}
