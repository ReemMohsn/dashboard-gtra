import 'package:flutter/foundation.dart';
import 'package:gtra_dashboard/features/dashboard/data/models/incident_enums.dart';
import 'package:gtra_dashboard/features/dashboard/data/models/incident_model.dart';
import 'package:gtra_dashboard/features/dashboard/data/models/neighborhood_model.dart';
import 'package:gtra_dashboard/features/dashboard/data/models/prediction_model.dart';

enum DashboardRequestStatus { initial, loading, success, failure }

@immutable
class DashboardState {
  const DashboardState({
    this.dashboardStatus = DashboardRequestStatus.initial,
    this.detailsStatus = DashboardRequestStatus.initial,
    this.predictionStatus = DashboardRequestStatus.initial,
    this.neighborhoods = const <NeighborhoodModel>[],
    this.incidents = const <IncidentModel>[],
    this.activeFilter = DashboardFilter.all,
    this.selectedNeighborhoodId,
    this.selectedIncidentId,
    this.selectedIncidentDetail,
    this.prediction,
    this.isDetailsOpen = false,
    this.isDemoMode = false,
    this.isUpdatingState = false,
    this.updatingTargetState,
    this.dashboardErrorMessage,
    this.detailsErrorMessage,
    this.predictionErrorMessage,
    this.stateUpdateErrorMessage,
    this.stateUpdateSuccessMessage,
    this.lastUpdatedAt,
  });

  final DashboardRequestStatus dashboardStatus;
  final DashboardRequestStatus detailsStatus;
  final DashboardRequestStatus predictionStatus;
  final List<NeighborhoodModel> neighborhoods;
  final List<IncidentModel> incidents;
  final DashboardFilter activeFilter;
  final String? selectedNeighborhoodId;
  final String? selectedIncidentId;
  final IncidentModel? selectedIncidentDetail;
  final PredictionModel? prediction;
  final bool isDetailsOpen;
  final bool isDemoMode;
  final bool isUpdatingState;
  final IncidentState? updatingTargetState;
  final String? dashboardErrorMessage;
  final String? detailsErrorMessage;
  final String? predictionErrorMessage;
  final String? stateUpdateErrorMessage;
  final String? stateUpdateSuccessMessage;
  final DateTime? lastUpdatedAt;

  List<IncidentModel> get filteredIncidents {
    switch (activeFilter) {
      case DashboardFilter.all:
        return incidents;
      case DashboardFilter.urgentHealth:
        return incidents
            .where((incident) => incident.urgentHealth)
            .toList(growable: false);
      case DashboardFilter.confirmed:
        return incidents
            .where((incident) => incident.state == IncidentState.confirmed)
            .toList(growable: false);
      case DashboardFilter.inProgress:
        return incidents
            .where((incident) => incident.state == IncidentState.inProgress)
            .toList(growable: false);
    }
  }

  IncidentModel? get selectedIncident {
    if (selectedIncidentDetail != null &&
        selectedIncidentDetail!.id == selectedIncidentId) {
      return selectedIncidentDetail;
    }
    if (selectedIncidentId != null) {
      for (final incident in incidents) {
        if (incident.id == selectedIncidentId) return incident;
      }
    }
    if (selectedNeighborhoodId != null) {
      return incidentForNeighborhood(selectedNeighborhoodId!);
    }
    return null;
  }

  NeighborhoodModel? get selectedNeighborhood {
    final targetId = selectedNeighborhoodId ?? selectedIncident?.neighborhoodId;
    if (targetId == null) return null;
    for (final neighborhood in neighborhoods) {
      if (neighborhood.id == targetId) return neighborhood;
    }
    return null;
  }

  IncidentModel? incidentForNeighborhood(String neighborhoodId) {
    IncidentModel? best;
    for (final incident in incidents) {
      if (incident.neighborhoodId == neighborhoodId) {
        if (best == null ||
            IncidentModel.compareByPriority(incident, best) < 0) {
          best = incident;
        }
      }
    }
    return best;
  }

