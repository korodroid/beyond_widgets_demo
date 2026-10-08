import 'package:flutter/material.dart';

import '../../core/camera/camera_stage.dart';
import '../../core/camera/camera_stage_controls.dart';
import '../../core/camera/fitted_camera_preview.dart';
import '../../core/detection/detection_box.dart';
import '../../core/overlay/overlay_painter.dart';
import '../../core/transform/coordinate_transformer.dart';
import '../../core/transform/preview_orientation_heuristic.dart';
import '../../home/demo_entry.dart';
import '../../l10n/generated/app_localizations.dart';

/// 05 — Interactive Overlays: tapping a box needs the *inverse* of the
/// same transform used to draw it — screen point -> image-space point —
/// so the tap can be matched back against the original detection.
class InteractiveOverlayScreen extends StatefulWidget {
  const InteractiveOverlayScreen({super.key});

  @override
  State<InteractiveOverlayScreen> createState() =>
      _InteractiveOverlayScreenState();
}

class _InteractiveOverlayScreenState extends State<InteractiveOverlayScreen> {
  Size? _previewBoxSize;
  int? _selectedBoxId;
  Offset? _lastTapImagePoint;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(numberedTitle('05', l10n.demo05Title))),
      body: SafeArea(
        child: CameraStage(
          builder: (context, stage) {
            final imageSize = stage.imageSize;
            final previewBoxSize = _previewBoxSize;
            final transformer = (imageSize != null && previewBoxSize != null)
                ? CoordinateTransformer(
                    imageSize: imageSize,
                    previewSize: previewBoxSize,
                    quarterTurns:
                        quarterTurnsForPreview(imageSize, previewBoxSize),
                    fit: stage.fit,
                    mirror: stage.mirror,
                  )
                : null;

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
                      if (transformer != null)
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTapDown: (details) => _handleTap(
                            details.localPosition,
                            transformer,
                            stage.overlayModel.boxes,
                          ),
                          child: CustomPaint(
                            painter: OverlayPainter(
                              model: stage.overlayModel,
                              transform: transformer.transform,
                              highlightedBoxId: _selectedBoxId,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Text(
                        _lastTapImagePoint == null
                            ? l10n.tapHint
                            : _selectedBoxId == null
                                ? l10n.noBoxAtPoint(
                                    _lastTapImagePoint!.dx.round(),
                                    _lastTapImagePoint!.dy.round(),
                                  )
                                : l10n.hitBoxAtPoint(
                                    stage.overlayModel.boxes
                                        .firstWhere(
                                            (b) => b.id == _selectedBoxId)
                                        .label,
                                    _lastTapImagePoint!.dx.round(),
                                    _lastTapImagePoint!.dy.round(),
                                  ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
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

  void _handleTap(
    Offset widgetPoint,
    CoordinateTransformer transformer,
    List<DetectionBox> boxes,
  ) {
    final imagePoint = transformer.inverseTransform(widgetPoint);
    DetectionBox? hit;
    for (final box in boxes) {
      if (box.rect.contains(imagePoint)) {
        hit = box;
        break;
      }
    }
    setState(() {
      _lastTapImagePoint = imagePoint;
      _selectedBoxId = hit?.id;
    });
  }
}
