import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../core/detection/detection_box.dart';
import '../../core/detection/mock_detection_source.dart';
import '../../core/overlay/overlay_model.dart';
import '../../core/overlay/overlay_painter.dart';
import '../../home/demo_entry.dart';
import '../../l10n/generated/app_localizations.dart';

enum _RenderMode { naive, better }

/// 04 — Rendering Performance: the same ~60fps stream of detection boxes,
/// rendered two ways.
///
/// Naive: `setState()` on every update rebuilds the whole subtree,
/// including a deliberately heavy "Other UI" sibling — because in naive
/// code that sibling is constructed inline in `build()`, a fresh instance
/// every single frame.
///
/// Better: an `OverlayModel` (`ChangeNotifier`) feeds a `CustomPainter`
/// inside a `RepaintBoundary`; the heavy sibling is a single widget
/// instance built once and never touched again — Flutter skips rebuilding
/// it because it's the same instance, not a new one.
class RenderingPerformanceScreen extends StatefulWidget {
  const RenderingPerformanceScreen({super.key});

  @override
  State<RenderingPerformanceScreen> createState() =>
      _RenderingPerformanceScreenState();
}

class _RenderingPerformanceScreenState
    extends State<RenderingPerformanceScreen> {
  _RenderMode _mode = _RenderMode.better;
  Size? _canvasSize;
  MockDetectionSource? _source;
  StreamSubscription<DetectionFrame>? _sub;

  List<DetectionBox> _naiveBoxes = const [];
  final OverlayModel _overlayModel = OverlayModel();

  int _heavyBuildCount = 0;
  final List<Duration> _recentBuildDurations = [];
  double _avgBuildMs = 0;
  Timer? _statsTimer;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addTimingsCallback(_onFrameTimings);
    _statsTimer =
        Timer.periodic(const Duration(milliseconds: 500), (_) => setState(() {}));
  }

  @override
  void dispose() {
    SchedulerBinding.instance.removeTimingsCallback(_onFrameTimings);
    _statsTimer?.cancel();
    _sub?.cancel();
    _source?.dispose();
    _overlayModel.dispose();
    super.dispose();
  }

  void _onFrameTimings(List<FrameTiming> timings) {
    for (final timing in timings) {
      _recentBuildDurations.add(timing.buildDuration);
      if (_recentBuildDurations.length > 60) {
        _recentBuildDurations.removeAt(0);
      }
    }
    if (_recentBuildDurations.isNotEmpty) {
      final totalMicros = _recentBuildDurations
          .fold<int>(0, (sum, d) => sum + d.inMicroseconds);
      _avgBuildMs = totalMicros / _recentBuildDurations.length / 1000;
    }
  }

  void _ensureSource(Size canvasSize) {
    if (_canvasSize == canvasSize && _source != null) return;
    _canvasSize = canvasSize;
    _sub?.cancel();
    _source?.dispose();
    final source = MockDetectionSource(
      imageSize: canvasSize,
      captureInterval: const Duration(milliseconds: 16),
    );
    _source = source;
    _sub = source.frames.listen(_onFrame);
    source.start();
  }

  void _onFrame(DetectionFrame frame) {
    if (_mode == _RenderMode.naive) {
      setState(() => _naiveBoxes = frame.boxes);
    } else {
      _overlayModel.update(frame.boxes);
    }
  }

  void _setMode(_RenderMode mode) {
    setState(() {
      _mode = mode;
      _heavyBuildCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(numberedTitle('04', l10n.demo04Title))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: SegmentedButton<_RenderMode>(
              segments: [
                ButtonSegment(
                  value: _RenderMode.naive,
                  label: Text(l10n.renderNaiveLabel),
                ),
                ButtonSegment(
                  value: _RenderMode.better,
                  label: Text(l10n.renderBetterLabel),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: (s) => _setMode(s.first),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final canvasSize = constraints.biggest;
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _ensureSource(canvasSize));
                return Stack(
                  fit: StackFit.expand,
                  children: _mode == _RenderMode.naive
                      ? [
                          // Inline: a brand-new instance every rebuild.
                          _HeavyDummyUi(onBuild: () => _heavyBuildCount++),
                          _NaiveBoxesLayer(boxes: _naiveBoxes),
                        ]
                      : [
                          _hoistedHeavyTree,
                          RepaintBoundary(
                            child: CustomPaint(
                              painter: OverlayPainter(
                                model: _overlayModel,
                                transform: (rect) => rect,
                              ),
                            ),
                          ),
                        ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _Stat(
                  label: l10n.statHeavyTreeBuilds,
                  value: '$_heavyBuildCount',
                ),
                _Stat(
                  label: l10n.statAvgFrameBuild,
                  value: l10n
                      .avgFrameBuildValue(_avgBuildMs.toStringAsFixed(2)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  late final Widget _hoistedHeavyTree =
      _HeavyDummyUi(onBuild: () => _heavyBuildCount++);
}

class _NaiveBoxesLayer extends StatelessWidget {
  const _NaiveBoxesLayer({required this.boxes});
  final List<DetectionBox> boxes;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        for (final box in boxes)
          Positioned(
            left: box.rect.left,
            top: box.rect.top,
            width: box.rect.width,
            height: box.rect.height,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF00E5A0), width: 2),
              ),
              alignment: Alignment.topLeft,
              child: Text(box.label,
                  style: const TextStyle(
                      color: Colors.black, backgroundColor: Color(0xFF00E5A0))),
            ),
          ),
      ],
    );
  }
}

/// Stands in for "Other UI" — expensive enough that rebuilding it 60
/// times a second is visibly costly, cheap enough to still hit ~60fps if
/// it's *not* being rebuilt every frame.
class _HeavyDummyUi extends StatelessWidget {
  const _HeavyDummyUi({required this.onBuild});
  final VoidCallback onBuild;

  @override
  Widget build(BuildContext context) {
    onBuild();
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
      itemCount: 320,
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.all(1),
        color: Colors.blueGrey.withValues(alpha: 0.1 + (index % 10) / 12),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineSmall),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
