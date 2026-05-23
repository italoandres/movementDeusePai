import 'package:flutter/material.dart';

/// Widget that detects taps on the entire screen
class TapDetectorWidget extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const TapDetectorWidget({
    super.key,
    required this.child,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }
}
