import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/typography.dart';

class CircularPreview extends StatelessWidget {
  final CameraController? controller;
  final bool isInitialized;
  final bool isMockMode;
  final double diameter;

  const CircularPreview({
    super.key,
    required this.controller,
    required this.isInitialized,
    this.isMockMode = false,
    this.diameter = 300.0,
  });

  @override
  Widget build(BuildContext context) {
    final bool showGlow = isMockMode || (isInitialized && controller != null);

    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: Offset.zero,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 16,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: ClipOval(
        child: Stack(
          children: [
            // Sharp Preview content
            if (isMockMode)
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF2C3E50), Color(0xFF4CA1AF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.photo_camera_outlined,
                      size: 48,
                      color: Colors.white70,
                    ),
                  ),
                ),
              )
            else if (isInitialized && controller != null)
              Positioned.fill(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: isInitialized ? 1.0 : 0.0,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: controller!.value.previewSize?.height ?? 1,
                      height: controller!.value.previewSize?.width ?? 1,
                      child: CameraPreview(controller!),
                    ),
                  ),
                ),
              )
            else
              const Positioned.fill(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),

            // Extremely subtle low-opacity MOCK badge
            if (isMockMode)
              Positioned(
                bottom: 12,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'MOCK',
                    style: AppTypography.caption.copyWith(
                      color: Colors.white54,
                      fontSize: 9,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
