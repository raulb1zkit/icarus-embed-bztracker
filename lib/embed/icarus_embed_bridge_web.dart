import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';
import 'package:icarus/const/app_navigator.dart';
import 'package:icarus/const/app_provider_container.dart';
import 'package:icarus/const/embed_mode.dart';
import 'package:icarus/providers/strategy_provider.dart';
import 'package:icarus/strategy_view.dart';

void registerIcarusEmbedBridge() {
  if (!icarusEmbedMode) return;

  html.window.onMessage.listen((event) {
    final data = event.data;
    Map<String, dynamic>? map;
    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) {
          map = decoded;
        }
      } catch (_) {}
    } else if (data is Map) {
      map = Map<String, dynamic>.from(data);
    }
    if (map == null) return;
    if (map['type'] != 'ICARUS_LOAD') return;
    final payload = map['payload'];
    String jsonStr;
    if (payload is String) {
      jsonStr = payload;
    } else if (payload != null) {
      jsonStr = jsonEncode(payload);
    } else {
      return;
    }
    _handleLoad(jsonStr);
  });

  SchedulerBinding.instance.addPostFrameCallback((_) {
    html.window.parent?.postMessage(
      jsonEncode({'type': 'ICARUS_READY'}),
      '*',
    );
  });
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
