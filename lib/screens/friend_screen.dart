import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/friend_model.dart';
import 'chat_screen.dart';

class FriendPage extends StatefulWidget {
  const FriendPage({super.key});

  @override
  State<FriendPage> createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> {
  final ApiService _apiService = ApiService();
  
  int _selectedTabIndex = 0;
  String _searchQuery = '';
  bool _isLoading = true;
  bool _isPremium = false;
  
  List<FriendModel> _allFriends = [];
  List<FriendRequestModel> _friendRequests = [];
  List<FriendModel> _searchResults = [];
  List<FriendModel> _filteredFriends = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    final prefs = await SharedPreferences.getInstance();
    final isPremium = prefs.getBool('is_premium') ?? false;
    
    setState(() {
      _isPremium = isPremium;
    });
    
    await _fetchFriends();
    await _fetchFriendRequests();
    
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchFriends() async {
    final result = await _apiService.getFriends();
    print('📱 getFriends - success: ${result['success']}');
    
    if (result['success']) {
      final data = result['data'];
      if (data is List) {
        setState(() {
          _allFriends = data.cast<FriendModel>();
          _filteredFriends = List.from(_allFriends);
          print('📱 Total friends after setState: ${_allFriends.length}');
        });
      } else {
        print('❌ Data is not a List, it is: ${data.runtimeType}');
        setState(() {
          _allFriends = [];
          _filteredFriends = [];
        });
      }
    } else {
      print('❌ getFriends failed: ${result['message']}');
      setState(() {
        _allFriends = [];
        _filteredFriends = [];
      });
    }
  }

  Future<void> _fetchFriendRequests() async {
    final result = await _apiService.getFriendRequests();
    print('📱 getFriendRequests - success: ${result['success']}');
    
    if (result['success']) {
      final data = result['data'];
      if (data is List) {
        setState(() {
          _friendRequests = data.cast<FriendRequestModel>();
          print('📱 Total friend requests after setState: ${_friendRequests.length}');
        });
      } else {
        print('❌ Data is not a List, it is: ${data.runtimeType}');
        setState(() {
          _friendRequests = [];
        });
      }
    } else {
      print('❌ getFriendRequests failed: ${result['message']}');
      setState(() {
        _friendRequests = [];
      });
    }
  }

  void _filterFriends() {
    setState(() {
      if (_searchQuery.isEmpty) {
        if (_selectedTabIndex == 0) {
          _filteredFriends = List.from(_allFriends);
        } else {
          _searchResults = [];
        }
      } else {
        _searchFriends(_searchQuery);
      }
    });
  }

  Future<void> _searchFriends(String query) async {
    final result = await _apiService.searchFriends(query);
    if (result['success']) {
      final data = result['data'];
      if (data is List) {
        setState(() {
          _searchResults = data.cast<FriendModel>();
        });
      } else {
        setState(() {
          _searchResults = [];
        });
      }
    }
  }

void _sendMessage(FriendModel friend) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ChatScreen(
        friend: {
          'id': friend.id,
          'name': friend.name,
          'username': friend.username,
          'avatar': friend.avatar ?? 'male',  
        },
      ),
    ),
  );
}

  IconData _getMoodIcon(String? mood) {
    switch (mood?.toLowerCase()) {
      case 'happy': return Icons.sentiment_very_satisfied;
      case 'calm': return Icons.spa;
      case 'anxious': return Icons.sentiment_dissatisfied;
      case 'sad': return Icons.sentiment_very_dissatisfied;
      default: return Icons.sentiment_neutral;
    }
  }

  Color _getMoodColor(String? mood) {
    switch (mood?.toLowerCase()) {
      case 'happy': return const Color(0xFFFBC02D);
      case 'calm': return const Color(0xFF66BB6A);
      case 'anxious': return const Color(0xFFEF5350);
      case 'sad': return const Color(0xFF42A5F5);
      default: return const Color(0xFF9E9E9E);
    }
  }

  Future<void> _acceptRequest(FriendRequestModel request) async {
    setState(() {
      _isLoading = true;
    });
    
    final friendshipId = request.friendshipId ?? request.id;
    
    print('✅ Accepting request - User ID: ${request.id}, Friendship ID: $friendshipId');
    
    final result = await _apiService.acceptFriendRequest(friendshipId);
    
    setState(() {
      _isLoading = false;
    });
    
    if (result['success']) {
      await _fetchFriends();
      await _fetchFriendRequests();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${request.name} sekarang adalah temanmu'),
            backgroundColor: const Color(0xFF4CAF50),
          ),
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Gagal menerima permintaan'),
          backgroundColor: const Color(0xFFA83836),
        ),
      );
    }
  }

  Future<void> _declineRequest(FriendRequestModel request) async {
    final deleteId = request.friendshipId ?? request.id;
    
    final result = await _apiService.deleteFriend(deleteId);
    if (result['success']) {
      await _fetchFriendRequests();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Permintaan dari ${request.name} ditolak'),
            backgroundColor: const Color(0xFFA83836),
          ),
        );
      }
    }
  }

  Future<void> _removeFriend(FriendModel friend) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Teman'),
        content: Text('Apakah Anda yakin ingin menghapus ${friend.name} dari daftar teman?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF6D5B56))),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final result = await _apiService.deleteFriend(friend.id);
              if (result['success']) {
                await _fetchFriends();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${friend.name} telah dihapus'),
                      backgroundColor: const Color(0xFFA83836),
                    ),
                  );
                }
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Color(0xFFA83836))),
          ),
        ],
      ),
    );
  }

  void _showAddFriendDialog() {
    final TextEditingController usernameController = TextEditingController();
    bool isLoading = false;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Row(
                children: [
                  Icon(Icons.person_add, color: Color(0xFFFF8A65), size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Tambah Teman',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3E2F2B),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Masukkan username teman yang ingin Anda tambahkan',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6D5B56),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: usernameController,
                    autofocus: true,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      hintText: 'contoh: johndoe',
                      hintStyle: const TextStyle(color: Color(0xFFC3ADA7)),
                      prefixIcon: const Icon(Icons.person_outline, color: Color(0xFFC3ADA7)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                    ),
                    onSubmitted: (_) {
                      if (!isLoading && usernameController.text.trim().isNotEmpty) {
                        _submitAddFriend(context, usernameController.text.trim(), setState);
                      }
                    },
                  ),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF8A65)),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: const Text(
                    'Batal',
                    style: TextStyle(color: Color(0xFF6D5B56), fontWeight: FontWeight.w600),
                  ),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          final username = usernameController.text.trim();
                          if (username.isNotEmpty) {
                            _submitAddFriend(context, username, setState);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Masukkan username terlebih dahulu'),
                                backgroundColor: Color(0xFFA83836),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8A65),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Kirim Permintaan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _submitAddFriend(
    BuildContext context,
    String username,
    void Function(void Function()) setState,
  ) async {
    setState(() => _isLoading = true);
    
    final result = await _apiService.addFriend(username);
    
    setState(() => _isLoading = false);
    
    if (result['success']) {
      await _fetchFriends();
      await _fetchFriendRequests();
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Permintaan teman terkirim'),
            backgroundColor: const Color(0xFF4CAF50),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } else {
      String errorMessage = result['message'] ?? 'Gagal mengirim permintaan';
      
      if (errorMessage.contains('tidak ditemukan') || 
          errorMessage.contains('not found')) {
        errorMessage = 'Username "@$username" tidak ditemukan. Pastikan username yang Anda masukkan benar.';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: const Color(0xFFA83836),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🔍 BUILD - selectedTab: $_selectedTabIndex');
    print('🔍 BUILD - friendRequests length: ${_friendRequests.length}');
    print('🔍 BUILD - allFriends length: ${_allFriends.length}');
    print('🔍 BUILD - isLoading: $_isLoading');
    
    final displayList = _selectedTabIndex == 0 
        ? (_searchQuery.isEmpty ? _filteredFriends : _searchResults)
        : _friendRequests;

    print('🔍 BUILD - displayList length: ${displayList.length}');

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF8A65)),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _buildSearchBar(),
                        const SizedBox(height: 20),
                        _buildToggleFilter(),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedTabIndex == 0 ? 'DAFTAR TEMAN ANDA' : 'PERMINTAAN PERTEMANAN',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                  color: Color(0xFF6D5B56),
                                ),
                              ),
                              if (_selectedTabIndex == 0)
                                GestureDetector(
                                  onTap: _showAddFriendDialog,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF8A65).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.person_add, size: 14, color: Color(0xFFFF8A65)),
                                        SizedBox(width: 4),
                                        Text(
                                          'Tambah',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFFFF8A65),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        _buildFriendList(displayList),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF9F6).withValues(alpha: 0.9),
          border: Border(
            bottom: BorderSide(
              color: const Color(0xFFE0E0E0).withValues(alpha: 0.1),
            ),
          ),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.bubble_chart,
              color: Color(0xFFFF8A65),
              size: 28,
            ),
            SizedBox(width: 8),
            Text(
              'EmoSync',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: Color(0xFFFF8A65),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) {
          _searchQuery = value;
          _filterFriends();
        },
        decoration: InputDecoration(
          hintText: 'Cari teman...',
          hintStyle: const TextStyle(
            color: Color(0xFFC3ADA7),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFFC3ADA7),
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildToggleFilter() {
    return Row(
      children: [
        _filterButton('Semua Teman', 0),
        const SizedBox(width: 12),
        _filterButton('Permintaan', 1),
      ],
    );
  }

  Widget _filterButton(String label, int index) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
          _searchQuery = '';
          _filterFriends();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF8A65) : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? Colors.transparent : const Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF6D5B56),
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildFriendList(dynamic items) {
    print('🔍 _buildFriendList - items length: ${items.length}');
    print('🔍 _buildFriendList - selectedTabIndex: $_selectedTabIndex');
    
    if (items.isEmpty) {
      return _buildEmptyState();
    }
    
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        if (_selectedTabIndex == 0) {
          final friend = items[index] as FriendModel;
          return _buildFriendCard(friend);
        } else {
          final request = items[index] as FriendRequestModel;
          return _buildRequestCard(request);
        }
      },
    );
  }

  Widget _buildFriendCard(FriendModel friend) {
    final avatar = friend.avatar ?? 'male';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: const Color(0xFFE0E0E0).withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: avatar == 'male' 
                    ? const Color(0xFFE3F2FD)
                    : const Color(0xFFFCE4EC),
                child: Icon(
                  avatar == 'male' ? Icons.person : Icons.person_outline,
                  color: avatar == 'male' 
                      ? const Color(0xFF2196F3)
                      : const Color(0xFFE91E63),
                  size: 32,
                ),
              ),
              if (friend.isPremium)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF8A65),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.stars,
                      color: Colors.white,
                      size: 10,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        friend.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF3E2F2B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (friend.isPremium)
                      Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF8A65).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFF8A65)),
                        ),
                        child: const Text(
                          'PREMIUM',
                          style: TextStyle(
                            fontSize: 6,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFF8A65),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      _getMoodIcon(friend.mood),
                      color: _getMoodColor(friend.mood),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        friend.lastCheckin ?? 'Belum pernah check-in',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6D5B56),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 8),
          
          GestureDetector(
            onTap: () => _sendMessage(friend),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF8A65),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Kirim Pesan',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 8),
          
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFFC3ADA7), size: 18),
            onSelected: (value) {
              if (value == 'remove') {
                _removeFriend(friend);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'remove',
                child: Row(
                  children: [
                    Icon(Icons.person_remove, size: 16, color: Color(0xFFA83836)),
                    SizedBox(width: 8),
                    Text('Hapus Teman', style: TextStyle(color: Color(0xFFA83836), fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(FriendRequestModel request) {
    print('🔍 _buildRequestCard - Request: ${request.name}, Status: ${request.status}');
    
    final avatar = request.avatar ?? 'male';
    
    String statusLabel = '';
    Color statusColor = Colors.grey;
    if (request.status == 'incoming') {
      statusLabel = '📩 Permintaan Masuk';
      statusColor = const Color(0xFF4CAF50);
    } else if (request.status == 'outgoing') {
      statusLabel = '📤 Permintaan Terkirim';
      statusColor = const Color(0xFFFF8A65);
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: const Color(0xFFE0E0E0).withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: avatar == 'male' 
                    ? const Color(0xFFE3F2FD)
                    : const Color(0xFFFCE4EC),
                child: Icon(
                  avatar == 'male' ? Icons.person : Icons.person_outline,
                  color: avatar == 'male' 
                      ? const Color(0xFF2196F3)
                      : const Color(0xFFE91E63),
                  size: 32,
                ),
              ),
              if (request.isPremium)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF8A65),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.stars,
                      color: Colors.white,
                      size: 10,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        request.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF3E2F2B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (request.isPremium)
                      Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF8A65).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFF8A65)),
                        ),
                        child: const Text(
                          'PREMIUM',
                          style: TextStyle(
                            fontSize: 6,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFF8A65),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  request.username,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6D5B56),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (statusLabel.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          if (request.status == 'incoming') ...[
            GestureDetector(
              onTap: () => _acceptRequest(request),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Color(0xFF4CAF50),
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _declineRequest(request),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFA83836).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Color(0xFFA83836),
                  size: 18,
                ),
              ),
            ),
          ] else if (request.status == 'outgoing') ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFF8A65).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFF8A65)),
              ),
              child: const Text(
                'Menunggu',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFF8A65),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE0E0E0).withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _selectedTabIndex == 0 ? Icons.group_off : Icons.person_add_disabled,
              size: 40,
              color: const Color(0xFFC3ADA7),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _selectedTabIndex == 0 ? 'Belum Ada Teman' : 'Tidak Ada Permintaan',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF3E2F2B),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              _selectedTabIndex == 0
                  ? 'Mulai petualanganmu dengan menambahkan teman baru'
                  : 'Belum ada permintaan pertemanan masuk',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6D5B56),
              ),
            ),
          ),
          if (_selectedTabIndex == 0) ...[
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showAddFriendDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8A65),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Tambah Teman Baru'),
            ),
          ],
        ],
      ),
    );
  }
}