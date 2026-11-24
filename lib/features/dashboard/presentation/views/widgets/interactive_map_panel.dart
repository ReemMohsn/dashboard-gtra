import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gtra_dashboard/core/common/widgets/status_badge.dart';
import 'package:gtra_dashboard/core/constants/app_strings.dart';
import 'package:gtra_dashboard/core/extensions/screen_context_extension.dart';
import 'package:gtra_dashboard/core/themes/app_color.dart';
import 'package:gtra_dashboard/core/themes/app_theme.dart';
import 'package:gtra_dashboard/features/dashboard/data/models/incident_model.dart';
import 'package:gtra_dashboard/features/dashboard/data/models/neighborhood_model.dart';
import 'package:gtra_dashboard/features/dashboard/presentation/view_model/dashboard_state.dart';

class InteractiveMapPanel extends StatefulWidget {
  const InteractiveMapPanel({
    super.key,
    required this.state,
    required this.onNeighborhoodTap,
    required this.onOpenDetails,
  });

  final DashboardState state;
  final ValueChanged<NeighborhoodModel> onNeighborhoodTap;
  final VoidCallback onOpenDetails;

  @override
  State<InteractiveMapPanel> createState() => _InteractiveMapPanelState();
}

class _InteractiveMapPanelState extends State<InteractiveMapPanel> {
  final TransformationController _transformationController =
      TransformationController();

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedNeighborhood = widget.state.selectedNeighborhood;
    final selectedIncident = widget.state.selectedIncident;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Map Title + Priority Legend
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              Text(
                AppStrings.needMapTitle,
                style: context.textTheme.headlineSmall?.copyWith(
                  color: AppColor.textPrimary,
                ),
              ),
              const _MapLegend(),
            ],
          ),
          const SizedBox(height: 14),

          // Interactive Map Viewport
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.innerCardRadius),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColor.mapBackground,
                  borderRadius: BorderRadius.circular(AppTheme.innerCardRadius),
                  border: Border.all(color: AppColor.borderSubtle),
                ),
                child: Stack(
                  children: [
                    InteractiveViewer(
                      transformationController: _transformationController,
                      minScale: 0.85,
                      maxScale: 2.8,
                      boundaryMargin: const EdgeInsets.all(40),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return _GeoNeighborhoodCanvas(
                            size: Size(
                              constraints.maxWidth,
                              constraints.maxHeight,
                            ),
                            state: widget.state,
                            onNeighborhoodTap: widget.onNeighborhoodTap,
                          );
                        },
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Material(
                        color: AppColor.surface.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          onTap: _resetZoom,
                          borderRadius: BorderRadius.circular(8),
                          child: const Tooltip(
                            message: AppStrings.resetMapView,
                            child: Padding(
                              padding: EdgeInsets.all(7),
                              child: Icon(
                                Icons.center_focus_strong_rounded,
                                size: 18,
                                color: AppColor.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Text(
              AppStrings.mapInteractiveHint,
              style: context.textTheme.bodySmall?.copyWith(fontSize: 11.5),
            ),
          ),
          const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 12),

          // Selected Neighborhood Action Bar (matches PDF Page 6 footer)
          _SelectedNeighborhoodBar(
            neighborhood: selectedNeighborhood,
            incident: selectedIncident,
            onOpenDetails: widget.onOpenDetails,
          ),
        ],
      ),
    );
  }
}

