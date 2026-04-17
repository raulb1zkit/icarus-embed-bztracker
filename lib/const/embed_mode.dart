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

/// Feature flags pushed by the parent shell via `ICARUS_EMBED_CONFIG`.
///
/// All defaults assume embed mode is active and BzTracker is the source of
/// truth. Flags can be toggled per-deployment to enable/disable still-rough
/// features without rebuilding the embed.
class EmbedFeatureFlags {
  EmbedFeatureFlags({
    this.imageUploads = true,
    this.lineups = true,
    this.youtubeView = true,
    this.exportFile = true,
    this.exportLibrary = false,
    this.screenshot = true,
  });

  factory EmbedFeatureFlags.fromJson(Map<String, dynamic> json) {
    bool flag(String key, bool fallback) {
      final value = json[key];
      return value is bool ? value : fallback;
    }

    return EmbedFeatureFlags(
      imageUploads: flag('imageUploads', true),
      lineups: flag('lineups', true),
      youtubeView: flag('youtubeView', true),
      exportFile: flag('exportFile', true),
      exportLibrary: flag('exportLibrary', false),
      screenshot: flag('screenshot', true),
    );
  }

  final bool imageUploads;
  final bool lineups;
  final bool youtubeView;
  final bool exportFile;
  final bool exportLibrary;
  final bool screenshot;
}

/// Mutable global flags. Updated when the parent sends `ICARUS_EMBED_CONFIG`.
EmbedFeatureFlags embedFeatureFlags = EmbedFeatureFlags();
