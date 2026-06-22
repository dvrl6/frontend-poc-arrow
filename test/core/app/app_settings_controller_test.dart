import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_poc_arrow/core/app/app_settings_controller.dart';

void main() {
  test('should_follow_system_locale_when_no_initial_locale', () {
    final controller = AppSettingsController();
    expect(controller.locale, isNull);
  });

  test('should_update_locale_when_set_locale_called', () {
    final controller = AppSettingsController();
    var notified = 0;
    controller.addListener(() => notified++);

    controller.setLocale(const Locale('es'));

    expect(controller.locale, const Locale('es'));
    expect(notified, 1);
  });

  test('should_not_notify_when_locale_unchanged', () {
    final controller = AppSettingsController(initialLocale: const Locale('en'));
    var notified = 0;
    controller.addListener(() => notified++);

    controller.setLocale(const Locale('en'));

    expect(notified, 0);
  });
}