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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visitsAsync = ref.watch(visitStreamProvider);
    final viewModel = ref.read(visitListViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.neutralUltraLight,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // Header
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
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
                              color: AppColors.neutral,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 4),
                        ],
                        const Text(
                          '📸 MEMORIES',
                          style: AppTypography.displayLarge,
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

            // List Content
            visitsAsync.when(
              data: (visits) {
                if (visits.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.photo_library_outlined,
                            size: 64,
                            color: AppColors.neutralLight.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No memories yet',
                            style: AppTypography.headlineMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Snap a photo or tap + to create your first memory record.',
                            style: AppTypography.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: SprinkleButton(
                              onPressed: () => _openAddSheet(context),
                              label: 'Add First Memory',
                              icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: 32,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final visit = visits[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14.0),
                          child: Dismissible(
                            key: Key(visit.uuid),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (direction) async {
                              return await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: AppColors.surface,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  title: const Text('Delete Memory', style: AppTypography.headlineMedium),
                                  content: Text(
                                    'Are you sure you want to delete "${visit.name}"?',
                                    style: AppTypography.bodyLarge,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: Text(
                                        'Cancel',
                                        style: AppTypography.bodyLarge.copyWith(color: AppColors.neutralLight),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      child: Text(
                                        'Delete',
                                        style: AppTypography.bodyLarge.copyWith(
                                          color: AppColors.error,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            onDismissed: (direction) {
                              viewModel.deleteVisit(visit.uuid);
                            },
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            child: _MemoryCard(
                              visit: visit,
                              onTap: () => _openDetail(context, visit),
                            ),
                          ),
                        );
                      },
                      childCount: visits.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
              error: (err, stack) => SliverFillRemaining(
                child: Center(
                  child: Text(
                    'Error: $err',
                    style: AppTypography.bodyLarge.copyWith(color: AppColors.error),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddSheet(context),
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}

class _MemoryCard extends StatelessWidget {
  final VisitRecord visit;
  final VoidCallback onTap;

  const _MemoryCard({
    required this.visit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20.0), // rounded-lg
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Thumbnail (60x60pt, rounded-sm 12pt)
            CustomThumbnail(
              imageFileName: visit.imageFileName,
              size: 60.0,
              borderRadius: 12.0,
            ),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    visit.name,
                    style: AppTypography.headlineMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      StarRating(rating: visit.rating, starSize: 14.0),
                      const SizedBox(width: 8),
                      Text(
                        visit.timestamp.toShortDateString(),
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                  if (visit.tags.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: visit.tags.take(3).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Text(
                            '#$tag',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.neutralLight,
            ),
          ],
        ),
      ),
    );
  }
}
