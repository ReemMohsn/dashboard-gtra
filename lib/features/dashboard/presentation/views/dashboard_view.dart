import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gtra_dashboard/core/constants/app_strings.dart';
import 'package:gtra_dashboard/core/extensions/screen_context_extension.dart';
import 'package:gtra_dashboard/core/extensions/snack_bar_context_extension.dart';
import 'package:gtra_dashboard/core/themes/app_color.dart';
import 'package:gtra_dashboard/core/themes/app_theme.dart';
import 'package:gtra_dashboard/features/dashboard/presentation/view_model/dashboard_cubit.dart';
import 'package:gtra_dashboard/features/dashboard/presentation/view_model/dashboard_state.dart';
import 'package:gtra_dashboard/features/dashboard/presentation/views/widgets/dashboard_top_bar.dart';
import 'package:gtra_dashboard/features/dashboard/presentation/views/widgets/incident_details_panel.dart';
import 'package:gtra_dashboard/features/dashboard/presentation/views/widgets/interactive_map_panel.dart';
import 'package:gtra_dashboard/features/dashboard/presentation/views/widgets/priority_sidebar.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DashboardCubit, DashboardState>(
      listenWhen: (previous, current) =>
          previous.stateUpdateSuccessMessage !=
              current.stateUpdateSuccessMessage ||
          previous.stateUpdateErrorMessage != current.stateUpdateErrorMessage,
      listener: (context, state) {
        if (state.stateUpdateSuccessMessage != null) {
          context.showSuccessSnackBar(state.stateUpdateSuccessMessage!);
          context.read<DashboardCubit>().clearFeedbackMessages();
        } else if (state.stateUpdateErrorMessage != null) {
          context.showErrorSnackBar(state.stateUpdateErrorMessage!);
          context.read<DashboardCubit>().clearFeedbackMessages();
        }
      },
      builder: (context, state) {
        final cubit = context.read<DashboardCubit>();

        return Scaffold(
          body: Column(
            children: [
              DashboardTopBar(
                isDemoMode: state.isDemoMode,
                isLoading:
                    state.dashboardStatus == DashboardRequestStatus.loading,
                onRefresh: () {
                  if (state.isDemoMode) {
                    cubit.loadDemoData();
                  } else {
                    cubit.loadDashboard();
                  }
                },
                onToggleLiveMode: cubit.loadDashboard,
              ),
              Expanded(child: _buildBody(context, state, cubit)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    DashboardState state,
    DashboardCubit cubit,
  ) {
    if (state.dashboardStatus == DashboardRequestStatus.loading &&
        state.neighborhoods.isEmpty &&
        state.incidents.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              AppStrings.loadingDashboard,
              style: context.textTheme.bodyLarge?.copyWith(
                color: AppColor.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (state.dashboardStatus == DashboardRequestStatus.failure &&
        state.neighborhoods.isEmpty &&
        state.incidents.isEmpty) {
      return _DashboardErrorState(
        errorMessage:
            state.dashboardErrorMessage ?? AppStrings.unableToLoadDashboard,
        onRetry: cubit.loadDashboard,
        onLoadDemo: cubit.loadDemoData,
      );
    }

    final isDesktop = context.isDesktop;

    if (isDesktop) {
      return Padding(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 370,
              child: PrioritySidebar(
                state: state,
                onFilterChanged: cubit.setFilter,
                onIncidentSelected: (incident) =>
                    cubit.selectIncident(incident),
              ),
            ),
            const SizedBox(width: AppTheme.spaceLg),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: state.isDetailsOpen
                    ? IncidentDetailsPanel(
                        key: ValueKey('details-${state.selectedIncidentId}'),
                        state: state,
                        onBackToMap: cubit.closeDetails,
                        onRetryDetails: cubit.retryIncidentDetails,
                        onRetryPrediction: cubit.retryPrediction,
                        onChangeState: cubit.updateIncidentState,
                      )
                    : InteractiveMapPanel(
                        key: const ValueKey('interactive-map'),
                        state: state,
                        onNeighborhoodTap: cubit.selectNeighborhood,
                        onOpenDetails: cubit.openSelectedIncidentDetails,
                      ),
              ),
            ),
          ],
        ),
      );
    }

    // Responsive Tablet / Mobile Stacked Layout
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.isDetailsOpen)
            IncidentDetailsPanel(
              state: state,
              onBackToMap: cubit.closeDetails,
              onRetryDetails: cubit.retryIncidentDetails,
              onRetryPrediction: cubit.retryPrediction,
              onChangeState: cubit.updateIncidentState,
            )
          else
            SizedBox(
              height: 460,
              child: InteractiveMapPanel(
                state: state,
                onNeighborhoodTap: cubit.selectNeighborhood,
                onOpenDetails: cubit.openSelectedIncidentDetails,
              ),
            ),
          const SizedBox(height: AppTheme.spaceLg),
          PrioritySidebar(
            state: state,
            shrinkWrap: true,
            onFilterChanged: cubit.setFilter,
            onIncidentSelected: (incident) => cubit.selectIncident(incident),
          ),
        ],
      ),
    );
  }
}

class _DashboardErrorState extends StatelessWidget {
  const _DashboardErrorState({
    required this.errorMessage,
    required this.onRetry,
    required this.onLoadDemo,
  });

  final String errorMessage;
  final VoidCallback onRetry;
  final VoidCallback onLoadDemo;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        margin: const EdgeInsets.all(AppTheme.spaceLg),
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        decoration: AppTheme.cardDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: AppColor.primarySoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 32,
                color: AppColor.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: context.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.offlineDemoHint,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text(AppStrings.retry),
                ),
                OutlinedButton.icon(
                  onPressed: onLoadDemo,
                  icon: const Icon(Icons.science_outlined, size: 18),
                  label: const Text(AppStrings.loadDemoData),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
