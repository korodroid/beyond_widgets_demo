import 'package:flutter/material.dart';

import '../../core/camera/camera_stage.dart';
import '../../core/camera/camera_stage_controls.dart';
import '../../core/camera/fitted_camera_preview.dart';
import '../../core/overlay/overlay_painter.dart';
import '../../core/transform/coordinate_transformer.dart';
import '../../core/transform/naive_scale_transform.dart';
import '../../core/transform/preview_orientation_heuristic.dart';
import '../../home/demo_entry.dart';
import '../../l10n/generated/app_localizations.dart';

/// 02 — Coordinate Transformation: Detect -> Normalize -> Rotate -> Scale
/// (BoxFit) -> Offset, as an explicit pipeline instead of a single scale
/// factor. A "Before/After" switch lets you flip back to the naive
/// transform from demo 01 under the exact same conditions.
///
/// Rotation is the one real-world quirk worth calling out: the camera
/// plugin's reported `previewSize` doesn't always match the orientation the
/// preview is actually rendered in. This demo detects that mismatch by
/// comparing the aspect-ratio *category* (landscape- vs portrait-shaped) of
/// the raw preview size against the box it's laid out into, and feeds a
/// 90° correction into [CoordinateTransformer] when they disagree.
class CoordinateTransformScreen extends StatefulWidget {
  const CoordinateTransformScreen({super.key});

  @override
  State<CoordinateTransformScreen> createState() =>
      _CoordinateTransformScreenState();
}

class _CoordinateTransformScreenState
    extends State<CoordinateTransformScreen> {
  Size? _previewBoxSize;
  bool _showCorrected = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(numberedTitle('02', l10n.demo02Title))),
      body: SafeArea(
        child: CameraStage(
          builder: (context, stage) {
            final imageSize = stage.imageSize;
            final previewBoxSize = _previewBoxSize;

            return Column(
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      FittedCameraPreview(
                        controller: stage.controller!,
                        fit: stage.fit,
                        onLayout: (size) {
                          if (_previewBoxSize != size) {
                            setState(() => _previewBoxSize = size);
                          }
                        },
                      ),
                      if (imageSize != null && previewBoxSize != null)
                        CustomPaint(
                          painter: OverlayPainter(
                            model: stage.overlayModel,
                            transform: (rect) => _showCorrected
                                ? _correctTransformer(
                                    imageSize,
                                    previewBoxSize,
                                    stage.fit,
                                    stage.mirror,
                                  ).transform(rect)
                                : naiveScaleTransform(
                                    rect, imageSize, previewBoxSize),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: Text(l10n.correctedTransformTitle),
                        subtitle: Text(_showCorrected
                            ? l10n.correctedTransformOnSubtitle
                            : l10n.correctedTransformOffSubtitle),
                        value: _showCorrected,
                        onChanged: (value) =>
                            setState(() => _showCorrected = value),
                      ),
                      CameraStageControls(stage: stage),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  CoordinateTransformer _correctTransformer(
    Size imageSize,
    Size previewBoxSize,
    BoxFit fit,
    bool mirror,
  ) {
    return CoordinateTransformer(
      imageSize: imageSize,
      previewSize: previewBoxSize,
      quarterTurns: quarterTurnsForPreview(imageSize, previewBoxSize),
      fit: fit,
      mirror: mirror,
    );
  }
}
