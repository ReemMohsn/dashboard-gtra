import 'package:flutter/material.dart';
import 'package:gtra_dashboard/core/routing/app_route.dart';
import 'package:gtra_dashboard/gtra_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    GtraApp(
      appRouter: AppRouter(),
      initialRoute: AppRoute.dashboard,
    ),
  );
}
