import 'dart:async';
import 'package:flutter/material.dart';
import '../design/ecosystem_theme.dart';

/// Contemplative Rotating Phrase — reusable across the entire ecosystem
/// 
/// "Lembrança silenciosa que respira."
/// Not marketing. Not notification. Just presence.
///
/// Matches the visual impact of the book-home rotating quotes:
/// - Golden color
/// - Italic
/// - Fade in/out animation
/// - 6 second interval
class ContemplativeRotatingPhrase extends StatefulWidget {
  final List<String>? customPhrases;
  final double? fontSize;

  const ContemplativeRotatingPhrase({
    super.key,
    this.customPhrases,
    this.fontSize,
  });

  @override
  State<ContemplativeRotatingPhrase> createState() =>
      _ContemplativeRotatingPhraseState();
}

class _ContemplativeRotatingPhraseState
    extends State<ContemplativeRotatingPhrase> {
  int _currentIndex = 0;
  Timer? _timer;
  double _opacity = 1.0;

  static const List<String> _defaultPhrases = [
    'Filho não conquista. Filho pertence.',
    'Você nunca esteve sozinho.',
    'Você não precisa merecer o amor que já é seu.',
    'O Pai nunca pediu performance.',
    'Talvez você só estivesse cansado.',
    'Relacionamento começa onde a obrigação termina.',
    'O fim da solidão começa quando Deus se torna Pai.',
  ];

  List<String> get _phrases => widget.customPhrases ?? _defaultPhrases;

  @override
  void initState() {
    super.initState();
    _startRotation();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startRotation() {
    _timer = Timer.periodic(const Duration(seconds: 6), (timer) {
      // Fade out
      setState(() => _opacity = 0.0);

      // Wait for fade out, then change phrase and fade in
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() {
            _currentIndex = (_currentIndex + 1) % _phrases.length;
            _opacity = 1.0;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      child: Text(
        _phrases[_currentIndex],
        style: TextStyle(
          color: EcosystemTheme.gold,
          fontSize: widget.fontSize ?? (isMobile ? 18 : 22),
          fontWeight: FontWeight.w300,
          letterSpacing: 0.5,
          height: 1.6,
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
