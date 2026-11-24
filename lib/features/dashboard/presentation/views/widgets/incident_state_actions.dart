import 'package:flutter/material.dart';
import 'package:gtra_dashboard/core/constants/app_strings.dart';
import 'package:gtra_dashboard/core/extensions/screen_context_extension.dart';
import 'package:gtra_dashboard/core/themes/app_color.dart';
import 'package:gtra_dashboard/core/themes/app_theme.dart';
import 'package:gtra_dashboard/features/dashboard/data/models/incident_enums.dart';

class IncidentStateActions extends StatelessWidget {
  const IncidentStateActions({
    super.key,
    required this.currentState,
    required this.isUpdating,
    required this.updatingTargetState,
    required this.onChangeState,
  });

  final IncidentState currentState;
  final bool isUpdating;
  final IncidentState? updatingTargetState;
  final ValueChanged<IncidentState> onChangeState;

  @override
  Widget build(BuildContext context) {
    final isInProgressCurrent = currentState == IncidentState.inProgress;
    final isResolvedCurrent = currentState == IncidentState.resolved;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: isUpdating || isInProgressCurrent
                    ? null
                    : () => onChangeState(IncidentState.inProgress),
                child: _ButtonLabel(
                  label: AppStrings.stateInProgress,
                  isBusy:
                      isUpdating &&
                      updatingTargetState == IncidentState.inProgress,
                  isActiveCurrent: isInProgressCurrent,
                  spinnerColor: AppColor.onPrimary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: isUpdating || isResolvedCurrent
                    ? null
                    : () => onChangeState(IncidentState.resolved),
                child: _ButtonLabel(
                  label: AppStrings.stateResolved,
                  isBusy:
                      isUpdating &&
                      updatingTargetState == IncidentState.resolved,
                  isActiveCurrent: isResolvedCurrent,
                  spinnerColor: AppColor.primary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<IncidentState>(
              tooltip: AppStrings.moreStatesLabel,
              enabled: !isUpdating,
              onSelected: onChangeState,
              itemBuilder: (context) => IncidentState.values
                  .map(
                    (state) => PopupMenuItem<IncidentState>(
                      value: state,
                      enabled: state != currentState,
                      child: Row(
                        children: [
                          Container(
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                              color: state.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            state.arabicLabel,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: state == currentState
                                  ? AppColor.textMuted
                                  : AppColor.textPrimary,
                              fontWeight: state == currentState
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(growable: false),
              child: Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: AppColor.surfaceSoft,
                  borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                  border: Border.all(color: AppColor.border),
                ),
                child: const Icon(
                  Icons.more_vert_rounded,
                  color: AppColor.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ButtonLabel extends StatelessWidget {
  const _ButtonLabel({
    required this.label,
    required this.isBusy,
    required this.isActiveCurrent,
    required this.spinnerColor,
  });

  final String label;
  final bool isBusy;
  final bool isActiveCurrent;
  final Color spinnerColor;

  @override
  Widget build(BuildContext context) {
    if (isBusy) {
      return SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2, color: spinnerColor),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isActiveCurrent) ...[
          const Icon(Icons.check_rounded, size: 17),
          const SizedBox(width: 6),
        ],
        Text(label),
      ],
    );
  }
}
