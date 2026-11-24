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
import 'package:gtra_dashboard/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:gtra_dashboard/features/dashboard/presentation/view_model/dashboard_cubit.dart';
import 'package:gtra_dashboard/features/dashboard/presentation/views/dashboard_view.dart';

void main() {
  group('Qatrah Dashboard Models & Golden Rule', () {
    test('UrgentHealth always tops priority list regardless of numeric score', () {
      final highOutage = IncidentModel.fromJson({
        'id': '1',
        'neighborhoodId': 'nb-1',
        'neighborhoodName': 'الشرقية',
        'priorityScore': 88.5,
        'UrgentHealth': false,
        'Escalating': true,
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
        'Escalating': false,
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

    test('NeighborhoodModel parses Lat/Lng and live nameAr field', () {
      final nb = NeighborhoodModel.fromJson({
        'Id': 10,
        'Name': 'الشرقية',
        'Lat': 12.866,
        'Lng': 44.994,
      });

      expect(nb.id, '10');
      expect(nb.name, 'الشرقية');
      expect(nb.lat, 12.866);
      expect(nb.lng, 44.994);

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

    test('PredictionModel parses flat and live nested details payloads', () {
      final pred = PredictionModel.fromJson({
        'neighborhoodId': 'nb-1',
        'cycleMean': 8.7,
        'ci90': [7.8, 9.7],
        'probArrival2d': 0.24,
        'probLate': 0.81,
        'abnormalDelay': true,
        'basis': 6,
      });

      expect(pred.cycleMean, 8.7);
      expect(pred.ci90Low, 7.8);
      expect(pred.ci90High, 9.7);
      expect(pred.probArrival2d, 0.24);
      expect(pred.probLate, 0.81);
      expect(pred.abnormalDelay, isTrue);
      expect(pred.basis, '6 ملاحظات');

      final livePred = PredictionModel.fromJson({
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

      expect(livePred.neighborhoodId, '6');
      expect(livePred.source, 'model');
      expect(livePred.modelVersion, 'unknown');
      expect(livePred.generatedAtUtc, isNotNull);
      expect(livePred.cycleMean, 2.0);
      expect(livePred.ci90Low, 1.2);
      expect(livePred.ci90High, 2.8);
      expect(livePred.probArrival2d, 0.85);
      expect(livePred.probLate, 0.0);
      expect(livePred.abnormalDelay, isFalse);
      expect(livePred.basis, '0 observations (Prior only)');
    });

    test('IncidentModel parses live RankedIncident payload including embedded prediction', () {
      final liveIncident = IncidentModel.fromJson({
        'incidentId': 1,
        'neighborhoodId': 6,
        'neighborhoodNameAr': 'الديس - الهجرة والجوازات',
        'issueType': 0,
        'status': 0,
        'distinctDevices': 5,
        'maxDurationDays': null,
        'isRepeat': false,
        'urgentHealth': false,
        'lastReportAt': '2026-11-21T19:57:31.7761373',
        'createdAt': '2026-11-21T13:06:41.0036289',
        'score': 70.2,
        'rank': 1,
        'explanation': 'حالة انقطاع المياه في حي الديس - الهجرة والجوازات',
        'explanationFromModel': false,
        'prediction': {
          'neighborhoodId': 6,
          'source': 'model',
          'modelVersion': 'unknown',
          'generatedAtUtc': '2026-11-22T14:01:48.8108699Z',
          'details': {
            'cycleMean': 2.0,
            'ci90': [1.2, 2.8],
            'probArrival2d': 0.85,
            'probLate': 0.0,
            'abnormalDelay': false,
            'basis': '0 observations (Prior only)',
          },
        },
      });

      expect(liveIncident.id, '1');
      expect(liveIncident.neighborhoodId, '6');
      expect(liveIncident.neighborhoodName, 'الديس - الهجرة والجوازات');
      expect(liveIncident.issueType, IssueType.outage);
      expect(liveIncident.displayIssueType, AppStrings.outageIssue);
      expect(liveIncident.state, IncidentState.newIncident);
      expect(liveIncident.distinctDevices, 5);
      expect(liveIncident.maxDurationDays, 0.0);
      expect(liveIncident.priorityScore, 70.2);
      expect(liveIncident.rank, 1);
      expect(liveIncident.explanationFromModel, isFalse);
      expect(liveIncident.embeddedPrediction, isNotNull);
      expect(liveIncident.embeddedPrediction!.cycleMean, 2.0);
      expect(liveIncident.embeddedPrediction!.probArrival2d, 0.85);
    });

    test('IncidentState and IssueType support integer apiCode round-trip', () {
      for (final state in IncidentState.values) {
        expect(IncidentState.fromApi(state.apiCode), state);
        expect(IncidentState.fromApi('${state.apiCode}'), state);
      }
      expect(IncidentState.newIncident.apiCode, 0);
      expect(IncidentState.confirmed.apiCode, 1);
      expect(IncidentState.inProgress.apiCode, 2);
      expect(IncidentState.resolved.apiCode, 3);
      expect(IncidentState.expired.apiCode, 4);

      for (final type in IssueType.values) {
        expect(IssueType.fromApi(type.apiCode), type);
        expect(IssueType.fromApi('${type.apiCode}'), type);
      }
      expect(IssueType.outage.apiCode, 0);
      expect(IssueType.contamination.apiCode, 1);
      expect(IssueType.fromApi('Contamination'), IssueType.contamination);
      expect(IssueType.fromApi('WaterOutage'), IssueType.outage);
    });
  });

  group('Qatrah DashboardView Smoke Test', () {
    testWidgets('Renders map, opens incident details, and updates state in demo mode', (
      tester,
    ) async {
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

      // Map view and ranked priority cards render
      expect(find.text(AppStrings.needMapTitle), findsOneWidget);
      expect(find.text('المنصورة'), findsWidgets);
      expect(find.text('الشرقية'), findsWidgets);

      // Open details for selected neighborhood (الشرقية)
      await tester.tap(find.text(AppStrings.openDetails));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.backToMap), findsOneWidget);
      expect(find.text(AppStrings.explanationTitle), findsOneWidget);
      expect(find.text(AppStrings.predictionTitle), findsOneWidget);
      expect(find.text(AppStrings.abnormalDelayBadge), findsOneWidget);

      // Transition state to Resolved
      await tester.tap(find.text(AppStrings.stateResolved));
      await tester.pumpAndSettle();

      expect(cubit.state.selectedIncident?.state, IncidentState.resolved);
      await cubit.close();
    });
  });
}
