import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/database_service.dart';
import '../services/image_service.dart';
import '../services/permission_service.dart';
import '../utils/constants.dart';

class CameraState {
  final bool isAuthorized;
  final bool isPermanentlyDenied;
  final bool isMockMode;
  final bool isFlashOn;
  final bool isCameraInitialized;
  final bool isCapturing;
  final String? capturedImagePath;
  final bool showingSheet;
  final File? latestThumbnailFile;
  final String? errorMessage;

  CameraState({
    this.isAuthorized = false,
    this.isPermanentlyDenied = false,
    this.isMockMode = kUseMockCamera,
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
    bool? isPermanentlyDenied,
    bool? isMockMode,
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
      isPermanentlyDenied: isPermanentlyDenied ?? this.isPermanentlyDenied,
      isMockMode: isMockMode ?? this.isMockMode,
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
    if (state.isMockMode) {
      state = state.copyWith(
        isAuthorized: true,
        isCameraInitialized: true,
      );
    } else {
      checkPermission();
    }
    loadLatestThumbnail();
  }

  void enableMockMode() {
    state = state.copyWith(
      isMockMode: true,
      isAuthorized: true,
      isCameraInitialized: true,
    );
  }

  Future<void> checkPermission() async {
    if (state.isMockMode) {
      state = state.copyWith(
        isAuthorized: true,
        isCameraInitialized: true,
      );
      return;
    }
    final status = await PermissionService.getCameraPermissionStatus();
    print('[CameraViewModel] Camera permission status check: $status');
    final isGranted = status.isGranted;
    final isPermDenied = status.isPermanentlyDenied;
    state = state.copyWith(
      isAuthorized: isGranted,
      isPermanentlyDenied: isPermDenied,
    );
    if (isGranted && !state.isCameraInitialized) {
      initCamera();
    }
  }

  Future<void> requestPermission() async {
    if (state.isMockMode) {
      state = state.copyWith(
        isAuthorized: true,
        isCameraInitialized: true,
      );
      return;
    }
    print('[CameraViewModel] User triggered requestPermission()');
    final status = await PermissionService.requestCameraPermissionStatus();
    print('[CameraViewModel] Permission request status: $status');
    final isGranted = status.isGranted;
    final isPermDenied = status.isPermanentlyDenied;
    state = state.copyWith(
      isAuthorized: isGranted,
      isPermanentlyDenied: isPermDenied,
    );
    if (isGranted) {
      initCamera();
    }
  }

  Future<void> openAppSettings() async {
    await PermissionService.openSettings();
  }

  Future<void> reloadCamera() async {
    if (state.isMockMode) {
      state = state.copyWith(
        isAuthorized: true,
        isCameraInitialized: true,
      );
      return;
    }
    print('[CameraViewModel] Manual reload camera requested');
    final status = await PermissionService.getCameraPermissionStatus();
    print('[CameraViewModel] Camera status on reload: $status');
    final isGranted = status.isGranted;
    state = state.copyWith(
      isAuthorized: isGranted,
      isPermanentlyDenied: status.isPermanentlyDenied,
    );
    if (isGranted) {
      await initCamera();
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

  int _selectedCameraIndex = 0;

  Future<void> switchCamera() async {
    if (_cameras.length <= 1) return;
    try {
      _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
      final camera = _cameras[_selectedCameraIndex];
      if (controller != null) {
        await controller!.dispose();
      }
      controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller!.initialize();
      state = state.copyWith(isCameraInitialized: true);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
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

  Future<String?> pickImageFromGallery() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        state = state.copyWith(
          capturedImagePath: pickedFile.path,
          showingSheet: true,
        );
        return pickedFile.path;
      }
      return null;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return null;
    }
  }

  Future<String?> capturePhoto() async {
    if (state.isMockMode) {
      try {
        state = state.copyWith(isCapturing: true);
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(source: ImageSource.gallery);
        state = state.copyWith(isCapturing: false);
        if (pickedFile != null) {
          state = state.copyWith(
            capturedImagePath: pickedFile.path,
            showingSheet: true,
          );
          return pickedFile.path;
        }
        return null;
      } catch (e) {
        state = state.copyWith(
          isCapturing: false,
          errorMessage: e.toString(),
        );
        return null;
      }
    }

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
