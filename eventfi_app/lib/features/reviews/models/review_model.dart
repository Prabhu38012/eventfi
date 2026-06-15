import 'package:intl/intl.dart';

class ReviewModel {
  final String  id;
  final String  userId;
  final String  eventId;
  final int     rating;
  final String  comment;
  final String  userName;
  final String? userAvatar;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.rating,
    required this.comment,
    required this.userName,
    this.userAvatar,
    required this.createdAt,
  });

  String get formattedDate => DateFormat('d MMM yyyy').format(createdAt);

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final user = json['userId'] is Map ? json['userId'] as Map : null;
    return ReviewModel(
      id:          json['_id']     ?? '',
      userId:      user?['_id']?.toString() ?? json['userId']?.toString() ?? '',
      eventId:     json['eventId']?.toString() ?? '',
      rating:      json['rating']  ?? 0,
      comment:     json['comment'] ?? '',
      userName:    user?['name']   ?? 'EventFi User',
      userAvatar:  user?['avatar'],
      createdAt:   DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
