import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../shared/design/ecosystem_theme.dart';

/// Widget that displays rotating inspirational quotes with fade animation
/// Uses the global EcosystemTheme for visual consistency
class RotatingQuote extends StatefulWidget {
  final bool isMobile;

  const RotatingQuote({
    super.key,
    required this.isMobile,
  });

  @override
  State<RotatingQuote> createState() => _RotatingQuoteState();
}

class _RotatingQuoteState extends State<RotatingQuote> {
  static const List<String> _quotes = [
    "Filho não conquista. Filho pertence.",
    "Você nunca esteve sozinho.",
    "Você não precisa merecer o amor que já é seu.",
    "O Pai nunca pediu performance.",
    "Talvez você só estivesse cansado.",
    "Relacionamento começa onde a obrigação termina.",
    "O fim da solidão começa quando Deus se torna Pai.",
  ];

  int _currentIndex = 0;
  Timer? _timer;
  double _opacity = 1.0;

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
      setState(() => _opacity = 0.0);

      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() {
            _currentIndex = (_currentIndex + 1) % _quotes.length;
            _opacity = 1.0;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      child: Text(
        _quotes[_currentIndex],
        style: TextStyle(
          color: EcosystemTheme.gold,
          fontSize: widget.isMobile ? 18 : 22,
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
