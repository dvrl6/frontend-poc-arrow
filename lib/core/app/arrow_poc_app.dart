import 'package:flutter/material.dart';
import 'package:frontend_poc_arrow/core/localization/l10n/app_localizations.dart';

import '../routing/app_routes.dart';
import '../theme/app_theme.dart';
import 'app_settings_controller.dart';
import 'app_settings_scope.dart';

class ArrowPocApp extends StatefulWidget {
  const ArrowPocApp({this.appSettings, super.key});

  final AppSettingsController? appSettings;

  @override
  State<ArrowPocApp> createState() => _ArrowPocAppState();
}

class _ArrowPocAppState extends State<ArrowPocApp> {
  late final AppSettingsController _appSettings =
      widget.appSettings ?? AppSettingsController();
  late final bool _ownsController = widget.appSettings == null;

  @override
  void dispose() {
    if (_ownsController) {
      _appSettings.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppSettingsScope(
      controller: _appSettings,
      child: AnimatedBuilder(
        animation: _appSettings,
        builder: (context, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
            theme: AppTheme.dark(),
            locale: _appSettings.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            initialRoute: AppRoutes.home,
            onGenerateRoute: AppRoutes.onGenerateRoute,
          );
        },
      ),
    );
  }
}