import 'package:flutter/material.dart';

import '../detection/detection_box.dart';
import 'overlay_model.dart';

/// Paints detection boxes directly via `Canvas`, driven by [OverlayModel] as
/// a repaint `Listenable` — no `setState`, no widget-tree rebuild.
///
/// [transform] maps a box's image-space [Rect] to widget-space. It's a
/// plain function rather than a `CoordinateTransformer` so both the naive
/// (intentionally wrong) and correct demos can share this painter.
class OverlayPainter extends CustomPainter {
  OverlayPainter({
    required this.model,
    required this.transform,
    this.highlightedBoxId,
  }) : super(repaint: model);

  final OverlayModel model;
  final Rect Function(Rect imageRect) transform;
  final int? highlightedBoxId;

  static const _boxPaintColor = Color(0xFF00E5A0);
  static const _highlightPaintColor = Color(0xFFFFC400);

  @override
  void paint(Canvas canvas, Size size) {
    final boxPaint = Paint()
      ..color = _boxPaintColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final highlightPaint = Paint()
      ..color = _highlightPaintColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    for (final DetectionBox box in model.boxes) {
      final rect = transform(box.rect);
      final isHighlighted = box.id == highlightedBoxId;
      canvas.drawRect(rect, isHighlighted ? highlightPaint : boxPaint);
      _drawLabel(canvas, rect, box.label, isHighlighted);
    }
  }

  void _drawLabel(Canvas canvas, Rect rect, String label, bool isHighlighted) {
    final painter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: Colors.black,
          fontSize: 12,
          backgroundColor:
              isHighlighted ? _highlightPaintColor : _boxPaintColor,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, Offset(rect.left, rect.top - painter.height));
  }

  @override
  bool shouldRepaint(covariant OverlayPainter oldDelegate) {
    return oldDelegate.model != model ||
        oldDelegate.transform != transform ||
        oldDelegate.highlightedBoxId != highlightedBoxId;
  }
}
