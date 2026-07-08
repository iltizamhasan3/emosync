import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> friend;

  const ChatScreen({super.key, required this.friend});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _apiService.getChatMessages(widget.friend['id']);
      
      if (result['success']) {
        setState(() {
          _messages = List<Map<String, dynamic>>.from(result['data'] ?? []);
          _isLoading = false;
        });
        
        Future.delayed(const Duration(milliseconds: 200), () {
          _scrollToBottom();
        });
      } else {
        setState(() {
          _messages = [];
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Gagal memuat pesan'),
              backgroundColor: const Color(0xFFA83836),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _messages = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
    });

    final tempMessage = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'text': text,
      'isMe': true,
      'time': _getCurrentTime(),
      'status': 'sending',
      'is_temp': true,
    };

    setState(() {
      _messages.add(tempMessage);
      _messageController.clear();
    });
    
    _scrollToBottom();

    try {
      final result = await _apiService.sendMessage(
        widget.friend['id'],
        text,
      );

      if (result['success']) {
        setState(() {
          _messages.removeWhere((msg) => msg['is_temp'] == true);
          if (result['data'] != null) {
            _messages.add(result['data']);
          }
          _isSending = false;
        });
        _scrollToBottom();
      } else {
        setState(() {
          final index = _messages.indexWhere((msg) => msg['is_temp'] == true);
          if (index != -1) {
            _messages[index]['status'] = 'failed';
            _messages[index]['is_temp'] = false;
          }
          _isSending = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Gagal mengirim pesan'),
              backgroundColor: const Color(0xFFA83836),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        final index = _messages.indexWhere((msg) => msg['is_temp'] == true);
        if (index != -1) {
          _messages[index]['status'] = 'failed';
          _messages[index]['is_temp'] = false;
        }
        _isSending = false;
      });

    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  String _getFriendName() {
    return widget.friend['name']?.toString() ?? 'Teman';
  }

  String _getFriendAvatar() {
    return widget.friend['avatar']?.toString() ?? 'male';
  }

  @override
  Widget build(BuildContext context) {
    final friendName = _getFriendName();
    final avatar = _getFriendAvatar();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF3E2F2B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            // ============ AVATAR SESUAI GENDER ============
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: avatar == 'male' 
                    ? const Color(0xFFE3F2FD)  // Biru sangat muda
                    : const Color(0xFFFCE4EC), // Pink sangat muda
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  avatar == 'male' 
                      ? Icons.person 
                      : Icons.person_outline,
                  color: avatar == 'male' 
                      ? const Color(0xFF2196F3)  // Biru
                      : const Color(0xFFE91E63), // Pink
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // ============ HANYA NAMA (TANPA MOOD) ============
            Text(
              friendName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF3E2F2B),
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF6D5B56)),
            onPressed: () {
              _showMenuDialog();
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: const Color(0xFFE0E0E0).withValues(alpha: 0.3),
          ),
        ),
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF8A65)),
                    ),
                  )
                : _messages.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          return _buildMessageBubble(message);
                        },
                      ),
          ),
          
          // Input message
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              size: 40,
              color: Color(0xFFC3ADA7),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada pesan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF3E2F2B),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Mulai percakapan dengan mengirim pesan',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF6D5B56),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isMe = message['isMe'] ?? false;
    final text = message['text']?.toString() ?? '';
    final time = message['time']?.toString() ?? _getCurrentTime();
    final status = message['status']?.toString() ?? 'sent';
    final isTemp = message['is_temp'] ?? false;
    final isFailed = status == 'failed';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe 
                    ? (isFailed ? Colors.grey[400] : const Color(0xFFFF8A65))
                    : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(4),
                  bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isFailed) ...[
                    const Icon(Icons.error_outline, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 14,
                      color: isMe ? Colors.white : const Color(0xFF3E2F2B),
                    ),
                  ),
                  if (isTemp && isMe) ...[
                    const SizedBox(width: 8),
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFFC3ADA7),
                  ),
                ),
                if (isMe && !isTemp && !isFailed) ...[
                  const SizedBox(width: 4),
                  Icon(
                    _getStatusIcon(status),
                    size: 12,
                    color: const Color(0xFFC3ADA7),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'sent':
        return Icons.check;
      case 'delivered':
        return Icons.done_all;
      case 'read':
        return Icons.done_all;
      default:
        return Icons.access_time;
    }
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: const Color(0xFFE0E0E0).withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _messageController,
                enabled: !_isSending,
                decoration: const InputDecoration(
                  hintText: 'Ketik pesan...',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFC3ADA7),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _isSending ? null : _sendMessage,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _isSending 
                    ? const Color(0xFFFF8A65).withValues(alpha: 0.5)
                    : const Color(0xFFFF8A65),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF8A65).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMenuDialog() {
    final friendName = _getFriendName();
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.block, color: Color(0xFFA83836)),
                title: const Text('Blokir Pengguna', style: TextStyle(color: Color(0xFFA83836))),
                onTap: () {
                  Navigator.pop(context);
                  _showBlockDialog(friendName);
                },
              ),
              ListTile(
                leading: const Icon(Icons.flag, color: Color(0xFFA83836)),
                title: const Text('Laporkan', style: TextStyle(color: Color(0xFFA83836))),
                onTap: () {
                  Navigator.pop(context);
                  _showReportDialog();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showBlockDialog(String friendName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Blokir Pengguna'),
        content: Text('Apakah Anda yakin ingin memblokir $friendName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF6D5B56))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$friendName telah diblokir'),
                  backgroundColor: const Color(0xFFA83836),
                ),
              );
            },
            child: const Text('Blokir', style: TextStyle(color: Color(0xFFA83836))),
          ),
        ],
      ),
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Laporkan Pengguna'),
        content: const Text('Terima kasih telah melaporkan. Tim kami akan meninjau laporan ini.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup', style: TextStyle(color: Color(0xFFFF8A65))),
          ),
        ],
      ),
    );
  }
}