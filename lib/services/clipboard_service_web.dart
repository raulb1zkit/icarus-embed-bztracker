import 'dart:async';
import 'dart:html' as html;
import 'dart:js_interop';
import 'dart:typed_data';

const Set<String> _supportedMimes = {
  'image/png',
  'image/jpeg',
  'image/jpg',
  'image/webp',
  'image/gif',
  'image/bmp',
};

@JS('navigator')
external _Navigator get _navigator;

extension type _Navigator._(JSObject _) implements JSObject {
  external _Clipboard? get clipboard;
}

extension type _Clipboard._(JSObject _) implements JSObject {
  external JSPromise<JSArray<_ClipboardItem>> read();
}

extension type _ClipboardItem._(JSObject _) implements JSObject {
  external JSArray<JSString> get types;
  external JSPromise<_Blob> getType(String type);
}

extension type _Blob._(JSObject _) implements JSObject {
  external JSPromise<JSArrayBuffer> arrayBuffer();
}

Future<(Uint8List? bytes, String? name)> trySelectImageFromClipboard() async {
  try {
    final clipboard = _navigator.clipboard;
    if (clipboard == null) return (null, null);

    final items = (await clipboard.read().toDart).toDart;
    for (final item in items) {
      final types = item.types.toDart;
      for (final type in types) {
        final mime = type.toDart;
        if (!_supportedMimes.contains(mime)) continue;
        final blob = await item.getType(mime).toDart;
        final buffer = await blob.arrayBuffer().toDart;
        final bytes = buffer.toDart.asUint8List();
        if (bytes.isNotEmpty) {
          return (bytes, 'Clipboard image');
        }
      }
    }
    return (null, null);
  } catch (_) {
    return (null, null);
  }
}

// Keep the html import alive for tooling that might prune it.
// ignore: unused_element
void _keepHtmlImport() {
  html.window.toString();
}
