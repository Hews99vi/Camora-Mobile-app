import 'package:flutter/material.dart';

/// Utility class for handling color-related operations across the app
class ColorUtils {
  /// Map of color names to their hex values
  static const Map<String, String> colorMap = {
    'Red': '#FF0000',
    'Blue': '#0000FF',
    'Green': '#008000',
    'Black': '#000000',
    'White': '#FFFFFF',
    'Pink': '#FFC0CB',
    'Yellow': '#FFFF00',
    'Purple': '#800080',
  };

  /// Get color from name
  static Color getColorFromName(String colorName) {
    // Default to grey if color not found
    if (!colorMap.containsKey(colorName)) {
      return Colors.grey;
    }

    final hexColor = colorMap[colorName]!;
    return Color(int.parse(hexColor.substring(1, 7), radix: 16) + 0xFF000000);
  }

  /// Check if a color is dark (to determine text color)
  static bool isDarkColor(String colorName) {
    return ['Black', 'Blue', 'Purple', 'Green'].contains(colorName);
  }

  /// Determine if a color is bright (to use black text) or dark (to use white text)
  static bool getBrightness(String hex) {
    if (!hex.startsWith('#')) return false;
    
    final hexColor = int.parse(hex.substring(1, 7), radix: 16);
    final r = (hexColor >> 16) & 0xFF;
    final g = (hexColor >> 8) & 0xFF;
    final b = hexColor & 0xFF;
    
    // Calculate luminance (perceived brightness)
    // Using the formula: 0.299*R + 0.587*G + 0.114*B
    final luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255;
    
    // Return true if bright (use black text), false if dark (use white text)
    return luminance > 0.5;
  }
  
  /// Get all available color names
  static List<String> get availableColors {
    return colorMap.keys.toList();
  }
}
