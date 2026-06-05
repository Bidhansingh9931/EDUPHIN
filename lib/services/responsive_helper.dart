import 'package:flutter/material.dart';

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const Responsive({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    if (width >= 1200) {
      return desktop;
    } else if (width >= 600 && tablet != null) {
      return tablet!;
    } else {
      return mobile;
    }
  }
}

extension ResponsiveExtension on BuildContext {
  bool get isMobile => Responsive.isMobile(this);
  bool get isTablet => Responsive.isTablet(this);
  bool get isDesktop => Responsive.isDesktop(this);

  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  ThemeData get theme => Theme.of(this);
  bool get isDarkMode => theme.brightness == Brightness.dark;

  // Adaptive spacing
  double get spacing => isMobile ? 16.0 : 24.0;

  double get xs => spacing * 0.25;
  double get sm => spacing * 0.5;
  double get md => spacing;
  double get lg => spacing * 1.5;
  double get xl => spacing * 2.0;

  // Adaptive padding
  EdgeInsets get pagePadding => EdgeInsets.all(spacing);

  // Adaptive value helper
  T responsive<T>(T mobile, {T? tablet, T? desktop}) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }

  // Scaling helpers
  double scale(double size) => isMobile ? size : (isTablet ? size * 1.2 : size * 1.4);
  double font(double size) => isMobile ? size : (isTablet ? size * 1.15 : size * 1.3);
  
  double get relativeWidth => screenWidth / (isMobile ? 375 : (isTablet ? 768 : 1440));
  double w(double width) => width * relativeWidth;
}
