import 'package:gtra_dashboard/features/dashboard/data/models/incident_enums.dart';
import 'package:gtra_dashboard/features/dashboard/data/models/incident_model.dart';
import 'package:gtra_dashboard/features/dashboard/data/models/neighborhood_model.dart';
import 'package:gtra_dashboard/features/dashboard/data/models/prediction_model.dart';
import 'package:gtra_dashboard/features/dashboard/data/models/report_model.dart';

abstract final class DemoDashboardData {
  static final List<NeighborhoodModel> neighborhoods = [
    const NeighborhoodModel(
      id: 'nb-mansoura',
      name: 'المنصورة',
      lat: 12.8420,
      lng: 44.9780,
    ),
    const NeighborhoodModel(
      id: 'nb-sharqiya',
      name: 'الشرقية',
      lat: 12.8660,
      lng: 44.9940,
    ),
    const NeighborhoodModel(
      id: 'nb-gharbiya',
      name: 'الغربية',
      lat: 12.8520,
      lng: 44.9480,
    ),
    const NeighborhoodModel(
      id: 'nb-shamaliya',
      name: 'الشمالية',
      lat: 12.8820,
      lng: 44.9620,
    ),
    const NeighborhoodModel(
      id: 'nb-rawda',
      name: 'الروضة',
      lat: 12.8780,
      lng: 44.9340,
    ),
    const NeighborhoodModel(
      id: 'nb-salam',
      name: 'السلام',
      lat: 12.8350,
      lng: 44.9380,
    ),
    const NeighborhoodModel(
      id: 'nb-nakheel',
      name: 'النخيل',
      lat: 12.8500,
      lng: 45.0160,
    ),
    const NeighborhoodModel(
      id: 'nb-janoubiya',
      name: 'الجنوبية',
      lat: 12.8360,
      lng: 45.0080,
    ),
  ];

  static final Map<String, PredictionModel> predictionsByNeighborhood = {
    'nb-sharqiya': const PredictionModel(
      neighborhoodId: 'nb-sharqiya',
      cycleMean: 2.5,
      ci90Low: 1.8,
      ci90High: 3.2,
      probArrival2d: 0.14,
      probLate: 0.92,
      abnormalDelay: true,
      basis: '6 observations (Gradient Boosting)',
      source: 'model',
    ),
    'nb-gharbiya': const PredictionModel(
      neighborhoodId: 'nb-gharbiya',
      cycleMean: 6.4,
      ci90Low: 5.9,
      ci90High: 7.1,
      probArrival2d: 0.68,
      probLate: 0.22,
      abnormalDelay: false,
      basis: '9 observations (Gradient Boosting)',
      source: 'model',
    ),
    'nb-mansoura': const PredictionModel(
      neighborhoodId: 'nb-mansoura',
      cycleMean: 7.2,
      ci90Low: 6.4,
      ci90High: 8.1,
      probArrival2d: 0.55,
      probLate: 0.0,
      abnormalDelay: false,
      basis: '0 observations (Prior only)',
      source: 'model',
    ),
  };

