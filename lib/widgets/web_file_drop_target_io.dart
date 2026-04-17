import 'package:flutter/foundation.dart';

import 'package:icarus/widgets/web_file_drop_target.dart' show DroppedImageFile;

Object? attachWebFileDrop({
  required Future<void> Function(DroppedImageFile file) onDropFile,
  ValueChanged<bool>? onDragChanged,
}) {
  return null;
}

void detachWebFileDrop(Object? subscription) {}
