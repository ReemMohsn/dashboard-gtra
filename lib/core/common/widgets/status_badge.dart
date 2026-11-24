import 'package:flutter/material.dart';
import 'package:gtra_dashboard/core/themes/app_theme.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    this.borderColor,
    this.icon,
    this.tooltip,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;
  final IconData? icon;
  final String? tooltip;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final badge = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.pillRadius),
        border: borderColor != null ? Border.all(color: borderColor!) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: foregroundColor),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: foregroundColor,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );

    if (tooltip != null && tooltip!.isNotEmpty) {
      return Tooltip(message: tooltip!, child: badge);
    }
    return badge;
  }
}
