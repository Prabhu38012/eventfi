import 'package:intl/intl.dart';

class BookingModel {
  final String  id;
  final String  bookingId;
  final String  userId;
  final String  eventId;
  final int     seats;
  final double  amount;
  final String? couponCode;
  final double  discount;
  final double  finalAmount;
  final String  paymentStatus;
  final String? razorpayPaymentId;
  final String? qrCode;
  final bool    attended;
  final DateTime createdAt;

  // Populated event fields
  final String? eventTitle;
  final String? eventCategory;
  final String? eventCity;
  final String? eventVenue;
  final DateTime? eventDate;
  final String? eventTime;
  final double? eventPrice;
  final String? eventPosterUrl;

  const BookingModel({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.eventId,
    required this.seats,
    required this.amount,
    this.couponCode,
    required this.discount,
    required this.finalAmount,
    required this.paymentStatus,
    this.razorpayPaymentId,
    this.qrCode,
    required this.attended,
    required this.createdAt,
    this.eventTitle,
    this.eventCategory,
    this.eventCity,
    this.eventVenue,
    this.eventDate,
    this.eventTime,
    this.eventPrice,
    this.eventPosterUrl,
  });

  bool get isPaid      => paymentStatus == 'paid';
  bool get isCancelled => paymentStatus == 'cancelled';
  bool get isRefunded  => paymentStatus == 'refunded';

  String get formattedDate => eventDate != null
      ? DateFormat('EEE, d MMM yyyy').format(eventDate!)
      : '';

  String get statusLabel {
    switch (paymentStatus) {
      case 'paid':      return attended ? 'Attended' : 'Confirmed';
      case 'cancelled': return 'Cancelled';
      case 'refunded':  return 'Refunded';
      default:          return 'Pending';
    }
  }

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    final event = json['eventId'] is Map ? json['eventId'] as Map : null;
    return BookingModel(
      id:                json['_id']               ?? '',
      bookingId:         json['bookingId']          ?? '',
      userId:            json['userId']?.toString() ?? '',
      eventId:           event?['_id']?.toString()  ?? json['eventId']?.toString() ?? '',
      seats:             json['seats']              ?? 0,
      amount:            (json['amount']      ?? 0).toDouble(),
      couponCode:        json['couponCode'],
      discount:          (json['discount']    ?? 0).toDouble(),
      finalAmount:       (json['finalAmount'] ?? 0).toDouble(),
      paymentStatus:     json['paymentStatus']      ?? 'pending',
      razorpayPaymentId: json['razorpayPaymentId'],
      qrCode:            json['qrCode'],
      attended:          json['attended']           ?? false,
      createdAt:         DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      eventTitle:        event?['title'],
      eventCategory:     event?['category'],
      eventCity:         event?['city'],
      eventVenue:        event?['venue'],
      eventDate:         event?['date'] != null ? DateTime.tryParse(event!['date']) : null,
      eventTime:         event?['time'],
      eventPrice:        event?['price']?.toDouble(),
      eventPosterUrl:    event?['posterUrl'],
    );
  }
}
