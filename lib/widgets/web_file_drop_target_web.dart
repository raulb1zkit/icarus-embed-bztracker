import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import 'package:icarus/widgets/web_file_drop_target.dart' show DroppedImageFile;

const Set<String> _supportedMimes = {
  'image/png',
  'image/jpeg',
  'image/jpg',
  'image/webp',
  'image/gif',
  'image/bmp',
};

class _DropSubscription {
  _DropSubscription(this.dragOver, this.dragEnter, this.dragLeave, this.drop);

  final StreamSubscription<html.MouseEvent> dragOver;
  final StreamSubscription<html.MouseEvent> dragEnter;
  final StreamSubscription<html.MouseEvent> dragLeave;
  final StreamSubscription<html.MouseEvent> drop;

  void cancel() {
    dragOver.cancel();
    dragEnter.cancel();
    dragLeave.cancel();
    drop.cancel();
  }
}

Object? attachWebFileDrop({
  required Future<void> Function(DroppedImageFile file) onDropFile,
  ValueChanged<bool>? onDragChanged,
}) {
  int dragDepth = 0;

  void setDragging(bool value) {
    if (onDragChanged != null) onDragChanged(value);
  }

  final dragOver = html.document.body!.onDragOver.listen((event) {
    event.preventDefault();
  });
  final dragEnter = html.document.body!.onDragEnter.listen((event) {
    event.preventDefault();
    dragDepth += 1;
    if (dragDepth == 1) setDragging(true);
  });
  final dragLeave = html.document.body!.onDragLeave.listen((event) {
    event.preventDefault();
    dragDepth = (dragDepth - 1).clamp(0, 1 << 30);
    if (dragDepth == 0) setDragging(false);
  });
  final drop = html.document.body!.onDrop.listen((event) async {
    event.preventDefault();
    dragDepth = 0;
    setDragging(false);
    final files = event.dataTransfer.files;
    if (files == null || files.isEmpty) return;
    for (final file in files) {
      final mime = file.type.toLowerCase();
      if (!_supportedMimes.contains(mime)) continue;
      final bytes = await _readFile(file);
      if (bytes == null || bytes.isEmpty) continue;
      await onDropFile(DroppedImageFile(
        name: file.name,
        bytes: bytes,
        mime: mime,
      ));
      break;
    }
  });

  return _DropSubscription(dragOver, dragEnter, dragLeave, drop);
}

void detachWebFileDrop(Object? subscription) {
  if (subscription is _DropSubscription) subscription.cancel();
}

Future<Uint8List?> _readFile(html.File file) async {
  final completer = Completer<Uint8List?>();
  final reader = html.FileReader();
  reader.onLoadEnd.first.then((_) {
    final result = reader.result;
    if (result is Uint8List) {
      completer.complete(result);
    } else if (result is ByteBuffer) {
      completer.complete(Uint8List.view(result));
    } else {
      completer.complete(null);
    }
  });
  reader.onError.first.then((_) => completer.complete(null));
  reader.readAsArrayBuffer(file);
  return completer.future;
}
