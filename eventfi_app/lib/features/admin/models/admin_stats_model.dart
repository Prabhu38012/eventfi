class AdminStats {
  final int    totalBookings;
  final double totalRevenue;
  final int    totalEvents;
  final int    totalUsers;
  final List<Map<String, dynamic>> recentBookings;

  const AdminStats({
    required this.totalBookings,
    required this.totalRevenue,
    required this.totalEvents,
    required this.totalUsers,
    required this.recentBookings,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] as Map<String, dynamic>? ?? {};
    return AdminStats(
      totalBookings:  stats['totalBookings']  ?? 0,
      totalRevenue:   (stats['totalRevenue']  ?? 0).toDouble(),
      totalEvents:    stats['totalEvents']    ?? 0,
      totalUsers:     stats['totalUsers']     ?? 0,
      recentBookings: List<Map<String, dynamic>>.from(
          json['recentBookings'] ?? []),
    );
  }
}
