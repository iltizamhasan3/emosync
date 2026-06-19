import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/mood_model.dart';
import '../models/content_model.dart';
import '../models/friend_model.dart';
import '../utils/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  static const Duration _timeout = Duration(seconds: 30);

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    print('📱 Response status: ${response.statusCode}');
    print('📱 Response body: ${response.body}');
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final decoded = response.body.isNotEmpty ? json.decode(response.body) : null;
        
        if (decoded is Map && decoded.containsKey('success')) {
          return {
            'success': decoded['success'],
            'data': decoded['data'] ?? null,
            'message': decoded['message'] ?? null,
          };
        }
        
        return {
          'success': true,
          'data': decoded,
        };
      } catch (e) {
        return {
          'success': true,
          'data': null,
        };
      }
    } else if (response.statusCode == 401) {
      return {
        'success': false,
        'message': 'Sesi telah berakhir, silakan login kembali',
        'unauthorized': true,
      };
    } else {
      String message = 'Terjadi kesalahan';
      try {
        final data = json.decode(response.body);
        message = data['message'] ?? data['error'] ?? message;
        if (data['errors'] != null) {
          final errors = data['errors'];
          if (errors is Map) {
            message = errors.values.map((e) => e.toString()).join(', ');
          }
        }
      } catch (e) {}
      return {
        'success': false,
        'message': message,
      };
    }
  }

  // ============ AUTH ============
  Future<Map<String, dynamic>> register({
    required String name,
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      print('📱 Register request: name=$name, username=$username, email=$email');
      
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.register}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'username': username,
          'email': email,
          'password': password,
        }),
      ).timeout(_timeout);

      print('📱 Register response status: ${response.statusCode}');
      print('📱 Register response body: ${response.body}');

      final result = _handleResponse(response);
      
      if (result['success'] && result['data'] != null) {
        final data = result['data'];
        final userData = data['user'] ?? data['data']['user'] ?? data;
        final tokenData = data['token'] ?? data['data']['token'];
        
        final prefs = await SharedPreferences.getInstance();
        if (tokenData != null) {
          await prefs.setString('auth_token', tokenData);
        }
        await prefs.setString('user_data', json.encode(userData));
        await prefs.setString('user_name', userData['name'] ?? '');
        await prefs.setString('user_username', userData['username'] ?? '');
        await prefs.setString('user_email', userData['email'] ?? '');
        await prefs.setString('user_avatar', userData['avatar'] ?? 'male');
        await prefs.setBool('is_premium', userData['is_premium'] ?? false);
        
        return {'success': true, 'user': UserModel.fromJson(userData)};
      }
      return result;
    } catch (e) {
      print('❌ Register error: $e');
      return {'success': false, 'message': 'Gagal terhubung ke server: $e'};
    }
  }

  Future<Map<String, dynamic>> login(String login, String password) async {
    try {
      print('📱 Login request: login=$login');
      
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.login}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'login': login,
          'password': password,
        }),
      ).timeout(_timeout);

      print('📱 Login response status: ${response.statusCode}');
      print('📱 Login response body: ${response.body}');

      final result = _handleResponse(response);
      
      if (result['success'] && result['data'] != null) {
        final data = result['data'];
        final userData = data['user'] ?? data['data']['user'] ?? data;
        final tokenData = data['token'] ?? data['data']['token'];
        
        final prefs = await SharedPreferences.getInstance();
        if (tokenData != null) {
          await prefs.setString('auth_token', tokenData);
        }
        await prefs.setString('user_data', json.encode(userData));
        await prefs.setString('user_name', userData['name'] ?? '');
        await prefs.setString('user_username', userData['username'] ?? '');
        await prefs.setString('user_email', userData['email'] ?? '');
        await prefs.setString('user_avatar', userData['avatar'] ?? 'male');
        await prefs.setBool('is_premium', userData['is_premium'] ?? false);
        
        return {'success': true, 'user': UserModel.fromJson(userData)};
      }
      return result;
    } catch (e) {
      print('❌ Login error: $e');
      return {'success': false, 'message': 'Gagal terhubung ke server: $e'};
    }
  }

  Future<Map<String, dynamic>> logout() async {
    try {
      final headers = await _getHeaders();
      await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.logout}'),
        headers: headers,
      ).timeout(_timeout);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_data');
      await prefs.remove('user_name');
      await prefs.remove('user_username');
      await prefs.remove('user_email');
      await prefs.remove('user_avatar');
      await prefs.remove('is_premium');
      await prefs.remove('premium_plan');
      return {'success': true};
    } catch (e) {
      print('❌ Logout error: $e');
      return {'success': false, 'message': 'Gagal logout'};
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.user}'),
        headers: headers,
      ).timeout(_timeout);

      final result = _handleResponse(response);
      if (result['success'] && result['data'] != null) {
        final userData = result['data']['user'] ?? result['data'];
        final prefs = await SharedPreferences.getInstance();
        final user = UserModel.fromJson(userData);
        await prefs.setString('user_name', user.name);
        await prefs.setString('user_username', user.username);
        await prefs.setString('user_email', user.email);
        await prefs.setString('user_avatar', user.avatar);
        await prefs.setBool('is_premium', user.isPremium);
        if (user.premiumPlan != null) {
          await prefs.setString('premium_plan', user.premiumPlan!);
        }
        return user;
      }
      return null;
    } catch (e) {
      print('❌ GetCurrentUser error: $e');
      return null;
    }
  }

  // ============ PROFILE ============
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.profile}'),
        headers: headers,
      ).timeout(_timeout);

      print('📱 GetProfile response status: ${response.statusCode}');
      print('📱 GetProfile response body: ${response.body}');

      final result = _handleResponse(response);
      if (result['success'] && result['data'] != null) {
        final data = result['data']['data'] ?? result['data'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', data['name'] ?? '');
        await prefs.setString('user_username', data['username'] ?? '');
        await prefs.setString('user_email', data['email'] ?? '');
        await prefs.setString('user_avatar', data['avatar'] ?? 'male');
        return {
          'success': true,
          'data': data,
        };
      }
      return result;
    } catch (e) {
      print('❌ GetProfile error: $e');
      return {'success': false, 'message': 'Gagal mengambil profil'};
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String avatar,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.profile}'),
        headers: headers,
        body: json.encode({
          'name': name,
          'avatar': avatar,
        }),
      ).timeout(_timeout);

      print('📱 UpdateProfile response status: ${response.statusCode}');
      print('📱 UpdateProfile response body: ${response.body}');

      final result = _handleResponse(response);
      
      if (result['success'] && result['data'] != null) {
        final data = result['data']['data'] ?? result['data'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', data['name'] ?? name);
        await prefs.setString('user_avatar', data['avatar'] ?? avatar);
      }
      
      return result;
    } catch (e) {
      print('❌ UpdateProfile error: $e');
      return {'success': false, 'message': 'Gagal menyimpan profil'};
    }
  }

  // ============ PEMICU ============
  Future<Map<String, dynamic>> getPemicu() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.pemicu}'),
        headers: headers,
      ).timeout(_timeout);

      final result = _handleResponse(response);
      if (result['success']) {
        final List data = result['data'] ?? [];
        return {
          'success': true,
          'data': data.map((e) => PemicuModel.fromJson(e)).toList(),
        };
      }
      return result;
    } catch (e) {
      print('❌ GetPemicu error: $e');
      return {'success': false, 'message': 'Gagal mengambil data pemicu'};
    }
  }

  // ============ CHECK-IN ============
  Future<Map<String, dynamic>> createCheckin({
    required String mood,
    String? catatan,
    required List<int> pemicuIds,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.checkin}'),
        headers: headers,
        body: json.encode({
          'mood': mood.toLowerCase(),
          'catatan': catatan,
          'pemicu_ids': pemicuIds,
        }),
      ).timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      print('❌ CreateCheckin error: $e');
      return {'success': false, 'message': 'Gagal menyimpan check-in'};
    }
  }

  Future<Map<String, dynamic>> getCheckinHistory() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.checkin}'),
        headers: headers,
      ).timeout(_timeout);

      final result = _handleResponse(response);
      if (result['success']) {
        final List data = result['data'] ?? [];
        return {
          'success': true,
          'data': data.map((e) => MoodCheckinModel.fromJson(e)).toList(),
        };
      }
      return result;
    } catch (e) {
      print('❌ GetCheckinHistory error: $e');
      return {'success': false, 'message': 'Gagal mengambil riwayat'};
    }
  }

  Future<Map<String, dynamic>> getDashboard() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.dashboard}'),
        headers: headers,
      ).timeout(_timeout);

      final result = _handleResponse(response);
      if (result['success'] && result['data'] != null) {
        return {
          'success': true,
          'data': DashboardModel.fromJson(result['data']),
        };
      }
      return result;
    } catch (e) {
      print('❌ GetDashboard error: $e');
      return {'success': false, 'message': 'Gagal mengambil data dashboard'};
    }
  }

  // ============ CONTENT ============
  Future<Map<String, dynamic>> getContents() async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConstants.baseUrl}${ApiConstants.konten}';
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        
        if (decoded is List) {
          final List<ContentModel> contents = [];
          for (var item in decoded) {
            if (item is Map<String, dynamic>) {
              contents.add(ContentModel.fromJson(item));
            }
          }
          return {
            'success': true,
            'data': contents,
          };
        } else if (decoded is Map && decoded.containsKey('data')) {
          final dataList = decoded['data'];
          if (dataList is List) {
            final List<ContentModel> contents = [];
            for (var item in dataList) {
              if (item is Map<String, dynamic>) {
                contents.add(ContentModel.fromJson(item));
              }
            }
            return {
              'success': true,
              'data': contents,
            };
          }
        }
        
        return {'success': false, 'message': 'Format response tidak dikenali'};
      } else {
        return _handleResponse(response);
      }
    } catch (e) {
      print('❌ GetContents error: $e');
      return {'success': false, 'message': 'Gagal mengambil konten: $e'};
    }
  }

  Future<Map<String, dynamic>> getContentDetail(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.konten}/$id'),
        headers: headers,
      ).timeout(_timeout);

      final result = _handleResponse(response);
      if (result['success'] && result['data'] != null) {
        return {
          'success': true,
          'data': ContentModel.fromJson(result['data']),
        };
      }
      return result;
    } catch (e) {
      print('❌ GetContentDetail error: $e');
      return {'success': false, 'message': 'Gagal mengambil detail konten'};
    }
  }

  // ============ PREMIUM ============
  Future<Map<String, dynamic>> getPremiumStatus() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.premiumStatus}'),
        headers: headers,
      ).timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      print('❌ GetPremiumStatus error: $e');
      return {'success': false, 'message': 'Gagal cek status premium'};
    }
  }

  Future<Map<String, dynamic>> getPremiumPlans() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.premiumPlans}'),
        headers: headers,
      ).timeout(_timeout);

      final result = _handleResponse(response);
      if (result['success']) {
        final List data = result['data'] ?? [];
        return {
          'success': true,
          'data': data.map((e) => PremiumPlanModel.fromJson(e)).toList(),
        };
      }
      return result;
    } catch (e) {
      print('❌ GetPremiumPlans error: $e');
      return {'success': false, 'message': 'Gagal mengambil daftar plan'};
    }
  }

  Future<Map<String, dynamic>> subscribe(String plan, String paymentMethod) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.premiumSubscribe}'),
        headers: headers,
        body: json.encode({
          'plan': plan,
          'payment_method': paymentMethod,
        }),
      ).timeout(_timeout);

      final result = _handleResponse(response);
      if (result['success']) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_premium', true);
        if (result['data'] != null) {
          await prefs.setString('premium_plan', result['data']['plan'] ?? plan);
        }
      }
      return result;
    } catch (e) {
      print('❌ Subscribe error: $e');
      return {'success': false, 'message': 'Gagal melakukan subscribe'};
    }
  }

  Future<Map<String, dynamic>> cancelSubscription() async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.premiumCancel}'),
        headers: headers,
      ).timeout(_timeout);

      final result = _handleResponse(response);
      if (result['success']) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_premium', false);
        await prefs.remove('premium_plan');
      }
      return result;
    } catch (e) {
      print('❌ CancelSubscription error: $e');
      return {'success': false, 'message': 'Gagal membatalkan langganan'};
    }
  }

  // ============ FRIENDSHIP ============
  Future<Map<String, dynamic>> getFriends() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.friends}'),
        headers: headers,
      ).timeout(_timeout);

      print('📱 getFriends - Status: ${response.statusCode}');
      print('📱 getFriends - Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = json.decode(response.body);
        
        if (decoded['success'] == true) {
          final data = decoded['data'];
          List<FriendModel> friends = [];
          
          if (data is List) {
            friends = data.map((e) => FriendModel.fromJson(e)).toList();
          } else if (data is Map) {
            final innerData = data['data'];
            if (innerData is List) {
              friends = innerData.map((e) => FriendModel.fromJson(e)).toList();
            }
          }
          
          print('✅ Total friends: ${friends.length}');
          
          return {
            'success': true,
            'data': friends,
          };
        }
      }
      
      return _handleResponse(response);
    } catch (e) {
      print('❌ GetFriends error: $e');
      return {'success': false, 'message': 'Gagal mengambil daftar teman'};
    }
  }

  Future<Map<String, dynamic>> addFriend(String username) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.friendsAdd}'),
        headers: headers,
        body: json.encode({'username': username}),
      ).timeout(_timeout);

      print('📱 AddFriend - Status: ${response.statusCode}');
      print('📱 AddFriend - Body: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      print('❌ AddFriend error: $e');
      return {'success': false, 'message': 'Gagal terhubung ke server: $e'};
    }
  }

  Future<Map<String, dynamic>> searchFriends(String query) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.friendsSearch}?q=$query'),
        headers: headers,
      ).timeout(_timeout);

      final result = _handleResponse(response);
      if (result['success']) {
        final data = result['data'];
        List<FriendModel> friends = [];
        
        if (data is List) {
          friends = data.map((e) => FriendModel.fromJson(e)).toList();
        }
        
        return {
          'success': true,
          'data': friends,
        };
      }
      return result;
    } catch (e) {
      print('❌ SearchFriends error: $e');
      return {'success': false, 'message': 'Gagal mencari teman'};
    }
  }

  Future<Map<String, dynamic>> deleteFriend(int friendId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.friends}/$friendId'),
        headers: headers,
      ).timeout(_timeout);

      print('📱 DeleteFriend - Status: ${response.statusCode}');
      print('📱 DeleteFriend - Body: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      print('❌ DeleteFriend error: $e');
      return {'success': false, 'message': 'Gagal menghapus teman'};
    }
  }

  Future<Map<String, dynamic>> getFriendRequests() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.friends}/requests'),
        headers: headers,
      ).timeout(_timeout);

      print('📱 getFriendRequests - Status: ${response.statusCode}');
      print('📱 getFriendRequests - Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = json.decode(response.body);
        
        if (decoded['success'] == true) {
          final data = decoded['data'];
          List<FriendRequestModel> requests = [];
          
          if (data is List) {
            requests = data.map((e) => FriendRequestModel.fromJson(e)).toList();
          } else if (data is Map) {
            final innerData = data['data'];
            if (innerData is List) {
              requests = innerData.map((e) => FriendRequestModel.fromJson(e)).toList();
            }
          }
          
          print('✅ Total friend requests: ${requests.length}');
          
          return {
            'success': true,
            'data': requests,
          };
        }
      }
      
      return _handleResponse(response);
    } catch (e) {
      print('❌ getFriendRequests error: $e');
      return {'success': false, 'message': 'Gagal mengambil permintaan teman'};
    }
  }

  Future<Map<String, dynamic>> acceptFriendRequest(int friendshipId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.friends}/accept/$friendshipId'),
        headers: headers,
      ).timeout(_timeout);

      print('📱 AcceptFriendRequest - Status: ${response.statusCode}');
      print('📱 AcceptFriendRequest - Body: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      print('❌ AcceptFriendRequest error: $e');
      return {'success': false, 'message': 'Gagal menerima permintaan'};
    }
  }

 // ============ CHAT ============
