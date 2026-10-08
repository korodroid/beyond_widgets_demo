import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../core/bridge/even_glasses_bridge_server.dart';
import '../../core/camera/fitted_camera_preview.dart';
import '../../core/detection/detection_box.dart';
import '../../core/detection/detection_source.dart';
import '../../core/detection/mlkit_detection_source.dart';
import '../../core/overlay/overlay_model.dart';
import '../../core/overlay/overlay_painter.dart';
import '../../core/transform/coordinate_transformer.dart';
import '../../core/transform/preview_orientation_heuristic.dart';
import '../../home/demo_entry.dart';
import '../../l10n/generated/app_localizations.dart';
import 'mock_translation_dictionary.dart';

/// 06 — Beyond the Phone Screen: real on-device OCR recognizes text from
/// the camera, a tiny dictionary "translates" it, and the result is
/// broadcast over a local WebSocket to the Even Hub mini-app
/// (`beyond_widgets_evenhub/`) running inside the Even App's WebView on
/// this same device — which renders it on the G2 display.
class BeyondScreenScreen extends StatefulWidget {
  const BeyondScreenScreen({super.key});

  @override
  State<BeyondScreenScreen> createState() => _BeyondScreenScreenState();
}

class _BeyondScreenScreenState extends State<BeyondScreenScreen> {
  final EvenGlassesBridgeServer _bridge = EvenGlassesBridgeServer();
  final OverlayModel _overlayModel = OverlayModel();

  CameraController? _controller;
  DetectionSource? _source;
  StreamSubscription<DetectionFrame>? _sub;
  Timer? _statsTimer;

  Size? _previewBoxSize;
  String? _lastRecognizedText;
  String? _lastSentText;
  bool _isInitializing = true;
  bool _noCameraAvailable = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _statsTimer =
        Timer.periodic(const Duration(milliseconds: 500), (_) => setState(() {}));
    _init();
  }

  Future<void> _init() async {
    try {
      await _bridge.start();

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _noCameraAvailable = true);
        return;
      }
      final controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await controller.initialize();
      _controller = controller;

      final source = MlkitDetectionSource(cameraController: controller);
      _source = source;
      _sub = source.frames.listen(_onFrame);
      await source.start();
    } catch (e) {
      _error = '$e';
    } finally {
      setState(() => _isInitializing = false);
    }
  }

  void _onFrame(DetectionFrame frame) {
    if (frame.boxes.isEmpty) return;

    final translatedBoxes = [
      for (final box in frame.boxes)
        DetectionBox(
          id: box.id,
          rect: box.rect,
          label: translateForDemo(box.label),
        ),
    ];
    _overlayModel.update(translatedBoxes);

    final recognized = frame.boxes.first.label;
    final translated = translatedBoxes.first.label;
    if (translated != _lastSentText) {
      _bridge.sendText(translated);
    }
    if (recognized != _lastRecognizedText || translated != _lastSentText) {
      setState(() {
        _lastRecognizedText = recognized;
        _lastSentText = translated;
      });
    }
  }

  @override
  void dispose() {
    _statsTimer?.cancel();
    _sub?.cancel();
    _source?.stop();
    _controller?.dispose();
    _overlayModel.dispose();
    _bridge.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = _controller;

    return Scaffold(
      appBar: AppBar(title: Text(numberedTitle('06', l10n.demo06Title))),
      body: SafeArea(
        child: (_noCameraAvailable || _error != null)
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                      _noCameraAvailable
                          ? l10n.noCameraAvailable
                          : _error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center),
                ),
              )
            : (_isInitializing || controller == null)
                ? const Center(child: CircularProgressIndicator())
                : _buildReady(controller, l10n),
      ),
    );
  }

  Widget _buildReady(CameraController controller, AppLocalizations l10n) {
    final previewBoxSize = _previewBoxSize;
    final imageSize = controller.value.previewSize;
    final transformer = (previewBoxSize != null && imageSize != null)
        ? CoordinateTransformer(
            imageSize: imageSize,
            previewSize: previewBoxSize,
            quarterTurns: quarterTurnsForPreview(imageSize, previewBoxSize),
            fit: BoxFit.cover,
          )
        : null;

    return Column(
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              FittedCameraPreview(
                controller: controller,
                fit: BoxFit.cover,
                onLayout: (size) {
                  if (_previewBoxSize != size) {
                    setState(() => _previewBoxSize = size);
                  }
                },
              ),
              if (transformer != null)
                CustomPaint(
                  painter: OverlayPainter(
                    model: _overlayModel,
                    transform: transformer.transform,
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _statusRow(
                l10n.bridgeLabel,
                _bridge.isRunning
                    ? l10n.bridgeListening(_bridge.port)
                    : l10n.bridgeStopped,
              ),
              _statusRow(
                l10n.evenHubClientsLabel,
                '${_bridge.connectedClientCount}',
              ),
              _statusRow(
                l10n.recognizedLabel,
                _lastRecognizedText ?? l10n.noValuePlaceholder,
              ),
              _statusRow(
                l10n.sentToG2Label,
                _lastSentText ?? l10n.noValuePlaceholder,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