class _MapLegend extends StatelessWidget {
  const _MapLegend();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: const [
        _LegendDot(
          color: AppColor.urgentHealth,
          label: AppStrings.priorityUrgentHealth,
        ),
        _LegendDot(
          color: AppColor.priorityHigh,
          label: AppStrings.priorityHigh,
        ),
        _LegendDot(
          color: AppColor.priorityMedium,
          label: AppStrings.priorityMedium,
        ),
        _LegendDot(
          color: AppColor.priorityLow,
          label: AppStrings.priorityLow,
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: AppColor.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _GeoNeighborhoodCanvas extends StatelessWidget {
  const _GeoNeighborhoodCanvas({
    required this.size,
    required this.state,
    required this.onNeighborhoodTap,
  });

  final Size size;
  final DashboardState state;
  final ValueChanged<NeighborhoodModel> onNeighborhoodTap;

  @override
  Widget build(BuildContext context) {
    final neighborhoods = state.neighborhoods;
    final projected = _projectPoints(neighborhoods, size);

    // Draw quiet markers underneath active incident markers
    final orderedIndices = List<int>.generate(neighborhoods.length, (i) => i)
      ..sort((a, b) {
        final incA = state.incidentForNeighborhood(neighborhoods[a].id);
        final incB = state.incidentForNeighborhood(neighborhoods[b].id);
        final activeA = incA != null ? 1 : 0;
        final activeB = incB != null ? 1 : 0;
        if (activeA != activeB) return activeA.compareTo(activeB);
        final selA = neighborhoods[a].id == state.selectedNeighborhoodId ? 1 : 0;
        final selB = neighborhoods[b].id == state.selectedNeighborhoodId ? 1 : 0;
        return selA.compareTo(selB);
      });

    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _StylizedCityMapPainter()),
          ),
          for (final index in orderedIndices)
            _buildMarker(
              context: context,
              neighborhood: neighborhoods[index],
              position: projected[index],
            ),
        ],
      ),
    );
  }

  Widget _buildMarker({
    required BuildContext context,
    required NeighborhoodModel neighborhood,
    required Offset position,
  }) {
    final incident = state.incidentForNeighborhood(neighborhood.id);
    final isSelected = neighborhood.id == state.selectedNeighborhoodId;
    final hasActiveIncident = incident != null;

    final markerDiameter = !hasActiveIncident
        ? (isSelected ? 18.0 : 12.0)
        : incident.urgentHealth
        ? 64.0
        : (incident.priorityScore >= 70 ? 74.0 : 60.0);

    final outerDiameter = hasActiveIncident ? markerDiameter + 12 : markerDiameter;
    final totalWidth = math.max(outerDiameter + 44, 118.0);

    return Positioned(
      left: position.dx - totalWidth / 2,
      top: position.dy - outerDiameter / 2,
      width: totalWidth,
      child: GestureDetector(
        onTap: () => onNeighborhoodTap(neighborhood),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Tooltip(
            message: _tooltipFor(neighborhood, incident),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!hasActiveIncident)
                  Container(
                    width: markerDiameter,
                    height: markerDiameter,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColor.primary
                          : AppColor.mapQuietMarker,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: AppColor.surface, width: 2.5)
                          : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColor.primary.withValues(alpha: 0.35),
                                blurRadius: 8,
                              ),
                            ]
                          : null,
                    ),
                  )
                else
                  _IncidentBubbleMarker(
                    incident: incident,
                    diameter: markerDiameter,
                    isSelected: isSelected,
                  ),
                if (hasActiveIncident || isSelected) ...[
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.surface.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      neighborhood.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.labelMedium?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColor.textPrimary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _tooltipFor(NeighborhoodModel nb, IncidentModel? incident) {
    final coords =
        '(${nb.lat.toStringAsFixed(4)}, ${nb.lng.toStringAsFixed(4)})';
    if (incident == null) {
      return '${nb.name}\n${AppStrings.noActiveIncidentInNeighborhood}\n$coords';
    }
    return '${nb.name} · ${incident.priorityLevel.arabicLabel} (${incident.priorityScore.toStringAsFixed(1)})\n'
        '${incident.state.arabicLabel} · ${AppStrings.devicesCountLabel(incident.distinctDevices)}\n$coords';
  }

  List<Offset> _projectPoints(List<NeighborhoodModel> items, Size canvasSize) {
    if (items.isEmpty) return const [];

    const horizontalPad = 78.0;
    const verticalPad = 68.0;
    final usableW = math.max(canvasSize.width - horizontalPad * 2, 40.0);
    final usableH = math.max(canvasSize.height - verticalPad * 2, 40.0);

    if (items.length == 1) {
      return [Offset(canvasSize.width / 2, canvasSize.height / 2)];
    }

    var minLat = items.first.lat;
    var maxLat = items.first.lat;
    var minLng = items.first.lng;
    var maxLng = items.first.lng;

    for (final nb in items) {
      if (nb.lat < minLat) minLat = nb.lat;
      if (nb.lat > maxLat) maxLat = nb.lat;
      if (nb.lng < minLng) minLng = nb.lng;
      if (nb.lng > maxLng) maxLng = nb.lng;
    }

    final latSpan = (maxLat - minLat).abs();
    final lngSpan = (maxLng - minLng).abs();

    final linearX = List<double>.generate(items.length, (i) {
      return lngSpan < 0.00001
          ? (i + 1) / (items.length + 1)
          : (items[i].lng - minLng) / lngSpan;
    });
    final linearY = List<double>.generate(items.length, (i) {
      return latSpan < 0.00001
          ? 0.5
          : 1.0 - ((items[i].lat - minLat) / latSpan);
    });

    final useClusterSpreadX = _isClusteredAxis(linearX);
    final useClusterSpreadY = _isClusteredAxis(linearY);

    final rankX = useClusterSpreadX ? _computeRankNorms(linearX) : null;
    final rankY = useClusterSpreadY ? _computeRankNorms(linearY) : null;

    return List<Offset>.generate(items.length, (i) {
      final normX = rankX != null
          ? (0.35 * linearX[i] + 0.65 * rankX[i])
          : linearX[i];
      final normY = rankY != null
          ? (0.35 * linearY[i] + 0.65 * rankY[i])
          : linearY[i];

      return Offset(
        horizontalPad + normX * usableW,
        verticalPad + normY * usableH,
      );
    });
  }

  bool _isClusteredAxis(List<double> norms) {
    if (norms.length < 4) return false;
    final sorted = List<double>.from(norms)..sort();
    final majorityCount = (sorted.length ~/ 2) + 1;
    for (var i = 0; i <= sorted.length - majorityCount; i++) {
      if (sorted[i + majorityCount - 1] - sorted[i] < 0.30) {
        return true;
      }
    }
    return false;
  }

  List<double> _computeRankNorms(List<double> values) {
    final n = values.length;
    if (n <= 1) return List<double>.filled(n, 0.5);
    final indices = List<int>.generate(n, (i) => i)
      ..sort((a, b) => values[a].compareTo(values[b]));
    final ranks = List<double>.filled(n, 0.0);
    for (var rank = 0; rank < n; rank++) {
      ranks[indices[rank]] = rank / (n - 1);
    }
    return ranks;
  }
}

