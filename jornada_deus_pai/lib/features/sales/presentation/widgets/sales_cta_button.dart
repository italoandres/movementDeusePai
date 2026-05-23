import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../data/constants/sales_theme.dart';

/// A call-to-action button widget for the sales landing page.
///
/// This widget implements a StatefulWidget with hover state tracking for desktop
/// and tap effects for mobile. It follows the contemplative minimalist design
/// with gold background and black text.
///
/// Features:
/// - Gold background (#D4AF37) with black text (#000000)
/// - Hover effect (opacity 0.9, 200ms transition) for desktop
/// - Tap effect (scale 0.98, 100ms transition) for mobile
/// - 8px border radius
/// - Minimum 48x48px touch target size
/// - Semantic label for accessibility
///
/// **Validates: Requirements 3.3, 3.4, 3.5, 3.6, 10.2, 10.3, 10.4, 13.1-13.4, 17.1, 19.1**
class SalesCtaButton extends StatefulWidget {
  /// The text to display on the button
  final String text;

  /// Callback function when the button is pressed
  final VoidCallback onPressed;

  /// Optional padding around the button content
  final EdgeInsets? padding;

  const SalesCtaButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.padding,
  });

  @override
  State<SalesCtaButton> createState() => _SalesCtaButtonState();
}

class _SalesCtaButtonState extends State<SalesCtaButton>
    with SingleTickerProviderStateMixin {
  /// Tracks whether the button is being hovered (desktop only)
  bool _isHovered = false;

  /// Tracks whether the button is being pressed (mobile tap effect)
  bool _isPressed = false;

  /// Animation controller for tap effect
  late AnimationController _tapController;

  /// Animation for scale effect on tap
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize tap animation controller
    _tapController = AnimationController(
      duration: SalesTheme.buttonTapDuration,
      vsync: this,
    );

    // Create scale animation from 1.0 to 0.98
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: SalesTheme.buttonTapScale,
    ).animate(
      CurvedAnimation(
        parent: _tapController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _tapController.dispose();
    super.dispose();
  }

  /// Handles tap down event - triggers scale animation on mobile
  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    _tapController.forward();
  }

  /// Handles tap up event - reverses scale animation
  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    _tapController.reverse();
  }

  /// Handles tap cancel event - reverses scale animation
  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _tapController.reverse();
  }

  /// Handles mouse enter event - triggers hover effect on desktop
  void _handleMouseEnter(PointerEvent event) {
    setState(() {
      _isHovered = true;
    });
  }

  /// Handles mouse exit event - removes hover effect
  void _handleMouseExit(PointerEvent event) {
    setState(() {
      _isHovered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine if we're on desktop (for hover effects)
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return MouseRegion(
      onEnter: isDesktop ? _handleMouseEnter : null,
      onExit: isDesktop ? _handleMouseExit : null,
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.onPressed,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedOpacity(
                // Apply hover opacity on desktop, full opacity otherwise
                opacity: _isHovered && isDesktop
                    ? SalesTheme.buttonHoverOpacity
                    : 1.0,
                duration: SalesTheme.buttonHoverDuration,
                curve: Curves.easeInOut,
                child: Semantics(
                  button: true,
                  label: widget.text,
                  hint: 'Toque para continuar',
                  child: Container(
                    constraints: const BoxConstraints(
                      // Ensure minimum touch target size (Requirement 19.1)
                      minWidth: SalesTheme.minTouchTargetSize,
                      minHeight: SalesTheme.minTouchTargetSize,
                    ),
                    padding: widget.padding ??
                        const EdgeInsets.symmetric(
                          horizontal: 32.0,
                          vertical: 16.0,
                        ),
                    decoration: BoxDecoration(
                      // Gold background (Requirement 3.4, 10.3)
                      color: SalesTheme.accentColor,
                      // 8px border radius (Requirement 13.4)
                      borderRadius: BorderRadius.circular(
                        SalesTheme.buttonBorderRadius,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        widget.text,
                        style: const TextStyle(
                          // Black text color (Requirement 3.5, 10.4)
                          color: Colors.black,
                          fontSize: 18.0,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
