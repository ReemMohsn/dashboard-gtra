import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gtra_dashboard/core/constants/app_strings.dart';
import 'package:gtra_dashboard/core/services/errors/exception.dart';
import 'package:gtra_dashboard/features/dashboard/data/demo_dashboard_data.dart';
import 'package:gtra_dashboard/features/dashboard/data/models/incident_enums.dart';
import 'package:gtra_dashboard/features/dashboard/data/models/incident_model.dart';
import 'package:gtra_dashboard/features/dashboard/data/models/neighborhood_model.dart';
import 'package:gtra_dashboard/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:gtra_dashboard/features/dashboard/presentation/view_model/dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this._repository) : super(const DashboardState());

  final DashboardRepository _repository;

  Future<void> loadDashboard() async {
    if (state.dashboardStatus == DashboardRequestStatus.loading) return;

    emit(
      state.copyWith(
        dashboardStatus: DashboardRequestStatus.loading,
        isDemoMode: false,
        clearDashboardErrorMessage: true,
        clearStateUpdateErrorMessage: true,
        clearStateUpdateSuccessMessage: true,
      ),
    );

    try {
      final results = await Future.wait<Object?>([
        _repository.getNeighborhoods(),
        _repository.getIncidents(),
      ]);

      final neighborhoodsResponse =
          results[0] as dynamic;
      final incidentsResponse =
          results[1] as dynamic;

      final neighborhoods =
          (neighborhoodsResponse.data as List<NeighborhoodModel>?) ??
          const <NeighborhoodModel>[];
      final rawIncidents =
          (incidentsResponse.data as List<IncidentModel>?) ??
          const <IncidentModel>[];

      final enrichedIncidents = _enrichAndSortIncidents(
        rawIncidents,
        neighborhoods,
      );

      final nextIncident = _resolveSelectedIncident(
        incidents: enrichedIncidents,
        currentIncidentId: state.selectedIncidentId,
      );

      final nextNeighborhoodId =
          nextIncident?.neighborhoodId ??
          state.selectedNeighborhoodId ??
          (neighborhoods.isNotEmpty ? neighborhoods.first.id : null);

      emit(
        state.copyWith(
          dashboardStatus: DashboardRequestStatus.success,
          neighborhoods: neighborhoods,
          incidents: enrichedIncidents,
          selectedIncidentId: nextIncident?.id,
          clearSelectedIncident: nextIncident == null,
          selectedNeighborhoodId: nextNeighborhoodId,
          clearSelectedNeighborhood: nextNeighborhoodId == null,
          isDemoMode: false,
          lastUpdatedAt: DateTime.now(),
          clearDashboardErrorMessage: true,
        ),
      );

      if (state.isDetailsOpen && nextIncident != null) {
        await _loadDetailsAndPrediction(nextIncident);
      }
    } on ServerException catch (error) {
      emit(
        state.copyWith(
          dashboardStatus: DashboardRequestStatus.failure,
          dashboardErrorMessage: error.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          dashboardStatus: DashboardRequestStatus.failure,
          dashboardErrorMessage: AppStrings.unableToLoadDashboard,
        ),
      );
    }
  }

  void loadDemoData() {
    final neighborhoods = DemoDashboardData.neighborhoods;
    final incidents = DemoDashboardData.buildIncidents();
    final defaultSelected = incidents.length > 1
        ? incidents[1]
        : (incidents.isNotEmpty ? incidents.first : null);

    emit(
      DashboardState(
        dashboardStatus: DashboardRequestStatus.success,
        neighborhoods: neighborhoods,
        incidents: incidents,
        selectedIncidentId: defaultSelected?.id,
        selectedNeighborhoodId: defaultSelected?.neighborhoodId,
        isDemoMode: true,
        isDetailsOpen: false,
        lastUpdatedAt: DateTime.now(),
      ),
    );
  }

  void setFilter(DashboardFilter filter) {
    if (state.activeFilter == filter) return;
    emit(state.copyWith(activeFilter: filter));
  }

  void selectIncident(IncidentModel incident, {bool openDetails = false}) {
    final shouldKeepDetailsOpen = openDetails || state.isDetailsOpen;
    final embedded = incident.embeddedPrediction;

    emit(
      state.copyWith(
        selectedIncidentId: incident.id,
        selectedNeighborhoodId: incident.neighborhoodId,
        isDetailsOpen: shouldKeepDetailsOpen,
        selectedIncidentDetail: incident,
        prediction: embedded,
        clearPrediction: embedded == null,
        predictionStatus: embedded != null
            ? DashboardRequestStatus.success
            : DashboardRequestStatus.initial,
        detailsStatus: shouldKeepDetailsOpen
            ? DashboardRequestStatus.loading
            : DashboardRequestStatus.initial,
        clearDetailsErrorMessage: true,
        clearPredictionErrorMessage: true,
        clearStateUpdateErrorMessage: true,
        clearStateUpdateSuccessMessage: true,
      ),
    );

    if (shouldKeepDetailsOpen) {
      _loadDetailsAndPrediction(incident);
    }
  }

  void selectNeighborhood(NeighborhoodModel neighborhood) {
    final linkedIncident = state.incidentForNeighborhood(neighborhood.id);
    if (linkedIncident != null) {
      selectIncident(linkedIncident, openDetails: state.isDetailsOpen);
      return;
    }

    emit(
      state.copyWith(
        selectedNeighborhoodId: neighborhood.id,
        clearSelectedIncident: true,
        clearSelectedIncidentDetail: true,
        clearPrediction: true,
        isDetailsOpen: false,
        clearStateUpdateErrorMessage: true,
        clearStateUpdateSuccessMessage: true,
      ),
    );
  }

  void openSelectedIncidentDetails() {
    final incident = state.selectedIncident;
    if (incident == null) return;
    selectIncident(incident, openDetails: true);
  }

  void closeDetails() {
    if (!state.isDetailsOpen) return;
    emit(
      state.copyWith(
        isDetailsOpen: false,
        clearStateUpdateErrorMessage: true,
        clearStateUpdateSuccessMessage: true,
      ),
    );
  }

  Future<void> retryIncidentDetails() async {
    final incident = state.selectedIncident;
    if (incident == null) return;
    await _fetchIncidentDetails(incident);
  }

  Future<void> retryPrediction() async {
    final incident = state.selectedIncident;
    if (incident == null) return;
    await _fetchPrediction(incident.neighborhoodId, incident.id);
  }

  Future<void> updateIncidentState(IncidentState newState) async {
    final incident = state.selectedIncident;
    if (incident == null || state.isUpdatingState) return;
    if (incident.state == newState) return;

    emit(
      state.copyWith(
        isUpdatingState: true,
        updatingTargetState: newState,
        clearStateUpdateErrorMessage: true,
        clearStateUpdateSuccessMessage: true,
      ),
    );

    if (state.isDemoMode) {
      await Future<void>.delayed(const Duration(milliseconds: 280));
      final updatedIncident = incident.copyWith(
        state: newState,
        updatedAt: DateTime.now(),
      );
      _applyUpdatedIncident(
        updatedIncident,
        message: AppStrings.stateUpdatedSuccess,
      );
      return;
    }

    try {
      final response = await _repository.updateIncidentState(
        incidentId: incident.id,
        state: newState,
      );

      final returnedIncident = response.data;
      final mergedIncident = returnedIncident != null
          ? incident.copyWith(
              state: returnedIncident.state,
              priorityScore: returnedIncident.priorityScore > 0
                  ? returnedIncident.priorityScore
                  : incident.priorityScore,
              updatedAt: returnedIncident.updatedAt ?? DateTime.now(),
            )
          : incident.copyWith(state: newState, updatedAt: DateTime.now());

      _applyUpdatedIncident(
        mergedIncident,
        message: AppStrings.stateUpdatedSuccess,
      );
    } on ServerException catch (error) {
      emit(
        state.copyWith(
          isUpdatingState: false,
          clearUpdatingTargetState: true,
          stateUpdateErrorMessage: error.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isUpdatingState: false,
          clearUpdatingTargetState: true,
          stateUpdateErrorMessage: AppStrings.stateUpdateFailed,
        ),
      );
    }
  }

  void clearFeedbackMessages() {
    if (state.stateUpdateErrorMessage == null &&
        state.stateUpdateSuccessMessage == null) {
      return;
    }
    emit(
      state.copyWith(
        clearStateUpdateErrorMessage: true,
        clearStateUpdateSuccessMessage: true,
      ),
    );
  }

  Future<void> _loadDetailsAndPrediction(IncidentModel incident) async {
    await Future.wait([
      _fetchIncidentDetails(incident),
      _fetchPrediction(incident.neighborhoodId, incident.id),
    ]);
  }

  Future<void> _fetchIncidentDetails(IncidentModel incident) async {
    emit(
      state.copyWith(
        detailsStatus: DashboardRequestStatus.loading,
        clearDetailsErrorMessage: true,
      ),
    );

    if (state.isDemoMode) {
      await Future<void>.delayed(const Duration(milliseconds: 160));
      if (state.selectedIncidentId != incident.id) return;
      emit(
        state.copyWith(
          detailsStatus: DashboardRequestStatus.success,
          selectedIncidentDetail: incident,
          clearDetailsErrorMessage: true,
        ),
      );
      return;
    }

    try {
      final response = await _repository.getIncidentDetails(incident.id);
      if (state.selectedIncidentId != incident.id) return;

      final detail = response.data;
      if (detail == null) {
        emit(
          state.copyWith(
            detailsStatus: DashboardRequestStatus.success,
            selectedIncidentDetail: incident,
          ),
        );
        return;
      }

      final merged = detail.copyWith(
        neighborhoodName:
            detail.neighborhoodName == 'حي غير محدد' ||
                detail.neighborhoodName.isEmpty
            ? incident.neighborhoodName
            : detail.neighborhoodName,
        embeddedPrediction:
            detail.embeddedPrediction ?? incident.embeddedPrediction,
      );

      final updatedList = state.incidents
          .map((item) => item.id == merged.id ? merged : item)
          .toList(growable: false);

      final shouldSeedPrediction =
          state.prediction == null && merged.embeddedPrediction != null;

      emit(
        state.copyWith(
          detailsStatus: DashboardRequestStatus.success,
          selectedIncidentDetail: merged,
          incidents: updatedList,
          prediction: shouldSeedPrediction ? merged.embeddedPrediction : null,
          predictionStatus: shouldSeedPrediction
              ? DashboardRequestStatus.success
              : null,
          clearDetailsErrorMessage: true,
        ),
      );
    } on ServerException catch (error) {
      if (state.selectedIncidentId != incident.id) return;
      emit(
        state.copyWith(
          detailsStatus: DashboardRequestStatus.failure,
          detailsErrorMessage: error.message,
        ),
      );
    } catch (_) {
      if (state.selectedIncidentId != incident.id) return;
      emit(
        state.copyWith(
          detailsStatus: DashboardRequestStatus.failure,
          detailsErrorMessage: AppStrings.unableToLoadIncidentDetails,
        ),
      );
    }
  }

  Future<void> _fetchPrediction(
    String neighborhoodId,
    String expectedIncidentId,
  ) async {
    if (neighborhoodId.isEmpty) {
      emit(
        state.copyWith(
          predictionStatus: DashboardRequestStatus.failure,
          clearPrediction: true,
          predictionErrorMessage: AppStrings.predictionUnavailableTitle,
        ),
      );
      return;
    }

    final hasSeededPrediction =
        state.prediction != null &&
        state.prediction!.neighborhoodId == neighborhoodId;

    if (!hasSeededPrediction) {
      emit(
        state.copyWith(
          predictionStatus: DashboardRequestStatus.loading,
          clearPredictionErrorMessage: true,
        ),
      );
    }

    if (state.isDemoMode) {
      await Future<void>.delayed(const Duration(milliseconds: 240));
      if (state.selectedIncidentId != expectedIncidentId) return;
      final demoPrediction =
          DemoDashboardData.predictionsByNeighborhood[neighborhoodId];
      if (demoPrediction != null) {
        emit(
          state.copyWith(
            predictionStatus: DashboardRequestStatus.success,
            prediction: demoPrediction,
            clearPredictionErrorMessage: true,
          ),
        );
      } else {
        emit(
          state.copyWith(
            predictionStatus: DashboardRequestStatus.failure,
            clearPrediction: true,
            predictionErrorMessage: AppStrings.predictionUnavailableTitle,
          ),
        );
      }
      return;
    }

    try {
      final response = await _repository.getPrediction(neighborhoodId);
      if (state.selectedIncidentId != expectedIncidentId) return;

      if (response.data == null) {
        if (state.prediction != null &&
            state.prediction!.neighborhoodId == neighborhoodId) {
          emit(
            state.copyWith(
              predictionStatus: DashboardRequestStatus.success,
              clearPredictionErrorMessage: true,
            ),
          );
          return;
        }
        emit(
          state.copyWith(
            predictionStatus: DashboardRequestStatus.failure,
            clearPrediction: true,
            predictionErrorMessage: AppStrings.predictionUnavailableTitle,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          predictionStatus: DashboardRequestStatus.success,
          prediction: response.data,
          clearPredictionErrorMessage: true,
        ),
      );
    } on ServerException catch (error) {
      if (state.selectedIncidentId != expectedIncidentId) return;
      if (state.prediction != null &&
          state.prediction!.neighborhoodId == neighborhoodId) {
        emit(
          state.copyWith(
            predictionStatus: DashboardRequestStatus.success,
            clearPredictionErrorMessage: true,
          ),
        );
        return;
      }
      emit(
        state.copyWith(
          predictionStatus: DashboardRequestStatus.failure,
          clearPrediction: true,
          predictionErrorMessage: error.message,
        ),
      );
    } catch (_) {
      if (state.selectedIncidentId != expectedIncidentId) return;
      if (state.prediction != null &&
          state.prediction!.neighborhoodId == neighborhoodId) {
        emit(
          state.copyWith(
            predictionStatus: DashboardRequestStatus.success,
            clearPredictionErrorMessage: true,
          ),
        );
        return;
      }
      emit(
        state.copyWith(
          predictionStatus: DashboardRequestStatus.failure,
          clearPrediction: true,
          predictionErrorMessage: AppStrings.predictionUnavailableTitle,
        ),
      );
    }
  }

  void _applyUpdatedIncident(
    IncidentModel updated, {
    required String message,
  }) {
    final updatedList =
        state.incidents
            .map((item) => item.id == updated.id ? updated : item)
            .toList()
          ..sort(IncidentModel.compareByPriority);

    emit(
      state.copyWith(
        incidents: updatedList,
        selectedIncidentDetail: updated,
        isUpdatingState: false,
        clearUpdatingTargetState: true,
        stateUpdateSuccessMessage: message,
        clearStateUpdateErrorMessage: true,
        lastUpdatedAt: DateTime.now(),
      ),
    );
  }

  List<IncidentModel> _enrichAndSortIncidents(
    List<IncidentModel> rawIncidents,
    List<NeighborhoodModel> neighborhoods,
  ) {
    final neighborhoodNames = {
      for (final nb in neighborhoods) nb.id: nb.name,
    };

    final enriched = rawIncidents.map((incident) {
      final resolvedName = neighborhoodNames[incident.neighborhoodId];
      if ((incident.neighborhoodName.isEmpty ||
              incident.neighborhoodName == 'حي غير محدد') &&
          resolvedName != null) {
        return incident.copyWith(neighborhoodName: resolvedName);
      }
      return incident;
    }).toList();

    enriched.sort(IncidentModel.compareByPriority);
    return enriched;
  }

  IncidentModel? _resolveSelectedIncident({
    required List<IncidentModel> incidents,
    required String? currentIncidentId,
  }) {
    if (incidents.isEmpty) return null;
    if (currentIncidentId != null) {
      for (final incident in incidents) {
        if (incident.id == currentIncidentId) return incident;
      }
    }
    return incidents.first;
  }
}
