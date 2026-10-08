import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'detection_box.dart';
import 'detection_source.dart';

const _rotationBySensorOrientation = {
  0: DeviceOrientation.portraitUp,
  90: DeviceOrientation.landscapeLeft,
  180: DeviceOrientation.portraitDown,
  270: DeviceOrientation.landscapeRight,
};

/// Real on-device OCR: streams frames from [cameraController] through ML
/// Kit's text recognizer. A "latest frame" gate is baked in — while one
/// frame is being analyzed, incoming camera frames are dropped rather than
/// queued, matching the back-pressure pattern demonstrated in the camera
/// pipeline & sync demo.
class MlkitDetectionSource implements DetectionSource {
  MlkitDetectionSource({required this.cameraController});

  final CameraController cameraController;
  final TextRecognizer _recognizer = TextRecognizer();
  final _controller = StreamController<DetectionFrame>.broadcast();

  bool _isProcessing = false;
  int _frameId = 0;
  int droppedCount = 0;
  int processedCount = 0;

  @override
  Stream<DetectionFrame> get frames => _controller.stream;

  @override
  Future<void> start() async {
    await cameraController.startImageStream(_onImage);
  }

  @override
  Future<void> stop() async {
    if (cameraController.value.isStreamingImages) {
      await cameraController.stopImageStream();
    }
    await _recognizer.close();
    await _controller.close();
  }

  void _onImage(CameraImage image) {
    if (_isProcessing) {
      droppedCount++;
      return;
    }
    _isProcessing = true;
    _process(image).whenComplete(() => _isProcessing = false);
  }

  Future<void> _process(CameraImage image) async {
    try {
      final inputImage = _toInputImage(image);
      if (inputImage == null) return;

      final result = await _recognizer.processImage(inputImage);
      final boxes = <DetectionBox>[];
      var i = 0;
      for (final block in result.blocks) {
        for (final line in block.lines) {
          boxes.add(DetectionBox(id: i++, rect: line.boundingBox, label: line.text));
        }
      }
      processedCount++;
      _controller.add(
        DetectionFrame(
          frameId: _frameId++,
          imageSize: Size(image.width.toDouble(), image.height.toDouble()),
          boxes: boxes,
          capturedAt: DateTime.now(),
        ),
      );
    } catch (_) {
      // Drop failed frames silently; the next camera frame will retry.
    }
  }

  InputImage? _toInputImage(CameraImage image) {
    final sensorOrientation = cameraController.description.sensorOrientation;
    InputImageRotation? rotation;

    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      final deviceOrientation =
          cameraController.value.deviceOrientation;
      var compensation = _rotationBySensorOrientation.entries
              .firstWhere((e) => e.value == deviceOrientation,
                  orElse: () => _rotationBySensorOrientation.entries.first)
              .key;
      if (cameraController.description.lensDirection ==
          CameraLensDirection.front) {
        compensation = (sensorOrientation + compensation) % 360;
      } else {
        compensation = (sensorOrientation - compensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(compensation);
    }
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null || image.planes.length != 1) return null;

    final plane = image.planes.first;
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }
}
