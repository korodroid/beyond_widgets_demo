import 'dart:ui';

/// The "it looked simple" transform: independent X/Y scale factors, no
/// rotation or BoxFit-crop compensation. Shared by the naive-overlay demo
/// and the coordinate-transform demo's "before" view, so both show exactly
/// the same bug.
Rect naiveScaleTransform(Rect imageRect, Size imageSize, Size previewSize) {
  final scaleX = previewSize.width / imageSize.width;
  final scaleY = previewSize.height / imageSize.height;
  return Rect.fromLTWH(
    imageRect.left * scaleX,
    imageRect.top * scaleY,
    imageRect.width * scaleX,
    imageRect.height * scaleY,
  );
}
