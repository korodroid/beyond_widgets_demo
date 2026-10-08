/// Only ever processes the most recently pushed item. If a new item arrives
/// while one is already being processed, it replaces whatever was pending
/// (which is dropped, incrementing [droppedCount]) instead of queueing — the
/// "latest frame" back-pressure pattern from the camera pipeline & sync
/// demo. Bounds queue growth at the cost of skipping stale frames.
class LatestFrameGate<T> {
  LatestFrameGate(this._process);

  final Future<void> Function(T item) _process;
  bool _isProcessing = false;
  T? _pending;

  int processedCount = 0;
  int droppedCount = 0;

  void push(T item) {
    if (_isProcessing) {
      if (_pending != null) droppedCount++;
      _pending = item;
      return;
    }
    _run(item);
  }

  Future<void> _run(T item) async {
    _isProcessing = true;
    await _process(item);
    processedCount++;
    _isProcessing = false;

    final next = _pending;
    _pending = null;
    if (next != null) {
      _run(next);
    }
  }

  void reset() {
    _pending = null;
    processedCount = 0;
    droppedCount = 0;
  }
}
