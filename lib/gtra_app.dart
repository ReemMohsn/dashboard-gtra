import 'package:flutter/material.dart';
import 'package:gtra_dashboard/core/constants/app_strings.dart';
import 'package:gtra_dashboard/core/routing/app_route.dart';
import 'package:gtra_dashboard/core/themes/app_theme.dart';

class GtraApp extends StatelessWidget {
  const GtraApp({
    super.key,
    required this.appRouter,
    this.initialRoute = AppRoute.dashboard,
  });

  final AppRouter appRouter;
  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.dashboardTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      navigatorKey: navigatorKey,
      onGenerateRoute: appRouter.generateRoute,
      initialRoute: initialRoute,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
