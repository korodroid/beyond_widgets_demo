import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/rendering.dart' show BoxFit;

/// Maps rectangles/points between "camera image pixel space" and "Flutter
/// widget logical pixel space", as an explicit pipeline rather than a
/// single scale factor:
///
///   Detect -> Normalize -> Rotate -> Scale (BoxFit) -> Offset
///
/// [imageSize] is the raw sensor image size, *before* [quarterTurns] of
/// clockwise rotation are applied for display. [previewSize] is the size
/// the (rotated) image is drawn into. [fit] controls whether the rotated
/// image is letterboxed ([BoxFit.contain]) or cropped ([BoxFit.cover]) to
/// fill [previewSize] — mirroring how `CameraPreview` fits its image.
class CoordinateTransformer {
  const CoordinateTransformer({
    required this.imageSize,
    required this.previewSize,
    this.quarterTurns = 0,
    this.fit = BoxFit.cover,
    this.mirror = false,
  });

  final Size imageSize;
  final Size previewSize;
  final int quarterTurns;
  final BoxFit fit;
  final bool mirror;

  Size get _rotatedImageSize => quarterTurns.isOdd
      ? Size(imageSize.height, imageSize.width)
      : imageSize;

  double get _scale {
    final rotated = _rotatedImageSize;
    final sx = previewSize.width / rotated.width;
    final sy = previewSize.height / rotated.height;
    return fit == BoxFit.cover ? math.max(sx, sy) : math.min(sx, sy);
  }

  Offset get _drawOffset {
    final rotated = _rotatedImageSize;
    final scale = _scale;
    final drawnW = rotated.width * scale;
    final drawnH = rotated.height * scale;
    return Offset(
      (previewSize.width - drawnW) / 2,
      (previewSize.height - drawnH) / 2,
    );
  }

  Offset _rotateNormalized(double x, double y) {
    switch (quarterTurns % 4) {
      case 1:
        return Offset(1 - y, x);
      case 2:
        return Offset(1 - x, 1 - y);
      case 3:
        return Offset(y, 1 - x);
      default:
        return Offset(x, y);
    }
  }

  Offset _inverseRotateNormalized(double x, double y) {
    switch (quarterTurns % 4) {
      case 1:
        return Offset(y, 1 - x);
      case 2:
        return Offset(1 - x, 1 - y);
      case 3:
        return Offset(1 - y, x);
      default:
        return Offset(x, y);
    }
  }

  /// Detect -> Normalize -> Rotate: image-space rect to a [0,1]-normalized
  /// rect in the rotated (display) orientation.
  Rect _normalizeAndRotate(Rect imageRect) {
    var nx1 = imageRect.left / imageSize.width;
    var ny1 = imageRect.top / imageSize.height;
    var nx2 = imageRect.right / imageSize.width;
    var ny2 = imageRect.bottom / imageSize.height;

    if (mirror) {
      final flippedLeft = 1 - nx2;
      final flippedRight = 1 - nx1;
      nx1 = flippedLeft;
      nx2 = flippedRight;
    }

    final p1 = _rotateNormalized(nx1, ny1);
    final p2 = _rotateNormalized(nx2, ny2);
    return Rect.fromLTRB(
      math.min(p1.dx, p2.dx),
      math.min(p1.dy, p2.dy),
      math.max(p1.dx, p2.dx),
      math.max(p1.dy, p2.dy),
    );
  }

  /// Scale (BoxFit) -> Offset: full forward transform, image space to
  /// widget logical pixel space.
  Rect transform(Rect imageRect) {
    final normalized = _normalizeAndRotate(imageRect);
    final rotated = _rotatedImageSize;
    final scale = _scale;
    final offset = _drawOffset;
    return Rect.fromLTWH(
      normalized.left * rotated.width * scale + offset.dx,
      normalized.top * rotated.height * scale + offset.dy,
      normalized.width * rotated.width * scale,
      normalized.height * rotated.height * scale,
    );
  }

  /// Inverse of [transform]: a point in widget logical pixel space back to
  /// image pixel space. Used for tap-on-overlay interaction.
  Offset inverseTransform(Offset widgetPoint) {
    final rotated = _rotatedImageSize;
    final scale = _scale;
    final offset = _drawOffset;

    final rx = (widgetPoint.dx - offset.dx) / (rotated.width * scale);
    final ry = (widgetPoint.dy - offset.dy) / (rotated.height * scale);

    final raw = _inverseRotateNormalized(rx, ry);
    var nx = raw.dx;
    final ny = raw.dy;
    if (mirror) nx = 1 - nx;

    return Offset(nx * imageSize.width, ny * imageSize.height);
  }
}
