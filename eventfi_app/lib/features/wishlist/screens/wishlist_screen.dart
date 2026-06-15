import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/wishlist_provider.dart';
import '../../home/widgets/event_card.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../../../shared/widgets/app_loader.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});
  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WishlistProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WishlistProvider>();

    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title:           Text('Wishlist', style: AppFonts.appLogo.copyWith(fontSize: 22)),
        backgroundColor: AppColors.dark,
        automaticallyImplyLeading: false,
        actions: [
          if (wp.count > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child:   Center(
                child: Text('${wp.count} saved',
                    style: AppFonts.labelSmall),
              ),
            ),
        ],
      ),
      body: wp.loading
          ? const AppLoader()
          : wp.events.isEmpty
              ? _EmptyState()
              : ListView.builder(
                  padding:    const EdgeInsets.all(AppSizes.pagePadding),
                  itemCount:  wp.events.length,
                  itemBuilder: (_, i) => EventCard(event: wp.events[i]),
                ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('🤍', style: TextStyle(fontSize: 56)),
      const SizedBox(height: 20),
      Text('No saved events', style: AppFonts.headlineSmall),
      const SizedBox(height: 8),
      Text('Tap the heart on any event to save it here',
          style: AppFonts.bodySmall, textAlign: TextAlign.center),
      const SizedBox(height: 24),
      ElevatedButton(
        onPressed: () => context.go('/home'),
        child: Text('Explore Events', style: AppFonts.buttonText),
      ),
    ]),
  );
}
