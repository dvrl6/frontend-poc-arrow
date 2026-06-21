import 'package:flutter/widgets.dart';

import 'app_settings_controller.dart';

/// Exposes the [AppSettingsController] to the widget subtree below
/// [MaterialApp] so any screen can read or change app-level settings.
class AppSettingsScope extends InheritedWidget {
  const AppSettingsScope({
    required this.controller,
    required super.child,
    super.key,
  });

  final AppSettingsController controller;

  static AppSettingsController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AppSettingsScope>()
        ?.controller;
  }

  @override
  bool updateShouldNotify(AppSettingsScope oldWidget) =>
      controller != oldWidget.controller;
}