Future<Map<String, dynamic>> getChatMessages(int friendId) async {
  try {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.chat}/$friendId'),
      headers: headers,
    ).timeout(_timeout);

    print('📱 getChatMessages - Status: ${response.statusCode}');
    print('📱 getChatMessages - Body: ${response.body}');

    return _handleResponse(response);
  } catch (e) {
    print('❌ getChatMessages error: $e');
    return {'success': false, 'message': 'Gagal mengambil pesan'};
  }
}

Future<Map<String, dynamic>> sendMessage(int friendId, String message) async {
  try {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.chatSend}'),
      headers: headers,
      body: json.encode({
        'friend_id': friendId,
        'message': message,
      }),
    ).timeout(_timeout);

    print('📱 sendMessage - Status: ${response.statusCode}');
    print('📱 sendMessage - Body: ${response.body}');

    return _handleResponse(response);
  } catch (e) {
    print('❌ sendMessage error: $e');
    return {'success': false, 'message': 'Gagal mengirim pesan'};
  }
}

Future<Map<String, dynamic>> getUnreadMessages() async {
  try {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.chat}/unread/count'),
      headers: headers,
    ).timeout(_timeout);

    return _handleResponse(response);
  } catch (e) {
    print('❌ getUnreadMessages error: $e');
    return {'success': false, 'message': 'Gagal mengambil pesan belum dibaca'};
  }
}

