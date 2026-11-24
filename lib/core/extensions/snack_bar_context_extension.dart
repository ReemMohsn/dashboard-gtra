import 'package:flutter/material.dart';
import 'package:gtra_dashboard/core/themes/app_color.dart';

extension SnackBarContextExtension on BuildContext {
  void showErrorSnackBar(String message) {
    _showSnackBar(message, AppColor.danger);
  }

  void showSuccessSnackBar(String message) {
    _showSnackBar(message, AppColor.success);
  }

  void showInfoSnackBar(String message) {
    _showSnackBar(message, AppColor.primary);
  }

  void _showSnackBar(String message, Color backgroundColor) {
    final messenger = ScaffoldMessenger.of(this);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 3),
        ),
      );
  }
}
