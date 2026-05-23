import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for scroll controller with automatic disposal
/// 
/// **Validates: Requirements 11.1, 11.2**
/// 
/// This provider manages the ScrollController lifecycle for the sales page,
/// ensuring proper disposal to prevent memory leaks. The controller is used
/// for smooth scrolling animations between sections.
final salesScrollControllerProvider = Provider<ScrollController>((ref) {
  final controller = ScrollController();
  ref.onDispose(() => controller.dispose());
  return controller;
});

/// Provider for tracking current scroll position
/// 
/// **Validates: Requirements 12.5, 15.7**
/// 
/// This provider maintains the current scroll position in pixels, which is
/// used to determine section visibility and trigger fade-in animations.
final scrollPositionProvider = StateProvider<double>((ref) => 0.0);

/// StateNotifier for managing section visibility states
/// 
/// **Validates: Requirements 12.5, 15.7**
/// 
/// This notifier tracks which sections are currently visible in the viewport,
/// enabling fade-in animations to trigger when sections become 20% visible.
class SectionVisibilityNotifier extends StateNotifier<Map<int, bool>> {
  SectionVisibilityNotifier() : super({});

  /// Updates the visibility state of a specific section
  /// 
  /// [sectionIndex] The index of the section to update
  /// [isVisible] Whether the section is currently visible in the viewport
  void updateVisibility(int sectionIndex, bool isVisible) {
    state = {...state, sectionIndex: isVisible};
  }
}

/// Provider for section visibility tracking
/// 
/// **Validates: Requirements 12.5, 15.7**
/// 
/// This provider exposes the SectionVisibilityNotifier, allowing widgets
/// to react to section visibility changes and trigger animations accordingly.
final sectionVisibilityProvider =
    StateNotifierProvider<SectionVisibilityNotifier, Map<int, bool>>((ref) {
  return SectionVisibilityNotifier();
});
