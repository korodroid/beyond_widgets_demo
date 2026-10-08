import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import 'camera_stage_controller.dart';

/// Shared controls row for the camera demos: BoxFit toggle, camera switch,
/// mock-vs-real-ML-Kit toggle. Kept separate from each demo's own controls
/// (rotation readout, latency slider, etc).
class CameraStageControls extends StatelessWidget {
  const CameraStageControls({super.key, required this.stage});

  final CameraStageController stage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SegmentedButton<BoxFit>(
          segments: [
            ButtonSegment(value: BoxFit.cover, label: Text(l10n.fitCover)),
            ButtonSegment(value: BoxFit.contain, label: Text(l10n.fitContain)),
          ],
          selected: {stage.fit},
          onSelectionChanged: (selection) => stage.setFit(selection.first),
        ),
        if (stage.hasMultipleCameras)
          IconButton(
            tooltip: l10n.switchCameraTooltip,
            icon: const Icon(Icons.cameraswitch),
            onPressed: stage.switchCamera,
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.realMlKitOcr),
            Switch(
              value: stage.useMlkit,
              onChanged: stage.setUseMlkit,
            ),
          ],
        ),
      ],
    );
  }
}
