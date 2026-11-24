import 'package:gtra_dashboard/core/services/API/api_service.dart';
import 'package:gtra_dashboard/features/dashboard/data/repositories/dashboard_repository.dart';

class AppServices {
  AppServices._();

  static final ApiService api = ApiService();

  static final DashboardRepository dashboardRepository = DashboardRepository(
    apiService: api,
  );
}
