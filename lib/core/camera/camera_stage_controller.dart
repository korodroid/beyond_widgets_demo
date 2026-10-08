import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../detection/detection_source.dart';
import '../detection/mlkit_detection_source.dart';
import '../detection/mock_detection_source.dart';
import '../overlay/overlay_model.dart';

/// Owns a single camera session and its detection source (mock or ML Kit),
/// feeding results into [overlayModel]. Shared by every demo that needs a
/// live camera + detection boxes, so each demo screen only has to worry
/// about how it *transforms and paints* the boxes, not camera lifecycle.
class CameraStageController extends ChangeNotifier {
  CameraStageController({this.fit = BoxFit.cover});

  BoxFit fit;
  bool useMlkit = false;
  bool isInitializing = true;
  bool noCameraAvailable = false;
  String? error;

  CameraController? controller;
  List<CameraDescription> _cameras = const [];
  int _cameraIndex = 0;

  DetectionSource? _source;
  StreamSubscription<dynamic>? _sub;

  final OverlayModel overlayModel = OverlayModel();

  bool get hasMultipleCameras => _cameras.length > 1;

  bool get mirror =>
      controller?.description.lensDirection == CameraLensDirection.front;

  /// Raw sensor preview size, as reported by the camera plugin — *not*
  /// guaranteed to match the orientation the preview is actually displayed
  /// in (see `CoordinateTransformer` docs).
  Size? get imageSize => controller?.value.previewSize;

  Future<void> init() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        noCameraAvailable = true;
        return;
      }
      await _openCamera(0);
    } catch (e) {
      error = '$e';
    } finally {
      isInitializing = false;
      notifyListeners();
    }
  }

  Future<void> _openCamera(int index) async {
    await _sub?.cancel();
    await _source?.stop();
    await controller?.dispose();

    _cameraIndex = index % _cameras.length;
    final newController = CameraController(
      _cameras[_cameraIndex],
      ResolutionPreset.medium,
      enableAudio: false,
    );
    await newController.initialize();
    controller = newController;
    await _startDetection();
    notifyListeners();
  }

  Future<void> _startDetection() async {
    await _sub?.cancel();
    await _source?.stop();

    final activeController = controller;
    if (activeController == null) return;

    final newSource = useMlkit
        ? MlkitDetectionSource(cameraController: activeController)
        : MockDetectionSource(imageSize: imageSize ?? const Size(1280, 720));
    _source = newSource;
    _sub = newSource.frames.listen((frame) => overlayModel.update(frame.boxes));
    await newSource.start();
  }

  Future<void> switchCamera() async {
    if (_cameras.length < 2) return;
    isInitializing = true;
    notifyListeners();
    await _openCamera(_cameraIndex + 1);
    isInitializing = false;
    notifyListeners();
  }

  Future<void> setUseMlkit(bool value) async {
    if (useMlkit == value) return;
    useMlkit = value;
    notifyListeners();
    await _startDetection();
  }

  void setFit(BoxFit value) {
    if (fit == value) return;
    fit = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _source?.stop();
    controller?.dispose();
    overlayModel.dispose();
    super.dispose();
  }
}
