import 'package:gtra_dashboard/features/dashboard/data/models/report_model.dart';

class PredictionModel {
  const PredictionModel({
    required this.neighborhoodId,
    this.cycleMean,
    this.ci90Low,
    this.ci90High,
    this.ci90Raw,
    this.probArrival2d,
    this.probLate,
    this.abnormalDelay = false,
    this.basis,
    this.source,
    this.modelVersion,
    this.generatedAtUtc,
    this.updatedAt,
  });

  final String neighborhoodId;
  final double? cycleMean;
  final double? ci90Low;
  final double? ci90High;
  final String? ci90Raw;
  final double? probArrival2d;
  final double? probLate;
  final bool abnormalDelay;
  final String? basis;
  final String? source;
  final String? modelVersion;
  final DateTime? generatedAtUtc;
  final DateTime? updatedAt;

  bool get hasCi90 =>
      (ci90Low != null && ci90High != null) ||
      (ci90Raw != null && ci90Raw!.isNotEmpty);

  bool get isPriorOnly {
    if (source?.toLowerCase() == 'prior_fallback') return true;
    final lower = basis?.trim().toLowerCase() ?? '';
    return lower.contains('prior only') || lower.startsWith('0 observations');
  }

  String get formattedCi90 {
    if (ci90Low != null && ci90High != null) {
      return '${ci90Low!.toStringAsFixed(1)} إلى ${ci90High!.toStringAsFixed(1)} يوم';
    }
    return ci90Raw ?? '';
  }

  factory PredictionModel.fromJson(
    Map<String, dynamic> json, {
    String fallbackNeighborhoodId = '',
  }) {
    final rawDetails = json['details'] ?? json['Details'];
    final details = rawDetails is Map
        ? Map<String, dynamic>.from(rawDetails)
        : json;

    final rawCi90 =
        details['ci90'] ??
        details['Ci90'] ??
        details['CI90'] ??
        json['ci90'] ??
        json['Ci90'] ??
        json['CI90'];
    double? ciLow;
    double? ciHigh;
    String? ciRaw;

    if (rawCi90 is List && rawCi90.length >= 2) {
      ciLow = _parseDouble(rawCi90[0]);
      ciHigh = _parseDouble(rawCi90[1]);
    } else if (rawCi90 is Map) {
      final map = Map<String, dynamic>.from(rawCi90);
      ciLow = _parseDouble(
        map['low'] ?? map['Low'] ?? map['min'] ?? map['Min'] ?? map['lower'],
      );
      ciHigh = _parseDouble(
        map['high'] ?? map['High'] ?? map['max'] ?? map['Max'] ?? map['upper'],
      );
    } else if (rawCi90 != null) {
      ciRaw = rawCi90.toString();
    }

    final rawBasis =
        details['basis'] ?? details['Basis'] ?? json['basis'] ?? json['Basis'];
    String? basisText;
    if (rawBasis is num) {
      basisText = '${rawBasis.toInt()} ملاحظات';
    } else if (rawBasis != null && rawBasis.toString().trim().isNotEmpty) {
      basisText = rawBasis.toString().trim();
    }

    final generatedAt = ReportModel.parseApiUtcDate(
      json['generatedAtUtc'] ?? json['GeneratedAtUtc'],
    );

    return PredictionModel(
      neighborhoodId:
          (json['neighborhoodId'] ??
                  json['NeighborhoodId'] ??
                  fallbackNeighborhoodId)
              .toString(),
      cycleMean: _parseDouble(
        details['cycleMean'] ??
            details['CycleMean'] ??
            details['cycle_days'] ??
            json['cycleMean'] ??
            json['CycleMean'],
      ),
      ci90Low: ciLow,
      ci90High: ciHigh,
      ci90Raw: ciRaw,
      probArrival2d: _parseDouble(
        details['probArrival2d'] ??
            details['ProbArrival2d'] ??
            json['probArrival2d'] ??
            json['ProbArrival2d'],
      ),
      probLate: _parseDouble(
        details['probLate'] ??
            details['ProbLate'] ??
            json['probLate'] ??
            json['ProbLate'],
      ),
      abnormalDelay: _parseBool(
        details['abnormalDelay'] ??
            details['AbnormalDelay'] ??
            json['abnormalDelay'] ??
            json['AbnormalDelay'],
      ),
      basis: basisText,
      source: (json['source'] ?? json['Source'])?.toString(),
      modelVersion: (json['modelVersion'] ?? json['ModelVersion'])?.toString(),
      generatedAtUtc: generatedAt,
      updatedAt:
          ReportModel.parseApiUtcDate(json['updatedAt'] ?? json['UpdatedAt']) ??
          generatedAt,
    );
  }

  static double? _parseDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
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
}
