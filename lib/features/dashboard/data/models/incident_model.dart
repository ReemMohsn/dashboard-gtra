import 'package:gtra_dashboard/core/constants/app_strings.dart';
import 'package:gtra_dashboard/features/dashboard/data/models/incident_enums.dart';
import 'package:gtra_dashboard/features/dashboard/data/models/prediction_model.dart';
import 'package:gtra_dashboard/features/dashboard/data/models/report_model.dart';

class IncidentModel {
  const IncidentModel({
    required this.id,
    required this.neighborhoodId,
    required this.neighborhoodName,
    required this.priorityScore,
    required this.priorityLevel,
    required this.urgentHealth,
    required this.escalating,
    required this.isRepeat,
    required this.state,
    required this.distinctDevices,
    required this.maxDurationDays,
    this.reportCount,
    this.confidenceLabel,
    this.issueType = IssueType.outage,
    this.rank,
    this.explanation,
    this.explanationFromModel = false,
    this.embeddedPrediction,
    this.lastReportAt,
    this.updatedAt,
    this.reports = const <ReportModel>[],
  });

  final String id;
  final String neighborhoodId;
  final String neighborhoodName;
  final double priorityScore;
  final PriorityLevel priorityLevel;
  final bool urgentHealth;
  final bool escalating;
  final bool isRepeat;
  final IncidentState state;
  final int distinctDevices;
  final double maxDurationDays;
  final int? reportCount;
  final String? confidenceLabel;
  final IssueType issueType;
  final int? rank;
  final String? explanation;
  final bool explanationFromModel;
  final PredictionModel? embeddedPrediction;
  final DateTime? lastReportAt;
  final DateTime? updatedAt;
  final List<ReportModel> reports;

  String get displayIssueType {
    if (urgentHealth || issueType == IssueType.contamination) {
      return AppStrings.contaminationIssue;
    }
    return AppStrings.outageIssue;
  }

  String get resolvedConfidenceLabel {
    if (confidenceLabel != null && confidenceLabel!.trim().isNotEmpty) {
      return _localizeConfidence(confidenceLabel!.trim());
    }
    if (distinctDevices >= 6) return AppStrings.confidenceHigh;
    if (distinctDevices >= 3) return AppStrings.confidenceMedium;
    return AppStrings.confidenceLow;
  }

  /// Deterministic Golden Rule priority comparator:
  /// 1. UrgentHealth incidents ALWAYS top the priority list.
  /// 2. Higher priorityScore comes next.
  /// 3. Tie-breakers: Escalating -> DistinctDevices -> MaxDurationDays.
  static int compareByPriority(IncidentModel a, IncidentModel b) {
    if (a.urgentHealth != b.urgentHealth) {
      return a.urgentHealth ? -1 : 1;
    }
    final scoreCompare = b.priorityScore.compareTo(a.priorityScore);
    if (scoreCompare != 0) return scoreCompare;
    if (a.escalating != b.escalating) {
      return a.escalating ? -1 : 1;
    }
    final devicesCompare = b.distinctDevices.compareTo(a.distinctDevices);
    if (devicesCompare != 0) return devicesCompare;
    return b.maxDurationDays.compareTo(a.maxDurationDays);
  }

  IncidentModel copyWith({
    String? id,
    String? neighborhoodId,
    String? neighborhoodName,
    double? priorityScore,
    PriorityLevel? priorityLevel,
    bool? urgentHealth,
    bool? escalating,
    bool? isRepeat,
    IncidentState? state,
    int? distinctDevices,
    double? maxDurationDays,
    int? reportCount,
    String? confidenceLabel,
    IssueType? issueType,
    int? rank,
    String? explanation,
    bool? explanationFromModel,
    PredictionModel? embeddedPrediction,
    DateTime? lastReportAt,
    DateTime? updatedAt,
    List<ReportModel>? reports,
  }) {
    final nextUrgentHealth = urgentHealth ?? this.urgentHealth;
    final nextScore = priorityScore ?? this.priorityScore;

    return IncidentModel(
      id: id ?? this.id,
      neighborhoodId: neighborhoodId ?? this.neighborhoodId,
      neighborhoodName: neighborhoodName ?? this.neighborhoodName,
      priorityScore: nextScore,
      priorityLevel:
          priorityLevel ??
          PriorityLevel.resolve(
            urgentHealth: nextUrgentHealth,
            priorityScore: nextScore,
          ),
      urgentHealth: nextUrgentHealth,
      escalating: escalating ?? this.escalating,
      isRepeat: isRepeat ?? this.isRepeat,
      state: state ?? this.state,
      distinctDevices: distinctDevices ?? this.distinctDevices,
      maxDurationDays: maxDurationDays ?? this.maxDurationDays,
      reportCount: reportCount ?? this.reportCount,
      confidenceLabel: confidenceLabel ?? this.confidenceLabel,
      issueType: issueType ?? this.issueType,
      rank: rank ?? this.rank,
      explanation: explanation ?? this.explanation,
      explanationFromModel: explanationFromModel ?? this.explanationFromModel,
      embeddedPrediction: embeddedPrediction ?? this.embeddedPrediction,
      lastReportAt: lastReportAt ?? this.lastReportAt,
      updatedAt: updatedAt ?? this.updatedAt,
      reports: reports ?? this.reports,
    );
  }

