import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Get current camera permission status
  static Future<PermissionStatus> getCameraPermissionStatus() async {
    return await Permission.camera.status;
  }

  /// Request camera permission and return PermissionStatus
  static Future<PermissionStatus> requestCameraPermissionStatus() async {
    print('[PermissionService] Requesting camera permission...');
    final status = await Permission.camera.request();
    print('[PermissionService] Camera permission status: $status');
    return status;
  }

  /// Check if camera permission is granted
  static Future<bool> checkCameraPermission() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  /// Request camera permission
  static Future<bool> requestCameraPermission() async {
    final status = await requestCameraPermissionStatus();
    return status.isGranted;
  }

  /// Open system app settings
  static Future<bool> openSettings() async {
    return await openAppSettings();
  }

  /// Check if photos/gallery permission is granted
  static Future<bool> checkGalleryPermission() async {
    final status = await Permission.photos.status;
    return status.isGranted || status.isLimited;
  }

  /// Request photos/gallery permission
  static Future<bool> requestGalleryPermission() async {
    final status = await Permission.photos.request();
    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
    return status.isGranted || status.isLimited;
  }
}
