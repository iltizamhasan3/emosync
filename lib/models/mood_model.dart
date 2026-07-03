class MoodCheckinModel {
  final int id;
  final String mood;
  final String? catatan;
  final List<String> pemicus;
  final DateTime createdAt;

  MoodCheckinModel({
    required this.id,
    required this.mood,
    this.catatan,
    required this.pemicus,
    required this.createdAt,
  });

  factory MoodCheckinModel.fromJson(Map<String, dynamic> json) {
    return MoodCheckinModel(
      id: json['id'],
      mood: json['mood'],
      catatan: json['catatan'],
      pemicus: json['pemicus'] != null 
          ? List<String>.from(json['pemicus'].map((p) => p['nama']))
          : [],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class PemicuModel {
  final int id;
  final String nama;
  final String ikon;
  final String? kategori;

  PemicuModel({
    required this.id,
    required this.nama,
    required this.ikon,
    this.kategori,
  });

  factory PemicuModel.fromJson(Map<String, dynamic> json) {
    return PemicuModel(
      id: json['id'],
      nama: json['nama'],
      ikon: json['ikon'] ?? '😔',
      kategori: json['kategori'],
    );
  }
}

class DashboardModel {
  final int streak;
  final double rataRataMood;
  final Map<String, int> moodDistribution;
  final List<MoodCheckinModel> weeklyCheckins;

  DashboardModel({
    required this.streak,
    required this.rataRataMood,
    required this.moodDistribution,
    required this.weeklyCheckins,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      streak: json['streak'] ?? 0,
      rataRataMood: (json['rata_rata_mood'] ?? 0).toDouble(),
      moodDistribution: Map<String, int>.from(json['mood_distribution'] ?? {}),
      weeklyCheckins: (json['weekly_checkins'] as List?)
          ?.map((e) => MoodCheckinModel.fromJson(e))
          .toList() ?? [],
    );
  }
}