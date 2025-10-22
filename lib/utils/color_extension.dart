import 'package:flutter/material.dart';

/// Extension methods for Color class
extension ColorExtension on Color {
  /// Returns a new color with modified values (alpha, red, green, blue)
  Color withValues({int? alpha, int? red, int? green, int? blue}) {
    return Color.fromARGB(
      alpha ?? ((a * 255.0).round() & 0xFF),
      red ?? ((r * 255.0).round() & 0xFF),
      green ?? ((g * 255.0).round() & 0xFF),
      blue ?? ((b * 255.0).round() & 0xFF),
    );
  }
}
