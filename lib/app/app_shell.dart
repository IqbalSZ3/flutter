import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/locale/app_strings.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../core/widgets/animated_scale_button.dart';
import 'package:flutter_animate/flutter_animate.dart';

// Global state to track active tab inside BillsScreen
final ValueNotifier<int> billsTabNotifier = ValueNotifier<int>(0);

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      floatingActionButton: _PremiumFab(
        onTap: () {
          final currentIndex = navigationShell.currentIndex;
          if (currentIndex == 2) {
            // We are on Bills screen
            if (billsTabNotifier.value == 0) {
              context.push('/add-installment');
            } else {
              context.push('/add-subscription');
            }
          } else {
            // Home, Analysis, Settings
            context.push('/add-transaction');
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final currentIndex = navigationShell.currentIndex;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.sidebar,
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _buildNavItem(
                context,
                index: 0,
                icon: Icons.home_rounded,
                activeIcon: Icons.home_rounded,
                label: context.tr('nav_home'),
                isSelected: currentIndex == 0,
              ),
              _buildNavItem(
                context,
                index: 1,
                icon: Icons.bar_chart_outlined,
                activeIcon: Icons.bar_chart_rounded,
                label: context.tr('nav_analysis'),
                isSelected: currentIndex == 1,
              ),
              const Expanded(child: SizedBox()), // space for FAB
              _buildNavItem(
                context,
                index: 2,
                icon: Icons.receipt_long_outlined,
                activeIcon: Icons.receipt_long_rounded,
                label: context.tr('nav_bills'),
                isSelected: currentIndex == 2,
              ),
              _buildNavItem(
                context,
                index: 3,
                icon: Icons.tune_outlined,
                activeIcon: Icons.tune_rounded,
                label: context.tr('nav_settings'),
                isSelected: currentIndex == 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isSelected,
  }) {
    return Expanded(
      child: AnimatedScaleButton(
        scaleFactor: 0.92,
        onTap: () => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Dot indicator for active state
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                width: isSelected ? 4 : 4,
                height: 4,
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
              ),
              Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? AppColors.primary : AppColors.textTertiary,
                size: 22,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: AppTypography.textTheme.labelSmall?.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textTertiary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// FAB dengan solid silver, no gradient
class _PremiumFab extends StatelessWidget {
  final VoidCallback onTap;

  const _PremiumFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedScaleButton(
      onTap: onTap,
      scaleFactor: 0.9,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.add_rounded,
          color: AppColors.onPrimary,
          size: 26,
        ),
      ),
    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
     .scale(begin: const Offset(1, 1), end: const Offset(1.03, 1.03), duration: 2.seconds, curve: Curves.easeInOut);
  }
}
