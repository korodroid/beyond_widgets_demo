// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Beyond Widgets';

  @override
  String get demo01Title => 'Naive Overlay';

  @override
  String get demo01Subtitle =>
      'CameraPreview + Stack + naive scaling — watch it break';

  @override
  String get demo02Title => 'Coordinate Transform';

  @override
  String get demo02Subtitle => 'Detect → Normalize → Rotate → Scale → Offset';

  @override
  String get demo03Title => 'Camera Pipeline & Sync';

  @override
  String get demo03Subtitle => 'Naive queueing vs. latest-frame back pressure';

  @override
  String get demo04Title => 'Rendering Performance';

  @override
  String get demo04Subtitle =>
      'setState() everything vs. Listenable + CustomPainter';

  @override
  String get demo05Title => 'Interactive Overlay';

  @override
  String get demo05Subtitle =>
      'Bidirectional transform: tap → image coordinates';

  @override
  String get demo06Title => 'Beyond the Phone Screen';

  @override
  String get demo06Subtitle =>
      'Real OCR → translation → Even G2 via Even Hub SDK';

  @override
  String get fitCover => 'cover';

  @override
  String get fitContain => 'contain';

  @override
  String get realMlKitOcr => 'Real ML Kit OCR';

  @override
  String get switchCameraTooltip => 'Switch camera';

  @override
  String get naiveOverlayHint =>
      'scaleX/scaleY only — no rotation or BoxFit-crop compensation. Rotate the device or switch to \"contain\" to see it break.';

  @override
  String get correctedTransformTitle => 'Corrected transform pipeline';

  @override
  String get correctedTransformOnSubtitle =>
      'Detect → Normalize → Rotate → Scale → Offset';

  @override
  String get correctedTransformOffSubtitle =>
      'Naive scaleX/scaleY (same as demo 01)';

  @override
  String get pacingNaiveLabel => 'Naive: process every frame';

  @override
  String get pacingLatestFrameLabel => 'Latest frame + back pressure';

  @override
  String simulatedAnalysisTime(int ms) {
    return 'Simulated analysis time: $ms ms (capture is fixed at ~30 fps / 33 ms)';
  }

  @override
  String get statProcessed => 'Processed';

  @override
  String get statQueued => 'Queued';

  @override
  String get statDropped => 'Dropped';

  @override
  String get statLastLatency => 'Last latency';

  @override
  String latencyMs(int ms) {
    return '${ms}ms';
  }

  @override
  String get naiveQueueExplanation =>
      'Every captured frame is queued. If analysis is slower than capture, the queue grows without bound and latency keeps climbing.';

  @override
  String get latestFrameExplanation =>
      'Only the newest frame is kept while one is being analyzed; anything captured in between is dropped, so latency stays bounded.';

  @override
  String queueMore(int count) {
    return '+$count more';
  }

  @override
  String get renderNaiveLabel => 'Naive: setState() everything';

  @override
  String get renderBetterLabel => 'Listenable + CustomPainter';

  @override
  String get statHeavyTreeBuilds => 'Heavy tree builds';

  @override
  String get statAvgFrameBuild => 'Avg frame build';

  @override
  String avgFrameBuildValue(String ms) {
    return '$ms ms';
  }

  @override
  String get tapHint => 'Tap a box to convert screen -> image coordinates.';

  @override
  String noBoxAtPoint(int x, int y) {
    return 'No box at image point ($x, $y)';
  }

  @override
  String hitBoxAtPoint(String label, int x, int y) {
    return 'Hit \"$label\" at image point ($x, $y)';
  }

  @override
  String get noCameraAvailable => 'No camera available on this device.';

  @override
  String get bridgeLabel => 'Bridge';

  @override
  String bridgeListening(int port) {
    return 'ws://127.0.0.1:$port';
  }

  @override
  String get bridgeStopped => 'stopped';

  @override
  String get evenHubClientsLabel => 'Even Hub clients';

  @override
  String get recognizedLabel => 'Recognized (OCR)';

  @override
  String get sentToG2Label => 'Sent to G2';

  @override
  String get noValuePlaceholder => '–';
}
