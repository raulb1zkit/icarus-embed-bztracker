import 'package:icarus/services/web_downloader_stub.dart'
    if (dart.library.html) 'package:icarus/services/web_downloader_web.dart'
    as impl;

void triggerBlobDownload(List<int> bytes, String filename, String mimeType) =>
    impl.triggerBlobDownload(bytes, filename, mimeType);
