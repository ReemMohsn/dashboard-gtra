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
    final borderColor = isSelected
        ? AppColor.primary
        : incident.urgentHealth
        ? AppColor.urgentHealth.withValues(alpha: 0.35)
        : AppColor.border;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.innerCardRadius),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColor.primarySoft.withValues(alpha: 0.38)
                : AppColor.surface,
            borderRadius: BorderRadius.circular(AppTheme.innerCardRadius),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 1.7 : 1,
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
              // Top row: Rank + Neighborhood Name + Score
              Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: incident.urgentHealth
                          ? AppColor.urgentHealthSoft
                          : AppColor.primarySoft,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      '$rank',
                      style: context.textTheme.labelMedium?.copyWith(
                        color: incident.urgentHealth
                            ? AppColor.urgentHealth
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
                        fontSize: 15.5,
                        color: AppColor.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    incident.priorityScore.toStringAsFixed(1),
                    style: context.textTheme.titleMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColor.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Badges row: Golden Rule / Priority + Confidence + State + Escalating + IsRepeat
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  StatusBadge(
                    label: incident.priorityLevel.arabicLabel,
                    backgroundColor: incident.priorityLevel.color,
                    foregroundColor: AppColor.onPrimary,
                    icon: incident.urgentHealth
                        ? Icons.warning_amber_rounded
                        : null,
                    tooltip: incident.urgentHealth
                        ? AppStrings.goldenRuleTooltip
                        : null,
                  ),
                  StatusBadge(
                    label: incident.resolvedConfidenceLabel,
                    backgroundColor: AppColor.neutralBadgeBg,
                    foregroundColor: AppColor.neutralBadgeText,
                    borderColor: AppColor.neutralBadgeBorder,
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
              const SizedBox(height: 10),

              // Metadata summary: issue type · devices · max duration
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _buildMetaSummary(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: AppColor.textSecondary,
                      ),
                    ),
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
    return parts.join(' · ');
  }
}
