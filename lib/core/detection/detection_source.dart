import 'detection_box.dart';

/// A source of [DetectionFrame]s — either a mock generator or a real
/// camera + ML Kit pipeline. Demos depend on this abstraction so they can
/// swap "mock" and "real" detection without changing their UI code.
abstract class DetectionSource {
  Stream<DetectionFrame> get frames;

  Future<void> start();

  Future<void> stop();
}
