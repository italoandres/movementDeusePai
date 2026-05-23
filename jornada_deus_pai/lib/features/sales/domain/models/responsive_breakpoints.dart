import 'package:flutter/material.dart';

/// Utility class for responsive design breakpoints
///
/// Provides methods to determine the current device type and apply
/// responsive layouts based on viewport width.
class ResponsiveBreakpoints {
  // Breakpoint Constants
  /// Minimum width for desktop layout (1024px)
  static const double desktop = 1024.0;

  /// Minimum width for tablet layout (768px)
  static const double tablet = 768.0;

  /// Minimum width for mobile layout (0px)
  static const double mobile = 0.0;

  /// Returns true if the current viewport is desktop size (≥1024px)
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktop;
  }

  /// Returns true if the current viewport is tablet size (≥768px and <1024px)
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= tablet && width < desktop;
  }

  /// Returns true if the current viewport is mobile size (<1024px)
  ///
  /// Note: For the sales page, we treat tablet as mobile for simplicity
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < desktop;
  }

  /// Returns the appropriate value based on the current viewport size
  ///
  /// Example:
  /// ```dart
  /// final fontSize = ResponsiveBreakpoints.valueWhen(
  ///   context,
  ///   desktop: 48.0,
  ///   mobile: 32.0,
  /// );
  /// ```
  static T valueWhen<T>(
    BuildContext context, {
    required T desktop,
    required T mobile,
  }) {
    return isDesktop(context) ? desktop : mobile;
  }

  /// Returns the current viewport width
  static double getWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Returns the current viewport height
  static double getHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
}
