import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class YoutubePlayer extends StatefulWidget {
  final String url;

  const YoutubePlayer({super.key, required this.url});

  @override
  State<YoutubePlayer> createState() => _YoutubePlayerState();
}

class _YoutubePlayerState extends State<YoutubePlayer> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) {
              setState(() => _isLoading = false);
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(_buildEmbedUrl(widget.url)));
  }

  String _buildEmbedUrl(String url) {
    final id = _extractVideoId(url);
    if (id == null) return url;
    return 'https://www.youtube.com/embed/$id?rel=0&autoplay=1';
  }

  String? _extractVideoId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    }

    if (uri.host.contains('youtube.com')) {
      if (uri.path.contains('/embed/')) {
        return uri.pathSegments.last;
      }
      return uri.queryParameters['v'];
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: WebViewWidget(controller: _controller),
        ),
        if (_isLoading)
          const AspectRatio(
            aspectRatio: 16 / 9,
            child: Center(
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
          ),
      ],
    );
  }
}
