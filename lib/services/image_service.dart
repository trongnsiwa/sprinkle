import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ImageService {
  /// Save and compress image bytes to local storage, returns saved filename
  static Future<String> saveImage(
    Uint8List rawBytes, {
    int maxWidth = 1200,
    int quality = 85,
  }) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(path.join(docsDir.path, 'images'));
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    final decodedImage = img.decodeImage(rawBytes);
    Uint8List processedBytes = rawBytes;

    if (decodedImage != null) {
      img.Image resized = decodedImage;
      if (decodedImage.width > maxWidth) {
        resized = img.copyResize(decodedImage, width: maxWidth);
      }
      processedBytes = Uint8List.fromList(img.encodeJpg(resized, quality: quality));
    }

    final fileName = '${const Uuid().v4()}.jpg';
    final filePath = path.join(imagesDir.path, fileName);
    final file = File(filePath);
    await file.writeAsBytes(processedBytes);

    return fileName;
  }

  /// Get absolute path for an image filename
  static Future<String> getImagePath(String fileName) async {
    final docsDir = await getApplicationDocumentsDirectory();
    return path.join(docsDir.path, 'images', fileName);
  }

  /// Get File object for an image filename
  static Future<File?> getImageFile(String fileName) async {
    final fullPath = await getImagePath(fileName);
    final file = File(fullPath);
    if (await file.exists()) {
      return file;
    }
    return null;
  }

  /// Delete image file by filename
  static Future<bool> deleteImage(String fileName) async {
    try {
      final fullPath = await getImagePath(fileName);
      final file = File(fullPath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
    } catch (_) {}
    return false;
  }
}
