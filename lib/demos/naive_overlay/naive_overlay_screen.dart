import 'package:flutter/material.dart';

import '../../core/camera/camera_stage.dart';
import '../../core/camera/camera_stage_controls.dart';
import '../../core/camera/fitted_camera_preview.dart';
import '../../core/overlay/overlay_painter.dart';
import '../../core/transform/naive_scale_transform.dart';
import '../../home/demo_entry.dart';
import '../../l10n/generated/app_localizations.dart';

/// 01 — Simple Prototype: `CameraPreview` + `Stack` + naive scaling
/// (`scaleX = previewW / imageW`, `scaleY = previewH / imageH`), with no
/// rotation or BoxFit-crop compensation at all.
///
/// This is the "it looked simple" implementation from slides 7–16 — rotate
/// the device or switch BoxFit to `contain` and watch the box drift away
/// from the label it's meant to be on.
class NaiveOverlayScreen extends StatefulWidget {
  const NaiveOverlayScreen({super.key});

  @override
  State<NaiveOverlayScreen> createState() => _NaiveOverlayScreenState();
}

class _NaiveOverlayScreenState extends State<NaiveOverlayScreen> {
  Size? _previewBoxSize;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(numberedTitle('01', l10n.demo01Title))),
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
                            transform: (rect) => naiveScaleTransform(
                              rect,
                              imageSize,
                              previewBoxSize,
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
                        l10n.naiveOverlayHint,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
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
}
