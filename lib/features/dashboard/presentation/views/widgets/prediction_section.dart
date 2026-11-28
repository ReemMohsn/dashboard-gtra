import 'package:flutter/material.dart';
import 'package:gtra_dashboard/core/constants/app_strings.dart';
import 'package:gtra_dashboard/core/extensions/screen_context_extension.dart';
import 'package:gtra_dashboard/core/themes/app_color.dart';
import 'package:gtra_dashboard/core/themes/app_theme.dart';
import 'package:gtra_dashboard/features/dashboard/data/models/prediction_model.dart';
import 'package:gtra_dashboard/features/dashboard/presentation/view_model/dashboard_state.dart';

class PredictionSection extends StatefulWidget {
  const PredictionSection({
    super.key,
    required this.status,
    required this.prediction,
    required this.errorMessage,
    required this.onRetry,
  });

  final DashboardRequestStatus status;
  final PredictionModel? prediction;
  final String? errorMessage;
  final VoidCallback onRetry;

  @override
  State<PredictionSection> createState() => _PredictionSectionState();
}

class _PredictionSectionState extends State<PredictionSection> {
  bool _showDetails = false;

  @override
  void didUpdateWidget(covariant PredictionSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.prediction?.neighborhoodId !=
        widget.prediction?.neighborhoodId) {
      _showDetails = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pred = widget.prediction;
    final hasData =
        widget.status == DashboardRequestStatus.success && pred != null;
    final isAbnormal = hasData && pred.abnormalDelay;
    final isInsufficient = hasData && !isAbnormal && pred.isPriorOnly;

    final Color bgColor = isAbnormal
        ? AppColor.abnormalDelayBg.withValues(alpha: 0.45)
        : isInsufficient
        ? AppColor.surfaceSoft
        : hasData
        ? AppColor.primarySoft.withValues(alpha: 0.4)
        : AppColor.surfaceSoft;

    final Color borderColor = isAbnormal
        ? AppColor.abnormalDelayBorder
        : isInsufficient
        ? AppColor.border
        : hasData
        ? AppColor.primaryBorder
        : AppColor.border;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppTheme.innerCardRadius),
        border: Border.all(
          color: borderColor,
          width: isAbnormal ? 1.4 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_graph_rounded,
                size: 18,
                color: isAbnormal
                    ? AppColor.abnormalDelayText
                    : AppColor.primaryDark,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppStrings.predictionQuestionTitle,
                  style: context.textTheme.titleSmall?.copyWith(
                    color: AppColor.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (widget.status == DashboardRequestStatus.loading ||
              widget.status == DashboardRequestStatus.initial)
            Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 10),
                Text(
                  AppStrings.predictionLoading,
                  style: context.textTheme.bodyMedium,
                ),
              ],
            )
          else if (widget.status == DashboardRequestStatus.failure ||
              pred == null)
            _PredictionFallback(
              errorMessage: widget.errorMessage,
              onRetry: widget.onRetry,
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Single Operational Verdict Headline
                _VerdictBanner(prediction: pred),
                const SizedBox(height: 8),

                // Collapsible Statistical Details Toggle
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () =>
                        setState(() => _showDetails = !_showDetails),
                    icon: Icon(
                      _showDetails
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 18,
                    ),
                    label: Text(
                      _showDetails
                          ? AppStrings.hideStatisticalDetails
                          : AppStrings.showStatisticalDetails,
                      style: context.textTheme.labelMedium?.copyWith(
                        color: AppColor.primaryDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                if (_showDetails) ...[
                  const SizedBox(height: 10),
                  _StatisticalDetailsGrid(prediction: pred),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _VerdictBanner extends StatelessWidget {
  const _VerdictBanner({required this.prediction});

  final PredictionModel prediction;

  @override
  Widget build(BuildContext context) {
    final bool isAbnormal = prediction.abnormalDelay;
    final bool isPriorOnly = prediction.isPriorOnly;

    final IconData icon;
    final Color accentColor;
    final String headline;
    final String subtitle;

    final cycleText = prediction.cycleMean != null
        ? '${prediction.cycleMean!.toStringAsFixed(1)} يوم'
        : AppStrings.notAvailableShort;

    if (isAbnormal) {
      icon = Icons.warning_amber_rounded;
      accentColor = AppColor.abnormalDelayText;
      headline = AppStrings.abnormalDelayVerdict;
      final latePart = prediction.probLate != null
          ? ' · ${AppStrings.probLateLabel}: ${AppStrings.percentageLabel(prediction.probLate!)}'
          : '';
      subtitle = 'الدورة المعتادة للحي نحو $cycleText$latePart';
    } else if (isPriorOnly) {
      icon = Icons.info_outline_rounded;
      accentColor = AppColor.textSecondary;
      headline = AppStrings.insufficientHistoryVerdict;
      subtitle = 'تقدير مبدئي للدورة: كل نحو $cycleText (دون ملاحظات سابقة للحي)';
    } else {
      icon = Icons.check_circle_outline_rounded;
      accentColor = AppColor.success;
      headline = AppStrings.normalCycleVerdict;
      final arrivalPart = prediction.probArrival2d != null
          ? ' · احتمال الوصول خلال يومين ${AppStrings.percentageLabel(prediction.probArrival2d!)}'
          : '';
      subtitle = 'الدورة المعتادة نحو $cycleText$arrivalPart';
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 20, color: accentColor),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                headline,
                style: context.textTheme.titleSmall?.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: context.textTheme.bodySmall?.copyWith(
                  color: AppColor.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatisticalDetailsGrid extends StatelessWidget {
  const _StatisticalDetailsGrid({required this.prediction});

  final PredictionModel prediction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _PredictionMetricChip(
              label: AppStrings.cycleMeanLabel,
              value: prediction.cycleMean != null
                  ? '${prediction.cycleMean!.toStringAsFixed(1)} يوم'
                  : AppStrings.notAvailableShort,
            ),
            _PredictionMetricChip(
              label: AppStrings.ci90Label,
              value: prediction.hasCi90
                  ? prediction.formattedCi90
                  : AppStrings.notAvailableShort,
            ),
            _PredictionMetricChip(
              label: AppStrings.probArrival2dLabel,
              value: prediction.probArrival2d != null
                  ? AppStrings.percentageLabel(prediction.probArrival2d!)
                  : AppStrings.notAvailableShort,
            ),
            _PredictionMetricChip(
              label: AppStrings.probLateLabel,
              value: prediction.probLate != null
                  ? AppStrings.percentageLabel(prediction.probLate!)
                  : AppStrings.notAvailableShort,
              highlightDanger:
                  prediction.abnormalDelay ||
                  (prediction.probLate != null &&
                      (prediction.probLate! > 0.6 ||
                          prediction.probLate! > 60)),
            ),
          ],
        ),
        if (prediction.basis != null && prediction.basis!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            '${AppStrings.basisLabel}: ${prediction.basis}',
            style: context.textTheme.bodySmall?.copyWith(
              color: AppColor.textMuted,
            ),
          ),
        ],
      ],
    );
  }
}

class _PredictionMetricChip extends StatelessWidget {
  const _PredictionMetricChip({
    required this.label,
    required this.value,
    this.highlightDanger = false,
  });

  final String label;
  final String value;
  final bool highlightDanger;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 112),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: highlightDanger
              ? AppColor.abnormalDelayBorder
              : AppColor.borderSubtle,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(fontSize: 11),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: highlightDanger
                  ? AppColor.abnormalDelayText
                  : AppColor.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PredictionFallback extends StatelessWidget {
  const _PredictionFallback({
    required this.errorMessage,
    required this.onRetry,
  });

  final String? errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(
          Icons.cloud_off_rounded,
          size: 20,
          color: AppColor.textMuted,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.predictionUnavailableTitle,
                style: context.textTheme.titleSmall?.copyWith(
                  color: AppColor.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                errorMessage != null &&
                        errorMessage != AppStrings.predictionUnavailableTitle
                    ? '$errorMessage — ${AppStrings.predictionUnavailableSubtitle}'
                    : AppStrings.predictionUnavailableSubtitle,
                style: context.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        TextButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded, size: 16),
          label: const Text(AppStrings.retry),
        ),
      ],
    );
  }
}
