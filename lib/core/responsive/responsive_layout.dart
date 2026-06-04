import 'package:flutter/material.dart';

enum ScreenType { mobile, tablet, desktop }

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  static ScreenType getScreenType(BuildContext context, {double? width}) {
    double effectiveWidth = width ?? MediaQuery.of(context).size.width;
    if (effectiveWidth < 600) {
      return ScreenType.mobile;
    } else if (effectiveWidth < 1024) {
      return ScreenType.tablet;
    } else {
      return ScreenType.desktop;
    }
  }

  static bool isMobile(BuildContext context, {double? width}) =>
      getScreenType(context, width: width) == ScreenType.mobile;

  static bool isTablet(BuildContext context, {double? width}) =>
      getScreenType(context, width: width) == ScreenType.tablet;

  static bool isDesktop(BuildContext context, {double? width}) =>
      getScreenType(context, width: width) == ScreenType.desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1024) {
          return desktop;
        } else if (constraints.maxWidth >= 600) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}
