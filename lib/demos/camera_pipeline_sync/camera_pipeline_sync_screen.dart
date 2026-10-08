import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/frame_pacing/latest_frame_gate.dart';
import '../../core/frame_pacing/naive_queue_gate.dart';
import '../../home/demo_entry.dart';
import '../../l10n/generated/app_localizations.dart';

enum _PacingStrategy { naiveQueue, latestFrame }

class _CapturedFrame {
  const _CapturedFrame({required this.id, required this.capturedAtMs});
  final int id;
  final int capturedAtMs;
}

/// 03 — Camera Pipeline & Sync: frames are "captured" on a fixed 30fps
/// timer while "analysis" takes a configurable, adjustable amount of time.
/// When analysis is slower than capture, naive queueing backs up without
/// bound; the latest-frame + back-pressure strategy instead drops stale
/// frames and keeps latency bounded.
///
/// No camera or model here on purpose — the queue-growth-vs-back-pressure
/// behavior is the point, and a fixed simulated delay makes it reproducible
/// on stage regardless of device performance.
class CameraPipelineSyncScreen extends StatefulWidget {
  const CameraPipelineSyncScreen({super.key});

  @override
  State<CameraPipelineSyncScreen> createState() =>
      _CameraPipelineSyncScreenState();
}

class _CameraPipelineSyncScreenState extends State<CameraPipelineSyncScreen> {
  static const _captureInterval = Duration(milliseconds: 33);

  final _stopwatch = Stopwatch()..start();
  Timer? _captureTimer;
  int _frameId = 0;
  double _analysisDelayMs = 120;
  _PacingStrategy _strategy = _PacingStrategy.naiveQueue;
  int? _lastLatencyMs;

  late final NaiveQueueGate<_CapturedFrame> _naiveGate =
      NaiveQueueGate(_process);
  late final LatestFrameGate<_CapturedFrame> _latestGate =
      LatestFrameGate(_process);

  @override
  void initState() {
    super.initState();
    _captureTimer = Timer.periodic(_captureInterval, (_) => _capture());
  }

  @override
  void dispose() {
    _captureTimer?.cancel();
    super.dispose();
  }

  void _capture() {
    final frame =
        _CapturedFrame(id: _frameId++, capturedAtMs: _stopwatch.elapsedMilliseconds);
    if (_strategy == _PacingStrategy.naiveQueue) {
      _naiveGate.push(frame);
    } else {
      _latestGate.push(frame);
    }
    setState(() {});
  }

  Future<void> _process(_CapturedFrame frame) async {
    await Future.delayed(Duration(milliseconds: _analysisDelayMs.round()));
    if (!mounted) return;
    setState(() {
      _lastLatencyMs = _stopwatch.elapsedMilliseconds - frame.capturedAtMs;
    });
  }

  void _setStrategy(_PacingStrategy strategy) {
    setState(() {
      _strategy = strategy;
      _naiveGate.reset();
      _latestGate.reset();
      _lastLatencyMs = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isNaive = _strategy == _PacingStrategy.naiveQueue;
    final queueLength = isNaive ? _naiveGate.queueLength : 0;
    final droppedCount = isNaive ? 0 : _latestGate.droppedCount;
    final processedCount =
        isNaive ? _naiveGate.processedCount : _latestGate.processedCount;

    return Scaffold(
      appBar: AppBar(title: Text(numberedTitle('03', l10n.demo03Title))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<_PacingStrategy>(
              segments: [
                ButtonSegment(
                  value: _PacingStrategy.naiveQueue,
                  label: Text(l10n.pacingNaiveLabel),
                ),
                ButtonSegment(
                  value: _PacingStrategy.latestFrame,
                  label: Text(l10n.pacingLatestFrameLabel),
                ),
              ],
              selected: {_strategy},
              onSelectionChanged: (s) => _setStrategy(s.first),
            ),
            const SizedBox(height: 16),
            Text(l10n.simulatedAnalysisTime(_analysisDelayMs.round())),
            Slider(
              value: _analysisDelayMs,
              min: 0,
              max: 400,
              onChanged: (value) => setState(() => _analysisDelayMs = value),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _Stat(label: l10n.statProcessed, value: '$processedCount'),
                _Stat(
                  label: isNaive ? l10n.statQueued : l10n.statDropped,
                  value: isNaive ? '$queueLength' : '$droppedCount',
                ),
                _Stat(
                  label: l10n.statLastLatency,
                  value: _lastLatencyMs == null
                      ? l10n.noValuePlaceholder
                      : l10n.latencyMs(_lastLatencyMs!),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              isNaive
                  ? l10n.naiveQueueExplanation
                  : l10n.latestFrameExplanation,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: _QueueVisualization(
                  count: isNaive ? queueLength : (droppedCount > 0 ? 1 : 0),
                ),
              ),
            ),
          ],
        ),
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

class _QueueVisualization extends StatelessWidget {
  const _QueueVisualization({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    const maxShown = 40;
    final shown = count.clamp(0, maxShown);
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (var i = 0; i < shown; i++)
          Container(
            width: 14,
            height: 14,
            color: Colors.deepOrange.withValues(alpha: 0.8),
          ),
        if (count > maxShown)
          Text(AppLocalizations.of(context)!.queueMore(count - maxShown)),
      ],
    );
  }
}
