import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../shared/widgets/app_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _page = 0;

  static const _slides = [
    _Slide(
      emoji:       '🎭',
      title:       'Discover Live Events',
      description: 'Theatre, concerts, standup comedy, dance shows and theme parks — all across Tamil Nadu in one place.',
      accent:      Color(0xFFFF6B35),
    ),
    _Slide(
      emoji:       '🏅',
      title:       'Earn Gold Points',
      description: 'Every ₹100 you spend earns 1 Gold Point. Redeem for free tickets, discounts and VIP passes.',
      accent:      Color(0xFFD4A853),
    ),
    _Slide(
      emoji:       '📍',
      title:       'Made for Tamil Nadu',
      description: 'From Chennai to Coimbatore, Madurai to Trichy — EventFi brings the best of your state to you.',
      accent:      Color(0xFF80CBC4),
    ),
  ];

  Future<void> _done() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
    if (mounted) context.go('/login');
  }

  void _next() {
    if (_page < _slides.length - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 350),
        curve:    Curves.easeInOut,
      );
    } else {
      _done();
    }
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _slides.length - 1;

    return Scaffold(
      backgroundColor: AppColors.dark,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Skip ──────────────────────────────────
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _done,
                child: Text('Skip', style: AppFonts.labelSmall.copyWith(color: AppColors.accent)),
              ),
            ),

            // ─── Page View ─────────────────────────────
            Expanded(
              child: PageView.builder(
                controller:   _pageCtrl,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount:    _slides.length,
                itemBuilder:  (_, i) => _SlideWidget(slide: _slides[i]),
              ),
            ),

            // ─── Dots ──────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width:  _page == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color:        _page == i ? AppColors.accent : AppColors.surface2,
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSizes.xxl),

            // ─── Button ────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
              child: AppButton(
                text:  isLast ? 'Get Started' : 'Next',
                onTap: _next,
              ),
            ),

            const SizedBox(height: AppSizes.xl),

            // ─── Login link ────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Already have an account? ', style: AppFonts.bodySmall),
                GestureDetector(
                  onTap: _done,
                  child: Text('Log in', style: AppFonts.labelMedium.copyWith(color: AppColors.accent)),
                ),
              ],
            ),

            const SizedBox(height: AppSizes.lg),
          ],
        ),
      ),
    );
  }
}

// ─── Slide Data ──────────────────────────────────────────────

class _Slide {
  final String emoji;
  final String title;
  final String description;
  final Color  accent;

  const _Slide({
    required this.emoji,
    required this.title,
    required this.description,
    required this.accent,
  });
}

class _SlideWidget extends StatelessWidget {
  final _Slide slide;

  const _SlideWidget({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.xxxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ─── Emoji Icon ──────────────────────────────
          Container(
            width:  110,
            height: 110,
            decoration: BoxDecoration(
              color:        AppColors.surface1,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
              child: Text(slide.emoji, style: const TextStyle(fontSize: 52)),
            ),
          ),

          const SizedBox(height: AppSizes.xxxl),

          // ─── Title ───────────────────────────────────
          Text(
            slide.title,
            style:     AppFonts.tanker(fontSize: 30, color: AppColors.light),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSizes.lg),

          // ─── Description ─────────────────────────────
          Text(
            slide.description,
            style:     AppFonts.bodyMedium.copyWith(height: 1.7),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
