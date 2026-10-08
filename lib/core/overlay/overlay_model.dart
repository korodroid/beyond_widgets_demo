import 'package:flutter/foundation.dart';

import '../detection/detection_box.dart';

/// Holds just the current overlay boxes and notifies listeners on change.
///
/// Kept deliberately tiny: the whole point of the rendering-performance demo
/// is that updating *this* object should not require rebuilding the rest of
/// the widget tree — only whoever listens to it (typically a single
/// `CustomPainter`) repaints.
class OverlayModel extends ChangeNotifier {
  List<DetectionBox> _boxes = const [];

  List<DetectionBox> get boxes => _boxes;

  int updateCount = 0;

  void update(List<DetectionBox> boxes) {
    _boxes = boxes;
    updateCount++;
    notifyListeners();
  }
}
