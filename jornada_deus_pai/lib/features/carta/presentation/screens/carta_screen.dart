import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

/// Carta de um Órfão — Immersive video experience
/// Full-screen contemplative video player
/// After video ends: shows CTA to continue the journey
class CartaScreen extends ConsumerStatefulWidget {
  const CartaScreen({super.key});

  @override
  ConsumerState<CartaScreen> createState() => _CartaScreenState();
}

class _CartaScreenState extends ConsumerState<CartaScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _showCTA = false;
  bool _showControls = true;

  // Design tokens
  static const _bgColor = Color(0xFF0D0D0D);
  static const _goldPrimary = Color(0xFFC6A15B);
  static const _textPrimary = Color(0xFFF5F1E8);
  static const _textContemplative = Color(0x6BF5F1E8);

  static const _videoUrl =
      'https://frtwqdpgslykzxeebmtw.supabase.co/storage/v1/object/public/media/a-carta-de-um-orfao.mp4';

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(_videoUrl));

    try {
      await _controller.initialize();
      _controller.addListener(_onVideoProgress);
      if (mounted) {
        setState(() => _isInitialized = true);
        _controller.play();
        // Hide controls after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted && _controller.value.isPlaying) {
            setState(() => _showControls = false);
          }
        });
      }
    } catch (e) {
      print('[CartaScreen] Error initializing video: $e');
    }
  }

  void _onVideoProgress() {
    if (!mounted) return;
    final position = _controller.value.position;
    final duration = _controller.value.duration;

    if (duration.inSeconds > 0 &&
        position.inSeconds >= duration.inSeconds - 1 &&
        !_showCTA) {
      setState(() => _showCTA = true);
      _controller.pause();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onVideoProgress);
    _controller.dispose();
    super.dispose();
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _controller.value.isPlaying) {
          setState(() => _showControls = false);
        }
      });
    }
  }

  void _togglePlayPause() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && _controller.value.isPlaying) {
          setState(() => _showControls = false);
        }
      });
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_showCTA) return _buildCTAScreen(context);

    return Scaffold(
      backgroundColor: _bgColor,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video
            if (_isInitialized)
              Center(
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              )
            else
              const Center(
                child: CircularProgressIndicator(
                  color: _goldPrimary,
                  strokeWidth: 1.5,
                ),
              ),

            // Controls overlay
            if (_showControls && _isInitialized)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: SafeArea(
                  child: Column(
                    children: [
                      // Top bar
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => context.go('/home'),
                              child: Icon(
                                Icons.arrow_back_ios,
                                color: _textPrimary.withOpacity(0.7),
                                size: 20,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'A Carta de um Órfão',
                              style: TextStyle(
                                color: _textPrimary.withOpacity(0.7),
                                fontSize: 14,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            const Spacer(),
                            const SizedBox(width: 20),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Play/Pause button
                      GestureDetector(
                        onTap: _togglePlayPause,
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: _bgColor.withOpacity(0.5),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _goldPrimary.withOpacity(0.3),
                            ),
                          ),
                          child: Icon(
                            _controller.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: _goldPrimary,
                            size: 32,
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Progress bar
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: VideoProgressIndicator(
                          _controller,
                          allowScrubbing: true,
                          colors: VideoProgressColors(
                            playedColor: _goldPrimary.withOpacity(0.7),
                            bufferedColor: _goldPrimary.withOpacity(0.15),
                            backgroundColor: _textPrimary.withOpacity(0.05),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
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

                  // CTA Button - go to sales
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

                  // Replay
                  GestureDetector(
                    onTap: () {
                      setState(() => _showCTA = false);
                      _controller.seekTo(Duration.zero);
                      _controller.play();
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
