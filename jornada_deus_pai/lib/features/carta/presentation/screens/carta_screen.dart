import 'dart:async';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Carta de um Órfão — Experiência contemplativa imersiva
///
/// Não é um player. É um espaço pessoal.
/// Uma carta viva. Um secreto diante do Pai.
class CartaScreen extends ConsumerStatefulWidget {
  const CartaScreen({super.key});

  @override
  ConsumerState<CartaScreen> createState() => _CartaScreenState();
}

class _CartaScreenState extends ConsumerState<CartaScreen>
    with TickerProviderStateMixin {
  late html.VideoElement _videoElement;
  final String _viewId = 'carta-video-contemplative';

  bool _isLoaded = false;
  bool _isPlaying = false;
  bool _showControls = true;
  bool _showCTA = false;
  bool _isMuted = false;
  bool _showResumePrompt = false;
  double _progress = 0.0;
  double _savedPosition = 0.0;
  int _currentPhraseIndex = 0;

  Timer? _hideControlsTimer;
  Timer? _phraseTimer;
  Timer? _progressTimer;

  // Animações
  late AnimationController _controlsFadeController;
  late Animation<double> _controlsFade;
  late AnimationController _phraseFadeController;
  late Animation<double> _phraseFade;
  late AnimationController _ctaFadeController;
  late Animation<double> _ctaFade;

  // Design tokens
  static const _bgColor = Color(0xFF0D0D0D);
  static const _goldPrimary = Color(0xFFC6A15B);
  static const _goldSoft = Color(0x59C6A15B); // 35%
  static const _textPrimary = Color(0xFFF5F1E8);
  static const _textSecondary = Color(0xB3F5F1E8);
  static const _textContemplative = Color(0x6BF5F1E8);

  static const _videoUrl =
      'https://frtwqdpgslykzxeebmtw.supabase.co/storage/v1/object/public/media/a-carta-de-um-orfao.mp4';

  // Frases contemplativas rotativas
  static const _phrases = [
    'a carta continua esperando por você.',
    'algumas palavras precisam ser ouvidas no tempo certo.',
    'talvez você nunca tenha sido abandonado.',
    'o fim da solidão começa quando Deus se torna Pai.',
    'nem toda carta precisa de resposta. só de presença.',
    'o silêncio também é linguagem do Pai.',
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _setupVideo();
    _loadSavedPosition();
    _startPhraseRotation();
  }

  void _initAnimations() {
    _controlsFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _controlsFade = CurvedAnimation(
      parent: _controlsFadeController,
      curve: Curves.easeInOut,
    );
    _controlsFadeController.forward();

    _phraseFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _phraseFade = CurvedAnimation(
      parent: _phraseFadeController,
      curve: Curves.easeInOut,
    );
    _phraseFadeController.forward();

    _ctaFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _ctaFade = CurvedAnimation(
      parent: _ctaFadeController,
      curve: Curves.easeIn,
    );
  }

  void _setupVideo() {
    _videoElement = html.VideoElement()
      ..src = _videoUrl
      ..autoplay = false
      ..controls = false
      ..muted = false
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'contain'
      ..style.backgroundColor = '#0D0D0D'
      ..setAttribute('playsinline', 'true')
      ..setAttribute('webkit-playsinline', 'true');

    _videoElement.onCanPlay.listen((_) {
      if (mounted && !_isLoaded) {
        setState(() => _isLoaded = true);
        _checkSavedPosition();
      }
    });

    _videoElement.onPlay.listen((_) {
      if (mounted) setState(() => _isPlaying = true);
      _scheduleHideControls();
      _startProgressTracking();
    });

    _videoElement.onPause.listen((_) {
      if (mounted) setState(() => _isPlaying = false);
      _savePosition();
    });

    _videoElement.onEnded.listen((_) {
      if (mounted) {
        _clearSavedPosition();
        // Silêncio contemplativo antes do CTA
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() => _showCTA = true);
            _ctaFadeController.forward();
          }
        });
      }
    });

    ui_web.platformViewRegistry.registerViewFactory(
      _viewId,
      (int viewId) => _videoElement,
    );
  }

  Future<void> _loadSavedPosition() async {
    final prefs = await SharedPreferences.getInstance();
    _savedPosition = prefs.getDouble('carta_position') ?? 0.0;
  }

  void _checkSavedPosition() {
    if (_savedPosition > 2.0) {
      setState(() => _showResumePrompt = true);
    } else {
      _videoElement.play();
    }
  }

  void _resumeFromSaved() {
    _videoElement.currentTime = _savedPosition;
    _videoElement.play();
    setState(() => _showResumePrompt = false);
  }

  void _startFromBeginning() {
    _videoElement.currentTime = 0;
    _videoElement.play();
    setState(() => _showResumePrompt = false);
  }

  Future<void> _savePosition() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('carta_position', _videoElement.currentTime.toDouble());
  }

  Future<void> _clearSavedPosition() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('carta_position');
  }

  void _startProgressTracking() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted && _videoElement.duration.isFinite && _videoElement.duration > 0) {
        setState(() {
          _progress = _videoElement.currentTime / _videoElement.duration;
        });
      }
    });
  }

  void _startPhraseRotation() {
    _phraseTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (mounted) {
        _phraseFadeController.reverse().then((_) {
          if (mounted) {
            setState(() {
              _currentPhraseIndex = (_currentPhraseIndex + 1) % _phrases.length;
            });
            _phraseFadeController.forward();
          }
        });
      }
    });
  }

  void _scheduleHideControls() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _isPlaying) {
        _controlsFadeController.reverse();
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControls() {
    if (_showControls) {
      _controlsFadeController.reverse();
      setState(() => _showControls = false);
    } else {
      setState(() => _showControls = true);
      _controlsFadeController.forward();
      _scheduleHideControls();
    }
  }

  void _togglePlayPause() {
    if (_videoElement.paused) {
      _videoElement.play();
    } else {
      _videoElement.pause();
    }
  }

  void _seek(double seconds) {
    final newTime = _videoElement.currentTime + seconds;
    _videoElement.currentTime = newTime.clamp(0, _videoElement.duration);
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _videoElement.muted = _isMuted;
    });
  }

  void _restart() {
    _videoElement.currentTime = 0;
    _videoElement.play();
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _phraseTimer?.cancel();
    _progressTimer?.cancel();
    _controlsFadeController.dispose();
    _phraseFadeController.dispose();
    _ctaFadeController.dispose();
    _savePosition();
    _videoElement.pause();
    _videoElement.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showCTA) return _buildCompletionScreen(context);

    return Scaffold(
      backgroundColor: _bgColor,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video
            HtmlElementView(viewType: _viewId),

            // Loading
            if (!_isLoaded)
              const Center(
                child: CircularProgressIndicator(
                  color: _goldPrimary,
                  strokeWidth: 1.5,
                ),
              ),

            // Resume prompt
            if (_showResumePrompt) _buildResumePrompt(),

            // Bottom contemplative area
            if (_isLoaded && !_showResumePrompt)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildContemplativeArea(),
              ),

            // Top bar (always subtle)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildTopBar(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                _savePosition();
                context.go('/home');
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _bgColor.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: _textPrimary.withOpacity(0.5),
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumePrompt() {
    final minutes = (_savedPosition / 60).floor();
    final seconds = (_savedPosition % 60).floor().toString().padLeft(2, '0');

    return Container(
      color: _bgColor.withOpacity(0.85),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'continuar de $minutes:$seconds?',
              style: const TextStyle(
                color: _textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w300,
                height: 1.7,
              ),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: _resumeFromSaved,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                decoration: BoxDecoration(
                  color: _goldPrimary.withOpacity(0.08),
                  border: Border.all(color: _goldSoft),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Text(
                  'continuar',
                  style: TextStyle(
                    color: _goldPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _startFromBeginning,
              child: Text(
                'recomeçar',
                style: TextStyle(
                  color: _textPrimary.withOpacity(0.3),
                  fontSize: 13,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContemplativeArea() {
    return FadeTransition(
      opacity: _controlsFade,
      child: Container(
        padding: const EdgeInsets.only(bottom: 32, left: 24, right: 24, top: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              _bgColor.withOpacity(0.6),
              _bgColor.withOpacity(0.9),
              _bgColor,
            ],
            stops: const [0.0, 0.2, 0.5, 1.0],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Frase contemplativa rotativa
            FadeTransition(
              opacity: _phraseFade,
              child: Text(
                _phrases[_currentPhraseIndex],
                style: TextStyle(
                  color: _goldPrimary.withOpacity(0.45),
                  fontSize: 13,
                  fontWeight: FontWeight.w300,
                  fontStyle: FontStyle.italic,
                  height: 1.6,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 24),

            // Controles minimalistas
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Restart
                _buildControlIcon(Icons.replay, _restart, size: 18),
                const SizedBox(width: 24),
                // -15s
                _buildControlIcon(Icons.replay_10, () => _seek(-15), size: 20),
                const SizedBox(width: 28),
                // Play/Pause (central, maior)
                GestureDetector(
                  onTap: _togglePlayPause,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _goldPrimary.withOpacity(0.06),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _goldPrimary.withOpacity(0.2),
                      ),
                    ),
                    child: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: _goldPrimary.withOpacity(0.8),
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 28),
                // +15s
                _buildControlIcon(Icons.forward_10, () => _seek(15), size: 20),
                const SizedBox(width: 24),
                // Mute
                _buildControlIcon(
                  _isMuted ? Icons.volume_off : Icons.volume_up,
                  _toggleMute,
                  size: 18,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Barra de progresso contemplativa
            Container(
              height: 2,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _textPrimary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(1),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: _goldPrimary.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlIcon(IconData icon, VoidCallback onTap, {double size = 20}) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        icon,
        color: _textPrimary.withOpacity(0.4),
        size: size,
      ),
    );
  }

  Widget _buildCompletionScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.3,
            colors: [
              const Color(0xFF1A121C).withOpacity(0.15),
              _bgColor,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _ctaFade,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 80),

                    const Text(
                      'talvez isso seja apenas o começo.',
                      style: TextStyle(
                        color: _textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w300,
                        height: 1.8,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 48),

                    Container(
                      width: 30,
                      height: 1,
                      color: _goldPrimary.withOpacity(0.15),
                    ),

                    const SizedBox(height: 48),

                    Text(
                      'Se essa carta parece que\nfoi escrita por você…',
                      style: TextStyle(
                        color: _textPrimary.withOpacity(0.7),
                        fontSize: 17,
                        fontWeight: FontWeight.w300,
                        height: 1.8,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 24),

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

                    const SizedBox(height: 56),

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
                        _ctaFadeController.reset();
                      },
                      child: Text(
                        'ouvir novamente',
                        style: TextStyle(
                          color: _textPrimary.withOpacity(0.25),
                          fontSize: 13,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
