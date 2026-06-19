class UserModel {
  final int id;
  final String name;
  final String username;
  final String email;
  final String avatar;
  final bool isPremium;
  final String? premiumPlan;
  final DateTime? premiumExpiry;
  final int streak;

  UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    this.avatar = 'male',
    this.isPremium = false,
    this.premiumPlan,
    this.premiumExpiry,
    this.streak = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      email: json['email'],
      avatar: json['avatar'] ?? 'male',
      isPremium: json['is_premium'] ?? false,
      premiumPlan: json['premium_plan'],
      premiumExpiry: json['premium_expiry'] != null 
          ? DateTime.parse(json['premium_expiry']) 
          : null,
      streak: json['streak'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'avatar': avatar,
      'is_premium': isPremium,
      'premium_plan': premiumPlan,
      'premium_expiry': premiumExpiry?.toIso8601String(),
      'streak': streak,
    };
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? username,
    String? email,
    String? avatar,
    bool? isPremium,
    String? premiumPlan,
    DateTime? premiumExpiry,
    int? streak,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      isPremium: isPremium ?? this.isPremium,
      premiumPlan: premiumPlan ?? this.premiumPlan,
      premiumExpiry: premiumExpiry ?? this.premiumExpiry,
      streak: streak ?? this.streak,
    );
  }
}