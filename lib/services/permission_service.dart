import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Check if camera permission is granted
  static Future<bool> checkCameraPermission() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  /// Request camera permission
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Check if photos/gallery permission is granted
  static Future<bool> checkGalleryPermission() async {
    final status = await Permission.photos.status;
    return status.isGranted || status.isLimited;
  }

  /// Request photos/gallery permission
  static Future<bool> requestGalleryPermission() async {
    final status = await Permission.photos.request();
    return status.isGranted || status.isLimited;
  }
}
