import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import '../models/content_model.dart';
import 'premium_plan_screen.dart';
import 'detail_content_screen.dart';

class ContentPage extends StatefulWidget {
  const ContentPage({super.key});

  @override
  State<ContentPage> createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {
  final ApiService _apiService = ApiService();
  
  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  List<ContentModel> _allContents = [];
  List<ContentModel> _filteredContents = [];
  List<ContentModel> _recommendations = [];
  bool _isLoading = true;
  bool _isPremium = false;
  String? _errorMessage;

  final Map<String, Color> _categoryColors = {
    'ARTIKEL': const Color(0xFFFF8A65),
    'VIDEO': const Color(0xFF66BB6A),
    'KUTIPAN': const Color(0xFFAB47BC),
  };

  final Map<String, Color> _categoryBgColors = {
    'ARTIKEL': const Color(0xFFFFF3E0),
    'VIDEO': const Color(0xFFE8F5E9),
    'KUTIPAN': const Color(0xFFF3E5F5),
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      if (authProvider.currentUser == null) {
        await authProvider.refreshUser();
        
        if (authProvider.currentUser == null) {
          setState(() {
            _errorMessage = 'Silakan login terlebih dahulu';
            _isLoading = false;
          });
          return;
        }
      }
      
      setState(() {
        _isPremium = authProvider.isPremium;
      });
      
      final result = await _apiService.getContents();
      
      if (result['success']) {
        final List<ContentModel> contents = result['data'] ?? [];
        
        setState(() {
          _allContents = contents;
          
          // Filter untuk user free
          if (!_isPremium) {
            _allContents = _allContents.where((c) => !c.isPremium).toList();
          }
          
          _filteredContents = List.from(_allContents);
          
          if (_allContents.length > 3) {
            _recommendations = _allContents.take(3).toList();
          } else {
            _recommendations = List.from(_allContents);
          }
          
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Gagal memuat konten';
          _isLoading = false;
        });
      }
    } catch (e) {

      setState(() {
        _errorMessage = 'Terjadi kesalahan: $e';
        _isLoading = false;
      });
    }
  }

  void _filterContent() {
    setState(() {
      _filteredContents = _allContents.where((content) {
        final matchesCategory = _selectedCategory == 'Semua' || content.type == _selectedCategory;
        final matchesSearch = _searchQuery.isEmpty || 
            content.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            content.description.toLowerCase().contains(_searchQuery.toLowerCase());
        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  void _navigateToPremium() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PremiumPlansScreen()),
    ).then((_) {
      _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF8A65)),
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Color(0xFFA83836),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6D5B56),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF8A65),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : _allContents.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.article_outlined,
                            size: 64,
                            color: Color(0xFFC3ADA7),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Belum ada konten',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3E2F2B),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isPremium 
                                ? 'Konten akan segera ditambahkan'
                                : 'Upgrade ke premium untuk akses lebih banyak konten',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6D5B56),
                            ),
                          ),
                          if (!_isPremium) ...[
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _navigateToPremium,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF8A65),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text('Lihat Paket Premium'),
                            ),
                          ],
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      color: const Color(0xFFFF8A65),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
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
                                  _buildCategoryFilter(),
                                  const SizedBox(height: 28),
                                  if (!_isPremium && _recommendations.isNotEmpty)
                                    _buildPremiumBanner(),
                                  if (!_isPremium && _recommendations.isNotEmpty)
                                    const SizedBox(height: 16),
                                  if (_recommendations.isNotEmpty)
                                    _buildRecommendationsSection(),
                                  if (_recommendations.isNotEmpty)
                                    const SizedBox(height: 32),
                                  _buildExploreSection(),
                                  const SizedBox(height: 40),
                                ],
                              ),
                            ),
                          ],
                        ),
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
          _filterContent();
        },
        decoration: InputDecoration(
          hintText: 'Cari konten...',
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

  Widget _buildCategoryFilter() {
    final categories = ['Semua', 'ARTIKEL', 'VIDEO', 'KUTIPAN'];
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = cat;
                  _filterContent();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFF8A65) : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : const Color(0xFFE0E0E0),
                    width: 1,
                  ),
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF6D5B56),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPremiumBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF8A65), Color(0xFFFDAE96)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.stars, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Akses Semua Konten!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Upgrade ke premium untuk akses tak terbatas',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _navigateToPremium,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Upgrade',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFF8A65),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection() {
    if (_recommendations.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'REKOMENDASI HARI INI',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: Color(0xFF3E2F2B),
          ),
        ),
        const SizedBox(height: 16),
        ..._recommendations.map((content) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildContentTile(content),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildExploreSection() {
    if (_filteredContents.isEmpty) {
      return Column(
        children: [
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.search_off,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 8),
                Text(
                  'Tidak ada konten yang cocok',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'JELAJAHI',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: Color(0xFF3E2F2B),
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _filteredContents.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final content = _filteredContents[index];
            return _buildContentTile(content);
          },
        ),
      ],
    );
  }

  Widget _buildContentTile(ContentModel content) {
    final categoryColor = _categoryColors[content.type] ?? const Color(0xFFFF8A65);
    final categoryBgColor = _categoryBgColors[content.type] ?? const Color(0xFFFFF3E0);
    final isLocked = content.isPremium && !_isPremium;
    
    return GestureDetector(
      onTap: () {
        if (isLocked) {
          _navigateToPremium();
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailContentPage(content: {
                'id': content.id,
                'title': content.title,
                'description': content.description,
                'full_content': content.fullContent,
                'type': content.type,
                'typeIcon': content.type == 'ARTIKEL' 
                    ? Icons.article 
                    : (content.type == 'VIDEO' 
                        ? Icons.play_circle_filled 
                        : Icons.format_quote),
                'is_premium': content.isPremium,
                'thumbnail_url': content.thumbnailUrl,
                'video_url': content.videoUrl,
              }),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isLocked ? Colors.grey[100] : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFE0E0E0).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: categoryBgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(
                  content.type == 'ARTIKEL' 
                      ? Icons.article 
                      : (content.type == 'VIDEO' 
                          ? Icons.play_circle_filled 
                          : Icons.format_quote),
                  color: categoryColor.withValues(alpha: isLocked ? 0.3 : 0.6),
                  size: 32,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        content.type,
                        style: TextStyle(
                          color: categoryColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (isLocked) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.lock, size: 12, color: Color(0xFFA83836)),
                      ],
                      if (content.isPremium && _isPremium) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.stars, size: 12, color: Color(0xFFFF8A65)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    content.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isLocked ? Colors.grey[600] : const Color(0xFF3E2F2B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content.description,
                    style: TextStyle(
                      fontSize: 11,
                      color: isLocked ? Colors.grey[500] : const Color(0xFF6D5B56),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              isLocked ? Icons.lock_outline : Icons.chevron_right,
              color: const Color(0xFFC3ADA7),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}