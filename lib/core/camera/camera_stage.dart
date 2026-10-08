import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import 'camera_stage_controller.dart';

/// Sets up a [CameraStageController], initializes it, keeps it disposed
/// correctly, and rebuilds [builder] whenever it changes (camera ready,
/// switched camera, fit/detection-mode toggled).
class CameraStage extends StatefulWidget {
  const CameraStage({super.key, required this.builder});

  final Widget Function(BuildContext context, CameraStageController stage)
      builder;

  @override
  State<CameraStage> createState() => _CameraStageState();
}

class _CameraStageState extends State<CameraStage> {
  late final CameraStageController stage = CameraStageController();

  @override
  void initState() {
    super.initState();
    stage.init();
  }

  @override
  void dispose() {
    stage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: stage,
      builder: (context, _) {
        if (stage.noCameraAvailable || stage.error != null) {
          final message = stage.noCameraAvailable
              ? AppLocalizations.of(context)!.noCameraAvailable
              : stage.error!;
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }
        if (stage.isInitializing || stage.controller == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return widget.builder(context, stage);
      },
    );
  }
}
