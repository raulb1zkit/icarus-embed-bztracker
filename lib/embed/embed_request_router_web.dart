import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:uuid/uuid.dart';

import 'package:icarus/const/embed_mode.dart';

class EmbedBridgeError implements Exception {
  EmbedBridgeError(this.message);
  final String message;

  @override
  String toString() => 'EmbedBridgeError: $message';
}

final Map<String, Completer<Map<String, dynamic>>> _pending =
    <String, Completer<Map<String, dynamic>>>{};

const _uuid = Uuid();

Future<Map<String, dynamic>> sendEmbedRequest(
  String type, {
  Map<String, dynamic> payload = const {},
  Duration timeout = const Duration(seconds: 30),
}) {
  final requestId = _uuid.v4();
  final completer = Completer<Map<String, dynamic>>();
  _pending[requestId] = completer;

  final message = <String, dynamic>{
    ...payload,
    'type': type,
    'requestId': requestId,
  };

  try {
    html.window.parent?.postMessage(jsonEncode(message), '*');
  } catch (error) {
    _pending.remove(requestId);
    completer.completeError(
      EmbedBridgeError('Failed to postMessage: $error'),
    );
    return completer.future;
  }

  Timer(timeout, () {
    final pending = _pending.remove(requestId);
    if (pending != null && !pending.isCompleted) {
      pending.completeError(
        TimeoutException('Embed request "$type" timed out', timeout),
      );
    }
  });

  return completer.future;
}

Future<String> uploadImageThroughBridge({
  required Uint8List bytes,
  required String mime,
  required String fileName,
}) async {
  if (!icarusEmbedMode) {
    throw EmbedBridgeError('Upload bridge requires embed mode');
  }

  final response = await sendEmbedRequest(
    'ICARUS_UPLOAD_IMAGE',
    payload: {
      'bytes': base64Encode(bytes),
      'mime': mime,
      'fileName': fileName,
    },
    timeout: const Duration(seconds: 60),
  );

  final url = response['url'];
  if (url is! String || url.isEmpty) {
    throw EmbedBridgeError(
      'Upload response missing url (got: ${response.toString()})',
    );
  }
  return url;
}

void handleIncomingEmbedResult(Map<String, dynamic> message) {
  final requestId = message['requestId'];
  if (requestId is! String) return;
  final completer = _pending.remove(requestId);
  if (completer == null || completer.isCompleted) return;
  final error = message['error'];
  if (error is String && error.isNotEmpty) {
    completer.completeError(EmbedBridgeError(error));
    return;
  }
  completer.complete(message);
}