  factory IncidentModel.fromJson(Map<String, dynamic> json) {
    final neighborhoodObj =
        json['neighborhood'] ?? json['Neighborhood'] as Object?;
    final neighborhoodMap = neighborhoodObj is Map
        ? Map<String, dynamic>.from(neighborhoodObj)
        : null;

    final id = (json['id'] ?? json['Id'] ?? json['incidentId'] ?? json['IncidentId'] ?? '')
        .toString();
    final neighborhoodId =
        (json['neighborhoodId'] ??
                json['NeighborhoodId'] ??
                neighborhoodMap?['id'] ??
                neighborhoodMap?['Id'] ??
                '')
            .toString();
    final neighborhoodName =
        (json['neighborhoodNameAr'] ??
                json['NeighborhoodNameAr'] ??
                json['neighborhoodName'] ??
                json['NeighborhoodName'] ??
                neighborhoodMap?['nameAr'] ??
                neighborhoodMap?['NameAr'] ??
                neighborhoodMap?['name'] ??
                neighborhoodMap?['Name'] ??
                'حي غير محدد')
            .toString();

    final score =
        _parseDouble(
          json['priorityScore'] ??
              json['PriorityScore'] ??
              json['score'] ??
              json['Score'] ??
              json['priority'] ??
              json['Priority'],
        ) ??
        0.0;

    final urgentHealth = _parseBool(
      json['UrgentHealth'] ??
          json['urgentHealth'] ??
          json['isUrgentHealth'] ??
          json['IsUrgentHealth'],
    );
    final escalating = _parseBool(
      json['Escalating'] ??
          json['escalating'] ??
          json['isEscalating'] ??
          json['IsEscalating'],
    );
    final isRepeat = _parseBool(
      json['IsRepeat'] ?? json['isRepeat'] ?? json['repeat'] ?? json['Repeat'],
    );

    final state = IncidentState.fromApi(
      json['state'] ?? json['State'] ?? json['status'] ?? json['Status'],
    );

    final distinctDevices =
        _parseInt(
          json['DistinctDevices'] ??
              json['distinctDevices'] ??
              json['deviceCount'] ??
              json['DeviceCount'],
        ) ??
        0;

    final maxDurationDays =
        _parseDouble(
          json['MaxDurationDays'] ??
              json['maxDurationDays'] ??
              json['maxOutageDays'] ??
              json['MaxOutageDays'],
        ) ??
        0.0;

    final rawReports =
        json['reports'] ??
        json['Reports'] ??
        json['mergedReports'] ??
        json['MergedReports'];
    final reports = rawReports is List
        ? rawReports
              .whereType<Map>()
              .map((item) => ReportModel.fromJson(Map<String, dynamic>.from(item)))
              .toList(growable: false)
        : const <ReportModel>[];

    final rawConfidence =
        (json['confidence'] ??
                json['Confidence'] ??
                json['confidenceLevel'] ??
                json['ConfidenceLevel'])
            ?.toString();

    final rawLevel =
        (json['priorityLevel'] ?? json['PriorityLevel'] ?? json['severity'] ?? json['Severity'])
            ?.toString();

    final rawPrediction = json['prediction'] ?? json['Prediction'];
    final embeddedPrediction = rawPrediction is Map
        ? PredictionModel.fromJson(
            Map<String, dynamic>.from(rawPrediction),
            fallbackNeighborhoodId: neighborhoodId,
          )
        : null;

    return IncidentModel(
      id: id,
      neighborhoodId: neighborhoodId,
      neighborhoodName: neighborhoodName,
      priorityScore: score,
      priorityLevel: PriorityLevel.resolve(
        urgentHealth: urgentHealth,
        priorityScore: score,
        rawLevel: rawLevel,
      ),
      urgentHealth: urgentHealth,
      escalating: escalating,
      isRepeat: isRepeat,
      state: state,
      distinctDevices: distinctDevices,
      maxDurationDays: maxDurationDays,
      reportCount: _parseInt(
        json['reportCount'] ?? json['ReportCount'] ?? json['reportsCount'],
      ),
      confidenceLabel: rawConfidence,
      issueType: IssueType.fromApi(
        json['issueType'] ??
            json['IssueType'] ??
            json['category'] ??
            json['Category'] ??
            json['type'] ??
            json['Type'],
      ),
      rank: _parseInt(json['rank'] ?? json['Rank']),
      explanation:
          (json['Explanation'] ??
                  json['explanation'] ??
                  json['summary'] ??
                  json['Summary'])
              ?.toString(),
      explanationFromModel: _parseBool(
        json['explanationFromModel'] ?? json['ExplanationFromModel'],
      ),
      embeddedPrediction: embeddedPrediction,
      lastReportAt: _parseDate(
        json['lastReportAt'] ??
            json['LastReportAt'] ??
            json['latestReportAt'] ??
            json['LatestReportAt'] ??
            json['updatedAt'] ??
            json['UpdatedAt'],
      ),
      updatedAt: _parseDate(json['updatedAt'] ?? json['UpdatedAt']),
      reports: reports,
    );
  }

  static String _localizeConfidence(String value) {
    switch (value.toLowerCase()) {
      case 'high':
        return AppStrings.confidenceHigh;
      case 'medium':
        return AppStrings.confidenceMedium;
      case 'low':
        return AppStrings.confidenceLow;
      default:
        return value;
    }
  }

  static bool _parseBool(Object? value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lower = value.trim().toLowerCase();
      return lower == 'true' || lower == '1' || lower == 'yes';
    }
    return false;
  }

  static int? _parseInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? _parseDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static DateTime? _parseDate(Object? value) {
    if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
    return null;
  }
}
