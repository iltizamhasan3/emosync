import 'package:flutter/material.dart';

enum MoodType { bahagia, cemas, tenang, sedih, netral }

class MoodHelper {
  static MoodType fromString(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return MoodType.bahagia;
      case 'anxious':
        return MoodType.cemas;
      case 'calm':
        return MoodType.tenang;
      case 'sad':
        return MoodType.sedih;
      default:
        return MoodType.netral;
    }
  }

  static Color getMoodColor(MoodType mood) {
    switch (mood) {
      case MoodType.bahagia:
        return const Color(0xFFFFD700);
      case MoodType.cemas:
        return const Color(0xFFF57E7E);
      case MoodType.tenang:
        return const Color(0xFFB2D8B2);
      case MoodType.sedih:
        return const Color(0xFFA7C7E7);
      case MoodType.netral:
        return Colors.grey[300]!;
    }
  }

  static Color getMoodBgColor(MoodType mood) {
    switch (mood) {
      case MoodType.bahagia:
        return const Color(0xFFFFF9E6);
      case MoodType.cemas:
        return const Color(0xFFFFF1F1);
      case MoodType.tenang:
        return const Color(0xFFF1FBF3);
      case MoodType.sedih:
        return const Color(0xFFF1F7FF);
      case MoodType.netral:
        return const Color(0xFFF5F5F5);
    }
  }

  static Color getMoodIconColor(MoodType mood) {
    switch (mood) {
      case MoodType.bahagia:
        return const Color(0xFFFFD700);
      case MoodType.cemas:
        return const Color(0xFFF57E7E);
      case MoodType.tenang:
        return const Color(0xFFB2D8B2);
      case MoodType.sedih:
        return const Color(0xFFA7C7E7);
      case MoodType.netral:
        return Colors.grey[400]!;
    }
  }

  static double getMoodHeight(MoodType mood) {
    switch (mood) {
      case MoodType.bahagia:
        return 100.0;
      case MoodType.cemas:
        return 80.0;
      case MoodType.tenang:
        return 60.0;
      case MoodType.sedih:
        return 30.0;
      case MoodType.netral:
        return 10.0;
    }
  }

  static String getMoodLabel(MoodType mood) {
    switch (mood) {
      case MoodType.bahagia:
        return 'Bahagia';
      case MoodType.cemas:
        return 'Cemas';
      case MoodType.tenang:
        return 'Tenang';
      case MoodType.sedih:
        return 'Sedih';
      case MoodType.netral:
        return 'Netral';
    }
  }

  static String getMoodEnglishLabel(MoodType mood) {
    switch (mood) {
      case MoodType.bahagia:
        return 'Happy';
      case MoodType.cemas:
        return 'Anxious';
      case MoodType.tenang:
        return 'Calm';
      case MoodType.sedih:
        return 'Sad';
      case MoodType.netral:
        return 'Neutral';
    }
  }

  static IconData getMoodIcon(MoodType mood) {
    switch (mood) {
      case MoodType.bahagia:
        return Icons.sentiment_very_satisfied;
      case MoodType.cemas:
        return Icons.sentiment_dissatisfied;
      case MoodType.tenang:
        return Icons.spa;
      case MoodType.sedih:
        return Icons.sentiment_very_dissatisfied;
      case MoodType.netral:
        return Icons.sentiment_neutral;
    }
  }

  static String getMoodEmoji(MoodType mood) {
    switch (mood) {
      case MoodType.bahagia:
        return '☀️';
      case MoodType.cemas:
        return '⚡';
      case MoodType.tenang:
        return '🌿';
      case MoodType.sedih:
        return '☁️';
      case MoodType.netral:
        return '😐';
    }
  }

  static String getMoodDescription(MoodType mood) {
    switch (mood) {
      case MoodType.bahagia:
        return 'Senang, semangat, ceria';
      case MoodType.cemas:
        return 'Marah, tegang, atau gelisah';
      case MoodType.tenang:
        return 'Tenang, damai, rileks';
      case MoodType.sedih:
        return 'Sedih, lelah, atau hampa';
      case MoodType.netral:
        return 'Biasa saja';
    }
  }

  static String getEnergyLabel(MoodType mood) {
    switch (mood) {
      case MoodType.bahagia:
        return 'HIGH ENERGY';
      case MoodType.cemas:
        return 'HIGH ENERGY';
      case MoodType.tenang:
        return 'LOW ENERGY';
      case MoodType.sedih:
        return 'LOW ENERGY';
      case MoodType.netral:
        return 'NEUTRAL';
    }
  }
}