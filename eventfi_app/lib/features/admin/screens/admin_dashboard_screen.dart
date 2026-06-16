import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../shared/widgets/app_loader.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ap = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title:           Text('EventFi Admin', style: AppFonts.appLogo.copyWith(fontSize: 20)),
        backgroundColor: AppColors.dark,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon:      const Icon(Icons.qr_code_scanner_rounded, color: AppColors.accent),
            tooltip:   'QR Gate Scanner',
            onPressed: () => context.push('/admin/scanner'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ap.loading
          ? const AppLoader()
          : RefreshIndicator(
              color:    AppColors.accent,
              onRefresh: ap.loadStats,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSizes.pagePadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Stats grid ────────────────────────────
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap:     true,
                      physics:        const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: AppSizes.md,
                      mainAxisSpacing:  AppSizes.md,
                      childAspectRatio: 1.6,
                      children: [
                        _StatCard('Total Bookings', '${ap.stats?.totalBookings ?? 0}',
                            Icons.confirmation_number_outlined, AppColors.accent),
                        _StatCard('Revenue', '₹${_fmt(ap.stats?.totalRevenue ?? 0)}',
                            Icons.currency_rupee_rounded, AppColors.success),
                        _StatCard('Active Events', '${ap.stats?.totalEvents ?? 0}',
                            Icons.event_outlined, AppColors.concert),
                        _StatCard('Users', '${ap.stats?.totalUsers ?? 0}',
                            Icons.people_outline_rounded, AppColors.gold),
                      ],
                    ),

                    const SizedBox(height: AppSizes.sectionGap),

                    // ── Quick actions ─────────────────────────
                    Text('Manage', style: AppFonts.headlineSmall),
                    const SizedBox(height: AppSizes.md),
                    Row(children: [
                      _ActionBtn('Events',   Icons.event_outlined,            () => context.push('/admin/events')),
                      const SizedBox(width: AppSizes.md),
                      _ActionBtn('Bookings', Icons.book_online_outlined,       () => context.push('/admin/bookings')),
                      const SizedBox(width: AppSizes.md),
                      _ActionBtn('Coupons',  Icons.local_offer_outlined,       () => context.push('/admin/coupons')),
                      const SizedBox(width: AppSizes.md),
                      _ActionBtn('Scanner',  Icons.qr_code_scanner_rounded,   () => context.push('/admin/scanner'),
                          color: AppColors.accent),
                    ]),

                    const SizedBox(height: AppSizes.sectionGap),

                    // ── Recent bookings ───────────────────────
                    Text('Recent Bookings', style: AppFonts.headlineSmall),
                    const SizedBox(height: AppSizes.md),
                    if ((ap.stats?.recentBookings ?? []).isEmpty)
                      Container(
                        padding: const EdgeInsets.all(AppSizes.xl),
                        decoration: BoxDecoration(
                          color:        AppColors.surface1,
                          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                        ),
                        child: Center(child: Text('No bookings yet', style: AppFonts.bodySmall)),
                      )
                    else
                      ...ap.stats!.recentBookings.map((b) => _BookingRow(b)),
                  ],
                ),
              ),
            ),
    );
  }

  String _fmt(double v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000)   return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toInt().toString();
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSizes.lg),
    decoration: BoxDecoration(
      color:        AppColors.surface1,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: color, size: 24),
      const Spacer(),
      Text(value, style: AppFonts.spaceGrotesk(fontSize: 24, weight: FontWeight.w700, color: AppColors.textPrimary)),
      const SizedBox(height: 2),
      Text(label, style: AppFonts.caption),
    ]),
  );
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  const _ActionBtn(this.label, this.icon, this.onTap, {this.color});

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color:        (color ?? AppColors.surface2).withOpacity(color != null ? 0.15 : 1),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border:       color != null ? Border.all(color: color!.withOpacity(0.4)) : null,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color ?? AppColors.textPrimary, size: 22),
          const SizedBox(height: 6),
          Text(label, style: AppFonts.caption.copyWith(color: color ?? AppColors.textPrimary)),
        ]),
      ),
    ),
  );
}

class _BookingRow extends StatelessWidget {
  final Map<String, dynamic> b;
  const _BookingRow(this.b);

  @override
  Widget build(BuildContext context) {
    final user  = b['userId']  is Map ? b['userId']  as Map : {};
    final event = b['eventId'] is Map ? b['eventId'] as Map : {};
    return Container(
      margin:  const EdgeInsets.only(bottom: AppSizes.sm),
      padding: const EdgeInsets.all(AppSizes.cardPadding),
      decoration: BoxDecoration(
        color:        AppColors.surface1,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Row(children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.person_outline_rounded, color: AppColors.accent, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(user['name']  ?? 'User',  style: AppFonts.labelMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(event['title'] ?? 'Event', style: AppFonts.caption,    maxLines: 1, overflow: TextOverflow.ellipsis),
        ])),
        Text('₹${(b['finalAmount'] ?? 0).toInt()}',
            style: AppFonts.bodySmall.copyWith(color: AppColors.success)),
      ]),
    );
  }
}
