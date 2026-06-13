import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';
import '../widgets/category_tab.dart';
import '../widgets/event_card.dart';
import '../widgets/trending_section.dart';
import '../widgets/search_bar_widget.dart';
import '../../events/widgets/event_filter_sheet.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../../../shared/widgets/app_loader.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_sizes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load data after first frame so Provider is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().init();
    });
  }

  void _openFilter(HomeProvider hp) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSizes.radiusXxl)),
      ),
      builder: (_) => EventFilterSheet(
        districts:        hp.districts,
        selectedDistrict: hp.district,
        minPrice:         hp.minPrice,
        maxPrice:         hp.maxPrice,
        onApply: ({district, minPrice, maxPrice}) =>
            hp.applyFilters(
              district: district,
              minPrice: minPrice,
              maxPrice: maxPrice,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hp = context.watch<HomeProvider>();

    return Scaffold(
      backgroundColor: AppColors.dark,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [

            // ─── Header ────────────────────────────────
            SliverToBoxAdapter(child: _Header(hp: hp)),

            // ─── Search bar ────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                    top: AppSizes.md, bottom: AppSizes.lg),
                child: SearchBarWidget(
                  initialValue: hp.search,
                  onChanged:    hp.setSearch,
                ),
              ),
            ),

            // ─── Category tabs ─────────────────────────
            SliverToBoxAdapter(
              child: CategoryTab(
                selected: hp.category,
                onSelect: hp.setCategory,
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSizes.sectionGap)),

            // ─── Trending (only when "All" selected) ───
            if (hp.category == 'all')
              SliverToBoxAdapter(
                child: TrendingSection(
                  events:  hp.trending,
                  loading: hp.trendingLoading,
                ),
              ),

            // ─── Section header with filter ────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.pagePadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      hp.category == 'all'
                          ? 'All Events'
                          : _catLabel(hp.category),
                      style: AppFonts.headlineSmall,
                    ),
                    Row(
                      children: [
                        if (hp.hasFilters)
                          Container(
                            width: 8, height: 8,
                            margin: const EdgeInsets.only(right: 6),
                            decoration: const BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        GestureDetector(
                          onTap:  () => _openFilter(hp),
                          child:  Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color:        AppColors.surface2,
                              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              const Icon(Icons.tune_rounded,
                                  size: 14, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text('Filter',
                                  style: AppFonts.labelSmall
                                      .copyWith(color: AppColors.textSecondary)),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSizes.md)),

            // ─── Event list ────────────────────────────
            if (hp.loading)
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.pagePadding),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, __) => const EventCardSkeleton(),
                    childCount: 5,
                  ),
                ),
              )
            else if (hp.error != null)
              SliverFillRemaining(
                child: _ErrorView(
                  message: hp.error!,
                  onRetry:  hp.loadEvents,
                ),
              )
            else if (hp.events.isEmpty)
              const SliverFillRemaining(child: _EmptyView())
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.pagePadding),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => EventCard(event: hp.events[i]),
                    childCount: hp.events.length,
                  ),
                ),
              ),

            // Bottom padding for nav bar
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }

  String _catLabel(String cat) {
    const m = {
      'concert': 'Concerts', 'theatre': 'Theatre', 'standup': 'Standup',
      'dance': 'Dance Shows', 'themePark': 'Theme Parks',
    };
    return m[cat] ?? cat;
  }
}

// ─── Header widget ───────────────────────────────────────────
class _Header extends StatelessWidget {
  final HomeProvider hp;
  const _Header({required this.hp});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSizes.pagePadding, AppSizes.xl,
          AppSizes.pagePadding, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('EventFi', style: AppFonts.appLogo),
                const SizedBox(height: 2),
                Row(children: [
                  const Icon(Icons.location_on_rounded,
                      size: 13, color: AppColors.accent),
                  const SizedBox(width: 3),
                  Text('Tamil Nadu', style: AppFonts.labelSmall),
                ]),
              ],
            ),
          ),
          // Notification bell
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: AppColors.textPrimary, size: 24),
                onPressed: () {}, // Phase 6: navigate to /notifications
              ),
              Positioned(
                top: 8, right: 8,
                child: Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.accent, shape: BoxShape.circle),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Empty state ─────────────────────────────────────────────
class _EmptyView extends StatelessWidget {
  const _EmptyView();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('🎭', style: TextStyle(fontSize: 48)),
        const SizedBox(height: AppSizes.lg),
        Text('No events found', style: AppFonts.headlineSmall),
        const SizedBox(height: AppSizes.sm),
        Text('Try a different category or filter',
            style: AppFonts.bodySmall),
      ],
    );
  }
}

// ─── Error state ─────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String       message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.wifi_off_rounded, color: AppColors.textSecondary, size: 48),
        const SizedBox(height: AppSizes.lg),
        Text(message, style: AppFonts.bodyMedium, textAlign: TextAlign.center),
        const SizedBox(height: AppSizes.xl),
        TextButton.icon(
          icon:     const Icon(Icons.refresh_rounded),
          label:    const Text('Try again'),
          onPressed: onRetry,
          style:    TextButton.styleFrom(foregroundColor: AppColors.accent),
        ),
      ],
    );
  }
}
