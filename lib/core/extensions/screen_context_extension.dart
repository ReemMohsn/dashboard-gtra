import 'package:flutter/material.dart';

extension ScreenContextExtension on BuildContext {
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => screenSize.width;
  bool get isDesktop => screenWidth >= 980;
  bool get isTablet => screenWidth >= 680 && screenWidth < 980;
  bool get isMobile => screenWidth < 680;
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
}