Future<Map<String, dynamic>> markMessagesAsRead(int friendId) async {
  try {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.chat}/read/$friendId'),
      headers: headers,
    ).timeout(_timeout);

    return _handleResponse(response);
  } catch (e) {
    print('❌ markMessagesAsRead error: $e');
    return {'success': false, 'message': 'Gagal menandai pesan sebagai sudah dibaca'};
  }
}

  // ============ SETTINGS ============
  Future<Map<String, dynamic>> getSettings() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.settings}'),
        headers: headers,
      ).timeout(_timeout);

      final result = _handleResponse(response);
      if (result['success'] && result['data'] != null) {
        return {
          'success': true,
          'data': result['data'],
        };
      }
      return result;
    } catch (e) {
      print('❌ GetSettings error: $e');
      return {'success': false, 'message': 'Gagal mengambil pengaturan'};
    }
  }

  Future<Map<String, dynamic>> updateNotificationSettings(Map<String, dynamic> settings) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.settingsNotification}'),
        headers: headers,
        body: json.encode(settings),
      ).timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      print('❌ UpdateNotificationSettings error: $e');
      return {'success': false, 'message': 'Gagal menyimpan pengaturan notifikasi'};
    }
  }

  Future<Map<String, dynamic>> updatePrivacySettings(Map<String, dynamic> settings) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.settingsPrivacy}'),
        headers: headers,
        body: json.encode(settings),
      ).timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      print('❌ UpdatePrivacySettings error: $e');
      return {'success': false, 'message': 'Gagal menyimpan pengaturan privasi'};
    }
  }
    // ============ PAYMENT ============

  // Get payment plans
  Future<Map<String, dynamic>> getPaymentPlans() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.paymentPlans}'),
        headers: headers,
      ).timeout(_timeout);

      print('📱 getPaymentPlans - Status: ${response.statusCode}');
      print('📱 getPaymentPlans - Body: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      print('❌ getPaymentPlans error: $e');
      return {'success': false, 'message': 'Gagal mengambil daftar paket'};
    }
  }

  // Create transaction
  Future<Map<String, dynamic>> createTransaction({
    required String plan,
    required String paymentMethod,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.paymentCreate}'),
        headers: headers,
        body: json.encode({
          'plan': plan,
          'payment_method': paymentMethod,
        }),
      ).timeout(_timeout);

      print('📱 createTransaction - Status: ${response.statusCode}');
      print('📱 createTransaction - Body: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      print('❌ createTransaction error: $e');
      return {'success': false, 'message': 'Gagal membuat transaksi'};
    }
  }

  // Check transaction status
  Future<Map<String, dynamic>> checkTransactionStatus(String transactionId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.paymentStatus}/$transactionId'),
        headers: headers,
      ).timeout(_timeout);

      print('📱 checkTransactionStatus - Status: ${response.statusCode}');
      print('📱 checkTransactionStatus - Body: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      print('❌ checkTransactionStatus error: $e');
      return {'success': false, 'message': 'Gagal cek status transaksi'};
    }
  }

  // Simulate payment (DEMO)
  Future<Map<String, dynamic>> simulatePayment(String transactionId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.paymentSimulate}/$transactionId'),
        headers: headers,
      ).timeout(_timeout);

      print('📱 simulatePayment - Status: ${response.statusCode}');
      print('📱 simulatePayment - Body: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      print('❌ simulatePayment error: $e');
      return {'success': false, 'message': 'Gagal memproses pembayaran'};
    }
  }

  // Cancel transaction
  Future<Map<String, dynamic>> cancelTransaction(String transactionId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.paymentCancel}/$transactionId'),
        headers: headers,
      ).timeout(_timeout);

      print('📱 cancelTransaction - Status: ${response.statusCode}');
      print('📱 cancelTransaction - Body: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      print('❌ cancelTransaction error: $e');
      return {'success': false, 'message': 'Gagal membatalkan transaksi'};
    }
  }

  // Get user transaction history
  Future<Map<String, dynamic>> getTransactionHistory() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.paymentHistory}'),
        headers: headers,
      ).timeout(_timeout);

      print('📱 getTransactionHistory - Status: ${response.statusCode}');
      print('📱 getTransactionHistory - Body: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      print('❌ getTransactionHistory error: $e');
      return {'success': false, 'message': 'Gagal mengambil riwayat transaksi'};
    }
  }
}