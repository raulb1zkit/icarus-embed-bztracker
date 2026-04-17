// Stub: no-op on non-web platforms.
//
// The real implementation lives in `embed_request_router_web.dart`.
import 'dart:async';
import 'dart:typed_data';

class EmbedBridgeError implements Exception {
  EmbedBridgeError(this.message);
  final String message;

  @override
  String toString() => 'EmbedBridgeError: $message';
}

Future<Map<String, dynamic>> sendEmbedRequest(
  String type, {
  Map<String, dynamic> payload = const {},
  Duration timeout = const Duration(seconds: 30),
}) async {
  throw UnsupportedError('Embed request router is only available on web.');
}

Future<String> uploadImageThroughBridge({
  required Uint8List bytes,
  required String mime,
  required String fileName,
}) async {
  throw UnsupportedError('Image upload bridge is only available on web.');
}

void handleIncomingEmbedResult(Map<String, dynamic> message) {}
