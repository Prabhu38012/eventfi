import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class NotificationModel {
  final String  id;
  final String  title;
  final String  body;
  final String  type;
  final bool    isRead;
  final DateTime createdAt;
  final Map<String, dynamic> data;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.data = const {},
  });

  // ─── Derived ──────────────────────────────────────────────
  IconData get icon {
    switch (type) {
      case 'booking': return Icons.confirmation_number_outlined;
      case 'event':   return Icons.event_outlined;
      case 'offer':   return Icons.local_offer_outlined;
      case 'points':  return Icons.star_outline_rounded;
      default:        return Icons.notifications_outlined;
    }
  }

  Color get iconColor {
    switch (type) {
      case 'booking': return AppColors.accent;
      case 'event':   return AppColors.concert;
      case 'offer':   return AppColors.gold;
      case 'points':  return AppColors.gold;
      default:        return AppColors.textSecondary;
    }
  }

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays > 7)   return '${(diff.inDays / 7).floor()}w ago';
    if (diff.inDays > 0)   return '${diff.inDays}d ago';
    if (diff.inHours > 0)  return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id:        json['_id']       ?? '',
        title:     json['title']     ?? '',
        body:      json['body']      ?? '',
        type:      json['type']      ?? 'system',
        isRead:    json['isRead']    ?? false,
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
        data:      Map<String, dynamic>.from(json['data'] ?? {}),
      );
}
