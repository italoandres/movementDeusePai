import 'package:flutter/material.dart';

/// Configuration model for a content section in the Sales Landing Page
///
/// This model defines the structure and styling for each section,
/// allowing flexible configuration of text, styling, and layout.
class SectionConfig {
  /// Unique index for the section (used for visibility tracking)
  final int index;

  /// Single text content for the section (mutually exclusive with multipleTexts)
  final String? text;

  /// Multiple text contents for sections with multiple paragraphs/questions
  final List<String>? multipleTexts;

  /// Text style to apply to the section content
  final TextStyle textStyle;

  /// Optional text color override
  final Color? textColor;

  /// Vertical spacing after this section (in pixels)
  final double verticalSpacing;

  /// Whether this section has special styling (e.g., borders, backgrounds)
  final bool hasSpecialStyling;

  /// Optional custom widget to render instead of standard text
  final Widget? customWidget;

  const SectionConfig({
    required this.index,
    this.text,
    this.multipleTexts,
    required this.textStyle,
    this.textColor,
    this.verticalSpacing = 96.0,
    this.hasSpecialStyling = false,
    this.customWidget,
  }) : assert(
          (text != null && multipleTexts == null) ||
              (text == null && multipleTexts != null) ||
              (text == null && multipleTexts == null && customWidget != null),
          'Must provide either text, multipleTexts, or customWidget',
        );

  /// Creates a copy of this SectionConfig with the given fields replaced
  SectionConfig copyWith({
    int? index,
    String? text,
    List<String>? multipleTexts,
    TextStyle? textStyle,
    Color? textColor,
    double? verticalSpacing,
    bool? hasSpecialStyling,
    Widget? customWidget,
  }) {
    return SectionConfig(
      index: index ?? this.index,
      text: text ?? this.text,
      multipleTexts: multipleTexts ?? this.multipleTexts,
      textStyle: textStyle ?? this.textStyle,
      textColor: textColor ?? this.textColor,
      verticalSpacing: verticalSpacing ?? this.verticalSpacing,
      hasSpecialStyling: hasSpecialStyling ?? this.hasSpecialStyling,
      customWidget: customWidget ?? this.customWidget,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SectionConfig &&
        other.index == index &&
        other.text == text &&
        _listEquals(other.multipleTexts, multipleTexts) &&
        other.textStyle == textStyle &&
        other.textColor == textColor &&
        other.verticalSpacing == verticalSpacing &&
        other.hasSpecialStyling == hasSpecialStyling &&
        other.customWidget == customWidget;
  }

  @override
  int get hashCode {
    return Object.hash(
      index,
      text,
      multipleTexts,
      textStyle,
      textColor,
      verticalSpacing,
      hasSpecialStyling,
      customWidget,
    );
  }

  /// Helper method to compare lists
  bool _listEquals(List<String>? a, List<String>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
