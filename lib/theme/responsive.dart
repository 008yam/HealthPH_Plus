import 'package:flutter/material.dart';

class Responsive {
  static bool isSmallPhone(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 360;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 660;

  static double pagePadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 360) return 14;
    if (width >= 600) return 28;
    return 20;
  } 

  static double formMaxWidth(BuildContext context) =>
      isTablet(context) ? 520 : 420;

  static double buttonHeight(BuildContext context) =>
      isSmallPhone(context) ? 44 : 48;

  static double logoHeight(BuildContext context) {
    if (isSmallPhone(context)) return 44;
    if (isTablet(context)) return 64;
    return 54;
  }

  static double splashLogoHeight(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    return (height * 0.38).clamp(220.0, 420.0).toDouble();
  }

  static double chartHeight(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    return (height * 0.28).clamp(180.0, 260.0).toDouble();
  }
}