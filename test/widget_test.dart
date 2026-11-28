import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gtra_dashboard/core/constants/app_strings.dart';
import 'package:gtra_dashboard/core/services/API/api_service.dart';
import 'package:gtra_dashboard/core/themes/app_theme.dart';
import 'package:gtra_dashboard/features/dashboard/data/models/incident_enums.dart';
import 'package:gtra_dashboard/features/dashboard/data/models/incident_model.dart';
import 'package:gtra_dashboard/features/dashboard/data/models/neighborhood_model.dart';
import 'package:gtra_dashboard/features/dashboard/data/models/prediction_model.dart';
import 'package:gtra_dashboard/features/dashboard/data/models/report_model.dart';
import 'package:gtra_dashboard/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:gtra_dashboard/features/dashboard/presentation/view_model/dashboard_cubit.dart';
import 'package:gtra_dashboard/features/dashboard/presentation/views/dashboard_view.dart';

void main() {
  group('Qatrah Dashboard Models, Ranking & UTC Parsing', () {
    test('Trusts backend rank as single source of truth when present', () {
      final rank2 = IncidentModel.fromJson({
        'incidentId': 1,
        'neighborhoodId': 6,
        'neighborhoodNameAr': 'الديس',
        'score': 90.0,
        'rank': 2,
        'urgentHealth': false,
        'status': 0,
        'distinctDevices': 8,
      });

      final rank1 = IncidentModel.fromJson({
        'incidentId': 2,
        'neighborhoodId': 7,
        'neighborhoodNameAr': 'فوه',
        'score': 45.0,
        'rank': 1,
        'urgentHealth': true,
        'status': 0,
        'distinctDevices': 2,
      });

      final list = [rank2, rank1]..sort(IncidentModel.compareByPriority);
      expect(list.first.id, '2');
      expect(list.first.rank, 1);
      expect(list.last.id, '1');
    });

    test('Falls back to Golden Rule when backend rank is absent', () {
      final highOutage = IncidentModel.fromJson({
        'id': '1',
        'neighborhoodId': 'nb-1',
        'neighborhoodName': 'الشرقية',
        'priorityScore': 88.5,
        'UrgentHealth': false,
        'IsRepeat': false,
        'state': 'Confirmed',
        'DistinctDevices': 9,
        'MaxDurationDays': 4,
      });

      final urgentContamination = IncidentModel.fromJson({
        'id': '2',
        'neighborhoodId': 'nb-2',
        'neighborhoodName': 'المنصورة',
        'priorityScore': 45.7,
        'UrgentHealth': true,
        'IsRepeat': false,
        'state': 'New',
        'DistinctDevices': 2,
        'MaxDurationDays': 1,
      });

      final list = [highOutage, urgentContamination]
        ..sort(IncidentModel.compareByPriority);

      expect(list.first.id, '2');
      expect(list.first.urgentHealth, isTrue);
      expect(list.first.priorityLevel, PriorityLevel.urgentHealth);
      expect(list.last.id, '1');
    });

    test('Parses backend timestamps without Z as UTC converted to local', () {
      final withoutZ = ReportModel.parseApiUtcDate('2026-11-25T23:17:31.433');
      final withZ = ReportModel.parseApiUtcDate('2026-11-25T23:17:31.433Z');

      expect(withoutZ, isNotNull);
      expect(withZ, isNotNull);
      expect(withoutZ!.isUtc, isFalse);
      expect(withoutZ.toUtc(), equals(withZ!.toUtc()));
    });

    test('NeighborhoodModel parses Lat/Lng and live nameAr field', () {
      final liveNb = NeighborhoodModel.fromJson({
        'id': 6,
        'nameAr': 'الديس - الهجرة والجوازات',
        'lat': 14.5485,
        'lng': 49.1312,
      });

      expect(liveNb.id, '6');
      expect(liveNb.name, 'الديس - الهجرة والجوازات');
      expect(liveNb.lat, 14.5485);
      expect(liveNb.lng, 49.1312);
    });

    test('PredictionModel parses nested details and detects prior-only basis', () {
      final priorPred = PredictionModel.fromJson({
        'neighborhoodId': 6,
        'source': 'model',
        'modelVersion': 'unknown',
        'generatedAtUtc': '2026-11-22T14:01:48.8108693Z',
        'details': {
          'cycleMean': 2.0,
          'ci90': [1.2, 2.8],
          'probArrival2d': 0.85,
          'probLate': 0.0,
          'abnormalDelay': false,
          'basis': '0 observations (Prior only)',
        },
      });

      expect(priorPred.isPriorOnly, isTrue);
      expect(priorPred.cycleMean, 2.0);
      expect(priorPred.ci90Low, 1.2);
      expect(priorPred.ci90High, 2.8);

      final learnedPred = PredictionModel.fromJson({
        'neighborhoodId': 6,
        'source': 'model',
        'details': {
          'cycleMean': 2.1,
          'ci90': [1.4, 2.8],
          'probArrival2d': 0.05,
          'probLate': 0.96,
          'abnormalDelay': true,
          'basis': '6 observations (Gradient Boosting)',
        },
      });

      expect(learnedPred.isPriorOnly, isFalse);
      expect(learnedPred.abnormalDelay, isTrue);
      expect(learnedPred.probLate, 0.96);
    });

    test('IncidentModel parses live RankedIncident payload including reports', () {
      final liveIncident = IncidentModel.fromJson({
        'incidentId': 1,
        'neighborhoodId': 6,
        'neighborhoodNameAr': 'الديس - الهجرة والجوازات',
        'issueType': 0,
        'status': 0,
        'distinctDevices': 5,
        'maxDurationDays': 6,
        'isRepeat': false,
        'urgentHealth': false,
        'lastReportAt': '2026-11-21T19:57:31.7761373',
        'createdAt': '2026-11-21T13:06:41.0036289',
        'score': 70.2,
        'rank': 1,
        'explanation': 'حالة انقطاع المياه في حي الديس',
        'explanationFromModel': true,
        'prediction': {
          'neighborhoodId': 6,
          'source': 'model',
          'details': {
            'cycleMean': 2.0,
            'ci90': [1.2, 2.8],
            'probArrival2d': 0.01,
            'probLate': 1.0,
            'abnormalDelay': true,
            'basis': '0 observations (Prior only)',
          },
        },
        'reports': [
          {
            'id': 11,
            'rawText': 'الماء مقطوع من ستة أيام',
            'issueType': 0,
            'durationDays': 6,
            'createdAt': '2026-11-21T19:57:31.7761373',
          },
        ],
      });

      expect(liveIncident.id, '1');
      expect(liveIncident.neighborhoodName, 'الديس - الهجرة والجوازات');
      expect(liveIncident.rank, 1);
      expect(liveIncident.explanationFromModel, isTrue);
      expect(liveIncident.embeddedPrediction?.abnormalDelay, isTrue);
      expect(liveIncident.reports, hasLength(1));
      expect(liveIncident.reports.first.text, 'الماء مقطوع من ستة أيام');
      expect(liveIncident.reports.first.category, AppStrings.outageIssue);
    });
  });

  group('Qatrah DashboardView Smoke Test', () {
    testWidgets(
      'Renders simplified map/cards, opens details with verdict & reports, and removes resolved incident',
      (tester) async {
        tester.view.physicalSize = const Size(1440, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        final cubit = DashboardCubit(
          DashboardRepository(apiService: ApiService()),
        )..loadDemoData();

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: BlocProvider.value(
                value: cubit,
                child: const DashboardView(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text(AppStrings.needMapTitle), findsOneWidget);
        expect(find.text('المنصورة'), findsWidgets);
        expect(find.text('الشرقية'), findsWidgets);
        final initialCount = cubit.state.incidents.length;
        final initialQuiet = cubit.state.quietNeighborhoodsCount;

        // Open details for selected neighborhood (الشرقية)
        await tester.tap(find.text(AppStrings.openDetails));
        await tester.pumpAndSettle();

        expect(find.text(AppStrings.backToMap), findsOneWidget);
        expect(find.text(AppStrings.whyThisNeighborhoodTitle), findsOneWidget);
        expect(find.text(AppStrings.predictionQuestionTitle), findsOneWidget);
        expect(find.text(AppStrings.abnormalDelayVerdict), findsOneWidget);
        expect(find.text(AppStrings.linkedReportsTitle), findsOneWidget);

        // Expand collapsible statistical details
        await tester.tap(find.text(AppStrings.showStatisticalDetails));
        await tester.pumpAndSettle();
        expect(find.text(AppStrings.ci90Label), findsOneWidget);

        // Resolve incident from top header action — must remove it immediately
        await tester.tap(find.text(AppStrings.stateResolved));
        await tester.pumpAndSettle();

        expect(cubit.state.incidents.length, initialCount - 1);
        expect(cubit.state.quietNeighborhoodsCount, initialQuiet + 1);
        expect(cubit.state.isDetailsOpen, isFalse);
        await cubit.close();
      },
    );
  });
}
