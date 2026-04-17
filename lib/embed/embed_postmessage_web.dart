import 'dart:convert';
import 'dart:html' as html;

import 'package:icarus/const/embed_mode.dart';

void postEmbedSavePayload(String json) {
  if (!icarusEmbedMode) return;
  try {
    html.window.parent?.postMessage(
      jsonEncode({
        'type': 'ICARUS_SAVE',
        'payload': jsonDecode(json),
      }),
      '*',
    );
  } catch (_) {
    // Ignore postMessage failures (e.g. no parent).
  }
}

void postOpenExternalLink(String url) {
  if (!icarusEmbedMode) return;
  try {
    html.window.parent?.postMessage(
      jsonEncode({
        'type': 'ICARUS_OPEN_EXTERNAL',
        'url': url,
      }),
      '*',
    );
  } catch (_) {}
}

void postStrategyNameChanged(String name) {
  if (!icarusEmbedMode) return;
  try {
    html.window.parent?.postMessage(
      jsonEncode({
        'type': 'ICARUS_NAME_CHANGED',
        'name': name,
      }),
      '*',
    );
  } catch (_) {}
}
