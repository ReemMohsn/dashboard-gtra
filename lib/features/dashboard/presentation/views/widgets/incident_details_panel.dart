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
    this.shrinkWrap = false,
  });

  final DashboardState state;
  final VoidCallback onBackToMap;
  final VoidCallback onRetryDetails;
  final VoidCallback onRetryPrediction;
  final ValueChanged<IncidentState> onChangeState;
  final bool shrinkWrap;

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

    final bodyContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Non-blocking error notice if details refresh fails
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

        // Two-Column Body: (1) Why + Verdict, (2) Linked Reports
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 640;
            final primaryColumn = _PrimaryDetailsColumn(
              incident: incident,
              state: state,
              onRetryPrediction: onRetryPrediction,
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
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: shrinkWrap ? MainAxisSize.min : MainAxisSize.max,
        children: [
          // Fixed Top Bar: Back to Map + Loading Status
          Row(
            children: [
              TextButton.icon(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
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
          const SizedBox(height: 10),

          // Fixed Header: Neighborhood Name + Badges + State Actions right on top!
          _IncidentDetailsHeader(
            incident: incident,
            isUpdating: state.isUpdatingState,
            updatingTargetState: state.updatingTargetState,
            onChangeState: onChangeState,
          ),
          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 14),

          if (shrinkWrap)
            bodyContent
          else
            Expanded(child: SingleChildScrollView(child: bodyContent)),
        ],
      ),
    );
  }
}

class _IncidentDetailsHeader extends StatelessWidget {
  const _IncidentDetailsHeader({
    required this.incident,
    required this.isUpdating,
    required this.updatingTargetState,
    required this.onChangeState,
  });

  final IncidentModel incident;
  final bool isUpdating;
  final IncidentState? updatingTargetState;
  final ValueChanged<IncidentState> onChangeState;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 14,
      runSpacing: 10,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            Text(
              incident.neighborhoodName,
              style: context.textTheme.headlineMedium?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (incident.urgentHealth)
              const StatusBadge(
                label: AppStrings.priorityUrgentHealth,
                backgroundColor: AppColor.urgentHealth,
                foregroundColor: AppColor.onPrimary,
                icon: Icons.warning_amber_rounded,
                tooltip: AppStrings.goldenRuleTooltip,
              ),
            StatusBadge(
              label: incident.state.arabicLabel,
              backgroundColor: incident.state.color,
              foregroundColor: AppColor.onPrimary,
            ),
            if (incident.isRepeat)
              const StatusBadge(
                label: AppStrings.repeatIncident,
                backgroundColor: AppColor.repeatBg,
                foregroundColor: AppColor.repeatText,
                borderColor: AppColor.repeatBorder,
              ),
            Tooltip(
              message: AppStrings.scoreTooltip,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColor.surfaceMuted,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${incident.priorityScore.toStringAsFixed(1)} ${AppStrings.outOfHundred}',
                  style: context.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColor.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
        IncidentStateActions(
          currentState: incident.state,
          isUpdating: isUpdating,
          updatingTargetState: updatingTargetState,
          onChangeState: onChangeState,
          compact: true,
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
  });

  final IncidentModel incident;
  final DashboardState state;
  final VoidCallback onRetryPrediction;

  @override
  Widget build(BuildContext context) {
    final explanationText =
        incident.explanation != null && incident.explanation!.trim().isNotEmpty
        ? incident.explanation!.trim()
        : AppStrings.noExplanationAvailable;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section 1: "لماذا هذا الحي؟" (Explanation + Compact Facts Strip)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: AppColor.explanationSurface,
            borderRadius: BorderRadius.circular(AppTheme.innerCardRadius),
            border: Border.all(color: AppColor.explanationBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 6,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.psychology_alt_outlined,
                        size: 18,
                        color: AppColor.primaryDark,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        AppStrings.whyThisNeighborhoodTitle,
                        style: context.textTheme.titleSmall?.copyWith(
                          color: AppColor.primaryDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  StatusBadge(
                    label: incident.explanationFromModel
                        ? AppStrings.explanationFromAiBadge
                        : AppStrings.explanationFromTemplateBadge,
                    backgroundColor: AppColor.surface.withValues(alpha: 0.85),
                    foregroundColor: AppColor.textSecondary,
                    borderColor: AppColor.explanationBorder,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                explanationText,
                style: context.textTheme.bodyLarge?.copyWith(
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 12),
              // Single Compact Facts Strip (replaces redundant KPI boxes)
              Wrap(
                spacing: 14,
                runSpacing: 6,
                children: [
                  _CompactFact(
                    icon: Icons.devices_outlined,
                    text: AppStrings.devicesCountLabel(
                      incident.distinctDevices,
                    ),
                  ),
                  if (incident.maxDurationDays > 0)
                    _CompactFact(
                      icon: Icons.schedule_rounded,
                      text:
                          '${AppStrings.maxOutageKpiLabel}: ${AppStrings.daysDurationLabel(incident.maxDurationDays)}',
                    ),
                  _CompactFact(
                    icon: Icons.history_rounded,
                    text:
                        '${AppStrings.lastReportKpiLabel}: ${AppStrings.relativeTime(incident.lastReportAt ?? incident.updatedAt)}',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Section 2: "هل هو عطل أم انتظار طبيعي؟"
        PredictionSection(
          status: state.predictionStatus,
          prediction: state.prediction,
          errorMessage: state.predictionErrorMessage,
          onRetry: onRetryPrediction,
        ),
      ],
    );
  }
}

class _CompactFact extends StatelessWidget {
  const _CompactFact({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppColor.primaryDark),
        const SizedBox(width: 5),
        Text(
          text,
          style: context.textTheme.bodySmall?.copyWith(
            color: AppColor.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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