class _IncidentBubbleMarker extends StatelessWidget {
  const _IncidentBubbleMarker({
    required this.incident,
    required this.diameter,
    required this.isSelected,
  });

  final IncidentModel incident;
  final double diameter;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final outerSize = diameter + 12;
    final bubbleColor = incident.priorityLevel.color;

    return SizedBox(
      width: outerSize,
      height: outerSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (incident.urgentHealth)
            CustomPaint(
              size: Size.square(outerSize),
              painter: _DashedCirclePainter(
                color: isSelected ? AppColor.primary : AppColor.urgentHealth,
                strokeWidth: isSelected ? 2.6 : 2.2,
              ),
            )
          else if (isSelected)
            Container(
              width: outerSize,
              height: outerSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColor.primary, width: 2.8),
              ),
            ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: diameter,
            height: diameter,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bubbleColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: bubbleColor.withValues(alpha: 0.34),
                  blurRadius: isSelected ? 14 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: incident.urgentHealth
                ? const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColor.onPrimary,
                    size: 26,
                  )
                : Text(
                    incident.priorityScore.toStringAsFixed(1),
                    style: context.textTheme.titleSmall?.copyWith(
                      color: AppColor.onPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: diameter >= 70 ? 15.5 : 13.5,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SelectedNeighborhoodBar extends StatelessWidget {
  const _SelectedNeighborhoodBar({
    required this.neighborhood,
    required this.incident,
    required this.onOpenDetails,
  });

  final NeighborhoodModel? neighborhood;
  final IncidentModel? incident;
  final VoidCallback onOpenDetails;

  @override
  Widget build(BuildContext context) {
    if (neighborhood == null && incident == null) {
      return Text(
        AppStrings.mapInteractiveHint,
        style: context.textTheme.bodyMedium,
      );
    }

    final displayName = incident?.neighborhoodName ?? neighborhood?.name ?? '';

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 10,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 10,
          runSpacing: 6,
          children: [
            Text(
              AppStrings.selectedNeighborhood,
              style: context.textTheme.bodySmall?.copyWith(
                color: AppColor.textMuted,
              ),
            ),
            Text(
              displayName,
              style: context.textTheme.titleMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (incident != null) ...[
              Text(
                incident!.priorityScore.toStringAsFixed(1),
                style: context.textTheme.titleMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColor.textPrimary,
                ),
              ),
              StatusBadge(
                label: incident!.priorityLevel.arabicLabel,
                backgroundColor: incident!.priorityLevel.color,
                foregroundColor: AppColor.onPrimary,
                icon: incident!.urgentHealth
                    ? Icons.warning_amber_rounded
                    : null,
              ),
              StatusBadge(
                label: incident!.state.arabicLabel,
                backgroundColor: incident!.state.color,
                foregroundColor: AppColor.onPrimary,
              ),
            ] else
              StatusBadge(
                label: AppStrings.noActiveIncidentInNeighborhood,
                backgroundColor: AppColor.surfaceSoft,
                foregroundColor: AppColor.textSecondary,
                borderColor: AppColor.border,
              ),
          ],
        ),
        if (incident != null)
          ElevatedButton(
            onPressed: onOpenDetails,
            child: const Text(AppStrings.openDetails),
          ),
      ],
    );
  }
}

