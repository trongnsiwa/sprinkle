import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/typography.dart';

/// Toast types for Sprinkle design feedback
enum ToastType {
  success,
  error,
  info,
  neutral,
}

/// Positioning options for SprinkleToast
enum ToastPosition {
  top,
  bottom,
}

/// Custom Minimalist Premium Overlay Toast system for Sprinkle
abstract class SprinkleToast {
  static OverlayEntry? _currentOverlay;

  /// Display a custom toast overlay across the entire application UI.
  static void show(
    BuildContext context,
    String message, {
    ToastType type = ToastType.neutral,
    ToastPosition position = ToastPosition.top,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Immediately replace active overlay if present
    dismiss();

    final overlayState = Overlay.of(context, rootOverlay: true);

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) {
        return _SprinkleToastWidget(
          message: message,
          type: type,
          position: position,
          duration: duration,
          onDismiss: () {
            if (_currentOverlay == entry) {
              entry.remove();
              _currentOverlay = null;
            }
          },
        );
      },
    );

    _currentOverlay = entry;
    overlayState.insert(entry);
  }

  /// Manually dismiss the current toast immediately without transition.
  static void dismiss() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }
}

class _SprinkleToastWidget extends StatefulWidget {
  final String message;
  final ToastType type;
  final ToastPosition position;
  final Duration duration;
  final VoidCallback onDismiss;

  const _SprinkleToastWidget({
    required this.message,
    required this.type,
    required this.position,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_SprinkleToastWidget> createState() => _SprinkleToastWidgetState();
}

class _SprinkleToastWidgetState extends State<_SprinkleToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  Timer? _timer;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    final beginOffset = widget.position == ToastPosition.top
        ? const Offset(0.0, -0.5)
        : const Offset(0.0, 0.5);

    _slideAnimation = Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();

    if (widget.duration > Duration.zero) {
      _timer = Timer(widget.duration, _dismissWithAnimation);
    }
  }

  Future<void> _dismissWithAnimation() async {
    if (_isDismissing || !mounted) return;
    _isDismissing = true;
    _timer?.cancel();
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Widget? _buildIcon() {
    switch (widget.type) {
      case ToastType.success:
        return const Icon(
          Icons.check_circle_rounded,
          color: AppColors.primary,
          size: 20,
        );
      case ToastType.error:
        return const Icon(
          Icons.error_rounded,
          color: AppColors.error,
          size: 20,
        );
      case ToastType.info:
        return const Icon(
          Icons.info_rounded,
          color: AppColors.primary,
          size: 20,
        );
      case ToastType.neutral:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final icon = _buildIcon();

    final double topPadding = widget.position == ToastPosition.top
        ? mediaQuery.padding.top + 16.0
        : 0.0;
    final double bottomPadding = widget.position == ToastPosition.bottom
        ? mediaQuery.padding.bottom + 16.0
        : 0.0;

    return Positioned(
      top: widget.position == ToastPosition.top ? topPadding : null,
      bottom: widget.position == ToastPosition.bottom ? bottomPadding : null,
      left: 20,
      right: 20,
      child: Material(
        type: MaterialType.transparency,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: GestureDetector(
              onTap: _dismissWithAnimation,
              behavior: HitTestBehavior.opaque,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 6.0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        icon,
                        const SizedBox(width: 8.0),
                      ],
                      Flexible(
                        child: Text(
                          widget.message,
                          style: AppTypography.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
