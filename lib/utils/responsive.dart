import 'package:flutter/material.dart';
import '../config/app_config.dart';

/// A utility class that provides responsive utilities for different screen sizes.
/// This is especially important for web support.
class Responsive {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < AppConfig.mobileBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= AppConfig.mobileBreakpoint &&
      MediaQuery.of(context).size.width < AppConfig.tabletBreakpoint;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= AppConfig.tabletBreakpoint;

  /// Get a value based on the current screen size
  static T value<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    required T desktop,
  }) {
    if (isDesktop(context)) {
      return desktop;
    } else if (isTablet(context)) {
      return tablet ?? desktop;
    } else {
      return mobile;
    }
  }

  /// Get a padding based on the current screen size
  static EdgeInsets padding(BuildContext context) {
    return value(
      context: context,
      mobile: const EdgeInsets.all(16.0),
      tablet: const EdgeInsets.all(24.0),
      desktop: const EdgeInsets.all(32.0),
    );
  }

  /// Get a horizontal padding based on the current screen size
  static EdgeInsets horizontalPadding(BuildContext context) {
    return value(
      context: context,
      mobile: const EdgeInsets.symmetric(horizontal: 16.0),
      tablet: const EdgeInsets.symmetric(horizontal: 48.0),
      desktop: const EdgeInsets.symmetric(horizontal: 64.0),
    );
  }

  /// Get the max content width for centered content
  static double maxContentWidth(BuildContext context) {
    return value(
      context: context,
      mobile: double.infinity,
      desktop: 1200,
    );
  }

  /// Get the number of grid items per row based on the current screen size
  static int gridCrossAxisCount(BuildContext context) {
    return value(
      context: context,
      mobile: 2,
      tablet: 3,
      desktop: 4,
    );
  }

  /// Wrap content with a max width constraint and center it
  static Widget centeredConstrainedBox({
    required BuildContext context,
    required Widget child,
    double? maxWidth,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? maxContentWidth(context),
        ),
        child: child,
      ),
    );
  }
}