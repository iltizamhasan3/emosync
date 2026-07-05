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
