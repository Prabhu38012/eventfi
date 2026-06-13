class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final int points;
  final String role; // 'user' | 'admin'
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    this.points = 0,
    this.role = 'user',
    required this.createdAt,
  });

  bool get isAdmin => role == 'admin';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id:        json['_id'] ?? json['id'] ?? '',
      name:      json['name'] ?? '',
      email:     json['email'] ?? '',
      phone:     json['phone'],
      avatar:    json['avatar'],
      points:    json['points'] ?? 0,
      role:      json['role'] ?? 'user',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id':        id,
    'name':      name,
    'email':     email,
    'phone':     phone,
    'avatar':    avatar,
    'points':    points,
    'role':      role,
    'createdAt': createdAt.toIso8601String(),
  };

  UserModel copyWith({
    String? name,
    String? phone,
    String? avatar,
    int? points,
  }) =>
      UserModel(
        id:        id,
        name:      name ?? this.name,
        email:     email,
        phone:     phone ?? this.phone,
        avatar:    avatar ?? this.avatar,
        points:    points ?? this.points,
        role:      role,
        createdAt: createdAt,
      );
}
