import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// Displays [controller]'s preview using [fit] the way `Image`/`BoxFit`
/// would — `BoxFit.contain` letterboxes (Flutter's default `AspectRatio`
/// behavior), `BoxFit.cover` scales the letterboxed preview up until it
/// fills the available box, cropping the overflow.
///
/// Reports the box size it was laid out into via [onLayout], so callers can
/// feed it into a [CoordinateTransformer] alongside the camera's own
/// `previewSize`.
class FittedCameraPreview extends StatelessWidget {
  const FittedCameraPreview({
    super.key,
    required this.controller,
    required this.fit,
    this.onLayout,
  });

  final CameraController controller;
  final BoxFit fit;
  final void Function(Size boxSize)? onLayout;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxSize = constraints.biggest;
        if (onLayout != null) {
          WidgetsBinding.instance
              .addPostFrameCallback((_) => onLayout!(boxSize));
        }

        final cameraAspectRatio = controller.value.aspectRatio;
        final preview = Center(
          child: AspectRatio(
            aspectRatio: cameraAspectRatio,
            child: CameraPreview(controller),
          ),
        );

        if (fit == BoxFit.contain || !boxSize.isFinite) {
          return preview;
        }

        final boxAspectRatio = boxSize.width / boxSize.height;
        final scale = boxAspectRatio > cameraAspectRatio
            ? boxAspectRatio / cameraAspectRatio
            : cameraAspectRatio / boxAspectRatio;
        return ClipRect(
          child: Transform.scale(scale: scale, child: preview),
        );
      },
    );
  }
}
