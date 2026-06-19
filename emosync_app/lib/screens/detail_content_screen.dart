import 'package:flutter/material.dart';

class DetailContentPage extends StatelessWidget {
  final Map<String, dynamic> content;

  const DetailContentPage({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(content['type']);
    final categoryBgColor = _getCategoryBgColor(content['type']);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF3E2F2B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          content['type'],
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: categoryColor,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image / Thumbnail
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                color: categoryBgColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Center(
                child: Icon(
                  content['typeIcon'],
                  color: categoryColor.withValues(alpha: 0.4),
                  size: 80,
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      content['type'],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: categoryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Title
                  Text(
                    content['title'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: Color(0xFF3E2F2B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Divider
                  Divider(
                    color: const Color(0xFFE0E0E0),
                    thickness: 1,
                  ),
                  const SizedBox(height: 16),
                  
                  // Content / Description
                  Text(
                    _getFullContent(content),
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Color(0xFF4A3A35),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Action Button (jika video)
                  if (content['type'] == 'VIDEO')
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Play video
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Video akan diputar'),
                              backgroundColor: Color(0xFFFF8A65),
                            ),
                          );
                        },
                        icon: const Icon(Icons.play_circle_filled, size: 24),
                        label: const Text(
                          'Tonton Video',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: categoryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  
                  if (content['type'] == 'ARTIKEL')
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Save to bookmarks or share
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Artikel disimpan'),
                              backgroundColor: Color(0xFF4CAF50),
                            ),
                          );
                        },
                        icon: const Icon(Icons.bookmark_border, size: 24),
                        label: const Text(
                          'Simpan Artikel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: categoryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String type) {
    switch (type) {
      case 'ARTIKEL':
        return const Color(0xFFFF8A65);
      case 'VIDEO':
        return const Color(0xFF66BB6A);
      case 'KUTIPAN':
        return const Color(0xFFAB47BC);
      default:
        return const Color(0xFFFF8A65);
    }
  }

  Color _getCategoryBgColor(String type) {
    switch (type) {
      case 'ARTIKEL':
        return const Color(0xFFFFF3E0);
      case 'VIDEO':
        return const Color(0xFFE8F5E9);
      case 'KUTIPAN':
        return const Color(0xFFF3E5F5);
      default:
        return const Color(0xFFFFF3E0);
    }
  }

  String _getFullContent(Map<String, dynamic> content) {
    switch (content['type']) {
      case 'ARTIKEL':
        return '${content['description']}\n\n'
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.\n\n'
            'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\n\n'
            'Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.';
      
      case 'VIDEO':
        return '${content['description']}\n\n'
            'Durasi: 5 menit\n\n'
            'Dalam video ini, Anda akan belajar:\n'
            '• Teknik pernapasan dasar\n'
            '• Cara menenangkan pikiran\n'
            '• Latihan relaksasi sederhana\n\n'
            'Ikuti panduan ini dengan perlahan dan rasakan perbedaannya.';
      
      case 'KUTIPAN':
        return content['description'];
      
      default:
        return content['description'];
    }
  }
}