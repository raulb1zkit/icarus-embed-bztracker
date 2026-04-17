import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';
import 'package:icarus/const/app_navigator.dart';
import 'package:icarus/const/app_provider_container.dart';
import 'package:icarus/const/embed_mode.dart';
import 'package:icarus/embed/embed_request_router_web.dart' as router;
import 'package:icarus/providers/strategy_provider.dart';
import 'package:icarus/strategy_view.dart';

void registerIcarusEmbedBridge() {
  if (!icarusEmbedMode) return;

  html.window.onMessage.listen((event) {
    final map = _decodeMessage(event.data);
    if (map == null) return;

    final type = map['type'];
    if (type is! String) return;

    if (type.endsWith('_RESULT') && map['requestId'] is String) {
      router.handleIncomingEmbedResult(map);
      return;
    }

    switch (type) {
      case 'ICARUS_LOAD':
        _handleLoadMessage(map['payload']);
      case 'ICARUS_EMBED_CONFIG':
        _handleEmbedConfig(map);
    }
  });

  SchedulerBinding.instance.addPostFrameCallback((_) {
    html.window.parent?.postMessage(
      jsonEncode({'type': 'ICARUS_READY'}),
      '*',
    );
  });
}

Map<String, dynamic>? _decodeMessage(dynamic data) {
  if (data is String) {
    try {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {
      return null;
    }
    return null;
  }
  if (data is Map) return Map<String, dynamic>.from(data);
  return null;
}

void _handleEmbedConfig(Map<String, dynamic> map) {
  final features = map['features'];
  if (features is Map) {
    embedFeatureFlags = EmbedFeatureFlags.fromJson(
      Map<String, dynamic>.from(features),
    );
  }
}

void _handleLoadMessage(dynamic payload) {
  String? jsonStr;
  if (payload is String) {
    jsonStr = payload;
  } else if (payload != null) {
    jsonStr = jsonEncode(payload);
  }
  if (jsonStr == null) return;
  _handleLoad(jsonStr);
}

Future<void> _handleLoad(String jsonStr) async {
  final notifier = appProviderContainer.read(strategyProvider.notifier);
  try {
    final id = await notifier.importFromEmbedJsonString(jsonStr);
    await notifier.loadFromHive(id);
    final ctx = appNavigatorKey.currentContext;
    if (ctx != null && ctx.mounted) {
      Navigator.of(ctx).push(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 200),
          reverseTransitionDuration: const Duration(milliseconds: 200),
          pageBuilder: (context, animation, secondaryAnimation) =>
              const StrategyView(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.9, end: 1.0)
                    .chain(CurveTween(curve: Curves.easeOut))
                    .animate(animation),
                child: child,
              ),
            );
          },
        ),
      );
    }
  } catch (e) {
    html.window.parent?.postMessage(
      jsonEncode({
        'type': 'ICARUS_ERROR',
        'message': e.toString(),
      }),
      '*',
    );
  }
}
