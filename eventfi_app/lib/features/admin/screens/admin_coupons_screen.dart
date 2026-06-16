import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../shared/widgets/app_loader.dart';
import '../../../shared/widgets/app_snackbar.dart';

class AdminCouponsScreen extends StatefulWidget {
  const AdminCouponsScreen({super.key});
  @override
  State<AdminCouponsScreen> createState() => _AdminCouponsScreenState();
}

class _AdminCouponsScreenState extends State<AdminCouponsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        context.read<AdminProvider>().loadCoupons());
  }

  @override
  Widget build(BuildContext context) {
    final ap = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title:           Text('Coupons', style: AppFonts.headlineSmall),
        backgroundColor: AppColors.dark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.canPop() ? context.pop() : context.go('/admin'),
        ),
        actions: [
          IconButton(
            icon:      const Icon(Icons.add_circle_outline_rounded,
                color: AppColors.accent, size: 26),
            tooltip:   'Create Coupon',
            onPressed: () => _showCreateDialog(context, ap),
          ),
        ],
      ),
      body: ap.loading
          ? const AppLoader()
          : ap.coupons.isEmpty
              ? Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Text('🎟️', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 16),
                    Text('No coupons yet', style: AppFonts.headlineSmall),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => _showCreateDialog(context, ap),
                      child: const Text('Create First Coupon'),
                    ),
                  ]),
                )
              : RefreshIndicator(
                  color: AppColors.accent,
                  onRefresh: ap.loadCoupons,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSizes.pagePadding),
                    itemCount: ap.coupons.length,
                    itemBuilder: (_, i) => _CouponTile(
                      coupon: ap.coupons[i],
                      onToggle: () => ap.toggleCoupon(ap.coupons[i]['_id']),
                      onDelete: () async {
                        await ap.deleteCoupon(ap.coupons[i]['_id']);
                        if (mounted) AppSnackbar.success(context, 'Coupon deleted');
                      },
                    ),
                  ),
                ),
    );
  }

  void _showCreateDialog(BuildContext ctx, AdminProvider ap) {
    final codeCtrl = TextEditingController();
    final valCtrl  = TextEditingController();
    final minCtrl  = TextEditingController(text: '0');
    String type    = 'fixed';

    showDialog(
      context: ctx,
      builder: (_) => StatefulBuilder(
        builder: (ctx2, ss) => AlertDialog(
          backgroundColor: AppColors.surface1,
          title:   Text('Create Coupon', style: AppFonts.headlineMedium),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              _dlgField('Coupon Code *', codeCtrl, hint: 'e.g. SAVE50'),
              const SizedBox(height: 12),
              // Type toggle
              Row(children: [
                Expanded(child: GestureDetector(
                  onTap: () => ss(() => type = 'fixed'),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: type == 'fixed' ? AppColors.accent : AppColors.surface2,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('₹ Fixed', textAlign: TextAlign.center,
                        style: AppFonts.labelSmall.copyWith(
                            color: type == 'fixed' ? AppColors.dark : AppColors.textPrimary)),
                  ),
                )),
                const SizedBox(width: 8),
                Expanded(child: GestureDetector(
                  onTap: () => ss(() => type = 'percentage'),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: type == 'percentage' ? AppColors.accent : AppColors.surface2,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('% Off', textAlign: TextAlign.center,
                        style: AppFonts.labelSmall.copyWith(
                            color: type == 'percentage' ? AppColors.dark : AppColors.textPrimary)),
                  ),
                )),
              ]),
              const SizedBox(height: 12),
              _dlgField(type == 'fixed' ? 'Discount ₹' : 'Discount %', valCtrl,
                  keyboard: TextInputType.number),
              const SizedBox(height: 8),
              _dlgField('Min Order ₹', minCtrl, keyboard: TextInputType.number),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx2), child: const Text('Cancel')),
            ListenableBuilder(
              listenable: ap,
              builder: (_, __) => ElevatedButton(
                onPressed: ap.saving ? null : () async {
                  if (codeCtrl.text.isEmpty || valCtrl.text.isEmpty) return;
                  final ok = await ap.createCoupon({
                    'code':       codeCtrl.text.trim().toUpperCase(),
                    'type':       type,
                    'value':      double.tryParse(valCtrl.text) ?? 0,
                    'minAmount':  double.tryParse(minCtrl.text) ?? 0,
                    'expiryDate': DateTime.now().add(const Duration(days: 365)).toIso8601String(),
                    'isActive':   true,
                  });
                  if (ok && ctx2.mounted) {
                    Navigator.pop(ctx2);
                    AppSnackbar.success(ctx, 'Coupon created!');
                    ap.clearMessages();
                  }
                },
                child: const Text('Create'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dlgField(String label, TextEditingController ctrl, {
    TextInputType keyboard = TextInputType.text,
    String? hint,
  }) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: AppFonts.caption),
    const SizedBox(height: 4),
    TextField(
      controller: ctrl,
      keyboardType: keyboard,
      style: AppFonts.bodySmall.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        filled: true, fillColor: AppColors.surface2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    ),
  ]);
}

class _CouponTile extends StatelessWidget {
  final Map<String, dynamic> coupon;
  final VoidCallback onToggle, onDelete;
  const _CouponTile({required this.coupon, required this.onToggle, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final active = coupon['isActive'] == true;
    final type   = coupon['type'] == 'percentage' ? '%' : '₹';
    final value  = coupon['value'] ?? 0;
    final used   = coupon['usedCount'] ?? 0;

    return Container(
      margin:  const EdgeInsets.only(bottom: AppSizes.md),
      padding: const EdgeInsets.all(AppSizes.cardPadding),
      decoration: BoxDecoration(
        color:        AppColors.surface1,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border:       active
            ? Border.all(color: AppColors.gold.withOpacity(0.3), width: 0.5)
            : null,
      ),
      child: Row(children: [
        // Code
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(coupon['code'] ?? '',
              style: AppFonts.tanker(fontSize: 18, color: active
                  ? AppColors.gold : AppColors.textSecondary)),
          Text('$type$value off · $used used',
              style: AppFonts.caption),
          if (coupon['minAmount'] != null && coupon['minAmount'] > 0)
            Text('Min ₹${coupon['minAmount']}', style: AppFonts.caption),
        ]),

        const Spacer(),

        // Toggle
        Switch(
          value:          active,
          onChanged:      (_) => onToggle(),
          activeColor:    AppColors.accent,
          inactiveThumbColor: AppColors.textHint,
        ),

        // Delete
        IconButton(
          icon:      Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
          onPressed: onDelete,
        ),
      ]),
    );
  }
}
