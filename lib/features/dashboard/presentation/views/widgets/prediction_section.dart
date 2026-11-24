import 'package:flutter/material.dart';
import 'package:gtra_dashboard/core/common/widgets/status_badge.dart';
import 'package:gtra_dashboard/core/constants/app_strings.dart';
import 'package:gtra_dashboard/core/extensions/screen_context_extension.dart';
import 'package:gtra_dashboard/core/themes/app_color.dart';
import 'package:gtra_dashboard/core/themes/app_theme.dart';
import 'package:gtra_dashboard/features/dashboard/data/models/prediction_model.dart';
import 'package:gtra_dashboard/features/dashboard/presentation/view_model/dashboard_state.dart';

class PredictionSection extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final isAbnormal =
        status == DashboardRequestStatus.success &&
        (prediction?.abnormalDelay ?? false);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isAbnormal
            ? AppColor.abnormalDelayBg.withValues(alpha: 0.4)
            : AppColor.surfaceSoft,
        borderRadius: BorderRadius.circular(AppTheme.innerCardRadius),
        border: Border.all(
          color: isAbnormal ? AppColor.abnormalDelayBorder : AppColor.border,
          width: isAbnormal ? 1.3 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_graph_rounded,
                    size: 18,
                    color: isAbnormal
                        ? AppColor.abnormalDelayText
                        : AppColor.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppStrings.predictionTitle,
                    style: context.textTheme.titleSmall?.copyWith(
                      color: AppColor.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              if (status == DashboardRequestStatus.success &&
                  prediction != null)
                StatusBadge(
                  label: prediction!.abnormalDelay
                      ? AppStrings.abnormalDelayBadge
                      : AppStrings.normalCycleBadge,
                  backgroundColor: prediction!.abnormalDelay
                      ? AppColor.abnormalDelayBg
                      : AppColor.primarySoft,
                  foregroundColor: prediction!.abnormalDelay
                      ? AppColor.abnormalDelayText
                      : AppColor.primaryDark,
                  borderColor: prediction!.abnormalDelay
                      ? AppColor.abnormalDelayBorder
                      : AppColor.primaryBorder,
                  icon: prediction!.abnormalDelay
                      ? Icons.warning_amber_rounded
                      : Icons.check_circle_outline_rounded,
                ),
            ],
          ),
          const SizedBox(height: 12),

          if (status == DashboardRequestStatus.loading ||
              status == DashboardRequestStatus.initial)
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
          else if (status == DashboardRequestStatus.failure ||
              prediction == null)
            _PredictionFallback(
              errorMessage: errorMessage,
              onRetry: onRetry,
            )
          else
            _PredictionContent(prediction: prediction!),
        ],
      ),
    );
  }
}

class _PredictionContent extends StatelessWidget {
  const _PredictionContent({required this.prediction});

  final PredictionModel prediction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
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
          const SizedBox(height: 10),
          Text(
            '${AppStrings.basisLabel}: ${prediction.basis}',
            style: context.textTheme.bodySmall?.copyWith(
              color: AppColor.textSecondary,
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
      constraints: const BoxConstraints(minWidth: 120),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
