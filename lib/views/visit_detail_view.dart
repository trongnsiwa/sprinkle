import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/visit_record.dart';
import '../services/image_service.dart';
import '../utils/colors.dart';
import '../utils/date_formatter.dart';
import '../utils/typography.dart';
import '../viewmodels/visit_list_viewmodel.dart';
import '../widgets/custom_thumbnail.dart';
import '../widgets/star_rating.dart';
import '../widgets/sprinkle_toast.dart';
import 'add_edit_view.dart';

class VisitDetailView extends ConsumerStatefulWidget {
  final VisitRecord visit;
  final File? resolvedImageFile;

  const VisitDetailView({
    super.key,
    required this.visit,
    this.resolvedImageFile,
  });

  @override
  ConsumerState<VisitDetailView> createState() => _VisitDetailViewState();
}

class _VisitDetailViewState extends ConsumerState<VisitDetailView> {
  late VisitRecord _currentVisit;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _currentVisit = widget.visit;
    _imageFile = widget.resolvedImageFile;
    if (_imageFile == null && _currentVisit.imageFileName != null && _currentVisit.imageFileName!.isNotEmpty) {
      ImageService.getImageFile(_currentVisit.imageFileName!).then((file) {
        if (mounted && file != null) {
          setState(() {
            _imageFile = file;
          });
        }
      });
    }
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
      if (_currentVisit.imageFileName != null && _currentVisit.imageFileName!.isNotEmpty) {
        final newFile = await ImageService.getImageFile(_currentVisit.imageFileName!);
        if (mounted && newFile != null) {
          setState(() {
            _imageFile = newFile;
          });
        }
      }
      ref.read(visitListViewModelProvider.notifier).fetchVisits();
    }
  }

  void _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Delete Memory', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          'Are you sure you want to delete "${_currentVisit.name}"?',
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

    if (confirm == true && mounted) {
      await ref.read(visitListViewModelProvider.notifier).deleteVisit(_currentVisit.uuid);
      if (mounted) {
        Navigator.maybePop(context);
      }
    }
  }

  Future<void> _openInMaps() async {
    final query = _currentVisit.address ?? _currentVisit.name;
    final encodedQuery = Uri.encodeComponent(query);
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedQuery');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          SprinkleToast.show(
            context,
            'Could not launch maps application',
            type: ToastType.error,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        SprinkleToast.show(
          context,
          'Error launching maps: $e',
          type: ToastType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Expandable Parallax Image Header
          SliverAppBar(
            expandedHeight: 340.0,
            pinned: true,
            backgroundColor: const Color(0xFF1C1C1E),
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () => Navigator.maybePop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: GestureDetector(
                  onTap: _openEditSheet,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: GestureDetector(
                  onTap: _confirmDelete,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.error,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Hero Image
                  Hero(
                    tag: 'memory_${_currentVisit.uuid}',
                    child: CustomThumbnail(
                      imageFileName: _currentVisit.imageFileName,
                      imageFile: _imageFile,
                      size: double.infinity,
                      borderRadius: 0,
                    ),
                  ),

                  // Bottom Gradient Overlay for text readability
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.3),
                          Colors.transparent,
                          const Color(0xFF1C1C1E).withValues(alpha: 0.95),
                        ],
                        stops: const [0.0, 0.4, 1.0],
                      ),
                    ),
                  ),

                  // Place Name Title at bottom of header
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 16,
                    child: Text(
                      _currentVisit.name,
                      style: AppTypography.displayLarge.copyWith(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        shadows: const [
                          Shadow(color: Colors.black87, blurRadius: 6),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Detail Content (Glass Info Cards)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Card 1: Rating, Date & Open in Maps
                _GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              StarRating(rating: _currentVisit.rating, starSize: 20.0),
                              const SizedBox(width: 8),
                              Text(
                                _currentVisit.rating > 0
                                    ? '${_currentVisit.rating.toStringAsFixed(1)} / 5.0'
                                    : 'No rating',
                                style: AppTypography.bodySmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            _currentVisit.timestamp.toFriendlyString(),
                            style: AppTypography.caption.copyWith(color: Colors.white60),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _openInMaps,
                          icon: const Icon(Icons.map_rounded, color: AppColors.secondary, size: 18),
                          label: Text(
                            'Open in Maps',
                            style: AppTypography.bodyLarge.copyWith(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: AppColors.secondary.withValues(alpha: 0.5),
                              width: 1.2,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Card 2: Tags
                if (_currentVisit.tags.isNotEmpty) ...[
                  _GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TAGS',
                          style: AppTypography.labelBold.copyWith(
                            color: AppColors.primary,
                            fontSize: 11,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _currentVisit.tags.map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(9999),
                                border: Border.all(
                                  color: AppColors.secondary.withValues(alpha: 0.3),
                                  width: 1.0,
                                ),
                              ),
                              child: Text(
                                '#$tag',
                                style: AppTypography.labelBold.copyWith(
                                  color: AppColors.secondary,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Card 3: Notes
                _GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NOTES',
                        style: AppTypography.labelBold.copyWith(
                          color: AppColors.primary,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        (_currentVisit.notes != null && _currentVisit.notes!.isNotEmpty)
                            ? _currentVisit.notes!
                            : 'No notes added for this memory.',
                        style: AppTypography.bodyLarge.copyWith(
                          color: (_currentVisit.notes != null && _currentVisit.notes!.isNotEmpty)
                              ? Colors.white
                              : Colors.white38,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;

  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
