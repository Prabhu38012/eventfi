import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';

class PointsModel {
  final String   id;
  final int      amount;
  final String   type;        // earn | redeem | referral | bonus | expire
  final String   description;
  final DateTime createdAt;
  final DateTime? expiresAt;

  const PointsModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.description,
    required this.createdAt,
    this.expiresAt,
  });

  bool   get isPositive    => amount > 0;
  String get displayAmount => amount > 0 ? '+$amount pts' : '$amount pts';
  String get formattedDate => DateFormat('d MMM yyyy').format(createdAt);

  Color get amountColor {
    if (amount > 0) return AppColors.success;
    if (amount < 0) return AppColors.error;
    return AppColors.textSecondary;
  }

  IconData get icon {
    switch (type) {
      case 'earn':     return Icons.star_rounded;
      case 'redeem':   return Icons.card_giftcard_rounded;
      case 'referral': return Icons.person_add_outlined;
      case 'bonus':    return Icons.celebration_outlined;
      case 'expire':   return Icons.timer_off_outlined;
      default:         return Icons.swap_horiz_rounded;
    }
  }

  factory PointsModel.fromJson(Map<String, dynamic> json) => PointsModel(
        id:          json['_id']         ?? '',
        amount:      json['amount']      ?? 0,
        type:        json['type']        ?? 'earn',
        description: json['description'] ?? '',
        createdAt:   DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
        expiresAt:   json['expiresAt'] != null
            ? DateTime.tryParse(json['expiresAt'])
            : null,
      );
}
