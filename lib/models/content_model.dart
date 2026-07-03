class ContentModel {
  final int id;
  final String title;
  final String description;
  final String fullContent;
  final String type;
  final String? thumbnailUrl;
  final String? videoUrl;
  final bool isPremium;

  ContentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.fullContent,
    required this.type,
    this.thumbnailUrl,
    this.videoUrl,
    required this.isPremium,
  });

  factory ContentModel.fromJson(Map<String, dynamic> json) {
    // Handle is_premium bisa berupa int (0/1) atau bool (true/false) atau String
    bool isPremiumValue = false;
    
    final isPremiumRaw = json['is_premium'];
    
    if (isPremiumRaw is bool) {
      isPremiumValue = isPremiumRaw;
    } else if (isPremiumRaw is int) {
      isPremiumValue = isPremiumRaw == 1;
    } else if (isPremiumRaw is String) {
      isPremiumValue = isPremiumRaw == '1' || isPremiumRaw == 'true';
    }
    
    return ContentModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      fullContent: json['full_content']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      thumbnailUrl: json['thumbnail_url']?.toString(),
      videoUrl: json['video_url']?.toString(),
      isPremium: isPremiumValue,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'full_content': fullContent,
      'type': type,
      'thumbnail_url': thumbnailUrl,
      'video_url': videoUrl,
      'is_premium': isPremium ? 1 : 0,
    };
  }
}