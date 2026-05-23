import 'package:flutter/material.dart';

/// Design System Global — Jornada Deus é Pai
/// 
/// "Como seria uma experiência digital construída
///  à luz de uma vela dourada diante do Pai?"
///
/// Every screen in the ecosystem must feel like ONE presence.
/// Not separate products. One continuous journey.
class EcosystemTheme {
  EcosystemTheme._();

  // ═══════════════════════════════════════════
  // CORES OFICIAIS
  // ═══════════════════════════════════════════
  
  /// Background principal — escuro profundo
  static const Color background = Color(0xFF0D0D0D);
  
  /// Texto quente principal
  static const Color textPrimary = Color(0xFFF5F1E8);
  
  /// Texto secundário (70%)
  static const Color textSecondary = Color(0xB3F5F1E8);
  
  /// Texto contemplativo (42%)
  static const Color textContemplative = Color(0x6BF5F1E8);
  
  /// Dourado oficial — presença, eternidade, valor espiritual
  static const Color gold = Color(0xFFC6A15B);
  
  /// Dourado suave
  static const Color goldSoft = Color(0xFFB8914A);
  
  /// Dourado envelhecido
  static const Color goldAged = Color(0xFF8F6B32);
  
  /// Roxo contemplativo profundo
  static const Color purpleDeep = Color(0xFF2A1F35);
  
  /// Roxo para gradientes sutis
  static const Color purpleGradient = Color(0xFF1A121C);

  // ═══════════════════════════════════════════
  // GRADIENTES
  // ═══════════════════════════════════════════
  
  /// Gradiente radial padrão para backgrounds
  static BoxDecoration get backgroundGradient => BoxDecoration(
    color: background,
    gradient: RadialGradient(
      center: Alignment.topCenter,
      radius: 1.8,
      colors: [
        purpleGradient.withOpacity(0.15),
        background,
      ],
    ),
  );

  // ═══════════════════════════════════════════
  // TIPOGRAFIA
  // ═══════════════════════════════════════════
  
  /// Título principal
  static const TextStyle headlineLarge = TextStyle(
    color: textPrimary,
    fontSize: 28,
    fontWeight: FontWeight.w300,
    letterSpacing: 0.5,
    height: 1.5,
  );
  
  /// Título secundário
  static const TextStyle headlineMedium = TextStyle(
    color: textPrimary,
    fontSize: 22,
    fontWeight: FontWeight.w300,
    height: 1.7,
  );
  
  /// Corpo principal
  static const TextStyle bodyLarge = TextStyle(
    color: textSecondary,
    fontSize: 16,
    fontWeight: FontWeight.w300,
    height: 1.8,
  );
  
  /// Corpo contemplativo
  static const TextStyle bodyContemplative = TextStyle(
    color: textContemplative,
    fontSize: 14,
    fontWeight: FontWeight.w300,
    height: 1.7,
  );
  
  /// Label dourado
  static TextStyle get labelGold => TextStyle(
    color: gold.withOpacity(0.6),
    fontSize: 13,
    fontWeight: FontWeight.w300,
    letterSpacing: 1,
  );

  // ═══════════════════════════════════════════
  // COMPONENTES
  // ═══════════════════════════════════════════
  
  /// Divisor dourado sutil
  static Widget get divider => Container(
    width: 30,
    height: 1,
    color: gold.withOpacity(0.15),
  );
  
  /// Botão CTA principal
  static Widget ctaButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
        decoration: BoxDecoration(
          color: gold.withOpacity(0.06),
          border: Border.all(color: gold.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: gold,
            fontSize: 16,
            fontWeight: FontWeight.w300,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
  
  /// Botão secundário discreto
  static Widget secondaryButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: textPrimary.withOpacity(0.12)),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textPrimary.withOpacity(0.45),
            fontSize: 14,
            fontWeight: FontWeight.w300,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
