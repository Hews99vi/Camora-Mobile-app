import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../utils/responsive.dart';

/// A wrapper widget for web-specific layouts
/// This widget automatically adjusts content based on screen width
/// and provides a more desktop-friendly experience on web
class WebScaffold extends StatelessWidget {
  final Widget mobileBody;
  final Widget? webBody;
  final PreferredSizeWidget? appBar;
  final Widget? drawer;
  final Widget? endDrawer;
  final Color? backgroundColor;
  final bool centerTitle;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;

  const WebScaffold({
    super.key,
    required this.mobileBody,
    this.webBody,
    this.appBar,
    this.drawer,
    this.endDrawer,
    this.backgroundColor,
    this.centerTitle = true,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    // If not web or webBody is null, just return a normal scaffold
    if (!kIsWeb || webBody == null) {
      return Scaffold(
        appBar: appBar,
        drawer: drawer,
        endDrawer: endDrawer,
        backgroundColor: backgroundColor,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
        bottomNavigationBar: bottomNavigationBar,
        body: mobileBody,
      );
    }

    // For web, check if we're on a mobile-sized screen
    if (Responsive.isMobile(context)) {
      return Scaffold(
        appBar: appBar,
        drawer: drawer,
        endDrawer: endDrawer,
        backgroundColor: backgroundColor,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
        bottomNavigationBar: bottomNavigationBar,
        body: mobileBody,
      );
    }

    // Web-specific layout for larger screens
    return Scaffold(
      appBar: appBar,
      backgroundColor: backgroundColor,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      body: webBody,
    );
  }
}

/// A widget that provides a responsive layout with maximum width constraint
/// Useful for preventing content from stretching too wide on large screens
class WebContentWrapper extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;

  const WebContentWrapper({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? Responsive.maxContentWidth(context),
        ),
        child: Padding(
          padding: padding ?? Responsive.padding(context),
          child: child,
        ),
      ),
    );
  }
}