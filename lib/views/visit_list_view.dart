import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/visit_record.dart';
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

  void _openDetail(BuildContext context, VisitRecord visit) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VisitDetailView(visit: visit),
      ),
    );
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
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
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
                      Row(
                        children: [
                          if (Navigator.canPop(context)) ...[
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            '📸 MEMORIES',
                            style: AppTypography.displayLarge.copyWith(color: Colors.white),
                          ),
                        ],
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.photo_library_outlined,
                          size: 64,
                          color: Colors.white38,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No memories yet',
                          style: AppTypography.headlineMedium.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Snap a photo or tap + to create your first memory record.',
                          style: AppTypography.bodySmall.copyWith(color: Colors.white60),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
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
    return GestureDetector(
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
              // Full-bleed Image Background
              CustomThumbnail(
                imageFileName: widget.visit.imageFileName,
                size: double.infinity,
                borderRadius: 12.0,
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
    );
  }
}
