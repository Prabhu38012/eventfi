import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../models/notification_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../shared/widgets/app_loader.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final np = context.watch<NotificationProvider>();

    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title:           Text('Notifications', style: AppFonts.appLogo.copyWith(fontSize: 22)),
        backgroundColor: AppColors.dark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
        actions: [
          if (np.unreadCount > 0)
            TextButton(
              onPressed: np.markAllRead,
              child: Text('Mark all read',
                  style: AppFonts.labelSmall
                      .copyWith(color: AppColors.accent)),
            ),
        ],
      ),
      body: np.loading
          ? const AppLoader()
          : np.notifications.isEmpty
              ? _EmptyState()
              : ListView.builder(
                  padding:    const EdgeInsets.symmetric(vertical: 8),
                  itemCount:  np.notifications.length,
                  itemBuilder: (_, i) => _NotifRow(
                    notif:   np.notifications[i],
                    onTap:   () => np.markRead(np.notifications[i].id),
                  ),
                ),
    );
  }
}

class _NotifRow extends StatelessWidget {
  final NotificationModel notif;
  final VoidCallback      onTap;
  const _NotifRow({required this.notif, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.pagePadding, vertical: 12),
        color: notif.isRead
            ? Colors.transparent
            : AppColors.surface1.withOpacity(0.4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color:  notif.iconColor.withOpacity(0.12),
                shape:  BoxShape.circle,
              ),
              child: Icon(notif.icon, color: notif.iconColor, size: 20),
            ),

            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notif.title,
                      style: AppFonts.labelMedium.copyWith(
                        color: notif.isRead
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                      )),
                  const SizedBox(height: 2),
                  Text(notif.body,
                      style: AppFonts.caption,
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(notif.timeAgo,
                      style: AppFonts.caption
                          .copyWith(fontSize: 10, color: AppColors.textHint)),
                ],
              ),
            ),

            // Unread dot
            if (!notif.isRead)
              Container(
                width: 8, height: 8, margin: const EdgeInsets.only(top: 6),
                decoration: const BoxDecoration(
                  color: AppColors.accent, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('🔔', style: TextStyle(fontSize: 56)),
      const SizedBox(height: 20),
      Text('No notifications yet', style: AppFonts.headlineSmall),
      const SizedBox(height: 8),
      Text('You\'ll get updates about bookings,\nevents, and offers here',
          style: AppFonts.bodySmall, textAlign: TextAlign.center),
    ]),
  );
}
