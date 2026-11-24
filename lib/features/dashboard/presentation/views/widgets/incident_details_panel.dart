import 'package:flutter/material.dart';
import 'package:gtra_dashboard/core/common/widgets/status_badge.dart';
import 'package:gtra_dashboard/core/constants/app_strings.dart';
import 'package:gtra_dashboard/core/extensions/screen_context_extension.dart';
import 'package:gtra_dashboard/core/themes/app_color.dart';
import 'package:gtra_dashboard/core/themes/app_theme.dart';
import 'package:gtra_dashboard/features/dashboard/data/models/incident_enums.dart';
import 'package:gtra_dashboard/features/dashboard/data/models/incident_model.dart';
import 'package:gtra_dashboard/features/dashboard/data/models/report_model.dart';
import 'package:gtra_dashboard/features/dashboard/presentation/view_model/dashboard_state.dart';
import 'package:gtra_dashboard/features/dashboard/presentation/views/widgets/incident_state_actions.dart';
import 'package:gtra_dashboard/features/dashboard/presentation/views/widgets/prediction_section.dart';

class IncidentDetailsPanel extends StatelessWidget {
  const IncidentDetailsPanel({
    super.key,
    required this.state,
    required this.onBackToMap,
    required this.onRetryDetails,
    required this.onRetryPrediction,
    required this.onChangeState,
  });

  final DashboardState state;
  final VoidCallback onBackToMap;
  final VoidCallback onRetryDetails;
  final VoidCallback onRetryPrediction;
  final ValueChanged<IncidentState> onChangeState;

