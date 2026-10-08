import 'dart:ui';

/// A camera plugin's reported `previewSize` isn't guaranteed to match the
/// orientation the preview is actually rendered in — a real, documented
/// gotcha, not something simulated for this demo. This compares the
/// aspect-ratio *category* (landscape- vs portrait-shaped) of the raw
/// image size against the box it's displayed in, and returns the quarter
/// turns needed to line the two back up.
///
/// Deliberately coarse: it distinguishes portrait from landscape, not
/// which landscape (left/right) — enough to reproduce and fix the bug from
/// slide 14 without a device-orientation plugin.
int quarterTurnsForPreview(Size imageSize, Size previewBoxSize) {
  final imageIsLandscapeShaped = imageSize.width >= imageSize.height;
  final boxIsLandscapeShaped = previewBoxSize.width >= previewBoxSize.height;
  return imageIsLandscapeShaped == boxIsLandscapeShaped ? 0 : 1;
}
