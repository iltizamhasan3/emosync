import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../screens/mood_helper.dart';

class LocalStorageService {
  static const String _keyUserName = 'user_name';
  static const String _keyUserUsername = 'user_username';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserAvatar = 'user_avatar';
  static const String _keyIsPremium = 'is_premium';
  static const String _keyPremiumPlan = 'premium_plan';
  static const String _keyCheckins = 'checkins';
  static const String _keyLastCheckinDate = 'last_checkin_date';
  static const String _keyStreak = 'streak';
  static const String _keyDashboard = 'dashboard_data';
  static const String _keyCheckinHistory = 'checkin_history';

  static Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  // ============ USER ============
  static Future<void> saveUser({
    required String name,
    required String username,
    required String email,
    String avatar = 'male',
    bool isPremium = false,
    String? premiumPlan,
  }) async {
    final prefs = await _getPrefs();
    await prefs.setString(_keyUserName, name);
    await prefs.setString(_keyUserUsername, username);
    await prefs.setString(_keyUserEmail, email);
    await prefs.setString(_keyUserAvatar, avatar);
    await prefs.setBool(_keyIsPremium, isPremium);
    if (premiumPlan != null) {
      await prefs.setString(_keyPremiumPlan, premiumPlan);
    } else {
      await prefs.remove(_keyPremiumPlan);
    }
  }

  static Future<String?> getUserName() async {
    final prefs = await _getPrefs();
    return prefs.getString(_keyUserName);
  }

  static Future<String?> getUserUsername() async {
    final prefs = await _getPrefs();
    return prefs.getString(_keyUserUsername);
  }

  static Future<String?> getUserEmail() async {
    final prefs = await _getPrefs();
    return prefs.getString(_keyUserEmail);
  }

  static Future<Map<String, dynamic>> getUser() async {
    final prefs = await _getPrefs();
    return {
      'name': prefs.getString(_keyUserName),
      'username': prefs.getString(_keyUserUsername),
      'email': prefs.getString(_keyUserEmail),
      'avatar': prefs.getString(_keyUserAvatar),
      'is_premium': prefs.getBool(_keyIsPremium),
      'premium_plan': prefs.getString(_keyPremiumPlan),
    };
  }

  static Future<void> clearUser() async {
    final prefs = await _getPrefs();
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserUsername);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyUserAvatar);
    await prefs.remove(_keyIsPremium);
    await prefs.remove(_keyPremiumPlan);
  }

  // ============ DASHBOARD & HISTORY CACHE ============
  static Future<void> saveDashboard(Map<String, dynamic> data) async {
    final prefs = await _getPrefs();
    await prefs.setString(_keyDashboard, jsonEncode(data));
  }

  static Future<Map<String, dynamic>?> getDashboard() async {
    final prefs = await _getPrefs();
    final dataStr = prefs.getString(_keyDashboard);
    if (dataStr == null) return null;
    try {
      return jsonDecode(dataStr);
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveCheckinHistory(List<dynamic> data) async {
    final prefs = await _getPrefs();
    await prefs.setString(_keyCheckinHistory, jsonEncode(data));
  }

  static Future<List<dynamic>?> getCheckinHistory() async {
    final prefs = await _getPrefs();
    final dataStr = prefs.getString(_keyCheckinHistory);
    if (dataStr == null) return null;
    try {
      return jsonDecode(dataStr);
    } catch (_) {
      return null;
    }
  }

  // ============ CHECK-IN ============
  static Future<void> saveCheckin({
    required String mood,
    required List<String> factors,
    required String journal,
    required DateTime date,
  }) async {
    final prefs = await _getPrefs();
    final checkins = await getCheckins();
    
    checkins.insert(0, {
      'mood': mood,
      'factors': factors,
      'journal': journal,
      'date': date.toIso8601String(),
      'timestamp': date.millisecondsSinceEpoch,
    });
    
    while (checkins.length > 30) {
      checkins.removeLast();
    }
    
    await prefs.setString(_keyCheckins, jsonEncode(checkins));
    await _updateStreak(date);
  }

  static Future<List<Map<String, dynamic>>> getCheckins() async {
    final prefs = await _getPrefs();
    final String? data = prefs.getString(_keyCheckins);
    if (data == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(data));
  }

  static Future<Map<String, dynamic>?> getTodayCheckin() async {
    final checkins = await getCheckins();
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = DateTime(today.year, today.month, today.day, 23, 59, 59);
    
    for (var checkin in checkins) {
      final date = DateTime.parse(checkin['date']);
      if (date.isAfter(todayStart) && date.isBefore(todayEnd)) {
        return checkin;
      }
    }
    return null;
  }

  static Future<bool> hasCheckedInToday() async {
    final todayCheckin = await getTodayCheckin();
    return todayCheckin != null;
  }

  // ============ STREAK ============
  static Future<void> _updateStreak(DateTime checkinDate) async {
    final prefs = await _getPrefs();
    final lastDateStr = prefs.getString(_keyLastCheckinDate);
    final currentStreak = prefs.getInt(_keyStreak) ?? 0;
    
    final today = DateTime(checkinDate.year, checkinDate.month, checkinDate.day);
    
    if (lastDateStr == null) {
      await prefs.setInt(_keyStreak, 1);
    } else {
      final lastDate = DateTime.parse(lastDateStr);
      final lastDateOnly = DateTime(lastDate.year, lastDate.month, lastDate.day);
      final difference = today.difference(lastDateOnly).inDays;
      
      if (difference == 1) {
        await prefs.setInt(_keyStreak, currentStreak + 1);
      } else if (difference > 1) {
        await prefs.setInt(_keyStreak, 1);
      }
    }
    
    await prefs.setString(_keyLastCheckinDate, today.toIso8601String());
  }

  static Future<int> getStreak() async {
    final prefs = await _getPrefs();
    return prefs.getInt(_keyStreak) ?? 0;
  }

  static Future<void> resetAllData() async {
    final prefs = await _getPrefs();
    await prefs.clear();
  }

  // ============ WEEKLY DATA ============
  static Future<List<Map<String, dynamic>>> getWeeklyData() async {
    final checkins = await getCheckins();
    final List<Map<String, dynamic>> weeklyData = [];
    final now = DateTime.now();
    
    final dayNames = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    
    final daysSinceMonday = now.weekday - 1;
    final monday = DateTime(now.year, now.month, now.day - daysSinceMonday);
    
    for (int i = 0; i < 7; i++) {
      final date = DateTime(monday.year, monday.month, monday.day + i);
      final dateStart = DateTime(date.year, date.month, date.day);
      final dateEnd = DateTime(date.year, date.month, date.day, 23, 59, 59);
      
      Map<String, dynamic>? checkinForDay;
      for (var checkin in checkins) {
        final checkinDate = DateTime.parse(checkin['date']);
        if (checkinDate.isAfter(dateStart) && checkinDate.isBefore(dateEnd)) {
          checkinForDay = checkin;
          break;
        }
      }
      
      final isToday = (date.year == now.year && 
                       date.month == now.month && 
                       date.day == now.day);
      
      weeklyData.add({
        'day': dayNames[i],
        'date': date,
        'mood': checkinForDay != null 
            ? MoodHelper.fromString(checkinForDay['mood']) 
            : MoodType.netral,
        'hasChecked': checkinForDay != null,
        'isToday': isToday,
      });
    }
    
    return weeklyData;
  }
}