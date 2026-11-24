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
    final rawId = json['id'] ?? json['Id'] ?? json['reportId'] ?? json['ReportId'];
    final rawText =
        json['text'] ??
        json['Text'] ??
        json['description'] ??
        json['Description'] ??
        json['message'] ??
        json['Message'] ??
        json['rawText'] ??
        json['RawText'] ??
        json['notes'] ??
        json['Notes'];
    final rawCategory =
        json['category'] ??
        json['Category'] ??
        json['type'] ??
        json['Type'] ??
        json['issueType'] ??
        json['IssueType'];
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

    return ReportModel(
      id: rawId?.toString() ?? '',
      text: rawText?.toString().trim() ?? '',
      category: rawCategory?.toString().trim(),
      durationDays: _parseDouble(rawDuration),
      createdAt: _parseDate(rawCreated),
      deviceHint: rawDevice?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    if (category != null) 'category': category,
    if (durationDays != null) 'durationDays': durationDays,
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    if (deviceHint != null) 'deviceId': deviceHint,
  };

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