  int get quietNeighborhoodsCount {
    if (neighborhoods.isEmpty) return 0;
    final activeNeighborhoodIds = incidents
        .where((incident) => incident.state.isActive)
        .map((incident) => incident.neighborhoodId)
        .toSet();
    return neighborhoods
        .where((nb) => !activeNeighborhoodIds.contains(nb.id))
        .length;
  }

  int get urgentHealthCount =>
      incidents.where((incident) => incident.urgentHealth).length;

  int get confirmedCount => incidents
      .where((incident) => incident.state == IncidentState.confirmed)
      .length;

  int get inProgressCount => incidents
      .where((incident) => incident.state == IncidentState.inProgress)
      .length;

  DashboardState copyWith({
    DashboardRequestStatus? dashboardStatus,
    DashboardRequestStatus? detailsStatus,
    DashboardRequestStatus? predictionStatus,
    List<NeighborhoodModel>? neighborhoods,
    List<IncidentModel>? incidents,
    DashboardFilter? activeFilter,
    String? selectedNeighborhoodId,
    bool clearSelectedNeighborhood = false,
    String? selectedIncidentId,
    bool clearSelectedIncident = false,
    IncidentModel? selectedIncidentDetail,
    bool clearSelectedIncidentDetail = false,
    PredictionModel? prediction,
    bool clearPrediction = false,
    bool? isDetailsOpen,
    bool? isDemoMode,
    bool? isUpdatingState,
    IncidentState? updatingTargetState,
    bool clearUpdatingTargetState = false,
    String? dashboardErrorMessage,
    bool clearDashboardErrorMessage = false,
    String? detailsErrorMessage,
    bool clearDetailsErrorMessage = false,
    String? predictionErrorMessage,
    bool clearPredictionErrorMessage = false,
    String? stateUpdateErrorMessage,
    bool clearStateUpdateErrorMessage = false,
    String? stateUpdateSuccessMessage,
    bool clearStateUpdateSuccessMessage = false,
    DateTime? lastUpdatedAt,
  }) {
    return DashboardState(
      dashboardStatus: dashboardStatus ?? this.dashboardStatus,
      detailsStatus: detailsStatus ?? this.detailsStatus,
      predictionStatus: predictionStatus ?? this.predictionStatus,
      neighborhoods: neighborhoods ?? this.neighborhoods,
      incidents: incidents ?? this.incidents,
      activeFilter: activeFilter ?? this.activeFilter,
      selectedNeighborhoodId: clearSelectedNeighborhood
          ? null
          : selectedNeighborhoodId ?? this.selectedNeighborhoodId,
      selectedIncidentId: clearSelectedIncident
          ? null
          : selectedIncidentId ?? this.selectedIncidentId,
      selectedIncidentDetail: clearSelectedIncidentDetail
          ? null
          : selectedIncidentDetail ?? this.selectedIncidentDetail,
      prediction: clearPrediction ? null : prediction ?? this.prediction,
      isDetailsOpen: isDetailsOpen ?? this.isDetailsOpen,
      isDemoMode: isDemoMode ?? this.isDemoMode,
      isUpdatingState: isUpdatingState ?? this.isUpdatingState,
      updatingTargetState: clearUpdatingTargetState
          ? null
          : updatingTargetState ?? this.updatingTargetState,
      dashboardErrorMessage: clearDashboardErrorMessage
          ? null
          : dashboardErrorMessage ?? this.dashboardErrorMessage,
      detailsErrorMessage: clearDetailsErrorMessage
          ? null
          : detailsErrorMessage ?? this.detailsErrorMessage,
      predictionErrorMessage: clearPredictionErrorMessage
          ? null
          : predictionErrorMessage ?? this.predictionErrorMessage,
      stateUpdateErrorMessage: clearStateUpdateErrorMessage
          ? null
          : stateUpdateErrorMessage ?? this.stateUpdateErrorMessage,
      stateUpdateSuccessMessage: clearStateUpdateSuccessMessage
          ? null
          : stateUpdateSuccessMessage ?? this.stateUpdateSuccessMessage,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }
}
