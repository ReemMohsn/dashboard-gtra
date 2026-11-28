import 'package:flutter/material.dart';
import 'package:gtra_dashboard/core/common/widgets/status_badge.dart';
import 'package:gtra_dashboard/core/constants/app_strings.dart';
import 'package:gtra_dashboard/core/extensions/screen_context_extension.dart';
import 'package:gtra_dashboard/core/themes/app_color.dart';
import 'package:gtra_dashboard/core/themes/app_theme.dart';
import 'package:gtra_dashboard/features/dashboard/data/models/incident_model.dart';

class IncidentPriorityCard extends StatelessWidget {
  const IncidentPriorityCard({
    super.key,
    required this.rank,
    required this.incident,
    required this.isSelected,
    required this.onTap,
  });

  final int rank;
  final IncidentModel incident;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isAbnormalDelay = incident.embeddedPrediction?.abnormalDelay == true;

    final borderColor = isSelected
        ? AppColor.primary
        : incident.urgentHealth
        ? AppColor.urgentHealth.withValues(alpha: 0.55)
        : AppColor.border;

    final bgColor = isSelected
        ? AppColor.primarySoft.withValues(alpha: 0.38)
        : incident.urgentHealth
        ? AppColor.urgentHealthSoft.withValues(alpha: 0.45)
        : AppColor.surface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.innerCardRadius),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppTheme.innerCardRadius),
            border: Border.all(
              color: borderColor,
              width: isSelected || incident.urgentHealth ? 1.6 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColor.primary.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Rank + Neighborhood Name + Small Subtle Score
              Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: incident.urgentHealth
                          ? AppColor.urgentHealth
                          : AppColor.primarySoft,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      '$rank',
                      style: context.textTheme.labelMedium?.copyWith(
                        color: incident.urgentHealth
                            ? AppColor.onPrimary
                            : AppColor.primaryDark,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      incident.neighborhoodName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontSize: 15,
                        color: AppColor.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Tooltip(
                    message: AppStrings.scoreTooltip,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.surfaceMuted,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        incident.priorityScore.toStringAsFixed(1),
                        style: context.textTheme.bodySmall?.copyWith(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppColor.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Row 2: Key Facts (issue type · devices · duration · last report)
              Text(
                _buildMetaSummary(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontSize: 13,
                  color: AppColor.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 9),

              // Row 3: Actionable Badges Only (UrgentHealth / State / AbnormalDelay / Repeat)
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
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
                  if (isAbnormalDelay)
                    const StatusBadge(
                      label: AppStrings.abnormalDelayShort,
                      backgroundColor: AppColor.abnormalDelayBg,
                      foregroundColor: AppColor.abnormalDelayText,
                      borderColor: AppColor.abnormalDelayBorder,
                      icon: Icons.warning_amber_rounded,
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
            ],
          ),
        ),
      ),
    );
  }

  String _buildMetaSummary() {
    final parts = <String>[
      incident.displayIssueType,
      AppStrings.devicesCountLabel(incident.distinctDevices),
    ];
    if (incident.maxDurationDays > 0) {
      parts.add(AppStrings.daysDurationLabel(incident.maxDurationDays));
    }
    final lastAt = incident.lastReportAt ?? incident.updatedAt;
    if (lastAt != null) {
      parts.add(AppStrings.relativeTime(lastAt));
    }
    return parts.join(' · ');
  }
}
