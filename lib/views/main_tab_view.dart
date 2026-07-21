import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/colors.dart';
import '../utils/typography.dart';
import 'camera_view.dart';
import 'visit_list_view.dart';

final currentTabProvider = StateProvider<int>((ref) => 1); // 1 = Camera (default)

class MainTabView extends ConsumerWidget {
  const MainTabView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(currentTabProvider);

    final pages = [
      const FriendsPlaceholderView(),
      const CameraView(),
      const VisitListView(),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      extendBody: true,
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: _buildGlassNavigationBar(context, ref, selectedIndex),
    );
  }

  Widget _buildGlassNavigationBar(
    BuildContext context,
    WidgetRef ref,
    int selectedIndex,
  ) {
    return Container(
      color: Colors.transparent,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 0.5,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 56,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      ref,
                      index: 0,
                      icon: Icons.people_alt_rounded,
                      label: 'Friends',
                      isSelected: selectedIndex == 0,
                    ),
                    _buildNavItem(
                      ref,
                      index: 1,
                      icon: Icons.camera_alt_rounded,
                      label: 'Camera',
                      isSelected: selectedIndex == 1,
                    ),
                    _buildNavItem(
                      ref,
                      index: 2,
                      icon: Icons.grid_view_rounded,
                      label: 'Memories',
                      isSelected: selectedIndex == 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    WidgetRef ref, {
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    final color = isSelected ? AppColors.primary : AppColors.neutralLight;
    return InkWell(
      onTap: () {
        ref.read(currentTabProvider.notifier).state = index;
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: color,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class FriendsPlaceholderView extends StatelessWidget {
  const FriendsPlaceholderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.neutralUltraLight,
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.people_alt_rounded,
                  size: 36,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Friends Feed',
                style: AppTypography.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Coming soon! Share memories with your friends.',
                style: AppTypography.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
