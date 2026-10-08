import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'detection_box.dart';
import 'detection_source.dart';

/// Emits a single bounding box moving in a smooth loop, standing in for a
/// real recognizer (OCR/CV/AI) so demos have a deterministic, reproducible
/// "detection result" to render — no camera or model required.
///
/// Frames are captured at a fixed rate ([captureInterval]), independent of
/// how long any downstream "analysis" step takes to consume them. That
/// separation is what lets the camera-pipeline demo show a queue building
/// up when analysis is slower than capture.
class MockDetectionSource implements DetectionSource {
  MockDetectionSource({
    this.imageSize = const Size(1280, 720),
    this.captureInterval = const Duration(milliseconds: 33),
    this.label = 'Milk',
  });

  final Size imageSize;
  final Duration captureInterval;
  final String label;

  final _controller = StreamController<DetectionFrame>.broadcast();
  Timer? _timer;
  int _frameId = 0;
  final _stopwatch = Stopwatch();

  @override
  Stream<DetectionFrame> get frames => _controller.stream;

  @override
  Future<void> start() async {
    _stopwatch..reset()..start();
    _timer?.cancel();
    _timer = Timer.periodic(captureInterval, (_) => _emit());
  }

  @override
  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
    _stopwatch.stop();
  }

  void _emit() {
    final t = _stopwatch.elapsedMilliseconds / 1000.0;
    const boxSize = Size(220, 120);
    final margin = boxSize / 2;
    final rangeX = imageSize.width - boxSize.width;
    final rangeY = imageSize.height - boxSize.height;
    final cx = margin.width + rangeX * (0.5 + 0.4 * math.sin(t * 0.9));
    final cy = margin.height + rangeY * (0.5 + 0.4 * math.sin(t * 1.3 + 1.0));

    final box = DetectionBox(
      id: 0,
      rect: Rect.fromCenter(
        center: Offset(cx, cy),
        width: boxSize.width,
        height: boxSize.height,
      ),
      label: label,
    );

    _controller.add(
      DetectionFrame(
        frameId: _frameId++,
        imageSize: imageSize,
        boxes: [box],
        capturedAt: DateTime.now(),
      ),
    );
  }

  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}
