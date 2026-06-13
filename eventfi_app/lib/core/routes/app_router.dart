import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/home/screens/home_screen.dart';
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
    GoRoute(path: '/login',           name: 'login',          builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/signup',          name: 'signup',         builder: (_, __) => const SignupScreen()),
    GoRoute(path: '/forgot-password', name: 'forgot-password',builder: (_, __) => const ForgotPasswordScreen()),
    GoRoute(path: '/otp',             name: 'otp',            builder: (_, __) => const OtpScreen()),

    // ─── Home ─────────────────────────────────────────────
    GoRoute(path: '/home',  name: 'home',  builder: (_, __) => const HomeScreen()),

    // ─── Event detail (Phase 3) ───────────────────────────
    GoRoute(
      path: '/event/:id',
      name: 'event-detail',
      builder: (_, state) => _PlaceholderScreen(
        title: 'Event Detail',
        subtitle: 'Coming in Phase 3\nEvent ID: ${state.pathParameters['id']}',
      ),
    ),

    // ─── Booking (Phase 4) ────────────────────────────────
    GoRoute(path: '/book/:id',   builder: (_, state) => _PlaceholderScreen(title:'Seat Selection', subtitle:'Coming in Phase 4')),
    GoRoute(path: '/checkout',   builder: (_, __) => _PlaceholderScreen(title:'Checkout',        subtitle:'Coming in Phase 4')),
    GoRoute(path: '/confirmed',  builder: (_, __) => _PlaceholderScreen(title:'Booking Confirmed',subtitle:'Coming in Phase 4')),
    GoRoute(path: '/bookings',   builder: (_, __) => _PlaceholderScreen(title:'My Bookings',     subtitle:'Coming in Phase 4')),
    GoRoute(path: '/ticket/:id', builder: (_, __) => _PlaceholderScreen(title:'My Ticket',       subtitle:'Coming in Phase 4')),

    // ─── Points & Rewards (Phase 5) ───────────────────────
    GoRoute(path: '/points',  builder: (_, __) => _PlaceholderScreen(title:'Gold Points', subtitle:'Coming in Phase 5')),
    GoRoute(path: '/rewards', builder: (_, __) => _PlaceholderScreen(title:'Rewards',    subtitle:'Coming in Phase 5')),

    // ─── Engagement (Phase 6) ─────────────────────────────
    GoRoute(path: '/wishlist',       builder: (_, __) => _PlaceholderScreen(title:'Wishlist',      subtitle:'Coming in Phase 6')),
    GoRoute(path: '/reviews/:id',    builder: (_, __) => _PlaceholderScreen(title:'Reviews',       subtitle:'Coming in Phase 6')),
    GoRoute(path: '/notifications',  builder: (_, __) => _PlaceholderScreen(title:'Notifications', subtitle:'Coming in Phase 6')),

    // ─── Profile ──────────────────────────────────────────
    GoRoute(path: '/profile', builder: (_, __) => _PlaceholderScreen(title:'Profile', subtitle:'Coming soon')),

    // ─── Search ───────────────────────────────────────────
    GoRoute(path: '/search', builder: (_, __) => _PlaceholderScreen(title:'Search', subtitle:'AI smart search in Phase 8')),

    // ─── Admin (Phase 7) ──────────────────────────────────
    GoRoute(path: '/admin', builder: (_, __) => _PlaceholderScreen(title:'Admin Dashboard', subtitle:'Coming in Phase 7')),
  ],
);

/// Temp placeholder screen — replaced phase by phase
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  const _PlaceholderScreen({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title: Text(title, style: AppFonts.appLogo.copyWith(fontSize: 20)),
        backgroundColor: AppColors.dark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🚧', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 20),
            Text(title, style: AppFonts.headlineSmall),
            const SizedBox(height: 8),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: AppFonts.bodySmall),
          ],
        ),
      ),
    );
  }
}
