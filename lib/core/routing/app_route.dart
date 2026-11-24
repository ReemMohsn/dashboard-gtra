import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gtra_dashboard/core/services/app_services.dart';
import 'package:gtra_dashboard/features/dashboard/presentation/view_model/dashboard_cubit.dart';
import 'package:gtra_dashboard/features/dashboard/presentation/views/dashboard_view.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoute.dashboard:
      default:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) =>
                DashboardCubit(AppServices.dashboardRepository)..loadDashboard(),
            child: const DashboardView(),
          ),
        );
    }
  }
}

abstract final class AppRoute {
  static const String dashboard = '/';
}
