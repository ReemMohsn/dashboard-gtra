import 'package:gtra_dashboard/features/dashboard/data/models/incident_enums.dart';

class ReportModel {
  const ReportModel({
    required this.id,
    required this.text,
    this.category,
    this.durationDays,
    this.createdAt,
    this.deviceHint,
  });

  final String id;
  final String text;
  final String? category;
  final double? durationDays;
  final DateTime? createdAt;
  final String? deviceHint;

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    final rawId =
        json['id'] ?? json['Id'] ?? json['reportId'] ?? json['ReportId'];
    final rawText =
        json['rawText'] ??
        json['RawText'] ??
        json['text'] ??
        json['Text'] ??
        json['description'] ??
        json['Description'] ??
        json['message'] ??
        json['Message'] ??
        json['notes'] ??
        json['Notes'];
    final rawCategory =
        json['issueType'] ??
        json['IssueType'] ??
        json['category'] ??
        json['Category'] ??
        json['type'] ??
        json['Type'];
    final rawDuration =
        json['durationDays'] ??
        json['DurationDays'] ??
        json['outageDays'] ??
        json['OutageDays'];
    final rawCreated =
        json['createdAt'] ??
        json['CreatedAt'] ??
        json['submittedAt'] ??
        json['SubmittedAt'] ??
        json['timestamp'] ??
        json['Timestamp'];
    final rawDevice =
        json['deviceId'] ??
        json['DeviceId'] ??
        json['deviceHash'] ??
        json['DeviceHash'];

    String? categoryLabel;
    if (rawCategory is int ||
        (rawCategory is String && int.tryParse(rawCategory.trim()) != null)) {
      categoryLabel = IssueType.fromApi(rawCategory).arabicLabel;
    } else if (rawCategory != null && rawCategory.toString().trim().isNotEmpty) {
      final str = rawCategory.toString().trim();
      final lower = str.toLowerCase();
      if (lower == 'outage' ||
          lower == 'wateroutage' ||
          lower == 'contaminated' ||
          lower == 'contamination') {
        categoryLabel = IssueType.fromApi(str).arabicLabel;
      } else {
        categoryLabel = str;
      }
    }

    return ReportModel(
      id: rawId?.toString() ?? '',
      text: rawText?.toString().trim() ?? '',
      category: categoryLabel,
      durationDays: _parseDouble(rawDuration),
      createdAt: parseApiUtcDate(rawCreated),
      deviceHint: rawDevice?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    if (category != null) 'category': category,
    if (durationDays != null) 'durationDays': durationDays,
    if (createdAt != null) 'createdAt': createdAt!.toUtc().toIso8601String(),
    if (deviceHint != null) 'deviceId': deviceHint,
  };

  static double? _parseDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Parses an ISO-8601 timestamp returned by the backend as UTC even if the
  /// trailing `Z` is missing (SQL Server datetime2), converting to local time.
  static DateTime? parseApiUtcDate(Object? value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;

    final hasTimeZone =
        trimmed.endsWith('Z') ||
        trimmed.endsWith('z') ||
        RegExp(r'[+-]\d{2}:?\d{2}$').hasMatch(trimmed);

    final parsed = DateTime.tryParse(hasTimeZone ? trimmed : '${trimmed}Z');
    return parsed?.toLocal();
  }
}