  @override
  Widget build(BuildContext context) {
    final incident = state.selectedIncident;
    if (incident == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: AppTheme.cardDecoration(),
        child: Center(
          child: Text(
            AppStrings.noActiveIncidents,
            style: context.textTheme.bodyLarge,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: AppTheme.cardDecoration(),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back to Map Button (matches PDF Page 7)
            Row(
              children: [
                TextButton.icon(
                  onPressed: onBackToMap,
                  icon: const Icon(Icons.chevron_left_rounded, size: 20),
                  label: const Text(AppStrings.backToMap),
                ),
                const Spacer(),
                if (state.detailsStatus == DashboardRequestStatus.loading)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppStrings.loadingDetails,
                        style: context.textTheme.bodySmall,
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Details fetch error notice (non-blocking if basic summary exists)
            if (state.detailsStatus == DashboardRequestStatus.failure &&
                state.detailsErrorMessage != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColor.abnormalDelayBg.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColor.abnormalDelayBorder),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: AppColor.abnormalDelayText,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.detailsErrorMessage!,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: AppColor.abnormalDelayText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: onRetryDetails,
                      child: const Text(AppStrings.retry),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Incident Header (Name + Badges + Priority Score)
            _IncidentDetailsHeader(incident: incident),
            const SizedBox(height: 20),

            // Two-Column Body (Desktop) or Single Column (Tablet/Mobile)
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 660;
                final primaryColumn = _PrimaryDetailsColumn(
                  incident: incident,
                  state: state,
                  onRetryPrediction: onRetryPrediction,
                  onChangeState: onChangeState,
                );
                final reportsColumn = _MergedReportsColumn(
                  reports: incident.reports,
                  isLoading:
                      state.detailsStatus == DashboardRequestStatus.loading &&
                      incident.reports.isEmpty,
                );

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 6, child: primaryColumn),
                      const SizedBox(width: 20),
                      Expanded(flex: 5, child: reportsColumn),
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    primaryColumn,
                    const SizedBox(height: 20),
                    reportsColumn,
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _IncidentDetailsHeader extends StatelessWidget {
  const _IncidentDetailsHeader({required this.incident});

  final IncidentModel incident;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 12,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            Text(
              incident.neighborhoodName,
              style: context.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 4),
            StatusBadge(
              label: incident.priorityLevel.arabicLabel,
              backgroundColor: incident.priorityLevel.color,
              foregroundColor: AppColor.onPrimary,
              icon: incident.urgentHealth ? Icons.warning_amber_rounded : null,
              tooltip: incident.urgentHealth
                  ? AppStrings.goldenRuleTooltip
                  : null,
            ),
            StatusBadge(
              label: incident.state.arabicLabel,
              backgroundColor: incident.state.color,
              foregroundColor: AppColor.onPrimary,
            ),
            if (incident.escalating)
              const StatusBadge(
                label: AppStrings.escalating,
                backgroundColor: AppColor.escalatingBg,
                foregroundColor: AppColor.escalatingText,
                borderColor: AppColor.escalatingBorder,
              ),
            if (incident.isRepeat)
              const StatusBadge(
                label: AppStrings.repeatIncident,
                backgroundColor: AppColor.repeatBg,
                foregroundColor: AppColor.repeatText,
                borderColor: AppColor.repeatBorder,
              ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              incident.priorityScore.toStringAsFixed(1),
              style: context.textTheme.headlineLarge?.copyWith(
                fontSize: 30,
                color: AppColor.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${AppStrings.outOfHundred} · ${incident.resolvedConfidenceLabel}',
              style: context.textTheme.bodySmall?.copyWith(
                color: AppColor.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PrimaryDetailsColumn extends StatelessWidget {
  const _PrimaryDetailsColumn({
    required this.incident,
    required this.state,
    required this.onRetryPrediction,
    required this.onChangeState,
  });

  final IncidentModel incident;
  final DashboardState state;
  final VoidCallback onRetryPrediction;
  final ValueChanged<IncidentState> onChangeState;

  @override
  Widget build(BuildContext context) {
    final explanationText =
        incident.explanation != null && incident.explanation!.trim().isNotEmpty
        ? incident.explanation!.trim()
        : AppStrings.noExplanationAvailable;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Neuro-Symbolic AI Explanation Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColor.explanationSurface,
            borderRadius: BorderRadius.circular(AppTheme.innerCardRadius),
            border: Border.all(color: AppColor.explanationBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.psychology_alt_outlined,
                    size: 18,
                    color: AppColor.primaryDark,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    AppStrings.explanationTitle,
                    style: context.textTheme.titleSmall?.copyWith(
                      color: AppColor.primaryDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                explanationText,
                style: context.textTheme.bodyLarge?.copyWith(
                  fontSize: 14.5,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // KPI Row (DistinctDevices, MaxDurationDays, LastReportAt)
        Row(
          children: [
            Expanded(
              child: _KpiMetricCard(
                value: '${incident.distinctDevices}',
                label: AppStrings.devicesKpiLabel,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _KpiMetricCard(
                value: incident.maxDurationDays > 0
                    ? AppStrings.daysDurationLabel(incident.maxDurationDays)
                    : AppStrings.notAvailableShort,
                label: AppStrings.maxOutageKpiLabel,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _KpiMetricCard(
                value: AppStrings.relativeTime(
                  incident.lastReportAt ?? incident.updatedAt,
                ),
                label: AppStrings.lastReportKpiLabel,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Prediction & Abnormal Delay Section
        PredictionSection(
          status: state.predictionStatus,
          prediction: state.prediction,
          errorMessage: state.predictionErrorMessage,
          onRetry: onRetryPrediction,
        ),
        const SizedBox(height: 18),

        // State Transition Controls (PATCH /api/incidents/{id}/state)
        IncidentStateActions(
          currentState: incident.state,
          isUpdating: state.isUpdatingState,
          updatingTargetState: state.updatingTargetState,
          onChangeState: onChangeState,
        ),
      ],
    );
  }
}

class _KpiMetricCard extends StatelessWidget {
  const _KpiMetricCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppColor.surfaceSoft,
        borderRadius: BorderRadius.circular(AppTheme.innerCardRadius),
        border: Border.all(color: AppColor.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.titleLarge?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColor.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _MergedReportsColumn extends StatelessWidget {
  const _MergedReportsColumn({
    required this.reports,
    required this.isLoading,
  });

  final List<ReportModel> reports;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              AppStrings.linkedReportsTitle,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColor.textPrimary,
              ),
            ),
            if (reports.isNotEmpty) ...[
              const SizedBox(width: 8),
              StatusBadge(
                label: '${reports.length}',
                backgroundColor: AppColor.primarySoft,
                foregroundColor: AppColor.primaryDark,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        if (isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          )
        else if (reports.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColor.surfaceSoft,
              borderRadius: BorderRadius.circular(AppTheme.innerCardRadius),
              border: Border.all(color: AppColor.borderSubtle),
            ),
            child: Text(
              AppStrings.noLinkedReports,
              style: context.textTheme.bodyMedium,
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: reports.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) => _ReportTile(report: reports[index]),
          ),
      ],
    );
  }
}

class _ReportTile extends StatelessWidget {
  const _ReportTile({required this.report});

  final ReportModel report;

  @override
  Widget build(BuildContext context) {
    final text = report.text.isNotEmpty
        ? '«${report.text}»'
        : '«بلاغ مسجّل بدون تفاصيل نصية إضافية»';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColor.surfaceMuted,
        borderRadius: BorderRadius.circular(AppTheme.innerCardRadius),
        border: Border.all(color: AppColor.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: context.textTheme.bodyLarge?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColor.textPrimary,
            ),
          ),
          if (report.category != null ||
              report.durationDays != null ||
              report.createdAt != null) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (report.category != null && report.category!.isNotEmpty)
                  Text(
                    report.category!,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: AppColor.primaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (report.durationDays != null && report.durationDays! > 0)
                  Text(
                    '· ${AppStrings.daysDurationLabel(report.durationDays!)}',
                    style: context.textTheme.bodySmall,
                  ),
                if (report.createdAt != null)
                  Text(
                    '· ${AppStrings.relativeTime(report.createdAt)}',
                    style: context.textTheme.bodySmall,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
