import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/home/providers/home_provider.dart';

class EventFiApp extends StatelessWidget {
  const EventFiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),  // ✅ Phase 2
        // Phase 4: ChangeNotifierProvider(create: (_) => BookingProvider()),
        // Phase 5: ChangeNotifierProvider(create: (_) => PointsProvider()),
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
