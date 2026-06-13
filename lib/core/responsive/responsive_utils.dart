import 'package:flutter/material.dart';
import 'responsive_layout.dart';

class ResponsiveUtils {
  // Screen-based padding and spacing helper
  static double getPadding(BuildContext context) {
    ScreenType screenType = ResponsiveLayout.getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return 16.0;
      case ScreenType.tablet:
        return 24.0;
      case ScreenType.desktop:
        return 32.0;
    }
  }

  // Max width of content containers for neat presentation on huge monitors
  static double getMaxContentWidth(BuildContext context) {
    return 1200.0;
  }

  // Cross axis count for grids (e.g., dashboard stats cards or features blocks)
  static int getGridCrossAxisCount(BuildContext context, {int desktop = 3, int tablet = 2, int mobile = 1, double? width}) {
    ScreenType screenType = ResponsiveLayout.getScreenType(context, width: width);
    switch (screenType) {
      case ScreenType.mobile:
        return mobile;
      case ScreenType.tablet:
        return tablet;
      case ScreenType.desktop:
        return desktop;
    }
  }

  // Cross axis count for grids directly from width (LayoutBuilder preferred)
  static int getContentColumns(double width, {int desktop = 3, int tablet = 2, int mobile = 1}) {
    if (width < 768) {
      return mobile;
    } else if (width < 1024) {
      return tablet;
    } else {
      return desktop;
    }
  }

}
