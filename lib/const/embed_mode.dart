import 'package:flutter/foundation.dart' show kIsWeb;

/// `true` when the Flutter web app is loaded with `?embed=1` (e.g. inside BzTracker iframe).
bool get icarusEmbedMode {
  if (!kIsWeb) return false;
  try {
    return Uri.base.queryParameters['embed'] == '1';
  } catch (_) {
    return false;
  }
}
