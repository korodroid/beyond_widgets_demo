import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// A tiny local WebSocket server that stands in for the "Companion Bridge"
/// between this Flutter app and the Even Hub mini-app running inside the
/// Even App's WebView on the same device (see `beyond_widgets_evenhub/`).
///
/// The Flutter app owns the camera + on-device OCR; whenever it produces a
/// short result, it broadcasts it here. The Even Hub mini-app connects as a
/// WebSocket client on `ws://127.0.0.1:<port>` and renders whatever text it
/// receives on the G2 display via `bridge.textContainerUpgrade(...)`.
class EvenGlassesBridgeServer {
  EvenGlassesBridgeServer({this.port = 8790});

  final int port;

  HttpServer? _server;
  final Set<WebSocketChannel> _clients = {};
  String? lastSentText;

  bool get isRunning => _server != null;

  int get connectedClientCount => _clients.length;

  Future<void> start() async {
    if (_server != null) return;
    final handler = webSocketHandler((webSocket, protocol) {
      _clients.add(webSocket);
      webSocket.stream.listen(
        (_) {},
        onDone: () => _clients.remove(webSocket),
        onError: (_) => _clients.remove(webSocket),
      );
    });
    _server = await shelf_io.serve(handler, InternetAddress.loopbackIPv4, port);
  }

  Future<void> stop() async {
    for (final client in _clients) {
      await client.sink.close();
    }
    _clients.clear();
    await _server?.close(force: true);
    _server = null;
  }

  void sendText(String text) {
    lastSentText = text;
    final payload = jsonEncode({'type': 'text', 'text': text});
    for (final client in _clients) {
      client.sink.add(payload);
    }
  }
}
