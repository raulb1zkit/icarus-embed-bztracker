import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:icarus/widgets/web_file_drop_target_io.dart'
    if (dart.library.html) 'package:icarus/widgets/web_file_drop_target_web.dart'
    as impl;

class DroppedImageFile {
  DroppedImageFile({required this.name, required this.bytes, required this.mime});

  final String name;
  final Uint8List bytes;
  final String mime;
}

/// Listens for drag/drop file events on web while this widget is mounted and
/// surfaces the first image file via [onDropFile]. On non-web platforms it is
/// a passthrough that just renders [child].
class WebFileDropTarget extends StatefulWidget {
  const WebFileDropTarget({
    super.key,
    required this.child,
    required this.onDropFile,
    this.onDragChanged,
  });

  final Widget child;
  final Future<void> Function(DroppedImageFile file) onDropFile;
  final ValueChanged<bool>? onDragChanged;

  @override
  State<WebFileDropTarget> createState() => _WebFileDropTargetState();
}

class _WebFileDropTargetState extends State<WebFileDropTarget> {
  Object? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = impl.attachWebFileDrop(
      onDropFile: widget.onDropFile,
      onDragChanged: widget.onDragChanged,
    );
  }

  @override
  void dispose() {
    impl.detachWebFileDrop(_subscription);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