class _StylizedCityMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Waterway curve inspired by Qatrah PDF map backdrop
    final riverPaint = Paint()
      ..color = AppColor.mapWaterway
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final riverPath = Path()
      ..moveTo(-20, size.height * 0.28)
      ..cubicTo(
        size.width * 0.25,
        size.height * 0.34,
        size.width * 0.42,
        size.height * 0.14,
        size.width * 0.65,
        size.height * 0.32,
      )
      ..cubicTo(
        size.width * 0.80,
        size.height * 0.42,
        size.width * 0.90,
        size.height * 0.36,
        size.width + 20,
        size.height * 0.28,
      );
    canvas.drawPath(riverPath, riverPaint);

    // Subtle urban arterial roads
    final roadPaint = Paint()
      ..color = AppColor.mapRoad.withValues(alpha: 0.88)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..isAntiAlias = true;

    canvas.drawLine(
      Offset(size.width * 0.14, 0),
      Offset(size.width * 0.22, size.height),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.48, 0),
      Offset(size.width * 0.56, size.height),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.80, 0),
      Offset(size.width * 0.74, size.height),
      roadPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.66),
      Offset(size.width, size.height * 0.58),
      roadPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DashedCirclePainter extends CustomPainter {
  const _DashedCirclePainter({
    required this.color,
    required this.strokeWidth,
  });

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: radius,
    );

    const dashCount = 18;
    const sweepPerSegment = (2 * math.pi) / dashCount;
    const dashSweep = sweepPerSegment * 0.55;

    for (var i = 0; i < dashCount; i++) {
      canvas.drawArc(rect, i * sweepPerSegment, dashSweep, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
