class NotificationSettings {
  final bool dailyReminder;
  final bool weeklyReport;
  final bool friendActivity;
  final bool tipsInsights;

  NotificationSettings({
    required this.dailyReminder,
    required this.weeklyReport,
    required this.friendActivity,
    required this.tipsInsights,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      dailyReminder: json['daily_reminder'] ?? true,
      weeklyReport: json['weekly_report'] ?? true,
      friendActivity: json['friend_activity'] ?? false,
      tipsInsights: json['tips_insights'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'daily_reminder': dailyReminder,
      'weekly_report': weeklyReport,
      'friend_activity': friendActivity,
      'tips_insights': tipsInsights,
    };
  }

  NotificationSettings copyWith({
    bool? dailyReminder,
    bool? weeklyReport,
    bool? friendActivity,
    bool? tipsInsights,
  }) {
    return NotificationSettings(
      dailyReminder: dailyReminder ?? this.dailyReminder,
      weeklyReport: weeklyReport ?? this.weeklyReport,
      friendActivity: friendActivity ?? this.friendActivity,
      tipsInsights: tipsInsights ?? this.tipsInsights,
    );
  }
}

class PrivacySettings {
  final bool showMood;
  final bool allowRequests;
  final bool showActive;

  PrivacySettings({
    required this.showMood,
    required this.allowRequests,
    required this.showActive,
  });

  factory PrivacySettings.fromJson(Map<String, dynamic> json) {
    return PrivacySettings(
      showMood: json['show_mood'] ?? true,
      allowRequests: json['allow_requests'] ?? true,
      showActive: json['show_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'show_mood': showMood,
      'allow_requests': allowRequests,
      'show_active': showActive,
    };
  }

  PrivacySettings copyWith({
    bool? showMood,
    bool? allowRequests,
    bool? showActive,
  }) {
    return PrivacySettings(
      showMood: showMood ?? this.showMood,
      allowRequests: allowRequests ?? this.allowRequests,
      showActive: showActive ?? this.showActive,
    );
  }
}