import 'dart:ui';

/// A single detection result, with its bounding box expressed in raw
/// camera-image pixel coordinates (before any rotation/scale/offset).
class DetectionBox {
  const DetectionBox({
    required this.id,
    required this.rect,
    required this.label,
  });

  final int id;
  final Rect rect;
  final String label;
}

/// One tick of the "analysis" layer: the boxes detected in a single frame,
/// plus the raw image size they were detected against and when the frame
/// was captured (used to visualize latency).
class DetectionFrame {
  const DetectionFrame({
    required this.frameId,
    required this.imageSize,
    required this.boxes,
    required this.capturedAt,
  });

  final int frameId;
  final Size imageSize;
  final List<DetectionBox> boxes;
  final DateTime capturedAt;
}
