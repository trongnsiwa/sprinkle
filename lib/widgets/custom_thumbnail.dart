import 'dart:io';
import 'package:flutter/material.dart';
import '../services/image_service.dart';

class CustomThumbnail extends StatelessWidget {
  final String? imageFileName;
  final String? imageUrl;
  final File? imageFile;
  final String? imagePath;
  final double size;
  final double borderRadius;
  final bool isCircle;
  final bool hasBorder;
  final Border? customBorder;

  const CustomThumbnail({
    super.key,
    this.imageFileName,
    this.imageUrl,
    this.imageFile,
    this.imagePath,
    this.size = 50.0,
    this.borderRadius = 12.0,
    this.isCircle = false,
    this.hasBorder = false,
    this.customBorder,
  });

  @override
  Widget build(BuildContext context) {
    BoxBorder? effectiveBorder;
    if (customBorder != null) {
      effectiveBorder = customBorder;
    } else if (hasBorder) {
      effectiveBorder = Border.all(color: Colors.white, width: 2.0);
    }

    final shape = isCircle ? BoxShape.circle : BoxShape.rectangle;
    final r = isCircle
        ? (size.isFinite ? BorderRadius.circular(size / 2) : BorderRadius.circular(50))
        : BorderRadius.circular(borderRadius);

    final double iconSize = size.isFinite ? size * 0.4 : 40.0;

    Widget darkBoxPlaceholder = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        shape: shape,
        borderRadius: isCircle ? null : r,
        border: effectiveBorder,
      ),
    );

    if (imageFile != null) {
      return _buildImageContainer(imageFile!, shape, r, effectiveBorder, iconSize);
    }

    if (imagePath != null && imagePath!.isNotEmpty) {
      final file = File(imagePath!);
      return _buildImageContainer(file, shape, r, effectiveBorder, iconSize);
    }

    if (imageFileName != null && imageFileName!.isNotEmpty) {
      return FutureBuilder<File?>(
        future: ImageService.getImageFile(imageFileName!),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return _buildImageContainer(snapshot.data!, shape, r, effectiveBorder, iconSize);
          }
          if (imageUrl != null && imageUrl!.isNotEmpty) {
            return _buildNetworkImageContainer(imageUrl!, shape, r, effectiveBorder, iconSize);
          }
          return darkBoxPlaceholder;
        },
      );
    }

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return _buildNetworkImageContainer(imageUrl!, shape, r, effectiveBorder, iconSize);
    }

    return darkBoxPlaceholder;
  }

  Widget _buildNetworkImageContainer(
    String url,
    BoxShape shape,
    BorderRadius borderRadius,
    BoxBorder? border,
    double iconSize,
  ) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        shape: shape,
        borderRadius: isCircle ? null : borderRadius,
        border: border,
      ),
      child: ClipRRect(
        borderRadius: isCircle
            ? (size.isFinite ? BorderRadius.circular(size / 2) : BorderRadius.circular(50))
            : borderRadius,
        child: Image.network(
          url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) return child;
            return AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              child: child,
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: const Color(0xFF1C1C1E),
              child: Center(
                child: Icon(
                  Icons.broken_image_rounded,
                  color: Colors.white.withValues(alpha: 0.5),
                  size: iconSize,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildImageContainer(
    File file,
    BoxShape shape,
    BorderRadius borderRadius,
    BoxBorder? border,
    double iconSize,
  ) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        shape: shape,
        borderRadius: isCircle ? null : borderRadius,
        border: border,
      ),
      child: ClipRRect(
        borderRadius: isCircle
            ? (size.isFinite ? BorderRadius.circular(size / 2) : BorderRadius.circular(50))
            : borderRadius,
        child: Image.file(
          file,
          width: size,
          height: size,
          fit: BoxFit.cover,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) return child;
            return AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              child: child,
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: const Color(0xFF1C1C1E),
              child: Center(
                child: Icon(
                  Icons.broken_image_rounded,
                  color: Colors.white.withValues(alpha: 0.5),
                  size: iconSize,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
