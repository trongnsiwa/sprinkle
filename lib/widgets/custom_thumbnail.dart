import 'dart:io';
import 'package:flutter/material.dart';
import '../services/image_service.dart';
import '../utils/colors.dart';

class CustomThumbnail extends StatelessWidget {
  final String? imageFileName;
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
    final r = isCircle ? BorderRadius.circular(size / 2) : BorderRadius.circular(borderRadius);

    Widget placeholderWidget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.neutral.withValues(alpha: 0.3),
        shape: shape,
        borderRadius: isCircle ? null : r,
        border: effectiveBorder,
      ),
      child: Center(
        child: Icon(
          Icons.photo_camera_rounded,
          color: Colors.white.withValues(alpha: 0.3),
          size: size * 0.4,
        ),
      ),
    );

    if (imageFile != null) {
      return _buildImageContainer(imageFile!, shape, r, effectiveBorder);
    }

    if (imagePath != null && imagePath!.isNotEmpty) {
      final file = File(imagePath!);
      return _buildImageContainer(file, shape, r, effectiveBorder);
    }

    if (imageFileName != null && imageFileName!.isNotEmpty) {
      return FutureBuilder<File?>(
        future: ImageService.getImageFile(imageFileName!),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return _buildImageContainer(snapshot.data!, shape, r, effectiveBorder);
          }
          return placeholderWidget;
        },
      );
    }

    return placeholderWidget;
  }

  Widget _buildImageContainer(
    File file,
    BoxShape shape,
    BorderRadius borderRadius,
    BoxBorder? border,
  ) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: shape,
        borderRadius: isCircle ? null : borderRadius,
        border: border,
      ),
      child: ClipRRect(
        borderRadius: isCircle ? BorderRadius.circular(size / 2) : borderRadius,
        child: Image.file(
          file,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppColors.neutralLight.withValues(alpha: 0.3),
              child: Icon(
                Icons.broken_image_rounded,
                color: Colors.white.withValues(alpha: 0.5),
                size: size * 0.4,
              ),
            );
          },
        ),
      ),
    );
  }
}
