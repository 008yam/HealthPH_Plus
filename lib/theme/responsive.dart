import 'package:flutter/material.dart';

class Responsive {
  static Size size(BuildContext context) => MediaQuery.sizeOf(context);

  static bool isLandscape(BuildContext context) {
    final screen = size(context);
    return screen.width > screen.height;
  }

  static bool isCompactHeight(BuildContext context) =>
      size(context).height < 620;

  static bool isLandscapePhone(BuildContext context) {
    final screen = size(context);
    return isLandscape(context) && screen.height < 520;
  }

  static bool isSmallPhone(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 360;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).shortestSide >= 600;

  static double pagePadding(BuildContext context) {
    final screen = size(context);
    final width = screen.width;
    if (isLandscapePhone(context)) return 12;
    if (width < 360) return 14;
    if (isTablet(context)) return 28;
    return 20;
  }

  static double contentMaxWidth(BuildContext context) {
    if (isTablet(context)) return 720;
    if (isLandscapePhone(context)) return 560;
    return 430;
  }

  static double formMaxWidth(BuildContext context) {
    if (isTablet(context)) return 560;
    if (isLandscapePhone(context)) return 600;
    return 420;
  }

  static double buttonHeight(BuildContext context) =>
      isCompactHeight(context) ? 42 : (isSmallPhone(context) ? 44 : 48);

  static double logoHeight(BuildContext context) {
    if (isLandscapePhone(context)) return 36;
    if (isSmallPhone(context)) return 44;
    if (isTablet(context)) return 64;
    return 54;
  }

  static double bottomNavHeight(BuildContext context) =>
      isLandscapePhone(context) ? 52 : 60;

  static double bottomNavClearance(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return bottomNavHeight(context) +
        bottomInset +
        (isLandscapePhone(context) ? 18 : 34);
  }

  static double mapControlSize(BuildContext context) =>
      isLandscapePhone(context) ? 38 : 44;

  static bool showBottomNavLabel(BuildContext context) =>
      !isSmallPhone(context) && !isLandscapePhone(context);

  static double verticalGap(
    BuildContext context,
    double regular, {
    double? compact,
  }) {
    if (isCompactHeight(context)) return compact ?? regular * 0.65;
    return regular;
  }

  static double splashLogoHeight(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final multiplier = isLandscapePhone(context) ? 0.34 : 0.38;
    return (height * multiplier).clamp(140.0, 420.0).toDouble();
  }

  static double chartHeight(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    return (height * 0.28).clamp(140.0, 260.0).toDouble();
  }
}
