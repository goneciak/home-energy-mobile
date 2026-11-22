import 'dart:async';

import 'package:flutter/services.dart';
import 'package:gi_home/src/core/platform/secure_display.dart';
import 'package:material_ui/material_ui.dart';

/// Shows [child], a secret, only while it is safe (plan §M3.5): screen
/// protection is on while this widget is mounted ([SecureDisplay]), and
/// [child] is replaced by [hidden] while the screen is being recorded (iOS)
/// or the app is not in the foreground, so the app switcher snapshot does
/// not hold it either.
class SecureContent extends StatefulWidget {
  const new({required this.child, required this.hidden, super.key});

  final Widget child;
  final Widget hidden;

  @override
  State<SecureContent> createState() => _SecureContentState();
}

class _SecureContentState extends State<SecureContent> {
  var _captured = false;
  var _foreground = true;
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    SecureDisplay.channel.setMethodCallHandler(_onCall);
    unawaited(SecureDisplay.setSecure(secure: true));
    _lifecycle = AppLifecycleListener(
      onStateChange: (state) {
        final foreground = state == AppLifecycleState.resumed;
        if (foreground != _foreground && mounted) {
          setState(() => _foreground = foreground);
        }
      },
    );
  }

  Future<void> _onCall(MethodCall call) async {
    if (call.method != SecureDisplay.captureChangedMethod) return;
    final captured = switch (call.arguments) {
      {'captured': final bool value} => value,
      _ => false,
    };
    if (mounted && captured != _captured) {
      setState(() => _captured = captured);
    }
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    SecureDisplay.channel.setMethodCallHandler(null);
    unawaited(SecureDisplay.setSecure(secure: false));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _captured || !_foreground ? widget.hidden : widget.child;
}
