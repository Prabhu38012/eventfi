import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/home/providers/home_provider.dart';
import 'features/booking/providers/booking_provider.dart';
import 'features/points/providers/points_provider.dart';

class EventFiApp extends StatelessWidget {
  const EventFiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => PointsProvider()),   // ✅ Phase 5
        // Phase 6: ChangeNotifierProvider(create: (_) => WishlistProvider()),
        // Phase 6: ChangeNotifierProvider(create: (_) => ReviewProvider()),
        // Phase 6: ChangeNotifierProvider(create: (_) => NotificationProvider()),
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
