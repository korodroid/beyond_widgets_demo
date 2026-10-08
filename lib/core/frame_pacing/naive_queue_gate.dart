import 'dart:collection';

/// Processes every incoming item strictly in order, queueing whatever
/// arrives while a previous item is still being processed. If processing is
/// slower than the arrival rate, [queueLength] grows without bound — this
/// is the "naive" strategy from the camera pipeline & sync demo.
class NaiveQueueGate<T> {
  NaiveQueueGate(this._process);

  final Future<void> Function(T item) _process;
  final Queue<T> _queue = Queue<T>();
  bool _isDraining = false;

  int processedCount = 0;

  int get queueLength => _queue.length;

  void push(T item) {
    _queue.add(item);
    _drain();
  }

  Future<void> _drain() async {
    if (_isDraining) return;
    _isDraining = true;
    while (_queue.isNotEmpty) {
      final item = _queue.removeFirst();
      await _process(item);
      processedCount++;
    }
    _isDraining = false;
  }

  void reset() {
    _queue.clear();
    processedCount = 0;
  }
}
