import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/home/providers/home_provider.dart';
import 'features/booking/providers/booking_provider.dart';
import 'features/points/providers/points_provider.dart';
import 'features/wishlist/providers/wishlist_provider.dart';
import 'features/notifications/providers/notification_provider.dart';

class EventFiApp extends StatelessWidget {
  const EventFiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => PointsProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        // Note: AdminProvider is created locally per admin screen
        // to avoid loading admin data for regular users
      ],
      child: MaterialApp.router(
        title:                      'EventFi',
        debugShowCheckedModeBanner: false,
        theme:                      AppTheme.theme,
        routerConfig:               appRouter,
      ),
    );
  }
}
