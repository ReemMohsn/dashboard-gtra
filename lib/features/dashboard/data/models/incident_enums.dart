import 'package:flutter/material.dart';
import 'package:gtra_dashboard/core/constants/app_strings.dart';
import 'package:gtra_dashboard/core/themes/app_color.dart';

enum IncidentState {
  newIncident(0, 'New', AppStrings.stateNew, AppColor.stateNew),
  confirmed(1, 'Confirmed', AppStrings.stateConfirmed, AppColor.stateConfirmed),
  inProgress(
    2,
    'InProgress',
    AppStrings.stateInProgress,
    AppColor.stateInProgress,
  ),
  resolved(3, 'Resolved', AppStrings.stateResolved, AppColor.stateResolved),
  expired(4, 'Expired', AppStrings.stateExpired, AppColor.stateExpired);

  const IncidentState(
    this.apiCode,
    this.apiValue,
    this.arabicLabel,
    this.color,
  );

  final int apiCode;
  final String apiValue;
  final String arabicLabel;
  final Color color;

  bool get isActive =>
      this != IncidentState.resolved && this != IncidentState.expired;

  static IncidentState fromApi(Object? rawValue) {
    final numericCode = rawValue is int
        ? rawValue
        : (rawValue != null ? int.tryParse(rawValue.toString().trim()) : null);
    if (numericCode != null) {
      for (final state in IncidentState.values) {
        if (state.apiCode == numericCode) return state;
      }
      return IncidentState.newIncident;
    }

    final normalized = rawValue?.toString().trim().toLowerCase() ?? '';
    switch (normalized) {
      case 'new':
      case 'newincident':
      case 'جديدة':
        return IncidentState.newIncident;
      case 'confirmed':
      case 'مؤكدة':
        return IncidentState.confirmed;
      case 'inprogress':
      case 'in_progress':
      case 'in-progress':
      case 'قيد المتابعة':
        return IncidentState.inProgress;
      case 'resolved':
      case 'تم الحل':
        return IncidentState.resolved;
      case 'expired':
      case 'منتهية':
        return IncidentState.expired;
      default:
        return IncidentState.newIncident;
    }
  }
}

enum IssueType {
  outage(0, AppStrings.outageIssue),
  contamination(1, AppStrings.contaminationIssue);

  const IssueType(this.apiCode, this.arabicLabel);

  final int apiCode;
  final String arabicLabel;

  static IssueType fromApi(Object? rawValue) {
    final numericCode = rawValue is int
        ? rawValue
        : (rawValue != null ? int.tryParse(rawValue.toString().trim()) : null);
    if (numericCode != null) {
      for (final type in IssueType.values) {
        if (type.apiCode == numericCode) return type;
      }
      return IssueType.outage;
    }

    final normalized = rawValue?.toString().trim().toLowerCase() ?? '';
    if (normalized.contains('contamin') ||
        normalized.contains('pollut') ||
        normalized.contains('ملوث')) {
      return IssueType.contamination;
    }
    return IssueType.outage;
  }
}

enum PriorityLevel {
  urgentHealth(AppStrings.priorityUrgentHealth, AppColor.urgentHealth),
  high(AppStrings.priorityHigh, AppColor.priorityHigh),
  medium(AppStrings.priorityMedium, AppColor.priorityMedium),
  low(AppStrings.priorityLow, AppColor.priorityLow);

  const PriorityLevel(this.arabicLabel, this.color);

  final String arabicLabel;
  final Color color;

  static PriorityLevel resolve({
    required bool urgentHealth,
    required double priorityScore,
    String? rawLevel,
  }) {
    if (urgentHealth) return PriorityLevel.urgentHealth;

    final normalized = rawLevel?.trim().toLowerCase() ?? '';
    if (normalized == 'urgenthealth' ||
        normalized == 'urgent_health' ||
        normalized == 'critical') {
      return PriorityLevel.urgentHealth;
    }
    if (normalized == 'high' || normalized == 'عالية') {
      return PriorityLevel.high;
    }
    if (normalized == 'medium' || normalized == 'متوسطة') {
      return PriorityLevel.medium;
    }
    if (normalized == 'low' || normalized == 'منخفضة') {
      return PriorityLevel.low;
    }

    if (priorityScore >= 70) return PriorityLevel.high;
    if (priorityScore >= 40) return PriorityLevel.medium;
    return PriorityLevel.low;
  }
}

enum DashboardFilter {
  all(AppStrings.filterAll),
  urgentHealth(AppStrings.filterUrgentHealth),
  inProgress(AppStrings.filterInProgress);

  const DashboardFilter(this.label);

  final String label;
}
