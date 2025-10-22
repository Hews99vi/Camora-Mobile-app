import 'package:flutter/material.dart';

class AppBarUtils {
  // Standard AppBar with pink background (primary theme)
  static AppBar primaryAppBar({
    required String title,
    List<Widget>? actions,
    PreferredSizeWidget? bottom,
    bool centerTitle = true,
  }) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      backgroundColor: const Color(0xFFFF69B4), // Primary pink
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: centerTitle,
      iconTheme: const IconThemeData(color: Colors.white),
      actionsIconTheme: const IconThemeData(color: Colors.white),
      actions: actions,
      bottom: bottom,
    );
  }

  // White AppBar with dark text and icons (for admin screens, order details, etc.)
  static AppBar whiteAppBar({
    required String title,
    List<Widget>? actions,
    PreferredSizeWidget? bottom,
    bool centerTitle = false,
    TextStyle? titleStyle,
  }) {
    return AppBar(
      title: Text(
        title,
        style: titleStyle ?? const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 0,
      centerTitle: centerTitle,
      iconTheme: const IconThemeData(
        color: Colors.black87, // Dark icons for visibility
      ),
      actionsIconTheme: const IconThemeData(
        color: Colors.black87, // Dark action icons for visibility
      ),
      actions: actions,
      bottom: bottom,
    );
  }

  // Transparent AppBar (for special cases)
  static AppBar transparentAppBar({
    String? title,
    List<Widget>? actions,
    Color iconColor = Colors.black87,
    Color textColor = Colors.black87,
  }) {
    return AppBar(
      title: title != null ? Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ) : null,
      backgroundColor: Colors.transparent,
      foregroundColor: textColor,
      elevation: 0,
      iconTheme: IconThemeData(color: iconColor),
      actionsIconTheme: IconThemeData(color: iconColor),
      actions: actions,
    );
  }
}
