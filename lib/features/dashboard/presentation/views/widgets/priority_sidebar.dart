import 'package:flutter/material.dart';
import 'package:gtra_dashboard/core/constants/app_strings.dart';
import 'package:gtra_dashboard/core/extensions/screen_context_extension.dart';
import 'package:gtra_dashboard/core/themes/app_color.dart';
import 'package:gtra_dashboard/core/themes/app_theme.dart';
import 'package:gtra_dashboard/features/dashboard/data/models/incident_enums.dart';
import 'package:gtra_dashboard/features/dashboard/data/models/incident_model.dart';
import 'package:gtra_dashboard/features/dashboard/presentation/view_model/dashboard_state.dart';
import 'package:gtra_dashboard/features/dashboard/presentation/views/widgets/incident_priority_card.dart';

class PrioritySidebar extends StatelessWidget {
  const PrioritySidebar({
    super.key,
    required this.state,
    required this.onFilterChanged,
    required this.onIncidentSelected,
    this.shrinkWrap = false,
  });

  final DashboardState state;
  final ValueChanged<DashboardFilter> onFilterChanged;
  final ValueChanged<IncidentModel> onIncidentSelected;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    final filtered = state.filteredIncidents;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: shrinkWrap ? MainAxisSize.min : MainAxisSize.max,
      children: [
        // Section Header
        Text(
          AppStrings.neighborhoodsByPriority,
          style: context.textTheme.headlineSmall?.copyWith(
            color: AppColor.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          state.isDemoMode ? AppStrings.demoSubtitle : AppStrings.liveSubtitle,
          style: context.textTheme.bodySmall,
        ),
        const SizedBox(height: 14),

        // Filter Chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: DashboardFilter.values
              .map((filter) {
                final isSelected = state.activeFilter == filter;
                final count = _countForFilter(filter);
                return _FilterPill(
                  label: count != null && filter != DashboardFilter.all
                      ? '${filter.label} ($count)'
                      : filter.label,
                  isSelected: isSelected,
                  onTap: () => onFilterChanged(filter),
                );
              })
              .toList(growable: false),
        ),
        const SizedBox(height: 14),

        // Ranked Incidents List
        if (filtered.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: AppTheme.cardDecoration(
              radius: AppTheme.innerCardRadius,
              elevated: false,
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.water_drop_outlined,
                  color: AppColor.textMuted,
                  size: 30,
                ),
                const SizedBox(height: 8),
                Text(
                  state.incidents.isEmpty
                      ? AppStrings.noActiveIncidents
                      : AppStrings.noIncidentsMatchFilter,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium,
                ),
              ],
            ),
          )
        else if (shrinkWrap)
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final incident = filtered[index];
              return IncidentPriorityCard(
                rank: index + 1,
                incident: incident,
                isSelected: incident.id == state.selectedIncidentId,
                onTap: () => onIncidentSelected(incident),
              );
            },
          )
        else
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: 12),
              itemCount: filtered.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final incident = filtered[index];
                return IncidentPriorityCard(
                  rank: index + 1,
                  incident: incident,
                  isSelected: incident.id == state.selectedIncidentId,
                  onTap: () => onIncidentSelected(incident),
                );
              },
            ),
          ),

        const SizedBox(height: 12),
        // Quiet Neighborhoods Footer
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            AppStrings.quietNeighborhoodsCount(state.quietNeighborhoodsCount),
            style: context.textTheme.bodySmall?.copyWith(
              color: AppColor.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  int? _countForFilter(DashboardFilter filter) {
    switch (filter) {
      case DashboardFilter.all:
        return state.incidents.length;
      case DashboardFilter.urgentHealth:
        return state.urgentHealthCount > 0 ? state.urgentHealthCount : null;
      case DashboardFilter.confirmed:
        return state.confirmedCount > 0 ? state.confirmedCount : null;
      case DashboardFilter.inProgress:
        return state.inProgressCount > 0 ? state.inProgressCount : null;
    }
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.pillRadius),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? AppColor.primary : AppColor.surface,
            borderRadius: BorderRadius.circular(AppTheme.pillRadius),
            border: Border.all(
              color: isSelected ? AppColor.primary : AppColor.border,
            ),
          ),
          child: Text(
            label,
            style: context.textTheme.labelMedium?.copyWith(
              color: isSelected ? AppColor.onPrimary : AppColor.textPrimary,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
