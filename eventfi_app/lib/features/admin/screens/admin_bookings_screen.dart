import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../shared/widgets/app_loader.dart';
import '../../../shared/widgets/app_snackbar.dart';

class AdminBookingsScreen extends StatefulWidget {
  const AdminBookingsScreen({super.key});
  @override
  State<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends State<AdminBookingsScreen> {
  String? _filterStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        context.read<AdminProvider>().loadBookings());
  }

  @override
  Widget build(BuildContext context) {
    final ap = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title:           Text('Bookings', style: AppFonts.headlineSmall),
        backgroundColor: AppColors.dark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.canPop() ? context.pop() : context.go('/admin'),
        ),
      ),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.pagePadding, vertical: 10),
            child: Row(children: [
              Text('${ap.totalBookings} total · ',
                  style: AppFonts.caption),
              _Chip('All',       null,        _filterStatus, _setFilter),
              const SizedBox(width: 8),
              _Chip('Paid',      'paid',      _filterStatus, _setFilter),
              const SizedBox(width: 8),
              _Chip('Cancelled', 'cancelled', _filterStatus, _setFilter),
            ]),
          ),

          Expanded(
            child: ap.loading
                ? const AppLoader()
                : ap.bookings.isEmpty
                    ? Center(child: Text('No bookings', style: AppFonts.bodySmall))
                    : RefreshIndicator(
                        color: AppColors.accent,
                        onRefresh: () => ap.loadBookings(status: _filterStatus),
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                              AppSizes.pagePadding, 0, AppSizes.pagePadding, 20),
                          itemCount: ap.bookings.length,
                          itemBuilder: (_, i) => _BookingTile(
                            b: ap.bookings[i],
                            onMarkAttended: () async {
                              await ap.confirmAttendance(ap.bookings[i]['_id']);
                              if (ap.success != null && mounted) {
                                AppSnackbar.success(context, ap.success!);
                                ap.clearMessages();
                                ap.loadBookings(status: _filterStatus);
                              }
                            },
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  void _setFilter(String? status) {
    setState(() => _filterStatus = status);
    context.read<AdminProvider>().loadBookings(status: status);
  }
}

class _Chip extends StatelessWidget {
  final String  label;
  final String? value;
  final String? selected;
  final Function(String?) onTap;
  const _Chip(this.label, this.value, this.selected, this.onTap);

  @override
  Widget build(BuildContext context) {
    final active = selected == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color:        active ? AppColors.accent : AppColors.surface2,
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        ),
        child: Text(label,
            style: AppFonts.caption.copyWith(
                color: active ? AppColors.dark : AppColors.textSecondary)),
      ),
    );
  }
}

class _BookingTile extends StatelessWidget {
  final Map<String, dynamic> b;
  final VoidCallback onMarkAttended;
  const _BookingTile({required this.b, required this.onMarkAttended});

  Color get _statusColor {
    switch (b['paymentStatus']) {
      case 'paid':      return b['attended'] == true ? AppColors.textSecondary : AppColors.success;
      case 'cancelled': return AppColors.error;
      default:          return AppColors.textHint;
    }
  }

  String get _statusLabel {
    if (b['paymentStatus'] == 'paid' && b['attended'] == true) return 'Attended';
    if (b['paymentStatus'] == 'paid') return 'Confirmed';
    return (b['paymentStatus'] ?? 'pending').toString().toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final user  = b['userId']  is Map ? b['userId']  as Map : {};
    final event = b['eventId'] is Map ? b['eventId'] as Map : {};

    return Container(
      margin:  const EdgeInsets.only(bottom: AppSizes.md),
      padding: const EdgeInsets.all(AppSizes.cardPadding),
      decoration: BoxDecoration(
        color:        AppColors.surface1,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(event['title'] ?? 'Event',
              style: AppFonts.labelLarge,
              maxLines: 1, overflow: TextOverflow.ellipsis)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color:        _statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            ),
            child: Text(_statusLabel,
                style: AppFonts.caption.copyWith(color: _statusColor, fontSize: 10)),
          ),
        ]),
        const SizedBox(height: 5),
        Text('${user['name'] ?? 'User'} · ${user['email'] ?? ''}',
            style: AppFonts.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 3),
        Row(children: [
          Text('${b['seats']} seats · ₹${(b['finalAmount'] ?? 0).toInt()}',
              style: AppFonts.bodySmall),
          const Spacer(),
          Text(b['bookingId'] ?? '', style: AppFonts.caption),
        ]),

        // Mark attended button (only for paid + not yet attended)
        if (b['paymentStatus'] == 'paid' && b['attended'] != true) ...[
          const SizedBox(height: 8),
          SizedBox(
            height: 32,
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onMarkAttended,
              icon:  const Icon(Icons.check_circle_outline_rounded, size: 16),
              label: const Text('Mark as Attended'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.success,
                side: const BorderSide(color: AppColors.success),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                textStyle: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ]),
    );
  }
}
