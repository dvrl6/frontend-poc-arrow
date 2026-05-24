import 'package:flutter/material.dart';
import 'package:frontend_poc_arrow/core/localization/l10n/app_localizations.dart';

import '../../../core/routing/app_routes.dart';

class LevelSelectionPlaceholderScreen extends StatelessWidget {
  const LevelSelectionPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(localizations.levels)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                localizations.levelSelectionPlaceholder,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.of(context).pushNamed(AppRoutes.game),
                child: Text(localizations.openGame),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
