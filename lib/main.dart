import 'package:flutter/widgets.dart';

import 'core/app/app_bootstrap.dart';

// Re-export so existing imports of `ArrowPocApp` via main keep working
// (e.g. widget_test.dart) after moving the widget into core/app.
export 'core/app/arrow_poc_app.dart' show ArrowPocApp;

Future<void> main() async {
  runApp(await bootstrap());
}