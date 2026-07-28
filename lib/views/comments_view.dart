import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/comment.dart';
import '../providers/engagement_providers.dart';
import '../services/supabase_service.dart';
import '../utils/colors.dart';
import '../utils/date_formatter.dart';
import '../utils/typography.dart';
import '../widgets/skeleton.dart';
import '../widgets/sprinkle_toast.dart';
import 'auth/login_view.dart';

class CommentsView extends ConsumerStatefulWidget {
  final String memoryUuid;

  const CommentsView({
    super.key,
    required this.memoryUuid,
  });

  @override
  ConsumerState<CommentsView> createState() => _CommentsViewState();
}

class _CommentsViewState extends ConsumerState<CommentsView> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isPosting = false;

  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _postComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _isPosting) return;

    if (SupabaseService.instance.currentUser == null) {
      SprinkleToast.show(
        context,
        'Log in to comment',
        type: ToastType.info,
      );
      return;
    }

    setState(() {
      _isPosting = true;
    });

    try {
      final newComment = await SupabaseService.instance.addComment(widget.memoryUuid, text);
      if (newComment != null && mounted) {
        _commentController.clear();
        _focusNode.unfocus();
        ref.invalidate(commentsStreamProvider(widget.memoryUuid));
        ref.invalidate(commentCountProvider(widget.memoryUuid));
        SprinkleToast.show(
          context,
          'Comment posted! ✨',
          type: ToastType.success,
          duration: const Duration(milliseconds: 1200),
        );
      }
    } catch (_) {
      if (mounted) {
        SprinkleToast.show(
          context,
          'Failed to post comment',
          type: ToastType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPosting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(commentsStreamProvider(widget.memoryUuid));
    final mediaQuery = MediaQuery.of(context);
    final isGuest = SupabaseService.instance.currentUser == null;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: mediaQuery.size.height * 0.75,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFF1C1C1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: EdgeInsets.only(
          bottom: mediaQuery.viewInsets.bottom,
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              // 1. Drag Handle
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 2. Header Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'COMMENTS',
                      style: AppTypography.sectionTitle.copyWith(
                        color: Colors.white,
                        letterSpacing: 2.0,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 22),
                      onPressed: () => Navigator.maybePop(context),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white10, height: 1),

              // 3. Comments List / Empty State
              Expanded(
                child: commentsAsync.when(
                  data: (comments) {
                    if (comments.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary.withValues(alpha: 0.15),
                              ),
                              child: const Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 28,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No comments yet',
                              style: AppTypography.headlineMedium.copyWith(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Be the first to share your thoughts!',
                              style: AppTypography.bodySmall.copyWith(
                                color: Colors.white60,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      itemCount: comments.length,
                      separatorBuilder: (_, _) => const Divider(color: Colors.white10, height: 0.5),
                      itemBuilder: (context, index) {
                        final Comment comment = comments[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                                child: Text(
                                  comment.userAvatar,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          comment.userName,
                                          style: AppTypography.labelBold.copyWith(color: Colors.white),
                                        ),
                                        const Spacer(),
                                        Text(
                                          comment.createdAt.toFriendlyString(),
                                          style: AppTypography.caption.copyWith(
                                            color: Colors.white38,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      comment.content,
                                      style: AppTypography.bodyLarge.copyWith(
                                        color: Colors.white.withValues(alpha: 0.9),
                                        fontSize: 15,
                                      ),
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  loading: () => ListView.builder(
                    itemCount: 4,
                    itemBuilder: (context, index) => const SkeletonCommentItem(),
                  ),
                  error: (err, _) => Center(
                    child: Text(
                      'Error loading comments: $err',
                      style: const TextStyle(color: Colors.white60),
                    ),
                  ),
                ),
              ),

              // 4. Input Area or Guest Banner
              Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, mediaQuery.padding.bottom + 12),
                child: isGuest
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C2C2E),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Log in to join the conversation',
                                style: AppTypography.bodySmall.copyWith(
                                  color: Colors.white60,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                Navigator.maybePop(context);
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => const LoginView()),
                                );
                              },
                              child: Text(
                                'Log In',
                                style: AppTypography.labelBold.copyWith(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2C2C2E),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: TextField(
                                controller: _commentController,
                                focusNode: _focusNode,
                                style: AppTypography.bodyLarge.copyWith(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Add a comment...',
                                  hintStyle: AppTypography.bodyLarge.copyWith(color: Colors.white38),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                maxLines: 3,
                                minLines: 1,
                                onSubmitted: (_) => _postComment(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: _postComment,
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: _isPosting
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.send_rounded,
                                        color: Colors.white,
                                        size: 20,
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
    );
  }
}
