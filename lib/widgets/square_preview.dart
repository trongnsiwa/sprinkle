import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/typography.dart';

class SquarePreview extends StatefulWidget {
  final CameraController? controller;
  final bool isInitialized;
  final bool isMockMode;
  final double width;
  final double? height;
  final double borderRadius;
  final bool isCircle;
  final bool isFlashing;
  final bool isFlashOn;
  final VoidCallback? onFlashToggle;
  final VoidCallback? onReactionTap;

  const SquarePreview({
    super.key,
    required this.controller,
    required this.isInitialized,
    this.isMockMode = false,
    required this.width,
    this.height,
    this.borderRadius = 32.0,
    this.isCircle = false,
    this.isFlashing = false,
    this.isFlashOn = false,
    this.onFlashToggle,
    this.onReactionTap,
  });

  @override
  State<SquarePreview> createState() => _SquarePreviewState();
}

class _SquarePreviewState extends State<SquarePreview> {
  @override
  Widget build(BuildContext context) {
    final double targetWidth = widget.width;
    final double targetHeight = widget.height ?? widget.width;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0.95, end: 1.0),
      builder: (context, scaleValue, child) {
        return Transform.scale(
          scale: scaleValue,
          child: Container(
            width: targetWidth,
            height: targetHeight,
            decoration: BoxDecoration(
              color: Colors.black,
              shape: widget.isCircle ? BoxShape.circle : BoxShape.rectangle,
              borderRadius: widget.isCircle ? null : BorderRadius.circular(widget.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.06),
                  blurRadius: 40,
                  spreadRadius: 4,
                  offset: Offset.zero,
                ),
              ],
            ),
            child: ClipPath(
              clipper: widget.isCircle ? const _CircleClipper() : null,
              child: ClipRRect(
                borderRadius: widget.isCircle
                    ? BorderRadius.zero
                    : BorderRadius.circular(widget.borderRadius),
                child: Stack(
                  children: [
                    // Base dark background
                    Positioned.fill(
                      child: Container(
                        color: const Color(0xFF1C1C1E),
                      ),
                    ),

                    // Mock Mode Preview / Live Camera Feed
                    if (widget.isMockMode)
                      Positioned.fill(
                        child: Stack(
                          children: [
                            // Rich dark aesthetic photo background
                            Positioned.fill(
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF2E313A),
                                      Color(0xFF1F2128),
                                      Color(0xFF2B2E38),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                            ),

                            // Inner Vignette radial gradient overlay
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: RadialGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.40),
                                    ],
                                    radius: 0.85,
                                  ),
                                ),
                              ),
                            ),

                            // Minimal Locket-Inspired Empty State Prompt
                            Positioned.fill(
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.20),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Center(
                                        child: Text('📸', style: TextStyle(fontSize: 28)),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Tap shutter to capture',
                                      style: AppTypography.bodyLarge.copyWith(
                                        color: Colors.white.withValues(alpha: 0.7),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (widget.isInitialized && widget.controller != null)
                      Positioned.fill(
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: widget.isInitialized ? 1.0 : 0.0,
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: widget.controller!.value.previewSize?.height ?? 1,
                              height: widget.controller!.value.previewSize?.width ?? 1,
                              child: CameraPreview(widget.controller!),
                            ),
                          ),
                        ),
                      )
                    else
                      Positioned.fill(
                        child: Container(
                          color: const Color(0xFF1C1C1E),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                              strokeWidth: 2.0,
                            ),
                          ),
                        ),
                      ),

                    // Top Flash Control Button
                    if (widget.onFlashToggle != null)
                      Positioned(
                        top: 12,
                        left: widget.isCircle ? null : 12,
                        right: widget.isCircle ? 24 : null,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.45),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: widget.onFlashToggle,
                            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              widget.isFlashOn
                                  ? Icons.flash_on_rounded
                                  : Icons.flash_off_rounded,
                              size: 18,
                              color: widget.isFlashOn
                                  ? const Color(0xFFFFCC00)
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),

                    // Camera Shutter Flash Effect Overlay
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 100),
                      opacity: widget.isFlashing ? 0.90 : 0.0,
                      child: Container(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CircleClipper extends CustomClipper<Path> {
  const _CircleClipper();

  @override
  Path getClip(Size size) {
    return Path()..addOval(Rect.fromLTWH(0, 0, size.width, size.height));
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
