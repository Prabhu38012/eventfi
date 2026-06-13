import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';

class EventModel {
  final String  id;
  final String  title;
  final String  category;
  final String  description;
  final String  city;
  final String  district;
  final String  venue;
  final String? posterUrl;
  final List<String> images;
  final DateTime date;
  final String  time;
  final double  price;
  final int     totalSeats;
  final int     availableSeats;
  final double? latitude;
  final double? longitude;
  final String  organizerName;
  final String  organizerPhone;
  final int     bookingCount;

  const EventModel({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.city,
    required this.district,
    required this.venue,
    this.posterUrl,
    this.images = const [],
    required this.date,
    required this.time,
    required this.price,
    required this.totalSeats,
    required this.availableSeats,
    this.latitude,
    this.longitude,
    this.organizerName = '',
    this.organizerPhone = '',
    this.bookingCount = 0,
  });

  // ─── Computed Properties ─────────────────────────────────
  String get formattedDate => DateFormat('EEE, d MMM yyyy').format(date);
  String get shortDate     => DateFormat('d MMM').format(date);

  String get priceDisplay =>
      price == 0 ? 'Free' : '₹${price.toInt()}';

  bool get hasSeatsLeft => availableSeats > 0;

  String get seatsLabel {
    if (availableSeats == 0)  return 'Sold out';
    if (availableSeats <= 20) return 'Only $availableSeats left!';
    return '$availableSeats seats';
  }

  Color get seatsColor {
    if (availableSeats == 0)  return AppColors.error;
    if (availableSeats <= 20) return AppColors.warning;
    return AppColors.textSecondary;
  }

  String get categoryLabel {
    switch (category) {
      case 'theatre':   return 'Theatre';
      case 'concert':   return 'Concert';
      case 'standup':   return 'Standup';
      case 'dance':     return 'Dance';
      case 'themePark': return 'Theme Park';
      default:          return category;
    }
  }

  Color get categoryColor {
    switch (category) {
      case 'theatre':   return AppColors.theatre;
      case 'concert':   return AppColors.concert;
      case 'standup':   return AppColors.standup;
      case 'dance':     return AppColors.dance;
      case 'themePark': return AppColors.themePark;
      default:          return AppColors.accent;
    }
  }

  IconData get categoryIcon {
    switch (category) {
      case 'theatre':   return Icons.theater_comedy_outlined;
      case 'concert':   return Icons.music_note_outlined;
      case 'standup':   return Icons.mic_outlined;
      case 'dance':     return Icons.directions_run_outlined;
      case 'themePark': return Icons.attractions_outlined;
      default:          return Icons.event_outlined;
    }
  }

  // ─── Factory ─────────────────────────────────────────────
  factory EventModel.fromJson(Map<String, dynamic> json) => EventModel(
        id:             json['_id']             ?? '',
        title:          json['title']           ?? '',
        category:       json['category']        ?? 'concert',
        description:    json['description']     ?? '',
        city:           json['city']            ?? '',
        district:       json['district']        ?? '',
        venue:          json['venue']           ?? '',
        posterUrl:      json['posterUrl'],
        images:         List<String>.from(json['images'] ?? []),
        date:           DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
        time:           json['time']            ?? '',
        price:          (json['price'] ?? 0).toDouble(),
        totalSeats:     json['totalSeats']      ?? 0,
        availableSeats: json['availableSeats']  ?? 0,
        latitude:       json['latitude']?.toDouble(),
        longitude:      json['longitude']?.toDouble(),
        organizerName:  json['organizerName']   ?? '',
        organizerPhone: json['organizerPhone']  ?? '',
        bookingCount:   json['bookingCount']    ?? 0,
      );
}
