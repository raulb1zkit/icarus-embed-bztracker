import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:icarus/services/clipboard_service.dart' show ClipboardService;
import 'package:pasteboard/pasteboard.dart';

Future<(Uint8List? bytes, String? name)> trySelectImageFromClipboard() async {
  Uint8List? selectedBytes;
  String? selectedName;

  try {
    final clipBoardImages = await Pasteboard.image;
    final clipBoardFiles = await Pasteboard.files();

    if (clipBoardImages != null) {
      selectedBytes = clipBoardImages;
      selectedName = 'Clipboard File';
      return (selectedBytes, selectedName);
    } else if (clipBoardFiles.isNotEmpty) {
      final file = clipBoardFiles.first;
      if (!ClipboardService.isSupportedImageClipboardFile(file)) {
        return (null, null);
      }
      final bytes = await XFile(file).readAsBytes();
      selectedBytes = bytes;
      selectedName = 'Clipboard File';
      return (selectedBytes, selectedName);
    } else {
      return (null, null);
    }
  } catch (_) {
    return (null, null);
  }
}
