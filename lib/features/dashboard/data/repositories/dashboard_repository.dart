import 'package:gtra_dashboard/core/constants/api_end_points.dart';
import 'package:gtra_dashboard/core/services/API/api_response.dart';
import 'package:gtra_dashboard/core/services/API/api_service.dart';
import 'package:gtra_dashboard/core/services/API/request_handler.dart';
import 'package:gtra_dashboard/features/dashboard/data/models/incident_enums.dart';
import 'package:gtra_dashboard/features/dashboard/data/models/incident_model.dart';
import 'package:gtra_dashboard/features/dashboard/data/models/neighborhood_model.dart';
import 'package:gtra_dashboard/features/dashboard/data/models/prediction_model.dart';

class DashboardRepository {
  const DashboardRepository({required ApiService apiService})
    : _apiService = apiService;

  final ApiService _apiService;

  Future<ApiResponse<List<NeighborhoodModel>>> getNeighborhoods() {
    return requestHandler<List<NeighborhoodModel>>(
      () => _apiService.get(ApiEndPoints.neighborhoods),
      fromJson: (data) => _extractList(data)
          .map(
            (item) =>
                NeighborhoodModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(growable: false),
    );
  }

  Future<ApiResponse<List<IncidentModel>>> getIncidents() {
    return requestHandler<List<IncidentModel>>(
      () => _apiService.get(ApiEndPoints.incidents),
      fromJson: (data) => _extractList(data)
          .map(
            (item) => IncidentModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(growable: false),
    );
  }

  Future<ApiResponse<IncidentModel>> getIncidentDetails(String incidentId) {
    return requestHandler<IncidentModel>(
      () => _apiService.get(ApiEndPoints.incidentDetails(incidentId)),
      fromJson: (data) =>
          IncidentModel.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  Future<ApiResponse<PredictionModel>> getPrediction(String neighborhoodId) {
    return requestHandler<PredictionModel>(
      () => _apiService.get(
        ApiEndPoints.neighborhoodPrediction(neighborhoodId),
        receiveTimeout: const Duration(seconds: 15),
      ),
      fromJson: (data) => PredictionModel.fromJson(
        Map<String, dynamic>.from(data as Map),
        fallbackNeighborhoodId: neighborhoodId,
      ),
    );
  }

  Future<ApiResponse<IncidentModel?>> updateIncidentState({
    required String incidentId,
    required IncidentState state,
  }) {
    return requestHandler<IncidentModel?>(
      () => _apiService.patch(
        ApiEndPoints.incidentStatus(incidentId),
        data: {'status': state.apiCode},
      ),
      fromJson: (data) {
        if (data is Map &&
            (data.containsKey('id') ||
                data.containsKey('Id') ||
                data.containsKey('incidentId') ||
                data.containsKey('IncidentId') ||
                data.containsKey('status') ||
                data.containsKey('Status') ||
                data.containsKey('state') ||
                data.containsKey('State'))) {
          return IncidentModel.fromJson(Map<String, dynamic>.from(data));
        }
        return null;
      },
    );
  }

  List<Map<dynamic, dynamic>> _extractList(Object? data) {
    if (data is List) {
      return data.whereType<Map>().toList(growable: false);
    }
    if (data is Map) {
      final candidate =
          data['items'] ??
          data['Items'] ??
          data['list'] ??
          data['List'] ??
          data['results'] ??
          data['Results'] ??
          data['incidents'] ??
          data['neighborhoods'];
      if (candidate is List) {
        return candidate.whereType<Map>().toList(growable: false);
      }
    }
    return const [];
  }
}
