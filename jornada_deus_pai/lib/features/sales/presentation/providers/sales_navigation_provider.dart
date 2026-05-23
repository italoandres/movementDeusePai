import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/core/app_routes.dart';

/// Navigation service for the Sales Landing Page
/// 
/// **Validates: Requirements 10.5, 11.3, 16.1, 16.2, 16.3**
/// 
/// This class provides navigation functionality for the sales page, including:
/// - Navigation to authentication screens
/// - Smooth scrolling to specific sections
/// - Error handling for navigation failures
class SalesNavigation {
  /// Navigates to the checkout screen
  /// 
  /// **Validates: Requirements 10.5, 16.2**
  /// 
  /// This method handles navigation to the checkout screen when users click
  /// the "Voltar para casa" CTA button. It includes error handling to
  /// gracefully manage navigation failures.
  /// 
  /// [context] The BuildContext for navigation
  /// 
  /// Throws no exceptions - errors are caught and displayed to the user
  void navigateToCheckout(BuildContext context) {
    try {
      context.go(AppRoutes.checkout);
    } catch (e) {
      // Log error for debugging
      debugPrint('Navigation error: $e');
      
      // Show user-friendly error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível navegar. Tente novamente.'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Scrolls smoothly to a specific section on the page
  /// 
  /// **Validates: Requirements 11.2, 11.3, 16.1**
  /// 
  /// This method provides smooth scrolling animation to a target section
  /// when users click the "Começar agora" button in the hero section.
  /// The animation uses a 600ms duration with easeInOut curve for a
  /// contemplative, smooth transition.
  /// 
  /// [controller] The ScrollController managing the page scroll
  /// [sectionIndex] The index of the target section (0-based)
  /// 
  /// The method calculates the target position based on viewport height,
  /// assuming each section occupies approximately one viewport height.
  void scrollToSection(ScrollController controller, int sectionIndex) {
    try {
      // Calculate approximate target position
      // Each section is roughly one viewport height
      final targetPosition = sectionIndex * 800.0;
      
      // Ensure we don't scroll beyond the maximum scroll extent
      final maxScroll = controller.position.maxScrollExtent;
      final scrollTarget = targetPosition > maxScroll ? maxScroll : targetPosition;
      
      // Animate to target position with smooth easeInOut curve
      controller.animateTo(
        scrollTarget,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    } catch (e) {
      // Log error for debugging
      debugPrint('Scroll error: $e');
      
      // Attempt immediate scroll as fallback
      try {
        final targetPosition = sectionIndex * 800.0;
        final maxScroll = controller.position.maxScrollExtent;
        final scrollTarget = targetPosition > maxScroll ? maxScroll : targetPosition;
        controller.jumpTo(scrollTarget);
      } catch (fallbackError) {
        debugPrint('Fallback scroll error: $fallbackError');
      }
    }
  }
}

/// Provider for sales navigation functionality
/// 
/// **Validates: Requirements 10.5, 11.3, 16.1, 16.2, 16.3**
/// 
/// This provider exposes the SalesNavigation service, allowing widgets
/// to access navigation functionality throughout the sales page.
/// 
/// Usage example:
/// ```dart
/// final navigation = ref.read(salesNavigationProvider);
/// navigation.navigateToAuth(context);
/// ```
final salesNavigationProvider = Provider<SalesNavigation>((ref) {
  return SalesNavigation();
});
