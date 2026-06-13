import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_strings.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>    _fade;
  late final Animation<double>    _slide;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 800),
    );

    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _slide = Tween<double>(begin: 20, end: 0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );

    _ctrl.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    // Minimum 2.5s splash + wait for auth to resolve
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    final auth = context.read<AuthProvider>();

    // If still determining auth state, wait up to 2 more seconds
    int waited = 0;
    while (auth.status == AuthStatus.initial && waited < 20) {
      await Future.delayed(const Duration(milliseconds: 100));
      waited++;
    }

    if (!mounted) return;

    if (auth.status == AuthStatus.authenticated) {
      context.go('/home');
    } else {
      final prefs = await SharedPreferences.getInstance();
      final seen  = prefs.getBool('onboarding_seen') ?? false;
      if (!mounted) return;
      context.go(seen ? '/login' : '/onboarding');
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      body: Center(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => Opacity(
            opacity: _fade.value,
            child: Transform.translate(
              offset: Offset(0, _slide.value),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ─── Logo ──────────────────────────────
                  Container(
                    width:  72,
                    height: 72,
                    decoration: BoxDecoration(
                      color:        AppColors.surface1,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Center(
                      child: Text(
                        'E',
                        style: AppFonts.tanker(fontSize: 36, color: AppColors.accent),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    AppStrings.appName,
                    style: AppFonts.tanker(fontSize: 38, color: AppColors.light),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    AppStrings.appTagline,
                    style: AppFonts.labelSmall,
                  ),

                  const SizedBox(height: 56),

                  // ─── Loading indicator ─────────────────
                  SizedBox(
                    width:  22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