  static List<IncidentModel> buildIncidents() {
    final now = DateTime.now();

    final list = [
      IncidentModel(
        id: 'inc-mansoura',
        neighborhoodId: 'nb-mansoura',
        neighborhoodName: 'المنصورة',
        priorityScore: 45.7,
        priorityLevel: PriorityLevel.urgentHealth,
        urgentHealth: true,
        isRepeat: false,
        state: IncidentState.newIncident,
        distinctDevices: 2,
        maxDurationDays: 1,
        reportCount: 2,
        issueType: IssueType.contamination,
        rank: 1,
        explanation:
            'تصدّر حي المنصورة الأولوية وفق القاعدة الذهبية لوجود بلاغين مستقلين عن تلوث ورائحة غير طبيعية في المياه، مما يستدعي فحصاً ميدانياً عاجلاً.',
        explanationFromModel: true,
        embeddedPrediction: predictionsByNeighborhood['nb-mansoura'],
        lastReportAt: now.subtract(const Duration(minutes: 40)),
        updatedAt: now.subtract(const Duration(minutes: 40)),
        reports: [
          ReportModel(
            id: 'rep-101',
            text: 'الماء وصل اليوم بلون متعكّر ورائحة غريبة غير صالحة للاستخدام',
            category: 'مياه ملوثة',
            durationDays: 1,
            createdAt: now.subtract(const Duration(minutes: 40)),
          ),
          ReportModel(
            id: 'rep-102',
            text: 'في ريحة غريبة في مياه الخزان بعد فتح الخط مباشرة',
            category: 'مياه ملوثة',
            durationDays: 1,
            createdAt: now.subtract(const Duration(hours: 2)),
          ),
        ],
      ),
      IncidentModel(
        id: 'inc-sharqiya',
        neighborhoodId: 'nb-sharqiya',
        neighborhoodName: 'الشرقية',
        priorityScore: 79.0,
        priorityLevel: PriorityLevel.high,
        urgentHealth: false,
        isRepeat: false,
        state: IncidentState.confirmed,
        distinctDevices: 9,
        maxDurationDays: 4,
        reportCount: 11,
        issueType: IssueType.outage,
        rank: 2,
        explanation:
            'يحتل حي الشرقية أعلى أولوية لانقطاع المياه بعد بلاغات من 9 أجهزة مستقلة، مع تجاوز مدة الانقطاع (4 أيام) للدورة المعتادة مما يرجّح عطلاً في الخط.',
        explanationFromModel: true,
        embeddedPrediction: predictionsByNeighborhood['nb-sharqiya'],
        lastReportAt: now.subtract(const Duration(hours: 3)),
        updatedAt: now.subtract(const Duration(hours: 2)),
        reports: [
          ReportModel(
            id: 'rep-201',
            text: 'ما وصلنا ماء من أربعة أيام',
            category: 'انقطاع',
            durationDays: 4,
            createdAt: now.subtract(const Duration(hours: 3)),
          ),
          ReportModel(
            id: 'rep-202',
            text: 'الماي مقطوع من السبت والضغط صفر في الخط الرئيسي',
            category: 'انقطاع',
            durationDays: 4,
            createdAt: now.subtract(const Duration(hours: 5)),
          ),
          ReportModel(
            id: 'rep-203',
            text: 'النوبة تأخرت عن موعدها المعتاد والحارة بدون ماء',
            category: 'انقطاع',
            durationDays: 3,
            createdAt: now.subtract(const Duration(hours: 9)),
          ),
        ],
      ),
      IncidentModel(
        id: 'inc-gharbiya',
        neighborhoodId: 'nb-gharbiya',
        neighborhoodName: 'الغربية',
        priorityScore: 59.4,
        priorityLevel: PriorityLevel.medium,
        urgentHealth: false,
        isRepeat: true,
        state: IncidentState.inProgress,
        distinctDevices: 3,
        maxDurationDays: 3,
        reportCount: 4,
        issueType: IssueType.outage,
        rank: 3,
        explanation:
            'حالة انقطاع متكررة في حي الغربية قيد المتابعة الميدانية حالياً، والمدة الحالية لا تزال ضمن النطاق المعتاد لدورة الضخ.',
        explanationFromModel: false,
        embeddedPrediction: predictionsByNeighborhood['nb-gharbiya'],
        lastReportAt: now.subtract(const Duration(hours: 6)),
        updatedAt: now.subtract(const Duration(hours: 4)),
        reports: [
          ReportModel(
            id: 'rep-301',
            text: 'الماء ضعيف جداً وانقطع بالكامل منذ 3 أيام',
            category: 'انقطاع',
            durationDays: 3,
            createdAt: now.subtract(const Duration(hours: 6)),
          ),
          ReportModel(
            id: 'rep-302',
            text: 'تكرر تأخر النوبة هذا الأسبوع مثل الأسبوع الماضي',
            category: 'انقطاع',
            durationDays: 2,
            createdAt: now.subtract(const Duration(hours: 11)),
          ),
        ],
      ),
    ];

    list.sort(IncidentModel.compareByPriority);
    return list;
  }
}
