import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/points_provider.dart';
import '../widgets/reward_tile.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../../../shared/widgets/app_loader.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});
  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pp = context.read<PointsProvider>();
      if (pp.rewards.isEmpty) pp.loadRewards();
    });
  }

  Future<void> _redeem(PointsProvider pp, Map<String, dynamic> reward) async {
    final ok = await pp.redeemReward(reward['id'] as String);
    if (!mounted) return;

    if (ok && pp.earnedCoupon != null) {
      // Show success dialog with coupon code
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.surface1,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusXl)),
          title: Text('🎉 Reward Unlocked!',
              style: AppFonts.headlineMedium),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(reward['name'] as String,
                  style: AppFonts.bodyMedium
                      .copyWith(color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              Text('Your coupon code:',
                  style: AppFonts.caption),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color:        AppColors.surface2,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border:       Border.all(color: AppColors.gold.withOpacity(0.4)),
                ),
                child: Text(
                  pp.earnedCoupon!,
                  style: AppFonts.tanker(
                      fontSize: 22, color: AppColors.gold),
                ),
              ),
              const SizedBox(height: 8),
              Text('Valid for 30 days · Single use',
                  style: AppFonts.caption),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                pp.clearRedeemState();
                Navigator.pop(context);
              },
              child: Text('Done',
                  style: AppFonts.labelLarge
                      .copyWith(color: AppColors.accent)),
            ),
          ],
        ),
      );
    } else if (!ok) {
      AppSnackbar.error(context, pp.redeemMsg ?? 'Redemption failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final pp = context.watch<PointsProvider>();

    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title:           Text('Rewards', style: AppFonts.appLogo.copyWith(fontSize: 22)),
        backgroundColor: AppColors.dark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/points'),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSizes.lg),
            child: Row(children: [
              const Icon(Icons.star_rounded, color: AppColors.gold, size: 16),
              const SizedBox(width: 4),
              Text('${pp.balance} pts',
                  style: AppFonts.labelMedium
                      .copyWith(color: AppColors.gold)),
            ]),
          ),
        ],
      ),
      body: pp.rewards.isEmpty
          ? const AppLoader()
          : Column(
              children: [
                // Info banner
                Container(
                  margin:  const EdgeInsets.all(AppSizes.pagePadding),
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color:        AppColors.gold.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    border:       Border.all(
                        color: AppColors.gold.withOpacity(0.2)),
                  ),
                  child: Row(children: [
                    const Text('⭐', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Redeem your Gold Points for exclusive discounts '
                        'and free event passes.',
                        style: AppFonts.bodySmall,
                      ),
                    ),
                  ]),
                ),

                // Grid
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(
                        AppSizes.pagePadding, 0,
                        AppSizes.pagePadding, AppSizes.pagePadding),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:   2,
                      childAspectRatio: 0.82,
                      crossAxisSpacing: 12,
                      mainAxisSpacing:  12,
                    ),
                    itemCount: pp.rewards.length,
                    itemBuilder: (_, i) => RewardTile(
                      reward:      pp.rewards[i],
                      userPoints:  pp.balance,
                      isRedeeming: pp.redeeming,
                      onRedeem:    () => _redeem(pp, pp.rewards[i]),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
