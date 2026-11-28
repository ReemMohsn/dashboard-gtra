import 'package:flutter/material.dart';
import 'package:gtra_dashboard/core/common/widgets/qatrah_logo.dart';
import 'package:gtra_dashboard/core/common/widgets/status_badge.dart';
import 'package:gtra_dashboard/core/constants/app_strings.dart';
import 'package:gtra_dashboard/core/extensions/screen_context_extension.dart';
import 'package:gtra_dashboard/core/themes/app_color.dart';
import 'package:gtra_dashboard/core/themes/app_theme.dart';

class DashboardTopBar extends StatelessWidget {
  const DashboardTopBar({
    super.key,
    required this.isDemoMode,
    required this.isLoading,
    required this.onRefresh,
    required this.onToggleLiveMode,
  });

  final bool isDemoMode;
  final bool isLoading;
  final VoidCallback onRefresh;
  final VoidCallback onToggleLiveMode;

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;

    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: AppColor.surface,
        border: Border(bottom: BorderSide(color: AppColor.border)),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppTheme.spaceMd : AppTheme.spaceLg,
      ),
      child: Row(
        children: [
          // Brand Identity (Right side in RTL)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const QatrahLogo(size: 28),
              const SizedBox(width: 10),
              Text(
                isMobile ? AppStrings.appName : AppStrings.dashboardTitle,
                style: context.textTheme.titleLarge?.copyWith(
                  fontSize: isMobile ? 16 : 17,
                  color: AppColor.textPrimary,
                ),
              ),
            ],
          ),
          const Spacer(),

          // Status / Actions / Authority Pill (Left side in RTL)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isMobile) ...[
                InkWell(
                  borderRadius: BorderRadius.circular(AppTheme.pillRadius),
                  onTap: isDemoMode ? onToggleLiveMode : onRefresh,
                  child: StatusBadge(
                    label: isDemoMode
                        ? AppStrings.demoDataMode
                        : AppStrings.liveDataMode,
                    backgroundColor: isDemoMode
                        ? AppColor.escalatingBg
                        : AppColor.primarySoft,
                    foregroundColor: isDemoMode
                        ? AppColor.escalatingText
                        : AppColor.primaryDark,
                    borderColor: isDemoMode
                        ? AppColor.escalatingBorder
                        : AppColor.primaryBorder,
                    icon: isDemoMode
                        ? Icons.science_outlined
                        : Icons.cloud_done_outlined,
                    tooltip: isDemoMode
                        ? AppStrings.reconnectLiveApi
                        : AppStrings.refreshData,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              IconButton(
                tooltip: AppStrings.refreshData,
                onPressed: isLoading ? null : onRefresh,
                icon: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(
                        Icons.refresh_rounded,
                        color: AppColor.textSecondary,
                      ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColor.surfaceSoft,
                  borderRadius: BorderRadius.circular(AppTheme.pillRadius),
                  border: Border.all(color: AppColor.borderSubtle),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: AppColor.primarySoft,
                      child: Text(
                        AppStrings.authorityAvatarLetter,
                        style: context.textTheme.labelMedium?.copyWith(
                          color: AppColor.primaryDark,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (!isMobile) ...[
                      const SizedBox(width: 8),
                      Text(
                        AppStrings.authorityBadge,
                        style: context.textTheme.labelMedium?.copyWith(
                          color: AppColor.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
