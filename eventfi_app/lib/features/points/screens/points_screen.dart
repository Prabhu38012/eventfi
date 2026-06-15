import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/points_provider.dart';
import '../models/points_model.dart';
import '../widgets/points_balance_card.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../../../shared/widgets/app_loader.dart';
import '../../../shared/widgets/app_button.dart';

class PointsScreen extends StatefulWidget {
  const PointsScreen({super.key});
  @override
  State<PointsScreen> createState() => _PointsScreenState();
}

class _PointsScreenState extends State<PointsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PointsProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pp = context.watch<PointsProvider>();

    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title:           Text('Gold Points', style: AppFonts.appLogo.copyWith(fontSize: 22)),
        backgroundColor: AppColors.dark,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () => context.push('/rewards'),
            child: Text('Rewards →',
                style: AppFonts.labelMedium.copyWith(color: AppColors.accent)),
          ),
        ],
      ),
      body: pp.loading
          ? const AppLoader()
          : CustomScrollView(
              slivers: [

                // ─── Balance card ───────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.pagePadding),
                    child: PointsBalanceCard(
                      balance:          pp.balance,
                      tier:             pp.tier,
                      tierEmoji:        pp.tierEmoji,
                      pointsToNextTier: pp.pointsToNextTier,
                      tierProgress:     pp.tierProgress,
                    ),
                  ),
                ),

                // ─── Redeem button ──────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.pagePadding),
                    child: AppButton(
                      text:      '🎁  Redeem Rewards',
                      onTap:     () => context.push('/rewards'),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(
                    child: SizedBox(height: AppSizes.sectionGap)),

                // ─── History header ─────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.pagePadding),
                    child: Text('Transaction History',
                        style: AppFonts.headlineSmall),
                  ),
                ),

                const SliverToBoxAdapter(
                    child: SizedBox(height: AppSizes.md)),

                // ─── History list ───────────────────────────
                pp.history.isEmpty
                    ? SliverFillRemaining(
                        child: _EmptyHistory(),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.pagePadding),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, i) => _HistoryRow(item: pp.history[i]),
                            childCount: pp.history.length,
                          ),
                        ),
                      ),

                const SliverToBoxAdapter(child: SizedBox(height: 90)),
              ],
            ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }
}

// ── Transaction row ───────────────────────────────────────────
class _HistoryRow extends StatelessWidget {
  final PointsModel item;
  const _HistoryRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:  const EdgeInsets.only(bottom: AppSizes.sm),
      padding: const EdgeInsets.all(AppSizes.cardPadding),
      decoration: BoxDecoration(
        color:        AppColors.surface1,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Row(children: [
        // Icon
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: (item.isPositive
                    ? AppColors.success
                    : AppColors.error)
                .withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(item.icon,
              color: item.isPositive ? AppColors.success : AppColors.error,
              size: 18),
        ),

        const SizedBox(width: 12),

        // Description
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.description,
                  style: AppFonts.bodySmall
                      .copyWith(color: AppColors.textPrimary),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(item.formattedDate, style: AppFonts.caption),
            ],
          ),
        ),

        // Amount
        Text(
          item.displayAmount,
          style: AppFonts.spaceGrotesk(
            fontSize:  13,
            weight:    FontWeight.w600,
            color:     item.amountColor,
          ),
        ),
      ]),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('⭐', style: TextStyle(fontSize: 48)),
      const SizedBox(height: 16),
      Text('No transactions yet', style: AppFonts.headlineSmall),
      const SizedBox(height: 8),
      Text('Book an event to earn your first Gold Points',
          style: AppFonts.bodySmall, textAlign: TextAlign.center),
    ]),
  );
}
