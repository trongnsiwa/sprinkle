import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/visit_record.dart';
import '../utils/colors.dart';
import '../utils/date_formatter.dart';
import '../utils/typography.dart';
import '../viewmodels/visit_list_viewmodel.dart';
import '../widgets/custom_thumbnail.dart';
import '../widgets/star_rating.dart';
import 'add_edit_view.dart';

class VisitDetailView extends ConsumerStatefulWidget {
  final VisitRecord visit;

  const VisitDetailView({
    super.key,
    required this.visit,
  });

  @override
  ConsumerState<VisitDetailView> createState() => _VisitDetailViewState();
}

class _VisitDetailViewState extends ConsumerState<VisitDetailView> {
  late VisitRecord _currentVisit;

  @override
  void initState() {
    super.initState();
    _currentVisit = widget.visit;
  }

  void _openEditSheet() async {
    final updated = await showModalBottomSheet<VisitRecord>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddEditView(existingVisit: _currentVisit),
    );

    if (updated != null && mounted) {
      setState(() {
        _currentVisit = updated;
      });
      ref.read(visitListViewModelProvider.notifier).fetchVisits();
    }
  }

  void _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Delete Memory', style: AppTypography.headlineMedium),
        content: Text(
          'Are you sure you want to delete "${_currentVisit.name}"?',
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

    if (confirm == true && mounted) {
      await ref.read(visitListViewModelProvider.notifier).deleteVisit(_currentVisit.uuid);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralUltraLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.neutral),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: AppColors.primary),
            onPressed: _openEditSheet,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Large Hero Image
            Center(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 340),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0), // rounded-lg
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: CustomThumbnail(
                    imageFileName: _currentVisit.imageFileName,
                    size: MediaQuery.of(context).size.width - 40,
                    borderRadius: 20.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Store / Place Name
            Text(
              _currentVisit.name,
              style: AppTypography.headlineLarge,
            ),
            const SizedBox(height: 10),

            // Star Rating & Date Row
            Row(
              children: [
                StarRating(rating: _currentVisit.rating, starSize: 20.0),
                const SizedBox(width: 10),
                Text(
                  _currentVisit.rating > 0 ? '${_currentVisit.rating.toStringAsFixed(1)} / 5.0' : 'No rating',
                  style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              _currentVisit.timestamp.toFriendlyString(),
              style: AppTypography.caption,
            ),
            const SizedBox(height: 20),

            // Tags
            if (_currentVisit.tags.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _currentVisit.tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(9999), // Capsule
                    ),
                    child: Text(
                      '#$tag',
                      style: AppTypography.labelBold.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],

            // Notes Card
            if (_currentVisit.notes != null && _currentVisit.notes!.isNotEmpty) ...[
              const Text('NOTES', style: AppTypography.labelBold),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  _currentVisit.notes!,
                  style: AppTypography.bodyLarge,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
