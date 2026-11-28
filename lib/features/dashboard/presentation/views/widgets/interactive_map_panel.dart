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
  bool _focusMainCluster = true;

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  void _toggleClusterFocus() {
    setState(() {
      _focusMainCluster = !_focusMainCluster;
      _transformationController.value = Matrix4.identity();
    });
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
    final clusterResult = _analyzeGeographicCluster(widget.state.neighborhoods);

    // If user explicitly selects an outlier neighborhood, automatically show all
    final selectedIsOutlier =
        selectedNeighborhood != null &&
        clusterResult.outlierIds.contains(selectedNeighborhood.id);
    final effectiveFocusCluster =
        clusterResult.hasOutliers && _focusMainCluster && !selectedIsOutlier;

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
                      maxScale: 3.2,
                      boundaryMargin: const EdgeInsets.all(40),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return _GeoNeighborhoodCanvas(
                            size: Size(
                              constraints.maxWidth,
                              constraints.maxHeight,
                            ),
                            state: widget.state,
                            boundsNeighborhoods: effectiveFocusCluster
                                ? clusterResult.coreNeighborhoods
                                : widget.state.neighborhoods,
                            visibleNeighborhoods: effectiveFocusCluster
                                ? clusterResult.coreNeighborhoods
                                : widget.state.neighborhoods,
                            onNeighborhoodTap: widget.onNeighborhoodTap,
                          );
                        },
                      ),
                    ),
                    // Map Toolbar Controls (Zoom Reset + Cluster/All Toggle when outliers exist)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (clusterResult.hasOutliers) ...[
                            Material(
                              color: AppColor.surface.withValues(alpha: 0.94),
                              borderRadius: BorderRadius.circular(8),
                              child: InkWell(
                                onTap: _toggleClusterFocus,
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 7,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        effectiveFocusCluster
                                            ? Icons.zoom_out_map_rounded
                                            : Icons.filter_center_focus_rounded,
                                        size: 16,
                                        color: AppColor.primaryDark,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        effectiveFocusCluster
                                            ? AppStrings.showAllNeighborhoods
                                            : AppStrings.focusMainCluster,
                                        style: context.textTheme.bodySmall
                                            ?.copyWith(
                                              color: AppColor.primaryDark,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Material(
                            color: AppColor.surface.withValues(alpha: 0.94),
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
                        ],
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

          // Simplified Selected Neighborhood Action Bar
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

class _ClusterAnalysis {
  const _ClusterAnalysis({
    required this.coreNeighborhoods,
    required this.outlierIds,
  });

  final List<NeighborhoodModel> coreNeighborhoods;
  final Set<String> outlierIds;

  bool get hasOutliers => outlierIds.isNotEmpty;
}

/// Detects distant geographic outliers (e.g. Al-Shihr vs Mukalla cluster) so the
/// map can fit-bounds cleanly onto the main urban cluster while preserving 100%
/// truthful linear geographic distances.
_ClusterAnalysis _analyzeGeographicCluster(List<NeighborhoodModel> items) {
  if (items.length < 4) {
    return _ClusterAnalysis(coreNeighborhoods: items, outlierIds: const {});
  }

  final sortedLats = items.map((e) => e.lat).toList()..sort();
  final sortedLngs = items.map((e) => e.lng).toList()..sort();
  final medLat = sortedLats[sortedLats.length ~/ 2];
  final medLng = sortedLngs[sortedLngs.length ~/ 2];
  final cosLat = math.cos(medLat * math.pi / 180.0).abs().clamp(0.1, 1.0);

  double geoDist(NeighborhoodModel nb) {
    final dLat = nb.lat - medLat;
    final dLng = (nb.lng - medLng) * cosLat;
    return math.sqrt(dLat * dLat + dLng * dLng);
  }

  final distances = items.map(geoDist).toList();
  final sortedDist = List<double>.from(distances)..sort();
  final medDist = sortedDist[sortedDist.length ~/ 2];
  if (medDist < 1e-6) {
    return _ClusterAnalysis(coreNeighborhoods: items, outlierIds: const {});
  }

  // Flag neighborhoods more than 3.5x the median distance from center as outliers
  final threshold = medDist * 3.5;
  final core = <NeighborhoodModel>[];
  final outliers = <String>{};

  for (var i = 0; i < items.length; i++) {
    if (distances[i] > threshold) {
      outliers.add(items[i].id);
    } else {
      core.add(items[i]);
    }
  }

  if (core.length < 2 || outliers.isEmpty) {
    return _ClusterAnalysis(coreNeighborhoods: items, outlierIds: const {});
  }

  return _ClusterAnalysis(coreNeighborhoods: core, outlierIds: outliers);
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
    required this.boundsNeighborhoods,
    required this.visibleNeighborhoods,
    required this.onNeighborhoodTap,
  });

  final Size size;
  final DashboardState state;
  final List<NeighborhoodModel> boundsNeighborhoods;
  final List<NeighborhoodModel> visibleNeighborhoods;
  final ValueChanged<NeighborhoodModel> onNeighborhoodTap;

  @override
  Widget build(BuildContext context) {
    final projected = _projectHonestLinear(
      visibleNeighborhoods,
      boundsNeighborhoods,
      size,
    );

    // Draw quiet markers underneath active incident markers
    final orderedIndices =
        List<int>.generate(visibleNeighborhoods.length, (i) => i)
          ..sort((a, b) {
            final incA = state.incidentForNeighborhood(
              visibleNeighborhoods[a].id,
            );
            final incB = state.incidentForNeighborhood(
              visibleNeighborhoods[b].id,
            );
            final activeA = incA != null ? 1 : 0;
            final activeB = incB != null ? 1 : 0;
            if (activeA != activeB) return activeA.compareTo(activeB);
            final selA =
                visibleNeighborhoods[a].id == state.selectedNeighborhoodId
                ? 1
                : 0;
            final selB =
                visibleNeighborhoods[b].id == state.selectedNeighborhoodId
                ? 1
                : 0;
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
              neighborhood: visibleNeighborhoods[index],
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
        ? 62.0
        : (incident.priorityScore >= 70 ? 70.0 : 58.0);

    final outerDiameter = hasActiveIncident
        ? markerDiameter + 12
        : markerDiameter;
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
                      color: AppColor.surface.withValues(alpha: 0.88),
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
    if (incident == null) {
      return '${nb.name}\n${AppStrings.noActiveIncidentInNeighborhood}';
    }
    final durationPart = incident.maxDurationDays > 0
        ? ' · ${AppStrings.daysDurationLabel(incident.maxDurationDays)}'
        : '';
    return '${nb.name} · ${incident.state.arabicLabel}\n'
        '${incident.displayIssueType} · ${AppStrings.devicesCountLabel(incident.distinctDevices)}$durationPart';
  }

  /// Honest linear geographic projection preserving true aspect ratio via
  /// cos(midLat) scaling so distances and compass directions are never distorted.
  List<Offset> _projectHonestLinear(
    List<NeighborhoodModel> items,
    List<NeighborhoodModel> boundsItems,
    Size canvasSize,
  ) {
    if (items.isEmpty) return const [];

    const horizontalPad = 78.0;
    const verticalPad = 68.0;
    final usableW = math.max(canvasSize.width - horizontalPad * 2, 40.0);
    final usableH = math.max(canvasSize.height - verticalPad * 2, 40.0);

    if (items.length == 1 || boundsItems.isEmpty) {
      return List<Offset>.filled(
        items.length,
        Offset(canvasSize.width / 2, canvasSize.height / 2),
      );
    }

    var minLat = boundsItems.first.lat;
    var maxLat = boundsItems.first.lat;
    var minLng = boundsItems.first.lng;
    var maxLng = boundsItems.first.lng;

    for (final nb in boundsItems) {
      if (nb.lat < minLat) minLat = nb.lat;
      if (nb.lat > maxLat) maxLat = nb.lat;
      if (nb.lng < minLng) minLng = nb.lng;
      if (nb.lng > maxLng) maxLng = nb.lng;
    }

    final midLat = (minLat + maxLat) / 2.0;
    final cosLat = math.cos(midLat * math.pi / 180.0).abs().clamp(0.1, 1.0);

    final geoW = (maxLng - minLng).abs() * cosLat;
    final geoH = (maxLat - minLat).abs();

    if (geoW < 1e-6 && geoH < 1e-6) {
      return List<Offset>.filled(
        items.length,
        Offset(canvasSize.width / 2, canvasSize.height / 2),
      );
    }

    // Uniform scale preserving aspect ratio while centering inside usable canvas
    final scaleX = geoW > 1e-6 ? usableW / geoW : double.infinity;
    final scaleY = geoH > 1e-6 ? usableH / geoH : double.infinity;
    final scale = math.min(scaleX, scaleY);

    final drawnW = geoW * scale;
    final drawnH = geoH * scale;
    final offsetX = horizontalPad + (usableW - drawnW) / 2;
    final offsetY = verticalPad + (usableH - drawnH) / 2;

    return List<Offset>.generate(items.length, (i) {
      final nb = items[i];
      final x = offsetX + ((nb.lng - minLng) * cosLat) * scale;
      final y = offsetY + (maxLat - nb.lat) * scale;
      return Offset(x, y);
    });
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
                      fontSize: diameter >= 68 ? 15 : 13.5,
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
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (incident != null) ...[
              if (incident!.urgentHealth)
                const StatusBadge(
                  label: AppStrings.priorityUrgentHealth,
                  backgroundColor: AppColor.urgentHealth,
                  foregroundColor: AppColor.onPrimary,
                  icon: Icons.warning_amber_rounded,
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
