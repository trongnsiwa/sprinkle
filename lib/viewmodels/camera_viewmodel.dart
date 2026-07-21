import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';
import '../services/image_service.dart';
import '../services/permission_service.dart';

class CameraState {
  final bool isAuthorized;
  final bool isFlashOn;
  final bool isCameraInitialized;
  final bool isCapturing;
  final String? capturedImagePath;
  final bool showingSheet;
  final File? latestThumbnailFile;
  final String? errorMessage;

  CameraState({
    this.isAuthorized = false,
    this.isFlashOn = false,
    this.isCameraInitialized = false,
    this.isCapturing = false,
    this.capturedImagePath,
    this.showingSheet = false,
    this.latestThumbnailFile,
    this.errorMessage,
  });

  CameraState copyWith({
    bool? isAuthorized,
    bool? isFlashOn,
    bool? isCameraInitialized,
    bool? isCapturing,
    String? capturedImagePath,
    bool? showingSheet,
    File? latestThumbnailFile,
    String? errorMessage,
  }) {
    return CameraState(
      isAuthorized: isAuthorized ?? this.isAuthorized,
      isFlashOn: isFlashOn ?? this.isFlashOn,
      isCameraInitialized: isCameraInitialized ?? this.isCameraInitialized,
      isCapturing: isCapturing ?? this.isCapturing,
      capturedImagePath: capturedImagePath ?? this.capturedImagePath,
      showingSheet: showingSheet ?? this.showingSheet,
      latestThumbnailFile: latestThumbnailFile ?? this.latestThumbnailFile,
      errorMessage: errorMessage,
    );
  }
}

class CameraViewModel extends StateNotifier<CameraState> {
  CameraController? controller;
  List<CameraDescription> _cameras = [];

  CameraViewModel() : super(CameraState()) {
    checkPermission();
    loadLatestThumbnail();
  }

  Future<void> checkPermission() async {
    final granted = await PermissionService.checkCameraPermission();
    state = state.copyWith(isAuthorized: granted);
    if (granted) {
      initCamera();
    }
  }

  Future<void> requestPermission() async {
    final granted = await PermissionService.requestCameraPermission();
    state = state.copyWith(isAuthorized: granted);
    if (granted) {
      initCamera();
    }
  }

  Future<void> initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        state = state.copyWith(errorMessage: 'No camera available');
        return;
      }

      final camera = _cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );

      controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await controller!.initialize();
      state = state.copyWith(
        isCameraInitialized: true,
        isFlashOn: false,
      );
    } catch (e) {
      state = state.copyWith(
        isCameraInitialized: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> toggleFlash() async {
    if (controller == null || !state.isCameraInitialized) return;
    try {
      final newFlash = !state.isFlashOn;
      await controller!.setFlashMode(
        newFlash ? FlashMode.torch : FlashMode.off,
      );
      state = state.copyWith(isFlashOn: newFlash);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<String?> capturePhoto() async {
    if (controller == null || !state.isCameraInitialized || state.isCapturing) {
      return null;
    }
    try {
      state = state.copyWith(isCapturing: true);
      final file = await controller!.takePicture();
      state = state.copyWith(
        isCapturing: false,
        capturedImagePath: file.path,
        showingSheet: true,
      );
      return file.path;
    } catch (e) {
      state = state.copyWith(
        isCapturing: false,
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  Future<void> loadLatestThumbnail() async {
    try {
      final visits = await DatabaseService.instance.getAllVisits();
      if (visits.isNotEmpty) {
        for (final visit in visits) {
          if (visit.imageFileName != null && visit.imageFileName!.isNotEmpty) {
            final file = await ImageService.getImageFile(visit.imageFileName!);
            if (file != null) {
              state = state.copyWith(latestThumbnailFile: file);
              return;
            }
          }
        }
      }
      state = state.copyWith(latestThumbnailFile: null);
    } catch (_) {}
  }

  void setShowingSheet(bool showing) {
    state = state.copyWith(showingSheet: showing);
    if (!showing) {
      loadLatestThumbnail();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

final cameraViewModelProvider =
    StateNotifierProvider<CameraViewModel, CameraState>((ref) {
  return CameraViewModel();
});
