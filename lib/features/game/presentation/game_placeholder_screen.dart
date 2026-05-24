import 'package:flutter/material.dart';
import 'package:frontend_poc_arrow/core/localization/l10n/app_localizations.dart';

import 'dotted_board_placeholder.dart';

class GamePlaceholderScreen extends StatelessWidget {
  const GamePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(localizations.gamePlaceholder)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              localizations.gamePlaceholder,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            const DottedBoardPlaceholder(),
            const SizedBox(height: 16),
            Text(
              'Visual placeholder only. Game engine arrives in a later phase.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
