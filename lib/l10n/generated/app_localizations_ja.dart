// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Beyond Widgets';

  @override
  String get demo01Title => 'ナイーブなオーバーレイ';

  @override
  String get demo01Subtitle => 'CameraPreview + Stack + 単純なスケーリング —— 崩れる様子を見る';

  @override
  String get demo02Title => '座標変換';

  @override
  String get demo02Subtitle => 'Detect → Normalize → Rotate → Scale → Offset';

  @override
  String get demo03Title => 'カメラパイプラインと同期';

  @override
  String get demo03Subtitle => 'ナイーブなキューイング vs. Latest Frame + Back Pressure';

  @override
  String get demo04Title => '描画パフォーマンス';

  @override
  String get demo04Subtitle =>
      'setState() everything vs. Listenable + CustomPainter';

  @override
  String get demo05Title => 'インタラクティブなオーバーレイ';

  @override
  String get demo05Subtitle => '双方向変換: タップ → 画像座標';

  @override
  String get demo06Title => 'スマートフォン画面の先へ';

  @override
  String get demo06Subtitle => '実OCR → 翻訳 → Even Hub SDK経由でEven G2へ';

  @override
  String get fitCover => 'cover';

  @override
  String get fitContain => 'contain';

  @override
  String get realMlKitOcr => '実ML Kit OCR';

  @override
  String get switchCameraTooltip => 'カメラを切り替え';

  @override
  String get naiveOverlayHint =>
      'scaleX/scaleYのみ —— 回転やBoxFitのクロップ補正なし。端末を回転するか\"contain\"に切り替えると崩れます。';

  @override
  String get correctedTransformTitle => '補正済みTransform Pipeline';

  @override
  String get correctedTransformOnSubtitle =>
      'Detect → Normalize → Rotate → Scale → Offset';

  @override
  String get correctedTransformOffSubtitle => 'ナイーブなscaleX/scaleY（デモ01と同じ）';

  @override
  String get pacingNaiveLabel => 'ナイーブ: 毎フレーム処理';

  @override
  String get pacingLatestFrameLabel => 'Latest Frame + Back Pressure';

  @override
  String simulatedAnalysisTime(int ms) {
    return '解析時間（擬似）: $ms ms（キャプチャは約30fps/33ms固定）';
  }

  @override
  String get statProcessed => '処理済み';

  @override
  String get statQueued => 'キュー';

  @override
  String get statDropped => '破棄';

  @override
  String get statLastLatency => '直近の遅延';

  @override
  String latencyMs(int ms) {
    return '${ms}ms';
  }

  @override
  String get naiveQueueExplanation =>
      'キャプチャしたフレームはすべてキューに入ります。解析がキャプチャより遅い場合、キューは無限に増え続け、遅延も増加し続けます。';

  @override
  String get latestFrameExplanation =>
      '解析中は最新のフレームだけを保持し、その間にキャプチャされたフレームは破棄されるため、遅延は一定の範囲に収まります。';

  @override
  String queueMore(int count) {
    return '他$count件';
  }

  @override
  String get renderNaiveLabel => 'Naive: setState() everything';

  @override
  String get renderBetterLabel => 'Listenable + CustomPainter';

  @override
  String get statHeavyTreeBuilds => '重いツリーの再構築回数';

  @override
  String get statAvgFrameBuild => '平均フレーム構築時間';

  @override
  String avgFrameBuildValue(String ms) {
    return '$ms ms';
  }

  @override
  String get tapHint => 'ボックスをタップしてスクリーン座標→画像座標に変換します。';

  @override
  String noBoxAtPoint(int x, int y) {
    return '画像座標 ($x, $y) にボックスはありません';
  }

  @override
  String hitBoxAtPoint(String label, int x, int y) {
    return '画像座標 ($x, $y) で「$label」にヒット';
  }

  @override
  String get noCameraAvailable => 'この端末では利用可能なカメラがありません。';

  @override
  String get bridgeLabel => 'ブリッジ';

  @override
  String bridgeListening(int port) {
    return 'ws://127.0.0.1:$port';
  }

  @override
  String get bridgeStopped => '停止中';

  @override
  String get evenHubClientsLabel => 'Even Hub 接続数';

  @override
  String get recognizedLabel => '認識結果（OCR）';

  @override
  String get sentToG2Label => 'G2へ送信';

  @override
  String get noValuePlaceholder => '–';
}
