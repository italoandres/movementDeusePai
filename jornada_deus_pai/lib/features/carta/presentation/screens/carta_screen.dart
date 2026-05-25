import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Carta de um Órfão — Immersive video experience (Web-optimized)
/// Uses HTML5 video element directly for best web compatibility
class CartaScreen extends ConsumerStatefulWidget {
  const CartaScreen({super.key});

  @override
  ConsumerState<CartaScreen> createState() => _CartaScreenState();
}

class _CartaScreenState extends ConsumerState<CartaScreen> {
  bool _showCTA = false;
  bool _isPlaying = false;
  bool _isLoaded = false;
  late html.VideoElement _videoElement;
  final String _viewId = 'carta-video-player';

  // Design tokens
  static const _bgColor = Color(0xFF0D0D0D);
  static const _goldPrimary = Color(0xFFC6A15B);
  static const _textPrimary = Color(0xFFF5F1E8);

  static const _videoUrl =
      'https://frtwqdpgslykzxeebmtw.supabase.co/storage/v1/object/public/media/a-carta-de-um-orfao.mp4';

  @override
  void initState() {
    super.initState();
    _setupVideo();
  }

  void _setupVideo() {
    _videoElement = html.VideoElement()
      ..src = _videoUrl
      ..autoplay = true
      ..controls = false
      ..muted = false
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'contain'
      ..style.backgroundColor = '#0D0D0D'
      ..setAttribute('playsinline', 'true')
      ..setAttribute('webkit-playsinline', 'true');

    _videoElement.onCanPlay.listen((_) {
      if (mounted) {
        setState(() {
          _isLoaded = true;
          _isPlaying = true;
        });
      }
    });

    _videoElement.onPlay.listen((_) {
      if (mounted) setState(() => _isPlaying = true);
    });

    _videoElement.onPause.listen((_) {
      if (mounted) setState(() => _isPlaying = false);
    });

    _videoElement.onEnded.listen((_) {
      if (mounted) setState(() => _showCTA = true);
    });

    // Register the view
    ui_web.platformViewRegistry.registerViewFactory(
      _viewId,
      (int viewId) => _videoElement,
    );
  }

  @override
  void dispose() {
    _videoElement.pause();
    _videoElement.remove();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_videoElement.paused) {
      _videoElement.play();
    } else {
      _videoElement.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showCTA) return _buildCTAScreen(context);

    return Scaffold(
      backgroundColor: _bgColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Video (HTML5 native)
          HtmlElementView(viewType: _viewId),

          // Loading indicator
          if (!_isLoaded)
            const Center(
              child: CircularProgressIndicator(
                color: _goldPrimary,
                strokeWidth: 1.5,
              ),
            ),

          // Top bar with back button
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.go('/home'),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _bgColor.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          color: _textPrimary.withOpacity(0.7),
                          size: 18,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _bgColor.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'A Carta de um Órfão',
                        style: TextStyle(
                          color: _textPrimary.withOpacity(0.7),
                          fontSize: 13,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 34),
                  ],
                ),
              ),
            ),
          ),

          // Tap to play/pause overlay
          if (_isLoaded)
            Positioned.fill(
              child: GestureDetector(
                onTap: _togglePlayPause,
                behavior: HitTestBehavior.translucent,
                child: !_isPlaying
                    ? Center(
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: _bgColor.withOpacity(0.6),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _goldPrimary.withOpacity(0.3),
                            ),
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            color: _goldPrimary,
                            size: 32,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCTAScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.3,
            colors: [
              const Color(0xFF1A121C).withOpacity(0.2),
              _bgColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),

                  Container(
                    width: 30,
                    height: 1,
                    color: _goldPrimary.withOpacity(0.2),
                  ),

                  const SizedBox(height: 48),

                  const Text(
                    'Se essa carta parece que\nfoi escrita por você…',
                    style: TextStyle(
                      color: _textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w300,
                      height: 1.8,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  const Text(
                    'Você precisa de um Pai.',
                    style: TextStyle(
                      color: _goldPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w300,
                      height: 1.8,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 48),

                  GestureDetector(
                    onTap: () => context.push('/journey/sales'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 36,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: _goldPrimary.withOpacity(0.08),
                        border: Border.all(
                          color: _goldPrimary.withOpacity(0.35),
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Text(
                        'conhecer o livro',
                        style: TextStyle(
                          color: _goldPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  GestureDetector(
                    onTap: () {
                      setState(() => _showCTA = false);
                      _videoElement.currentTime = 0;
                      _videoElement.play();
                    },
                    child: Text(
                      'assistir novamente',
                      style: TextStyle(
                        color: _textPrimary.withOpacity(0.3),
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
