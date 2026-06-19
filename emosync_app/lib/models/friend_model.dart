class FriendModel {
  final int id;
  final String name;
  final String username;
  final String avatar;
  final String? mood;
  final String? lastCheckin;
  final bool isPremium;

  FriendModel({
    required this.id,
    required this.name,
    required this.username,
    this.avatar = 'male',
    this.mood,
    this.lastCheckin,
    this.isPremium = false,
  });

  factory FriendModel.fromJson(Map<String, dynamic> json) {
    return FriendModel(
      id: json['id'],
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      avatar: json['avatar'] ?? 'male',
      mood: json['mood'],
      lastCheckin: json['last_checkin'],
      isPremium: json['is_premium'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'avatar': avatar,
      'mood': mood,
      'last_checkin': lastCheckin,
      'is_premium': isPremium,
    };
  }

  FriendModel copyWith({
    int? id,
    String? name,
    String? username,
    String? avatar,
    String? mood,
    String? lastCheckin,
    bool? isPremium,
  }) {
    return FriendModel(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      avatar: avatar ?? this.avatar,
      mood: mood ?? this.mood,
      lastCheckin: lastCheckin ?? this.lastCheckin,
      isPremium: isPremium ?? this.isPremium,
    );
  }
}

class FriendRequestModel {
  final int id;              // ID user (pengirim/penerima)
  final String name;
  final String username;
  final String avatar;
  final bool isPremium;
  final int? friendshipId;
  final String? status;      // 'incoming' atau 'outgoing'

  FriendRequestModel({
    required this.id,
    required this.name,
    required this.username,
    this.avatar = 'male',
    this.isPremium = false,
    this.friendshipId,
    this.status,
  });

  factory FriendRequestModel.fromJson(Map<String, dynamic> json) {
    return FriendRequestModel(
      id: json['id'],
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      avatar: json['avatar'] ?? 'male',
      isPremium: json['is_premium'] ?? false,
      friendshipId: json['friendship_id'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'avatar': avatar,
      'is_premium': isPremium,
      'friendship_id': friendshipId,
      'status': status,
    };
  }

  FriendRequestModel copyWith({
    int? id,
    String? name,
    String? username,
    String? avatar,
    bool? isPremium,
    int? friendshipId,
    String? status,
  }) {
    return FriendRequestModel(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      avatar: avatar ?? this.avatar,
      isPremium: isPremium ?? this.isPremium,
      friendshipId: friendshipId ?? this.friendshipId,
      status: status ?? this.status,
    );
  }
}

class PremiumPlanModel {
  final String id;
  final String name;
  final int price;
  final String priceFormatted;
  final String period;
  final int durationDays;
  final String? badge;
  final String? saving;

  PremiumPlanModel({
    required this.id,
    required this.name,
    required this.price,
    required this.priceFormatted,
    required this.period,
    required this.durationDays,
    this.badge,
    this.saving,
  });

  factory PremiumPlanModel.fromJson(Map<String, dynamic> json) {
    return PremiumPlanModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: json['price'] ?? 0,
      priceFormatted: json['price_formatted'] ?? 'Rp 0',
      period: json['period'] ?? '',
      durationDays: json['duration_days'] ?? 0,
      badge: json['badge'],
      saving: json['saving'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'price_formatted': priceFormatted,
      'period': period,
      'duration_days': durationDays,
      'badge': badge,
      'saving': saving,
    };
  }

  PremiumPlanModel copyWith({
    String? id,
    String? name,
    int? price,
    String? priceFormatted,
    String? period,
    int? durationDays,
    String? badge,
    String? saving,
  }) {
    return PremiumPlanModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      priceFormatted: priceFormatted ?? this.priceFormatted,
      period: period ?? this.period,
      durationDays: durationDays ?? this.durationDays,
      badge: badge ?? this.badge,
      saving: saving ?? this.saving,
    );
  }
}