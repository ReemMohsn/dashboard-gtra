import 'package:flutter/material.dart';
import 'package:gtra_dashboard/core/constants/app_strings.dart';
import 'package:gtra_dashboard/core/themes/app_color.dart';
import 'package:gtra_dashboard/features/dashboard/data/models/incident_enums.dart';

class IncidentStateActions extends StatelessWidget {
  const IncidentStateActions({
    super.key,
    required this.currentState,
    required this.isUpdating,
    required this.updatingTargetState,
    required this.onChangeState,
    this.compact = false,
  });

  final IncidentState currentState;
  final bool isUpdating;
  final IncidentState? updatingTargetState;
  final ValueChanged<IncidentState> onChangeState;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isInProgressCurrent = currentState == IncidentState.inProgress;
    final isResolvedCurrent = currentState == IncidentState.resolved;

    final buttonStyleElevated = compact
        ? ElevatedButton.styleFrom(
            minimumSize: const Size(0, 38),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          )
        : null;
    final buttonStyleOutlined = compact
        ? OutlinedButton.styleFrom(
            minimumSize: const Size(0, 38),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          )
        : null;

    final inProgressButton = ElevatedButton(
      style: buttonStyleElevated,
      onPressed: isUpdating || isInProgressCurrent
          ? null
          : () => onChangeState(IncidentState.inProgress),
      child: _ButtonLabel(
        label: AppStrings.stateInProgress,
        isBusy:
            isUpdating && updatingTargetState == IncidentState.inProgress,
        isActiveCurrent: isInProgressCurrent,
        spinnerColor: AppColor.onPrimary,
      ),
    );

    final resolvedButton = OutlinedButton(
      style: buttonStyleOutlined,
      onPressed: isUpdating || isResolvedCurrent
          ? null
          : () => onChangeState(IncidentState.resolved),
      child: _ButtonLabel(
        label: AppStrings.stateResolved,
        isBusy: isUpdating && updatingTargetState == IncidentState.resolved,
        isActiveCurrent: isResolvedCurrent,
        spinnerColor: AppColor.primary,
      ),
    );

    if (compact) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [inProgressButton, resolvedButton],
      );
    }

    return Row(
      children: [
        Expanded(child: inProgressButton),
        const SizedBox(width: 12),
        Expanded(child: resolvedButton),
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
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2, color: spinnerColor),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isActiveCurrent) ...[
          const Icon(Icons.check_rounded, size: 16),
          const SizedBox(width: 5),
        ],
        Text(label),
      ],
    );
  }
}
