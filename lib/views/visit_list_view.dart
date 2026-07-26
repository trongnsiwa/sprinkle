import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/visit_record.dart';
import '../services/image_service.dart';
import '../utils/colors.dart';
import '../utils/date_formatter.dart';
import '../utils/typography.dart';
import '../viewmodels/visit_list_viewmodel.dart';
import '../widgets/custom_thumbnail.dart';
import '../widgets/sprinkle_button.dart';
import '../widgets/star_rating.dart';
import 'add_edit_view.dart';
import 'visit_detail_view.dart';

class VisitListView extends ConsumerWidget {
  const VisitListView({super.key});

  void _openAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddEditView(),
    );
  }

  void _openDetail(BuildContext context, VisitRecord visit) async {
    File? imageFile;
    if (visit.imageFileName != null && visit.imageFileName!.isNotEmpty) {
      imageFile = await ImageService.getImageFile(visit.imageFileName!);
      if (imageFile != null && context.mounted) {
        await precacheImage(FileImage(imageFile), context);
      }
    }
    if (context.mounted) {
      Navigator.of(context).push(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 250),
          pageBuilder: (context, animation, secondaryAnimation) => VisitDetailView(
            visit: visit,
            resolvedImageFile: imageFile,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );
            return FadeTransition(
              opacity: curvedAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.05),
                  end: Offset.zero,
                ).animate(curvedAnimation),
                child: child,
              ),
            );
          },
        ),
      );
    }
  }

  void _confirmDelete(BuildContext context, VisitListViewModel viewModel, VisitRecord visit) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Delete Memory', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          'Are you sure you want to delete "${visit.name}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.maybePop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.maybePop(context, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      viewModel.deleteVisit(visit.uuid);
    }
  }

  Map<DateTime, List<VisitRecord>> _groupVisitsByDate(List<VisitRecord> visits) {
    final Map<DateTime, List<VisitRecord>> groups = {};
    for (final visit in visits) {
      final dateKey = DateTime(visit.timestamp.year, visit.timestamp.month, visit.timestamp.day);
      groups.putIfAbsent(dateKey, () => []).add(visit);
    }
    final sortedKeys = groups.keys.toList()..sort((a, b) => b.compareTo(a));
    final Map<DateTime, List<VisitRecord>> sortedGroups = {};
    for (final key in sortedKeys) {
      sortedGroups[key] = groups[key]!;
    }
    return sortedGroups;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visitsAsync = ref.watch(visitStreamProvider);
    final viewModel = ref.read(visitListViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      body: SafeArea(
        bottom: false,
        child: visitsAsync.when(
          data: (visits) {
            final List<Widget> slivers = [
              // Header App Bar
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '📸 MEMORIES',
                        style: AppTypography.displayLarge.copyWith(color: Colors.white),
                      ),
                      IconButton(
                        onPressed: () => _openAddSheet(context),
                        icon: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ];

            if (visits.isEmpty) {
              slivers.add(
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 1. Icon Container with Primary Glow
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withValues(alpha: 0.15),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.25),
                                  blurRadius: 24,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.photo_library_rounded,
                                size: 40,
                                color: Colors.white60,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // 2. Typography
                          Text(
                            'No memories yet',
                            style: AppTypography.headlineMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Capture your first memory to start your journal.',
                            style: AppTypography.bodySmall.copyWith(
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),

                          // 3. CTA Button
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: SprinkleButton(
                              onPressed: () => _openAddSheet(context),
                              label: 'Add First Memory',
                              isDark: true,
                              icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            } else {
              final grouped = _groupVisitsByDate(visits);
              for (final entry in grouped.entries) {
                final dateKey = entry.key;
                final groupVisits = entry.value;

                // Date Section Header
                slivers.add(
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(12, 16, 12, 6),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            dateKey.toShortDateString().toUpperCase(),
                            style: AppTypography.caption.copyWith(
                              color: Colors.white60,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Text(
                            '${groupVisits.length} ${groupVisits.length == 1 ? 'photo' : 'photos'}',
                            style: AppTypography.caption.copyWith(
                              color: Colors.white38,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );

                // Date Section 3-Column Grid
                slivers.add(
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 4,
                        crossAxisSpacing: 4,
                        childAspectRatio: 1.0,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final visit = groupVisits[index];
                          return _GridMemoryTile(
                            visit: visit,
                            onTap: () => _openDetail(context, visit),
                            onLongPress: () => _confirmDelete(context, viewModel, visit),
                          );
                        },
                        childCount: groupVisits.length,
                      ),
                    ),
                  ),
                );
              }

              // Bottom Spacer
              slivers.add(
                const SliverToBoxAdapter(
                  child: SizedBox(height: 32),
                ),
              );
            }

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: slivers,
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (err, stack) => Center(
            child: Text(
              'Error: $err',
              style: AppTypography.bodyLarge.copyWith(color: AppColors.error),
            ),
          ),
        ),
      ),
    );
  }
}

class _GridMemoryTile extends StatefulWidget {
  final VisitRecord visit;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _GridMemoryTile({
    required this.visit,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  State<_GridMemoryTile> createState() => _GridMemoryTileState();
}

class _GridMemoryTileState extends State<_GridMemoryTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: AnimatedScale(
          scale: _isPressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Full-bleed Image Background with Hero Animation
                Hero(
                  tag: 'memory_${widget.visit.uuid}',
                  child: CustomThumbnail(
                    imageFileName: widget.visit.imageFileName,
                    size: double.infinity,
                    borderRadius: 12.0,
                  ),
                ),

                // Gradient Overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.15),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.85),
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),

                // Bottom Overlay Info (Place Name & Star Rating)
                Positioned(
                  left: 6,
                  right: 6,
                  bottom: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.visit.name,
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          shadows: const [
                            Shadow(color: Colors.black87, blurRadius: 4),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.visit.rating > 0) ...[
                        const SizedBox(height: 2),
                        StarRating(rating: widget.visit.rating, starSize: 9.0),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
